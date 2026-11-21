from datetime import datetime
from decimal import Decimal
from typing import Any, Optional
import uuid

from pydantic import BaseModel, ConfigDict, Field


class ProblemDetails(BaseModel):
    """RFC 7807 Problem Details representation."""

    model_config = ConfigDict(extra="allow")

    type: str = Field(default="about:blank", description="URI reference identifying problem type")
    title: str = Field(..., description="Short, human-readable summary of problem")
    status: int = Field(..., description="HTTP status code")
    detail: str = Field(..., description="Human-readable explanation specific to this occurrence")
    instance: Optional[str] = Field(default=None, description="URI reference identifying specific occurrence")


class TracePayload(BaseModel):
    """Execution trace telemetry payload."""

    model_config = ConfigDict(extra="ignore")

    id: str = Field(..., min_length=1, max_length=64, description="Unique trace identifier")
    agent_name: str = Field(..., min_length=1, max_length=128, description="Target agent name/class")
    session_id: Optional[str] = Field(default=None, max_length=128)
    user_identifier: Optional[str] = Field(default=None, max_length=128)
    status: str = Field(default="RUNNING", max_length=32, description="Trace status: RUNNING, SUCCESS, ERROR, PARTIAL")
    start_time: datetime = Field(..., description="Start timestamp in UTC")
    end_time: Optional[datetime] = Field(default=None, description="End timestamp in UTC")
    duration_ms: Optional[int] = Field(default=None, ge=0, description="Duration in milliseconds")
    total_tokens: Optional[int] = Field(default=None, ge=0)
    prompt_tokens: Optional[int] = Field(default=None, ge=0)
    completion_tokens: Optional[int] = Field(default=None, ge=0)
    estimated_cost_usd: Optional[Decimal] = Field(default=None, ge=0)
    root_span_name: Optional[str] = Field(default=None, max_length=255)
    metadata: Optional[dict[str, Any]] = Field(default_factory=dict)


class SpanPayload(BaseModel):
    """Hierarchical unit of execution telemetry."""

    model_config = ConfigDict(extra="ignore")

    id: str = Field(..., min_length=1, max_length=64, description="Unique span identifier")
    trace_id: str = Field(..., min_length=1, max_length=64, description="Parent trace identifier")
    parent_span_id: Optional[str] = Field(default=None, max_length=64, description="Parent span identifier")
    name: str = Field(..., min_length=1, max_length=255, description="Span name")
    span_type: str = Field(default="AGENT_STEP", max_length=32, description="AGENT_STEP, TOOL_CALL, LLM_CALL, CHAIN, ROUTER")
    status: str = Field(default="RUNNING", max_length=32, description="Span status: RUNNING, OK, ERROR")
    start_time: datetime = Field(..., description="Start timestamp in UTC")
    end_time: Optional[datetime] = Field(default=None, description="End timestamp in UTC")
    duration_ms: Optional[int] = Field(default=None, ge=0, description="Duration in milliseconds")
    input_payload: Optional[Any] = Field(default=None, description="JSON-serializable input")
    input_hash: Optional[str] = Field(default=None, max_length=64, description="SHA-256 hash of canonical input")
    output_payload: Optional[Any] = Field(default=None, description="JSON-serializable output")
    error_message: Optional[str] = Field(default=None, description="Error message if failed")
    error_type: Optional[str] = Field(default=None, max_length=128, description="Exception or error type")
    error_stack: Optional[str] = Field(default=None, description="Traceback or stack trace")
    attributes: Optional[dict[str, Any]] = Field(default_factory=dict, description="Metadata and metrics")


class EventPayload(BaseModel):
    """Instantaneous occurrence milestone payload."""

    model_config = ConfigDict(extra="ignore")

    id: str = Field(..., min_length=1, max_length=64, description="Unique event identifier")
    span_id: str = Field(..., min_length=1, max_length=64, description="Associated span identifier")
    trace_id: str = Field(..., min_length=1, max_length=64, description="Associated trace identifier")
    name: str = Field(..., min_length=1, max_length=128, description="Event name")
    timestamp: datetime = Field(..., description="Occurrence timestamp in UTC")
    data: Optional[dict[str, Any]] = Field(default_factory=dict, description="Event payload data")


class IngestRequest(BaseModel):
    """Batch telemetry ingestion request payload."""

    model_config = ConfigDict(extra="forbid")

    project_id: uuid.UUID = Field(..., description="Target project UUID")
    environment: str = Field(..., min_length=1, max_length=32, description="Environment slug: e.g. production, staging, development")
    trace: TracePayload = Field(..., description="Trace execution record")
    spans: list[SpanPayload] = Field(default_factory=list, description="List of execution spans")
    events: list[EventPayload] = Field(default_factory=list, description="List of milestone events")


class IngestResponse(BaseModel):
    """Batch telemetry ingestion response payload."""

    status: str = Field(default="accepted", description="Status confirmation")
    trace_id: str = Field(..., description="Ingested trace ID")
    spans_upserted: int = Field(..., ge=0, description="Number of spans created or updated")
    events_inserted: int = Field(..., ge=0, description="Number of events inserted")
    rules_evaluated: int = Field(default=0, ge=0, description="Number of deterministic rules checked")
    findings_detected: int = Field(default=0, ge=0, description="Number of failure findings detected")
    findings_updated: int = Field(default=0, ge=0, description="Number of existing findings updated")
    ingested_at: datetime = Field(..., description="Timestamp of ingestion completion")


class SpanIngestRequest(BaseModel):
    """Incremental streaming span ingestion request payload."""

    model_config = ConfigDict(extra="forbid")

    trace_id: str = Field(..., min_length=1, max_length=64, description="Target trace ID")
    spans: list[SpanPayload] = Field(..., min_length=1, description="List of streamed execution spans")


class SpanIngestResponse(BaseModel):
    """Incremental streaming span ingestion response payload."""

    status: str = Field(default="accepted", description="Status confirmation")
    spans_processed: int = Field(..., ge=0, description="Number of spans upserted")
