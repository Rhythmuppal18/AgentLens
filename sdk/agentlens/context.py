import contextvars
from contextvars import ContextVar
from datetime import datetime, timezone
import functools
import logging
import traceback
from typing import TYPE_CHECKING, Any, Callable, Optional
import uuid

from agentlens.models import EventData, SpanData, TraceData, format_iso
from agentlens.privacy import (
    compute_canonical_input_hash,
    redact_sensitive_data,
)
from agentlens.worker import TelemetryItem

if TYPE_CHECKING:
    from agentlens.client import AgentLens

logger = logging.getLogger("agentlens.context")

# Context variables for automatic hierarchical span propagation across coroutines.
# Note: For newly created OS threads (e.g. threading.Thread), context must be propagated
# explicitly using `propagate_context(func)` or `contextvars.copy_context().run(func)`.
_active_trace: ContextVar[Optional["TraceContext"]] = ContextVar("agentlens_active_trace", default=None)
_active_span: ContextVar[Optional["SpanContext"]] = ContextVar("agentlens_active_span", default=None)


def copy_context() -> contextvars.Context:
    """Returns a snapshot of the current contextvars Context for propagating to new threads."""
    return contextvars.copy_context()


def propagate_context(func: Callable) -> Callable:
    """Wraps a callable so it executes within a copy of the current contextvars Context in new threads."""
    ctx = contextvars.copy_context()

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        return ctx.run(func, *args, **kwargs)

    return wrapper


class SpanContext:
    """Context manager and container for a discrete unit of execution within a trace."""

    def __init__(
        self,
        trace: "TraceContext",
        name: str,
        span_type: str = "AGENT_STEP",
        parent_span_id: Optional[str] = None,
        input_payload: Optional[Any] = None,
        attributes: Optional[dict[str, Any]] = None,
        capture_payloads: Optional[bool] = None,
    ):
        self.trace = trace
        self.id = f"spn_{uuid.uuid4().hex[:16]}"
        self.name = name
        self.span_type = span_type

        # Inherit active parent span if not explicitly passed
        current_parent = _active_span.get()
        if parent_span_id is not None:
            self.parent_span_id = parent_span_id
        elif current_parent is not None:
            self.parent_span_id = current_parent.id
        else:
            self.parent_span_id = None

        self.status = "RUNNING"
        self.start_time: Optional[datetime] = None
        self.end_time: Optional[datetime] = None
        self.duration_ms: Optional[int] = None

        self.attributes: dict[str, Any] = dict(attributes or {})
        self.error_message: Optional[str] = None
        self.error_type: Optional[str] = None
        self.error_stack: Optional[str] = None

        # Check payload capture policy
        should_capture = (
            capture_payloads
            if capture_payloads is not None
            else self.trace.client.capture_payloads
        )

        # Compute canonical input hash for tool call repetition matching
        self.input_hash = compute_canonical_input_hash(input_payload)

        if should_capture and input_payload is not None:
            self.input_payload = redact_sensitive_data(input_payload)
        else:
            self.input_payload = None

        self.output_payload: Optional[Any] = None
        self._token = None

    def __enter__(self) -> "SpanContext":
        try:
            self.start_time = datetime.now(timezone.utc)
            self._token = _active_span.set(self)
        except Exception as exc:
            logger.debug("SpanContext __enter__ error (suppressed): %s", exc)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        try:
            self.end_time = datetime.now(timezone.utc)
            if self.start_time:
                self.duration_ms = max(
                    0, int((self.end_time - self.start_time).total_seconds() * 1000)
                )

            if exc_type is not None:
                self.status = "ERROR"
                self.error_message = str(exc_val)
                self.error_type = getattr(exc_type, "__name__", "Exception")
                self.error_stack = "".join(
                    traceback.format_exception(exc_type, exc_val, exc_tb)
                )
            elif self.status == "RUNNING":
                self.status = "OK"

            # Reset active context
            if self._token is not None:
                _active_span.reset(self._token)

            # Dispatch span telemetry
            span_data = SpanData(
                id=self.id,
                trace_id=self.trace.id,
                parent_span_id=self.parent_span_id,
                name=self.name,
                span_type=self.span_type,
                status=self.status,
                start_time=format_iso(self.start_time),
                end_time=format_iso(self.end_time),
                duration_ms=self.duration_ms,
                input_payload=self.input_payload,
                input_hash=self.input_hash,
                output_payload=self.output_payload,
                error_message=self.error_message,
                error_type=self.error_type,
                error_stack=self.error_stack,
                attributes=self.attributes,
            )

            self.trace.client.enqueue_item(
                TelemetryItem(
                    item_type="span",
                    data=span_data.to_dict(),
                    project_id=self.trace.client.project_id,
                    environment=self.trace.client.environment,
                    trace_id=self.trace.id,
                )
            )
        except Exception as exc:
            logger.debug("SpanContext __exit__ error (suppressed): %s", exc)

    def set_output(self, payload: Any) -> "SpanContext":
        """Records output payload with redaction and truncation."""
        try:
            should_capture = self.trace.client.capture_payloads
            if should_capture or payload is not None:
                self.output_payload = redact_sensitive_data(payload)
        except Exception as exc:
            logger.debug("set_output error (suppressed): %s", exc)
        return self

    def set_attributes(self, attributes: dict[str, Any]) -> "SpanContext":
        """Adds or updates span attributes."""
        try:
            self.attributes.update(attributes)
        except Exception as exc:
            logger.debug("set_attributes error (suppressed): %s", exc)
        return self

    def set_tokens(
        self,
        prompt_tokens: Optional[int] = None,
        completion_tokens: Optional[int] = None,
        total_tokens: Optional[int] = None,
        cost: Optional[float] = None,
    ) -> "SpanContext":
        """Records token counts and cost for LLM spans."""
        try:
            if prompt_tokens is not None:
                self.attributes["prompt_tokens"] = prompt_tokens
            if completion_tokens is not None:
                self.attributes["completion_tokens"] = completion_tokens
            if total_tokens is not None:
                self.attributes["total_tokens"] = total_tokens
            elif prompt_tokens is not None and completion_tokens is not None:
                self.attributes["total_tokens"] = prompt_tokens + completion_tokens
            if cost is not None:
                self.attributes["estimated_cost_usd"] = cost
        except Exception as exc:
            logger.debug("set_tokens error (suppressed): %s", exc)
        return self

    def event(self, name: str, data: Optional[dict[str, Any]] = None) -> None:
        """Records a point-in-time milestone event within this span."""
        try:
            event_id = f"evt_{uuid.uuid4().hex[:16]}"
            evt_data = EventData(
                id=event_id,
                span_id=self.id,
                trace_id=self.trace.id,
                name=name,
                timestamp=format_iso(datetime.now(timezone.utc)),
                data=data or {},
            )
            self.trace.client.enqueue_item(
                TelemetryItem(
                    item_type="event",
                    data=evt_data.to_dict(),
                    project_id=self.trace.client.project_id,
                    environment=self.trace.client.environment,
                    trace_id=self.trace.id,
                )
            )
        except Exception as exc:
            logger.debug("Span event error (suppressed): %s", exc)

    def span(
        self,
        name: str,
        span_type: str = "AGENT_STEP",
        input_payload: Optional[Any] = None,
        attributes: Optional[dict[str, Any]] = None,
        capture_payloads: Optional[bool] = None,
    ) -> "SpanContext":
        """Creates a child span nested under this span."""
        return SpanContext(
            trace=self.trace,
            name=name,
            span_type=span_type,
            parent_span_id=self.id,
            input_payload=input_payload,
            attributes=attributes,
            capture_payloads=capture_payloads,
        )


class TraceContext:
    """Context manager representing an entire agent execution trace session."""

    def __init__(
        self,
        client: "AgentLens",
        agent_name: str,
        session_id: Optional[str] = None,
        user_identifier: Optional[str] = None,
        metadata: Optional[dict[str, Any]] = None,
    ):
        self.client = client
        self.id = f"trc_{uuid.uuid4().hex[:16]}"
        self.agent_name = agent_name
        self.session_id = session_id
        self.user_identifier = user_identifier
        self.metadata = dict(metadata or {})

        self.status = "RUNNING"
        self.start_time: Optional[datetime] = None
        self.end_time: Optional[datetime] = None
        self.duration_ms: Optional[int] = None
        self.root_span_name: Optional[str] = None

        self.total_tokens: Optional[int] = None
        self.prompt_tokens: Optional[int] = None
        self.completion_tokens: Optional[int] = None
        self.estimated_cost_usd: Optional[float] = None

        self._token = None

    def __enter__(self) -> "TraceContext":
        try:
            self.start_time = datetime.now(timezone.utc)
            self._token = _active_trace.set(self)
        except Exception as exc:
            logger.debug("TraceContext __enter__ error (suppressed): %s", exc)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        try:
            self.end_time = datetime.now(timezone.utc)
            if self.start_time:
                self.duration_ms = max(
                    0, int((self.end_time - self.start_time).total_seconds() * 1000)
                )

            if exc_type is not None:
                self.status = "ERROR"
            elif self.status == "RUNNING":
                self.status = "SUCCESS"

            if self._token is not None:
                _active_trace.reset(self._token)

            trace_data = TraceData(
                id=self.id,
                agent_name=self.agent_name,
                session_id=self.session_id,
                user_identifier=self.user_identifier,
                status=self.status,
                start_time=format_iso(self.start_time),
                end_time=format_iso(self.end_time),
                duration_ms=self.duration_ms,
                total_tokens=self.total_tokens,
                prompt_tokens=self.prompt_tokens,
                completion_tokens=self.completion_tokens,
                estimated_cost_usd=self.estimated_cost_usd,
                root_span_name=self.root_span_name,
                metadata=self.metadata,
            )

            self.client.enqueue_item(
                TelemetryItem(
                    item_type="trace",
                    data=trace_data.to_dict(),
                    project_id=self.client.project_id,
                    environment=self.client.environment,
                    trace_id=self.id,
                )
            )
        except Exception as exc:
            logger.debug("TraceContext __exit__ error (suppressed): %s", exc)

    def span(
        self,
        name: str,
        span_type: str = "AGENT_STEP",
        parent_span_id: Optional[str] = None,
        input_payload: Optional[Any] = None,
        attributes: Optional[dict[str, Any]] = None,
        capture_payloads: Optional[bool] = None,
    ) -> SpanContext:
        """Creates a span within this trace."""
        if self.root_span_name is None:
            self.root_span_name = name
        return SpanContext(
            trace=self,
            name=name,
            span_type=span_type,
            parent_span_id=parent_span_id,
            input_payload=input_payload,
            attributes=attributes,
            capture_payloads=capture_payloads,
        )

    def event(self, name: str, data: Optional[dict[str, Any]] = None) -> None:
        """Records a point-in-time milestone event associated with this trace."""
        active_sp = _active_span.get()
        span_id = active_sp.id if active_sp else "root"
        try:
            event_id = f"evt_{uuid.uuid4().hex[:16]}"
            evt_data = EventData(
                id=event_id,
                span_id=span_id,
                trace_id=self.id,
                name=name,
                timestamp=format_iso(datetime.now(timezone.utc)),
                data=data or {},
            )
            self.client.enqueue_item(
                TelemetryItem(
                    item_type="event",
                    data=evt_data.to_dict(),
                    project_id=self.client.project_id,
                    environment=self.client.environment,
                    trace_id=self.id,
                )
            )
        except Exception as exc:
            logger.debug("Trace event error (suppressed): %s", exc)

    def set_tokens(
        self,
        prompt_tokens: Optional[int] = None,
        completion_tokens: Optional[int] = None,
        total_tokens: Optional[int] = None,
        cost: Optional[float] = None,
    ) -> "TraceContext":
        """Records aggregate token counts and estimated cost."""
        if prompt_tokens is not None:
            self.prompt_tokens = prompt_tokens
        if completion_tokens is not None:
            self.completion_tokens = completion_tokens
        if total_tokens is not None:
            self.total_tokens = total_tokens
        elif prompt_tokens is not None and completion_tokens is not None:
            self.total_tokens = prompt_tokens + completion_tokens
        if cost is not None:
            self.estimated_cost_usd = cost
        return self
