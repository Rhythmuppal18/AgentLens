from datetime import datetime
from typing import Any, Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict

from app.schemas.span import EventResponse


class SpanTreeNode(BaseModel):
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
    children: list["SpanTreeNode"] = []


class TraceListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    project_id: UUID
    environment: str
    agent_name: str
    session_id: Optional[str] = None
    user_identifier: Optional[str] = None
    root_span_name: Optional[str] = None
    status: str
    start_time: datetime
    end_time: Optional[datetime] = None
    duration_ms: Optional[int] = None
    span_count: int = 0
    has_failures: bool = False
    total_tokens: Optional[int] = None
    prompt_tokens: Optional[int] = None
    completion_tokens: Optional[int] = None
    estimated_cost_usd: Optional[float] = None
    created_at: datetime
    metadata: dict[str, Any] = {}


class TraceListResponse(BaseModel):
    total: int
    limit: int
    offset: int
    items: list[TraceListItem]


class TraceDetailResponse(TraceListItem):
    spans: list[SpanTreeNode] = []
    root_span: Optional[SpanTreeNode] = None
