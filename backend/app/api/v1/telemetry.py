import logging

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import AuthenticatedProject
from app.core.database import get_db_session
from app.models.project import Project
from app.schemas.telemetry import (
    IngestRequest,
    IngestResponse,
    SpanIngestRequest,
    SpanIngestResponse,
)
from app.services.ingestion import process_batch_ingestion, process_spans_ingestion

logger = logging.getLogger("agentlens.api.telemetry")

router = APIRouter(tags=["telemetry"])


@router.post(
    "/ingest",
    response_model=IngestResponse,
    status_code=status.HTTP_202_ACCEPTED,
    summary="Batch Ingest Telemetry",
    description="Batch ingest a full execution trace along with child spans and events with server deduplication.",
)
async def ingest_telemetry_batch(
    payload: IngestRequest,
    project: AuthenticatedProject,
    session: AsyncSession = Depends(get_db_session),
) -> IngestResponse:
    """Ingests full execution trace, spans, and events in an atomic database transaction."""
    return await process_batch_ingestion(session=session, project=project, payload=payload)


@router.post(
    "/spans",
    response_model=SpanIngestResponse,
    status_code=status.HTTP_202_ACCEPTED,
    summary="Incremental Streaming Spans",
    description="Stream execution spans incrementally for an active, long-running agent trace.",
)
async def ingest_streaming_spans(
    payload: SpanIngestRequest,
    project: AuthenticatedProject,
    session: AsyncSession = Depends(get_db_session),
) -> SpanIngestResponse:
    """Ingests incremental spans for an active trace session."""
    return await process_spans_ingestion(session=session, project=project, payload=payload)
