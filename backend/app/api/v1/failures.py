from datetime import datetime, timedelta, timezone
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import desc, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.models.environment import Environment
from app.models.finding import FailureFinding, FindingEvidenceLink
from app.models.span import Span
from app.models.trace import Trace
from app.schemas.finding import (
    EvidenceLinkResponse,
    FailureFindingDetailResponse,
    FailureFindingListItem,
    FailureFindingListResponse,
)

router = APIRouter(tags=["Failure Findings"])


def _calculate_time_window(time_range: Optional[str]) -> Optional[datetime]:
    if not time_range:
        return None
    now = datetime.now(timezone.utc)
    tr = time_range.lower()
    if tr == "1h":
        return now - timedelta(hours=1)
    elif tr == "24h":
        return now - timedelta(hours=24)
    elif tr == "7d":
        return now - timedelta(days=7)
    elif tr == "30d":
        return now - timedelta(days=30)
    return None


@router.get("", response_model=FailureFindingListResponse)
async def list_failures(
    project_id: Optional[UUID] = Query(None, description="Filter by Project UUID"),
    environment: Optional[str] = Query(None, description="Filter by environment name"),
    rule_type: Optional[str] = Query(None, description="Filter by rule type"),
    severity: Optional[str] = Query(None, description="Filter by severity (CRITICAL, HIGH, WARNING)"),
    trace_id: Optional[str] = Query(None, description="Filter by Trace ID"),
    time_range: Optional[str] = Query("24h", description="Time window: 1h, 24h, 7d, 30d, all"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    offset: int = Query(0, ge=0, description="Pagination offset"),
    session: AsyncSession = Depends(get_db_session),
) -> FailureFindingListResponse:
    """Retrieves paginated, filterable failure findings with evidence links and diagnostic summaries."""
    query = (
        select(FailureFinding, Span.name.label("span_name"))
        .outerjoin(Span, FailureFinding.span_id == Span.id)
        .join(Trace, FailureFinding.trace_id == Trace.id)
    )

    if project_id is not None:
        query = query.where(Trace.project_id == project_id)

    if environment:
        query = query.join(Environment, Trace.environment_id == Environment.id).where(
            or_(
                Environment.name.ilike(environment),
                Environment.slug.ilike(environment),
            )
        )

    if rule_type:
        query = query.where(FailureFinding.rule_type == rule_type.upper())

    if severity:
        query = query.where(FailureFinding.severity == severity.upper())

    if trace_id:
        query = query.where(FailureFinding.trace_id == trace_id)

    since = _calculate_time_window(time_range)
    if since is not None:
        query = query.where(FailureFinding.first_detected_at >= since)

    count_query = select(func.count()).select_from(query.subquery())
    total_count = (await session.execute(count_query)).scalar_one()

    paginated_query = query.order_by(desc(FailureFinding.first_detected_at)).limit(limit).offset(offset)
    results = await session.execute(paginated_query)

    items = []
    for finding, span_name in results.all():
        items.append(
            FailureFindingListItem(
                id=finding.id,
                finding_fingerprint=finding.finding_fingerprint,
                rule_version=finding.rule_version,
                trace_id=finding.trace_id,
                span_id=finding.span_id,
                span_name=span_name,
                rule_type=finding.rule_type,
                severity=finding.severity,
                iteration_count=finding.iteration_count,
                summary=finding.summary,
                evidence_summary=finding.evidence_summary,
                first_detected_at=finding.first_detected_at,
                last_updated_at=finding.last_updated_at,
            )
        )

    return FailureFindingListResponse(
        total=total_count,
        limit=limit,
        offset=offset,
        items=items,
    )


@router.get("/{finding_id}", response_model=FailureFindingDetailResponse)
async def get_failure_detail(
    finding_id: str,
    session: AsyncSession = Depends(get_db_session),
) -> FailureFindingDetailResponse:
    """Retrieves single failure finding with full structured evidence data and evidence links."""
    query = (
        select(FailureFinding, Span.name.label("span_name"))
        .outerjoin(Span, FailureFinding.span_id == Span.id)
        .where(FailureFinding.id == finding_id)
    )
    result = (await session.execute(query)).first()
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Failure finding '{finding_id}' not found",
        )
    finding, span_name = result

    # Query evidence links
    links_res = await session.execute(
        select(FindingEvidenceLink)
        .where(FindingEvidenceLink.finding_id == finding_id)
        .order_by(FindingEvidenceLink.created_at.asc())
    )
    evidence_links = [
        EvidenceLinkResponse(
            id=l.id,
            finding_id=l.finding_id,
            span_id=l.span_id,
            event_id=l.event_id,
            role=l.role,
            evidence_hash=l.evidence_hash,
            created_at=l.created_at,
        )
        for l in links_res.scalars().all()
    ]

    return FailureFindingDetailResponse(
        id=finding.id,
        finding_fingerprint=finding.finding_fingerprint,
        rule_version=finding.rule_version,
        trace_id=finding.trace_id,
        span_id=finding.span_id,
        span_name=span_name,
        rule_type=finding.rule_type,
        severity=finding.severity,
        iteration_count=finding.iteration_count,
        summary=finding.summary,
        evidence_summary=finding.evidence_summary,
        first_detected_at=finding.first_detected_at,
        last_updated_at=finding.last_updated_at,
        evidence_data=finding.evidence_data or {},
        evidence_links=evidence_links,
    )
