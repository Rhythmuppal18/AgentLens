from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.models.event import Event
from app.models.span import Span
from app.schemas.span import EventResponse, SpanDetailResponse

router = APIRouter(tags=["Spans"])


@router.get("/{span_id}", response_model=SpanDetailResponse)
async def get_span_detail(
    span_id: str,
    session: AsyncSession = Depends(get_db_session),
) -> SpanDetailResponse:
    """Retrieves full details for a single execution span, including associated milestone events."""
    sp_res = await session.execute(select(Span).where(Span.id == span_id))
    span = sp_res.scalar_one_or_none()
    if not span:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Span '{span_id}' not found",
        )

    # Query events for this span
    events_res = await session.execute(
        select(Event).where(Event.span_id == span_id).order_by(Event.timestamp.asc())
    )
    events = [
        EventResponse(
            id=evt.id,
            span_id=evt.span_id,
            trace_id=evt.trace_id,
            name=evt.name,
            timestamp=evt.timestamp,
            data=evt.data or {},
        )
        for evt in events_res.scalars().all()
    ]

    return SpanDetailResponse(
        id=span.id,
        trace_id=span.trace_id,
        parent_span_id=span.parent_span_id,
        name=span.name,
        span_type=span.span_type,
        status=span.status,
        start_time=span.start_time,
        end_time=span.end_time,
        duration_ms=span.duration_ms,
        input_payload=span.input_payload,
        input_hash=span.input_hash,
        output_payload=span.output_payload,
        error_message=span.error_message,
        error_type=span.error_type,
        error_stack=span.error_stack,
        attributes=span.attributes or {},
        events=events,
    )


@router.get("/{span_id}/events", response_model=list[EventResponse])
async def list_span_events(
    span_id: str,
    session: AsyncSession = Depends(get_db_session),
) -> list[EventResponse]:
    """Retrieves chronological milestone events recorded within a span."""
    sp_res = await session.execute(select(Span.id).where(Span.id == span_id))
    if not sp_res.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Span '{span_id}' not found",
        )

    events_res = await session.execute(
        select(Event).where(Event.span_id == span_id).order_by(Event.timestamp.asc())
    )
    return [
        EventResponse(
            id=evt.id,
            span_id=evt.span_id,
            trace_id=evt.trace_id,
            name=evt.name,
            timestamp=evt.timestamp,
            data=evt.data or {},
        )
        for evt in events_res.scalars().all()
    ]
