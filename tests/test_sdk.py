import asyncio
import queue
import threading
import time
import unittest

from agentlens import AgentLens, copy_context, propagate_context
from agentlens.context import _active_span, _active_trace
from agentlens.models import SpanData, TraceData
from agentlens.privacy import (
    compute_canonical_input_hash,
    redact_sensitive_data,
)
from agentlens.transport import HttpTransport, TransportError
from agentlens.worker import BackgroundQueueWorker, TelemetryItem


class DummyTransport:
    """Mock transport capturing dispatched payloads."""

    def __init__(self, should_fail: bool = False, fail_code: int = 500):
        self.should_fail = should_fail
        self.fail_code = fail_code
        self.dispatched_batches: list[dict] = []

    def send_batch(self, payload: dict) -> bool:
        if self.should_fail:
            raise TransportError("Simulated failure", status_code=self.fail_code, retryable=(self.fail_code >= 500))
        self.dispatched_batches.append(payload)
        return True


class TestAgentLensSDK(unittest.TestCase):
    """Unit tests for the AgentLens Python SDK."""

    def setUp(self):
        self.client = AgentLens(
            api_key="al_test_key_123",
            project_id="11111111-2222-3333-4444-555555555555",
            environment="test",
            api_url="http://localhost:8000",
            capture_payloads=True,
            disabled=True,  # Disable background worker for direct unit testing
        )

    def test_trace_and_span_hierarchy(self):
        """Verifies automatic parent-child context propagation."""
        with self.client.trace(agent_name="TestAgent", session_id="sess_01") as trace:
            self.assertIsNotNone(_active_trace.get())
            self.assertEqual(trace.agent_name, "TestAgent")
            self.assertEqual(trace.status, "RUNNING")

            with trace.span(name="root_step", span_type="AGENT_STEP") as root_span:
                self.assertIsNotNone(_active_span.get())
                self.assertIsNone(root_span.parent_span_id)
                self.assertEqual(root_span.name, "root_step")

                # Nested child span
                with root_span.span(name="child_tool", span_type="TOOL_CALL") as child_span:
                    self.assertEqual(child_span.parent_span_id, root_span.id)
                    self.assertEqual(child_span.span_type, "TOOL_CALL")

                # Context restored to root_span after child exits
                self.assertEqual(_active_span.get().id, root_span.id)

        # Context cleared after trace exits
        self.assertIsNone(_active_trace.get())
        self.assertIsNone(_active_span.get())
        self.assertEqual(trace.status, "SUCCESS")
        self.assertIsNotNone(trace.duration_ms)

    def test_unhandled_exception_capture(self):
        """Verifies automatic error capture and non-suppression of exceptions."""
        with self.assertRaises(ValueError) as cm:
            with self.client.trace(agent_name="FailingAgent") as trace:
                with trace.span(name="failing_span", span_type="TOOL_CALL") as span:
                    raise ValueError("Simulated tool crash")

        self.assertEqual(str(cm.exception), "Simulated tool crash")
        self.assertEqual(span.status, "ERROR")
        self.assertEqual(span.error_message, "Simulated tool crash")
        self.assertEqual(span.error_type, "ValueError")
        self.assertIn("Simulated tool crash", span.error_stack)
        self.assertEqual(trace.status, "ERROR")

    def test_sensitive_data_redaction(self):
        """Verifies sensitive credential keys are redacted to [REDACTED]."""
        payload = {
            "api_key": "secret_key_value",
            "auth_token": "Bearer 12345",
            "db_password": "my_password",
            "nested": {
                "private_key": "private_data",
                "normal_field": "safe_value",
            },
            "user_id": 42,
        }
        redacted = redact_sensitive_data(payload)
        self.assertEqual(redacted["api_key"], "[REDACTED]")
        self.assertEqual(redacted["auth_token"], "[REDACTED]")
        self.assertEqual(redacted["db_password"], "[REDACTED]")
        self.assertEqual(redacted["nested"]["private_key"], "[REDACTED]")
        self.assertEqual(redacted["nested"]["normal_field"], "safe_value")
        self.assertEqual(redacted["user_id"], 42)

    def test_payload_truncation(self):
        """Verifies payloads larger than 64KB are truncated with preview."""
        large_string = "X" * (70 * 1024)  # 70 KB
        result = redact_sensitive_data(large_string)
        self.assertIsInstance(result, dict)
        self.assertTrue(result["_truncated"])
        self.assertEqual(result["original_bytes"], 70 * 1024)
        self.assertIn("[TRUNCATED]", result["preview"])

    def test_canonical_input_hashing(self):
        """Verifies input_hash is deterministic and insensitive to dictionary key order."""
        dict1 = {"b": 2, "a": 1, "c": [3, 4]}
        dict2 = {"a": 1, "c": [3, 4], "b": 2}
        hash1 = compute_canonical_input_hash(dict1)
        hash2 = compute_canonical_input_hash(dict2)
        self.assertIsNotNone(hash1)
        self.assertEqual(hash1, hash2)

    def test_bounded_queue_overflow_policy(self):
        """Verifies Drop Oldest policy when queue capacity is reached."""
        dummy_transport = DummyTransport()
        worker = BackgroundQueueWorker(
            transport=dummy_transport,  # type: ignore
            max_queue_size=3,
            batch_size=10,
            flush_interval=10.0,  # Don't auto-flush during test
        )
        try:
            # Fill queue to capacity (3 items)
            for i in range(3):
                worker.enqueue(
                    TelemetryItem(
                        item_type="span",
                        data={"id": f"spn_{i}"},
                        project_id="p1",
                        environment="dev",
                        trace_id="t1",
                    )
                )

            self.assertEqual(worker._queue.qsize(), 3)
            self.assertEqual(worker._dropped_count, 0)

            # Enqueue a 4th item: should drop the oldest item (spn_0)
            worker.enqueue(
                TelemetryItem(
                    item_type="span",
                    data={"id": "spn_3"},
                    project_id="p1",
                    environment="dev",
                    trace_id="t1",
                )
            )

            # Queue remains at maxsize=3, dropped counter increments
            self.assertEqual(worker._queue.qsize(), 3)
            self.assertEqual(worker._dropped_count, 1)
        finally:
            worker.shutdown(timeout=0.5)

    def test_fail_safe_guarantee(self):
        """Verifies SDK failures never disrupt host application execution."""
        # Configure client with broken transport
        client = AgentLens(
            api_key="invalid",
            project_id="p1",
            disabled=False,
        )
        # Mock transport to raise catastrophic exception
        client.transport.send_batch = lambda payload: (_ for _ in ()).throw(RuntimeError("Network collapsed"))

        # Agent execution must complete without crashing
        completed = False
        with client.trace(agent_name="ResilientAgent") as trace:
            with trace.span("resilient_span") as span:
                span.set_output({"status": "ok"})
                completed = True

        self.assertTrue(completed)
        client.shutdown(timeout=0.5)

    def test_async_coroutine_propagation(self):
        """Verifies contextvars propagate automatically across async coroutines."""
        async def run_async():
            with self.client.trace(agent_name="AsyncAgent") as trace:
                trace_id = trace.id

                async def child_step(step_name: str):
                    await asyncio.sleep(0.01)
                    with trace.span(name=step_name, span_type="AGENT_STEP") as span:
                        await asyncio.sleep(0.01)
                        return span.trace.id, span.name

                res1, res2 = await asyncio.gather(
                    child_step("async_task_1"),
                    child_step("async_task_2"),
                )
                self.assertEqual(res1[0], trace_id)
                self.assertEqual(res2[0], trace_id)

        asyncio.run(run_async())

    def test_thread_propagation_with_copy_context(self):
        """Verifies explicit context propagation to new threads using propagate_context / copy_context."""
        with self.client.trace(agent_name="ThreadAgent") as trace:
            with trace.span(name="parent_thread_span") as parent_span:
                thread_results = {}

                def worker_in_thread():
                    active_s = _active_span.get()
                    thread_results["active_span_id"] = active_s.id if active_s else None
                    with trace.span(name="child_in_thread") as child_s:
                        thread_results["child_parent_id"] = child_s.parent_span_id
                        thread_results["child_trace_id"] = child_s.trace.id

                # Run worker in new thread with propagate_context
                propagated_worker = self.client.propagate_context(worker_in_thread)
                t = threading.Thread(target=propagated_worker)
                t.start()
                t.join()

                self.assertEqual(thread_results["active_span_id"], parent_span.id)
                self.assertEqual(thread_results["child_parent_id"], parent_span.id)
                self.assertEqual(thread_results["child_trace_id"], trace.id)

    def test_thread_isolation_without_copy_context(self):
        """Verifies unpropagated threads do not implicitly inherit parent context or leak state."""
        with self.client.trace(agent_name="IsolationAgent") as trace:
            with trace.span(name="main_span"):
                thread_results = {}

                def unpropagated_worker():
                    thread_results["active_span"] = _active_span.get()
                    thread_results["active_trace"] = _active_trace.get()

                t = threading.Thread(target=unpropagated_worker)
                t.start()
                t.join()

                # Raw threads without copy_context have None context
                self.assertIsNone(thread_results["active_span"])
                self.assertIsNone(thread_results["active_trace"])

    def test_worker_flush_waits_for_in_flight(self):
        """Verifies worker flush waits for active in-flight HTTP dispatches to complete."""
        class SlowTransport:
            def __init__(self):
                self.batches = []

            def send_batch(self, payload):
                time.sleep(0.1)
                self.batches.append(payload)
                return True

        slow_transport = SlowTransport()
        worker = BackgroundQueueWorker(
            transport=slow_transport,  # type: ignore
            flush_interval=0.01,
        )
        try:
            worker.enqueue(
                TelemetryItem(
                    item_type="span",
                    data={"id": "s_inflight_1"},
                    project_id="p",
                    environment="d",
                    trace_id="t",
                )
            )
            # Give background thread time to start processing
            time.sleep(0.03)

            # Flush must wait for in-flight request to finish
            worker.flush(timeout=2.0)
            self.assertEqual(len(slow_transport.batches), 1)
        finally:
            worker.shutdown(timeout=1.0)

    def test_worker_shutdown_timeout_and_retries_non_blocking(self):
        """Verifies worker shutdown terminates within timeout even if backend is failing with retries."""
        failing_transport = DummyTransport(should_fail=True, fail_code=503)
        worker = BackgroundQueueWorker(
            transport=failing_transport,  # type: ignore
            flush_interval=0.01,
        )
        worker.enqueue(
            TelemetryItem(
                item_type="span",
                data={"id": "s_failing_1"},
                project_id="p",
                environment="d",
                trace_id="t",
            )
        )
        # Calling shutdown with 0.5s timeout must not block for full 6+ seconds of backoff retries
        t0 = time.time()
        worker.shutdown(timeout=0.6)
        elapsed = time.time() - t0

        self.assertLess(elapsed, 1.5)
        self.assertFalse(worker._worker_thread.is_alive())

    def test_concurrent_enqueue_thread_safety(self):
        """Verifies concurrent multi-threaded enqueuing handles load safely without deadlocks."""
        dummy_transport = DummyTransport()
        worker = BackgroundQueueWorker(
            transport=dummy_transport,  # type: ignore
            max_queue_size=1000,
            batch_size=50,
            flush_interval=0.05,
        )
        try:
            def producer(thread_id: int):
                for i in range(20):
                    worker.enqueue(
                        TelemetryItem(
                            item_type="span",
                            data={"id": f"spn_{thread_id}_{i}"},
                            project_id="p",
                            environment="d",
                            trace_id="t",
                        )
                    )

            threads = [threading.Thread(target=producer, args=(i,)) for i in range(5)]
            for t in threads:
                t.start()
            for t in threads:
                t.join()

            worker.flush(timeout=3.0)
            total_spans = sum(len(b.get("spans", [])) for b in dummy_transport.dispatched_batches)
            self.assertEqual(total_spans, 100)
        finally:
            worker.shutdown(timeout=1.0)


if __name__ == "__main__":
    unittest.main()
