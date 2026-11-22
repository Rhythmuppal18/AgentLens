import functools
import logging
import os
from typing import Any, Callable, Optional

from agentlens.context import (
    SpanContext,
    TraceContext,
    _active_span,
    _active_trace,
    copy_context,
    propagate_context,
)
from agentlens.transport import HttpTransport
from agentlens.worker import BackgroundQueueWorker, TelemetryItem

logger = logging.getLogger("agentlens")


class AgentLens:
    """AgentLens Observability and Telemetry Ingestion Client."""

    def __init__(
        self,
        api_key: Optional[str] = None,
        project_id: Optional[str] = None,
        environment: Optional[str] = None,
        api_url: Optional[str] = None,
        capture_payloads: Optional[bool] = None,
        batch_size: int = 50,
        flush_interval: float = 0.5,
        max_queue_size: int = 10000,
        disabled: bool = False,
    ):
        self.api_key = api_key or os.getenv("AGENTLENS_API_KEY", "")
        self.project_id = project_id or os.getenv("AGENTLENS_PROJECT_ID", "")
        self.environment = environment or os.getenv("AGENTLENS_ENVIRONMENT", "development")
        self.api_url = (api_url or os.getenv("AGENTLENS_API_URL", "http://localhost:8000")).rstrip("/")

        env_capture = os.getenv("AGENTLENS_CAPTURE_PAYLOADS", "false").lower() in ("1", "true", "yes")
        self.capture_payloads = capture_payloads if capture_payloads is not None else env_capture
        self.disabled = disabled or os.getenv("AGENTLENS_DISABLED", "false").lower() in ("1", "true", "yes")

        self.transport = HttpTransport(
            api_url=self.api_url,
            api_key=self.api_key,
        )

        if not self.disabled:
            self.worker = BackgroundQueueWorker(
                transport=self.transport,
                max_queue_size=max_queue_size,
                batch_size=batch_size,
                flush_interval=flush_interval,
            )
        else:
            self.worker = None

    def enqueue_item(self, item: TelemetryItem) -> None:
        """Enqueues a telemetry item for background dispatch."""
        if self.disabled or self.worker is None:
            return
        try:
            self.worker.enqueue(item)
        except Exception as exc:
            logger.debug("Failed to enqueue telemetry item (suppressed): %s", exc)

    def trace(
        self,
        agent_name: str,
        session_id: Optional[str] = None,
        user_identifier: Optional[str] = None,
        metadata: Optional[dict[str, Any]] = None,
    ):
        """Context manager or decorator to start a trace."""
        trace_ctx = TraceContext(
            client=self,
            agent_name=agent_name,
            session_id=session_id,
            user_identifier=user_identifier,
            metadata=metadata,
        )
        return trace_ctx

    def span(
        self,
        name: str,
        span_type: str = "AGENT_STEP",
        parent_span_id: Optional[str] = None,
        input_payload: Optional[Any] = None,
        attributes: Optional[dict[str, Any]] = None,
        capture_payloads: Optional[bool] = None,
    ):
        """Context manager to start a span within the active trace."""
        active_tr = _active_trace.get()
        if active_tr is None:
            # Create ad-hoc root trace if called outside trace block
            active_tr = TraceContext(
                client=self,
                agent_name="ImplicitAgent",
            )
            active_tr.__enter__()

        return active_tr.span(
            name=name,
            span_type=span_type,
            parent_span_id=parent_span_id,
            input_payload=input_payload,
            attributes=attributes,
            capture_payloads=capture_payloads,
        )

    def trace_function(
        self,
        agent_name: Optional[str] = None,
        session_id: Optional[str] = None,
    ) -> Callable:
        """Decorator to trace an entire function as an agent execution."""

        def decorator(func: Callable) -> Callable:
            name = agent_name or func.__name__

            @functools.wraps(func)
            def wrapper(*args, **kwargs):
                with self.trace(agent_name=name, session_id=session_id):
                    return func(*args, **kwargs)

            return wrapper

        return decorator

    def span_function(
        self,
        name: Optional[str] = None,
        span_type: str = "AGENT_STEP",
        capture_payloads: Optional[bool] = None,
    ) -> Callable:
        """Decorator to wrap a function execution in a span."""

        def decorator(func: Callable) -> Callable:
            span_name = name or func.__name__

            @functools.wraps(func)
            def wrapper(*args, **kwargs):
                input_data = {"args": args, "kwargs": kwargs} if capture_payloads else None
                with self.span(
                    name=span_name,
                    span_type=span_type,
                    input_payload=input_data,
                    capture_payloads=capture_payloads,
                ) as s:
                    result = func(*args, **kwargs)
                    if capture_payloads:
                        s.set_output(result)
                    return result

            return wrapper

        return decorator

    def propagate_context(self, func: Callable) -> Callable:
        """Wraps a callable so it preserves the current tracing context when executed in a new thread."""
        return propagate_context(func)

    def flush(self, timeout: float = 5.0) -> None:
        """Flushes all queued telemetry to backend."""
        if self.worker:
            self.worker.flush(timeout=timeout)

    def shutdown(self, timeout: float = 5.0) -> None:
        """Shuts down background dispatcher cleanly."""
        if self.worker:
            self.worker.shutdown(timeout=timeout)


# Global singleton client support
_global_client: Optional[AgentLens] = None


def init(
    api_key: Optional[str] = None,
    project_id: Optional[str] = None,
    environment: Optional[str] = None,
    api_url: Optional[str] = None,
    capture_payloads: Optional[bool] = None,
    **kwargs,
) -> AgentLens:
    """Initializes global AgentLens singleton client."""
    global _global_client
    _global_client = AgentLens(
        api_key=api_key,
        project_id=project_id,
        environment=environment,
        api_url=api_url,
        capture_payloads=capture_payloads,
        **kwargs,
    )
    return _global_client


def get_client() -> AgentLens:
    """Retrieves active global AgentLens client or creates default."""
    global _global_client
    if _global_client is None:
        _global_client = AgentLens()
    return _global_client


def trace(*args, **kwargs):
    return get_client().trace(*args, **kwargs)


def span(*args, **kwargs):
    return get_client().span(*args, **kwargs)


def flush(*args, **kwargs):
    return get_client().flush(*args, **kwargs)


def shutdown(*args, **kwargs):
    return get_client().shutdown(*args, **kwargs)
