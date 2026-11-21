from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel, ConfigDict


class EventResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    span_id: str
    trace_id: str
    name: str
    timestamp: datetime
    data: dict[str, Any]


class SpanDetailResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    trace_id: str
    parent_span_id: Optional[str] = None
    name: str
    span_type: str
    status: str
    start_time: datetime
    end_time: Optional[datetime] = None
    duration_ms: Optional[int] = None
    input_payload: Optional[Any] = None
    input_hash: Optional[str] = None
    output_payload: Optional[Any] = None
    error_message: Optional[str] = None
    error_type: Optional[str] = None
    error_stack: Optional[str] = None
    attributes: dict[str, Any] = {}
    events: list[EventResponse] = []
