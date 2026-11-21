from datetime import datetime
from typing import Any, Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict


class EvidenceLinkResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int | str
    finding_id: str
    span_id: Optional[str] = None
    event_id: Optional[str] = None
    role: str
    evidence_hash: str
    created_at: datetime


class FailureFindingListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    finding_fingerprint: str
    rule_version: str
    trace_id: str
    span_id: Optional[str] = None
    span_name: Optional[str] = None
    rule_type: str
    severity: str
    iteration_count: int
    summary: str
    evidence_summary: str
    first_detected_at: datetime
    last_updated_at: datetime


class FailureFindingListResponse(BaseModel):
    total: int
    limit: int
    offset: int
    items: list[FailureFindingListItem]


class FailureFindingDetailResponse(FailureFindingListItem):
    evidence_data: dict[str, Any] = {}
    evidence_links: list[EvidenceLinkResponse] = []
