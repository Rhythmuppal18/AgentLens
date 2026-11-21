import atexit
from dataclasses import dataclass
import logging
import queue
import random
import threading
import time
from typing import Any, Optional

from agentlens.transport import HttpTransport, TransportError

logger = logging.getLogger("agentlens.worker")


@dataclass
class TelemetryItem:
    """Wrapper for items queued for background dispatch."""

    item_type: str  # "trace", "span", "event"
    data: dict[str, Any]
    project_id: str
    environment: str
    trace_id: str


class BackgroundQueueWorker:
    """Thread-safe background worker dispatching telemetry with bounded queue and retry backoff."""

    def __init__(
        self,
        transport: HttpTransport,
        max_queue_size: int = 10000,
        batch_size: int = 50,
        flush_interval: float = 0.5,
    ):
        self.transport = transport
        self.max_queue_size = max_queue_size
        self.batch_size = batch_size
        self.flush_interval = flush_interval

        self._queue: queue.Queue[Optional[TelemetryItem]] = queue.Queue(maxsize=max_queue_size)
        self._running = True
        self._lock = threading.Lock()
        self._dropped_count = 0
        self._in_flight = False

        # Circuit breaker state
        self._consecutive_failures = 0
        self._circuit_open_until = 0.0
        self._last_circuit_log = 0.0

        # Start background worker daemon thread
        self._worker_thread = threading.Thread(
            target=self._worker_loop,
            name="AgentLensBackgroundWorker",
            daemon=True,
        )
        self._worker_thread.start()

        # Register process exit hook
        atexit.register(self.shutdown)

    def enqueue(self, item: TelemetryItem) -> None:
        """Enqueues a telemetry item with Drop Oldest overflow policy."""
        if not self._running:
            return

        try:
            self._queue.put_nowait(item)
        except queue.Full:
            # Drop Oldest Policy
            try:
                self._queue.get_nowait()
                self._queue.task_done()
                with self._lock:
                    self._dropped_count += 1
            except (queue.Empty, ValueError):
                pass

            try:
                self._queue.put_nowait(item)
            except queue.Full:
                with self._lock:
                    self._dropped_count += 1

    def flush(self, timeout: float = 5.0) -> None:
        """Drains pending queue items and in-flight requests up to timeout."""
        start = time.time()
        while (not self._queue.empty() or self._in_flight) and (time.time() - start) < timeout:
            time.sleep(0.02)

    def shutdown(self, timeout: float = 5.0) -> None:
        """Gracefully shuts down worker thread and flushes remaining items up to timeout."""
        with self._lock:
            if not self._running:
                return
            self._running = False

        start = time.time()
        deadline = start + timeout

        # Wake worker thread if it is waiting in queue.get
        try:
            self._queue.put_nowait(None)
        except Exception:
            pass

        # Wait for worker thread to drain queue and terminate cleanly
        remaining = max(0.05, deadline - time.time())
        if self._worker_thread.is_alive():
            self._worker_thread.join(timeout=remaining)

    def _worker_loop(self) -> None:
        """Background thread execution loop."""
        while self._running or not self._queue.empty():
            try:
                # Respect circuit breaker
                now = time.time()
                if now < self._circuit_open_until:
                    if not self._running:
                        # Terminate immediately during shutdown if circuit breaker is open
                        break
                    if now - self._last_circuit_log > 60.0:
                        logger.warning(
                            "AgentLens SDK Circuit Breaker ACTIVE: Dispatches paused due to persistent backend errors."
                        )
                        self._last_circuit_log = now
                    time.sleep(1.0)
                    continue

                items: list[TelemetryItem] = []
                # During shutdown, drain immediately without waiting for flush_interval deadline
                deadline = time.time() + (0.01 if not self._running else self.flush_interval)

                # Collect batch
                while len(items) < self.batch_size and time.time() < deadline:
                    remaining = max(0.005, deadline - time.time())
                    try:
                        item = self._queue.get(timeout=remaining)
                        if item is None:
                            self._queue.task_done()
                            break
                        items.append(item)
                    except queue.Empty:
                        break

                if not items:
                    if not self._running:
                        break
                    continue

                # Group items by (project_id, environment, trace_id)
                batches: dict[tuple[str, str, str], list[TelemetryItem]] = {}
                for it in items:
                    key = (it.project_id, it.environment, it.trace_id)
                    batches.setdefault(key, []).append(it)

                with self._lock:
                    self._in_flight = True
                try:
                    for (proj_id, env, trc_id), batch_items in batches.items():
                        self._dispatch_batch(proj_id, env, trc_id, batch_items)
                finally:
                    with self._lock:
                        self._in_flight = False

                for _ in range(len(items)):
                    self._queue.task_done()

            except Exception as exc:
                logger.debug("Worker loop exception (suppressed): %s", exc)
                time.sleep(0.5)

    def _dispatch_batch(
        self,
        project_id: str,
        environment: str,
        trace_id: str,
        items: list[TelemetryItem],
    ) -> None:
        """Builds and dispatches batch with exponential retry backoff."""
        trace_payload: Optional[dict[str, Any]] = None
        spans: list[dict[str, Any]] = []
        events: list[dict[str, Any]] = []

        for it in items:
            if it.item_type == "trace":
                trace_payload = it.data
            elif it.item_type == "span":
                spans.append(it.data)
            elif it.item_type == "event":
                events.append(it.data)

        # Inject dropped telemetry event marker if overflow occurred
        with self._lock:
            dropped = self._dropped_count
            if dropped > 0:
                events.append(
                    {
                        "id": f"evt_overflow_{int(time.time()*1000)}",
                        "span_id": spans[0]["id"] if spans else "root",
                        "trace_id": trace_id,
                        "name": "telemetry_dropped_overflow",
                        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                        "data": {"dropped_count": dropped},
                    }
                )
                self._dropped_count = 0

        if not trace_payload:
            # Synthesize minimal trace payload if trace item is missing
            trace_payload = {
                "id": trace_id,
                "agent_name": "UnknownAgent",
                "status": "RUNNING",
                "start_time": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            }

        payload = {
            "project_id": project_id,
            "environment": environment,
            "trace": trace_payload,
            "spans": spans,
            "events": events,
        }

        # Exponential backoff retry: up to 4 attempts
        delays = [0.0, 0.5, 1.5, 4.0]
        success = False

        for attempt, base_delay in enumerate(delays, start=1):
            if not self._running and attempt > 1:
                # Do not perform long retries during shutdown to prevent blocking
                break
            if base_delay > 0:
                jitter = random.uniform(0.0, 0.2 * base_delay)
                time.sleep(base_delay + jitter)

            try:
                self.transport.send_batch(payload)
                success = True
                self._consecutive_failures = 0
                break
            except TransportError as err:
                if not err.retryable:
                    logger.debug("Non-retryable batch dropped: %s", err)
                    break
                logger.debug(
                    "Telemetry dispatch attempt %d failed: %s",
                    attempt,
                    err,
                )
            except Exception as exc:
                logger.debug("Telemetry dispatch error: %s", exc)

        if not success:
            self._consecutive_failures += 1
            if self._consecutive_failures >= 3:
                # Open circuit breaker for 60 seconds
                self._circuit_open_until = time.time() + 60.0
                logger.warning(
                    "AgentLens SDK: 3 consecutive dispatch failures. Entering quiet mode for 60 seconds."
                )
