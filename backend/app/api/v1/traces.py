from collections import defaultdict
from datetime import datetime, timedelta, timezone
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import desc, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.models.environment import Environment
from app.models.event import Event
from app.models.finding import FailureFinding
from app.models.span import Span
from app.models.trace import Trace
from app.schemas.finding import FailureFindingListItem
from app.schemas.span import EventResponse, SpanDetailResponse
from app.schemas.trace import (
    SpanTreeNode,
    TraceDetailResponse,
    TraceListItem,
    TraceListResponse,
)

router = APIRouter(tags=["Traces"])


def _calculate_time_window(time_range: Optional[str]) -> Optional[datetime]:
    """Calculates UTC start timestamp for relative time window filters."""
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


@router.get("", response_model=TraceListResponse)
async def list_traces(
    project_id: Optional[UUID] = Query(None, description="Filter by Project UUID"),
    environment: Optional[str] = Query(None, description="Filter by environment name (e.g. development, production)"),
    status: Optional[str] = Query(None, description="Filter by status (SUCCESS, ERROR, PARTIAL, RUNNING)"),
    has_failures: Optional[bool] = Query(None, description="Filter traces with detected failure findings"),
    agent_name: Optional[str] = Query(None, description="Filter by agent name"),
    search: Optional[str] = Query(None, description="Sub-string search on trace ID, agent name, session ID, or root span"),
    time_range: Optional[str] = Query("24h", description="Time window: 1h, 24h, 7d, 30d, all"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    offset: int = Query(0, ge=0, description="Pagination offset"),
    session: AsyncSession = Depends(get_db_session),
) -> TraceListResponse:
    """Retrieves paginated, filtered list of execution traces."""
    # Build query joining Environment to access environment name
    query = select(Trace, Environment.name.label("env_name")).join(
        Environment, Trace.environment_id == Environment.id
    )

    if project_id is not None:
        query = query.where(Trace.project_id == project_id)

    if environment:
        query = query.where(
            or_(
                Environment.name.ilike(environment),
                Environment.slug.ilike(environment),
            )
        )

    if status:
        stat_upper = status.upper()
        if stat_upper in ("FAILED", "ERROR"):
            query = query.where(or_(Trace.status == "FAILED", Trace.status == "ERROR"))
        elif stat_upper in ("SUCCESS", "OK"):
            query = query.where(or_(Trace.status == "SUCCESS", Trace.status == "OK"))
        else:
            query = query.where(Trace.status == stat_upper)

    if has_failures is not None:
        query = query.where(Trace.has_failures == has_failures)

    if agent_name:
        query = query.where(Trace.agent_name.ilike(f"%{agent_name}%"))

    if search:
        search_pattern = f"%{search}%"
        query = query.where(
            or_(
                Trace.id.ilike(search_pattern),
                Trace.agent_name.ilike(search_pattern),
                Trace.session_id.ilike(search_pattern),
                Trace.root_span_name.ilike(search_pattern),
            )
        )

    since = _calculate_time_window(time_range)
    if since is not None:
        query = query.where(Trace.start_time >= since)

    # Count total matching rows
    count_query = select(func.count()).select_from(query.subquery())
    total_count = (await session.execute(count_query)).scalar_one()

    # Apply pagination and sorting
    paginated_query = query.order_by(desc(Trace.start_time)).limit(limit).offset(offset)
    results = await session.execute(paginated_query)

    items: list[TraceListItem] = []
    for trace_obj, env_name in results.all():
        items.append(
            TraceListItem(
                id=trace_obj.id,
                project_id=trace_obj.project_id,
                environment=env_name,
                agent_name=trace_obj.agent_name,
                session_id=trace_obj.session_id,
                user_identifier=trace_obj.user_identifier,
                root_span_name=trace_obj.root_span_name,
                status=trace_obj.status,
                start_time=trace_obj.start_time,
                end_time=trace_obj.end_time,
                duration_ms=trace_obj.duration_ms,
                span_count=trace_obj.span_count,
                has_failures=trace_obj.has_failures,
                total_tokens=trace_obj.total_tokens,
                prompt_tokens=trace_obj.prompt_tokens,
                completion_tokens=trace_obj.completion_tokens,
                estimated_cost_usd=float(trace_obj.estimated_cost_usd) if trace_obj.estimated_cost_usd is not None else None,
                created_at=trace_obj.created_at,
                metadata=trace_obj.trace_metadata or {},
            )
        )

    return TraceListResponse(
        total=total_count,
        limit=limit,
        offset=offset,
        items=items,
    )


@router.get("/{trace_id}", response_model=TraceDetailResponse)
async def get_trace_detail(
    trace_id: str,
    session: AsyncSession = Depends(get_db_session),
) -> TraceDetailResponse:
    """Retrieves full details for a trace, including its hierarchical span tree and milestone events."""
    # Query trace and environment
    tr_res = await session.execute(
        select(Trace, Environment.name.label("env_name"))
        .join(Environment, Trace.environment_id == Environment.id)
        .where(Trace.id == trace_id)
    )
    row = tr_res.first()
    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Trace '{trace_id}' not found",
        )
    trace_obj, env_name = row

    # Query all spans for this trace ordered by start_time
    spans_res = await session.execute(
        select(Span).where(Span.trace_id == trace_id).order_by(Span.start_time.asc())
    )
    raw_spans = list(spans_res.scalars().all())

    # Query all events for this trace ordered by timestamp
    events_res = await session.execute(
        select(Event).where(Event.trace_id == trace_id).order_by(Event.timestamp.asc())
    )
    raw_events = list(events_res.scalars().all())

    # Group events by span_id
    events_by_span: dict[str, list[EventResponse]] = defaultdict(list)
    for evt in raw_events:
        events_by_span[evt.span_id].append(
            EventResponse(
                id=evt.id,
                span_id=evt.span_id,
                trace_id=evt.trace_id,
                name=evt.name,
                timestamp=evt.timestamp,
                data=evt.data or {},
            )
        )

    # Build hierarchical span tree
    span_nodes: dict[str, SpanTreeNode] = {}
    for sp in raw_spans:
        span_nodes[sp.id] = SpanTreeNode(
            id=sp.id,
            trace_id=sp.trace_id,
            parent_span_id=sp.parent_span_id,
            name=sp.name,
            span_type=sp.span_type,
            status=sp.status,
            start_time=sp.start_time,
            end_time=sp.end_time,
            duration_ms=sp.duration_ms,
            input_payload=sp.input_payload,
            input_hash=sp.input_hash,
            output_payload=sp.output_payload,
            error_message=sp.error_message,
            error_type=sp.error_type,
            error_stack=sp.error_stack,
            attributes=sp.attributes or {},
            events=events_by_span.get(sp.id, []),
            children=[],
        )

    root_node: Optional[SpanTreeNode] = None
    ordered_tree: list[SpanTreeNode] = []

    for sp in raw_spans:
        node = span_nodes[sp.id]
        if sp.parent_span_id and sp.parent_span_id in span_nodes and sp.parent_span_id != sp.id:
            parent_node = span_nodes[sp.parent_span_id]
            parent_node.children.append(node)
        else:
            ordered_tree.append(node)
            if root_node is None:
                root_node = node

    return TraceDetailResponse(
        id=trace_obj.id,
        project_id=trace_obj.project_id,
        environment=env_name,
        agent_name=trace_obj.agent_name,
        session_id=trace_obj.session_id,
        user_identifier=trace_obj.user_identifier,
        root_span_name=trace_obj.root_span_name,
        status=trace_obj.status,
        start_time=trace_obj.start_time,
        end_time=trace_obj.end_time,
        duration_ms=trace_obj.duration_ms,
        span_count=len(raw_spans) or trace_obj.span_count,
        has_failures=trace_obj.has_failures,
        total_tokens=trace_obj.total_tokens,
        prompt_tokens=trace_obj.prompt_tokens,
        completion_tokens=trace_obj.completion_tokens,
        estimated_cost_usd=float(trace_obj.estimated_cost_usd) if trace_obj.estimated_cost_usd is not None else None,
        created_at=trace_obj.created_at,
        metadata=trace_obj.trace_metadata or {},
        spans=ordered_tree,
        root_span=root_node,
    )


@router.get("/{trace_id}/spans", response_model=list[SpanDetailResponse])
async def list_trace_spans(
    trace_id: str,
    session: AsyncSession = Depends(get_db_session),
) -> list[SpanDetailResponse]:
    """Retrieves flat list of all spans belonging to a trace."""
    # Verify trace exists
    tr_res = await session.execute(select(Trace.id).where(Trace.id == trace_id))
    if not tr_res.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Trace '{trace_id}' not found",
        )

    spans_res = await session.execute(
        select(Span).where(Span.trace_id == trace_id).order_by(Span.start_time.asc())
    )
    raw_spans = list(spans_res.scalars().all())

    events_res = await session.execute(
        select(Event).where(Event.trace_id == trace_id).order_by(Event.timestamp.asc())
    )
    events_by_span: dict[str, list[EventResponse]] = defaultdict(list)
    for evt in events_res.scalars().all():
        events_by_span[evt.span_id].append(
            EventResponse(
                id=evt.id,
                span_id=evt.span_id,
                trace_id=evt.trace_id,
                name=evt.name,
                timestamp=evt.timestamp,
                data=evt.data or {},
            )
        )

    return [
        SpanDetailResponse(
            id=sp.id,
            trace_id=sp.trace_id,
            parent_span_id=sp.parent_span_id,
            name=sp.name,
            span_type=sp.span_type,
            status=sp.status,
            start_time=sp.start_time,
            end_time=sp.end_time,
            duration_ms=sp.duration_ms,
            input_payload=sp.input_payload,
            input_hash=sp.input_hash,
            output_payload=sp.output_payload,
            error_message=sp.error_message,
            error_type=sp.error_type,
            error_stack=sp.error_stack,
            attributes=sp.attributes or {},
            events=events_by_span.get(sp.id, []),
        )
        for sp in raw_spans
    ]


@router.get("/{trace_id}/failures", response_model=list[FailureFindingListItem])
async def list_trace_failures(
    trace_id: str,
    session: AsyncSession = Depends(get_db_session),
) -> list[FailureFindingListItem]:
    """Retrieves all failure findings detected within a trace."""
    query = (
        select(FailureFinding, Span.name.label("span_name"))
        .outerjoin(Span, FailureFinding.span_id == Span.id)
        .where(FailureFinding.trace_id == trace_id)
        .order_by(desc(FailureFinding.first_detected_at))
    )
    results = await session.execute(query)

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
    return items
