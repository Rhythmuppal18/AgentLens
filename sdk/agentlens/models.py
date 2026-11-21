from dataclasses import asdict, dataclass, field
from datetime import datetime
from typing import Any, Optional


def format_iso(dt: Optional[datetime]) -> Optional[str]:
    """Formats datetime to ISO 8601 UTC string."""
    if dt is None:
        return None
    return dt.isoformat()


@dataclass
class TraceData:
    id: str
    agent_name: str
    session_id: Optional[str] = None
    user_identifier: Optional[str] = None
    status: str = "RUNNING"
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    duration_ms: Optional[int] = None
    total_tokens: Optional[int] = None
    prompt_tokens: Optional[int] = None
    completion_tokens: Optional[int] = None
    estimated_cost_usd: Optional[float] = None
    root_span_name: Optional[str] = None
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return {k: v for k, v in asdict(self).items() if v is not None or k in ("metadata", "status")}


@dataclass
class SpanData:
    id: str
    trace_id: str
    name: str
    parent_span_id: Optional[str] = None
    span_type: str = "AGENT_STEP"
    status: str = "RUNNING"
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    duration_ms: Optional[int] = None
    input_payload: Optional[Any] = None
    input_hash: Optional[str] = None
    output_payload: Optional[Any] = None
    error_message: Optional[str] = None
    error_type: Optional[str] = None
    error_stack: Optional[str] = None
    attributes: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        d = asdict(self)
        return {k: v for k, v in d.items() if v is not None or k in ("attributes", "status")}


@dataclass
class EventData:
    id: str
    span_id: str
    trace_id: str
    name: str
    timestamp: str
    data: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
