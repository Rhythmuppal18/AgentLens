from datetime import datetime, timezone
import logging
from typing import Optional
import uuid

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.environment import Environment
from app.models.event import Event
from app.models.finding import FailureFinding, FindingEvidenceLink
from app.models.project import Project
from app.models.span import Span
from app.models.trace import Trace
from app.schemas.telemetry import (
    IngestRequest,
    IngestResponse,
    SpanIngestRequest,
    SpanIngestResponse,
    SpanPayload,
)
from app.services.rules import RuleEngine

logger = logging.getLogger("agentlens.ingestion")

TERMINAL_SPAN_STATUSES = {"OK", "ERROR"}
TERMINAL_TRACE_STATUSES = {"SUCCESS", "ERROR", "PARTIAL"}


async def resolve_or_create_environment(
    session: AsyncSession,
    project_id: uuid.UUID,
    environment_slug: str,
) -> Environment:
    """Finds existing environment by slug for project, or auto-creates it dynamically."""
    result = await session.execute(
        select(Environment).where(
            Environment.project_id == project_id,
            Environment.slug == environment_slug,
        )
    )
    env = result.scalar_one_or_none()
    if env:
        return env

    env = Environment(
        project_id=project_id,
        slug=environment_slug,
        name=environment_slug.capitalize(),
    )
    session.add(env)
    await session.flush()
    logger.info("Created new environment '%s' for project %s", environment_slug, project_id)
    return env


async def safe_upsert_spans(
    session: AsyncSession,
    trace_id: str,
    span_payloads: list[SpanPayload],
) -> int:
    """Safely upserts spans with parent-child topological safety and terminal status preservation."""
    if not span_payloads:
        return 0

    # Query all existing spans for this trace
    result = await session.execute(
        select(Span).where(Span.trace_id == trace_id)
    )
    existing_spans: dict[str, Span] = {s.id: s for s in result.scalars().all()}

    # Phase 1: Upsert all spans without foreign parent references initially
    # This prevents ForeignKeyViolationError when a child span is processed before its parent.
    upserted_count = 0
    spans_to_link_parent: list[tuple[Span, str]] = []

    for sp in span_payloads:
        if sp.id in existing_spans:
            # Update existing span
            existing = existing_spans[sp.id]

            # Terminal status preservation: do not overwrite OK/ERROR with RUNNING
            if existing.status not in TERMINAL_SPAN_STATUSES or sp.status in TERMINAL_SPAN_STATUSES:
                existing.status = sp.status

            if sp.end_time is not None:
                existing.end_time = sp.end_time
            if sp.duration_ms is not None:
                existing.duration_ms = sp.duration_ms
            if sp.output_payload is not None:
                existing.output_payload = sp.output_payload
            if sp.error_message is not None:
                existing.error_message = sp.error_message
            if sp.error_type is not None:
                existing.error_type = sp.error_type
            if sp.error_stack is not None:
                existing.error_stack = sp.error_stack
            if sp.attributes:
                existing.attributes = {**existing.attributes, **sp.attributes}

            if sp.parent_span_id:
                spans_to_link_parent.append((existing, sp.parent_span_id))

            upserted_count += 1
        else:
            # Create new span with parent_span_id=None initially
            new_span = Span(
                id=sp.id,
                trace_id=trace_id,
                parent_span_id=None,
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
            )
            session.add(new_span)
            existing_spans[new_span.id] = new_span
            if sp.parent_span_id:
                spans_to_link_parent.append((new_span, sp.parent_span_id))
            upserted_count += 1

    # Flush so all new spans now exist in the database table
    await session.flush()

    # Phase 2: Link parent_span_id for spans whose parents exist in the database
    for span, parent_id in spans_to_link_parent:
        if parent_id in existing_spans and parent_id != span.id:
            span.parent_span_id = parent_id

    await session.flush()
    return upserted_count


async def process_batch_ingestion(
    session: AsyncSession,
    project: Project,
    payload: IngestRequest,
) -> IngestResponse:
    """Processes full batch telemetry ingestion with idempotency and rule evaluation."""
    # 1. Validate tenant consistency
    if payload.project_id != project.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Project ID '{payload.project_id}' does not match authenticated API key for project '{project.id}'",
        )

    # 2. Environment resolution
    env = await resolve_or_create_environment(session, project.id, payload.environment)

    # 3. Upsert Trace
    trace_result = await session.execute(
        select(Trace).where(Trace.id == payload.trace.id)
    )
    trace = trace_result.scalar_one_or_none()

    if trace:
        # Verify trace belongs to project
        if trace.project_id != project.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Trace '{payload.trace.id}' belongs to another project",
            )

        # Terminal status preservation: do not overwrite SUCCESS/ERROR with RUNNING
        if trace.status not in TERMINAL_TRACE_STATUSES or payload.trace.status in TERMINAL_TRACE_STATUSES:
            trace.status = payload.trace.status

        if payload.trace.end_time is not None:
            trace.end_time = payload.trace.end_time
        if payload.trace.duration_ms is not None:
            trace.duration_ms = payload.trace.duration_ms
        if payload.trace.total_tokens is not None:
            trace.total_tokens = payload.trace.total_tokens
        if payload.trace.prompt_tokens is not None:
            trace.prompt_tokens = payload.trace.prompt_tokens
        if payload.trace.completion_tokens is not None:
            trace.completion_tokens = payload.trace.completion_tokens
        if payload.trace.estimated_cost_usd is not None:
            trace.estimated_cost_usd = payload.trace.estimated_cost_usd
        if payload.trace.root_span_name is not None:
            trace.root_span_name = payload.trace.root_span_name
        if payload.trace.metadata:
            trace.trace_metadata = {**trace.trace_metadata, **payload.trace.metadata}

        trace.span_count = max(trace.span_count, len(payload.spans))
    else:
        trace = Trace(
            id=payload.trace.id,
            project_id=project.id,
            environment_id=env.id,
            agent_name=payload.trace.agent_name,
            session_id=payload.trace.session_id,
            user_identifier=payload.trace.user_identifier,
            status=payload.trace.status,
            start_time=payload.trace.start_time,
            end_time=payload.trace.end_time,
            duration_ms=payload.trace.duration_ms,
            total_tokens=payload.trace.total_tokens,
            prompt_tokens=payload.trace.prompt_tokens,
            completion_tokens=payload.trace.completion_tokens,
            estimated_cost_usd=payload.trace.estimated_cost_usd,
            root_span_name=payload.trace.root_span_name,
            span_count=len(payload.spans),
            metadata_=payload.trace.metadata or {},
        )
        session.add(trace)

    await session.flush()

    # 4. Upsert Spans
    spans_upserted = await safe_upsert_spans(session, payload.trace.id, payload.spans)

    # 5. Insert Events with deduplication
    events_inserted = 0
    if payload.events:
        # Check existing events
        event_ids = [e.id for e in payload.events]
        evt_res = await session.execute(
            select(Event.id).where(Event.id.in_(event_ids))
        )
        existing_event_ids = set(evt_res.scalars().all())

        # Check existing spans for trace
        spn_res = await session.execute(
            select(Span.id).where(Span.trace_id == payload.trace.id)
        )
        valid_span_ids = set(spn_res.scalars().all())

        for evt in payload.events:
            if evt.id not in existing_event_ids and evt.span_id in valid_span_ids:
                new_event = Event(
                    id=evt.id,
                    span_id=evt.span_id,
                    trace_id=payload.trace.id,
                    name=evt.name,
                    timestamp=evt.timestamp,
                    data=evt.data or {},
                )
                session.add(new_event)
                events_inserted += 1

        await session.flush()

    # 6. Evaluate Deterministic Rule Engine
    all_spans_res = await session.execute(
        select(Span).where(Span.trace_id == payload.trace.id)
    )
    all_spans = list(all_spans_res.scalars().all())

    detected_findings = RuleEngine.evaluate_spans(
        trace_id=payload.trace.id,
        spans=all_spans,
        project_settings=project.settings,
    )

    findings_detected = 0
    findings_updated = 0

    if detected_findings:
        for finding in detected_findings:
            # Query existing finding by fingerprint
            fp_res = await session.execute(
                select(FailureFinding).where(
                    FailureFinding.finding_fingerprint == finding.fingerprint
                )
            )
            existing_finding = fp_res.scalar_one_or_none()

            if existing_finding:
                existing_finding.iteration_count = finding.iteration_count
                existing_finding.severity = finding.severity
                existing_finding.summary = finding.summary
                existing_finding.evidence_summary = finding.evidence_summary
                existing_finding.evidence_data = finding.evidence_data
                existing_finding.last_updated_at = datetime.now(timezone.utc)
                finding_id = existing_finding.id
                findings_updated += 1
            else:
                finding_id = f"fnd_{uuid.uuid4().hex[:16]}"
                new_finding = FailureFinding(
                    id=finding_id,
                    finding_fingerprint=finding.fingerprint,
                    rule_version=finding.rule_version,
                    trace_id=payload.trace.id,
                    span_id=finding.span_id,
                    rule_type=finding.rule_type,
                    severity=finding.severity,
                    iteration_count=finding.iteration_count,
                    summary=finding.summary,
                    evidence_summary=finding.evidence_summary,
                    evidence_data=finding.evidence_data,
                )
                session.add(new_finding)
                findings_detected += 1

            await session.flush()

            # Insert evidence links
            for link in finding.evidence_links:
                ev_hash = FindingEvidenceLink.generate_evidence_hash(
                    finding_id=finding_id,
                    span_id=link.get("span_id"),
                    event_id=link.get("event_id"),
                    role=link.get("role", "primary"),
                )
                link_res = await session.execute(
                    select(FindingEvidenceLink).where(
                        FindingEvidenceLink.finding_id == finding_id,
                        FindingEvidenceLink.evidence_hash == ev_hash,
                    )
                )
                if not link_res.scalar_one_or_none():
                    new_link = FindingEvidenceLink(
                        finding_id=finding_id,
                        span_id=link.get("span_id"),
                        event_id=link.get("event_id"),
                        role=link.get("role", "primary"),
                        evidence_hash=ev_hash,
                    )
                    session.add(new_link)

        trace.has_failures = True
        await session.flush()

    # Commit all changes atomically
    await session.commit()

    return IngestResponse(
        status="accepted",
        trace_id=payload.trace.id,
        spans_upserted=spans_upserted,
        events_inserted=events_inserted,
        rules_evaluated=5,
        findings_detected=findings_detected,
        findings_updated=findings_updated,
        ingested_at=datetime.now(timezone.utc),
    )


async def process_spans_ingestion(
    session: AsyncSession,
    project: Project,
    payload: SpanIngestRequest,
) -> SpanIngestResponse:
    """Processes incremental span ingestion for an existing running trace."""
    # Verify trace exists and belongs to project
    trace_res = await session.execute(
        select(Trace).where(Trace.id == payload.trace_id)
    )
    trace = trace_res.scalar_one_or_none()

    if not trace:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Trace '{payload.trace_id}' not found for span ingestion",
        )

    if trace.project_id != project.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Trace '{payload.trace_id}' belongs to another project",
        )

    # Upsert spans
    spans_upserted = await safe_upsert_spans(session, payload.trace_id, payload.spans)
    trace.span_count += len(payload.spans)

    # Re-evaluate rules
    all_spans_res = await session.execute(
        select(Span).where(Span.trace_id == payload.trace_id)
    )
    all_spans = list(all_spans_res.scalars().all())

    detected_findings = RuleEngine.evaluate_spans(
        trace_id=payload.trace_id,
        spans=all_spans,
        project_settings=project.settings,
    )

    if detected_findings:
        for finding in detected_findings:
            fp_res = await session.execute(
                select(FailureFinding).where(
                    FailureFinding.finding_fingerprint == finding.fingerprint
                )
            )
            existing_finding = fp_res.scalar_one_or_none()
            if existing_finding:
                existing_finding.iteration_count = finding.iteration_count
                existing_finding.severity = finding.severity
                existing_finding.summary = finding.summary
                existing_finding.evidence_summary = finding.evidence_summary
                existing_finding.evidence_data = finding.evidence_data
                existing_finding.last_updated_at = datetime.now(timezone.utc)
                finding_id = existing_finding.id
            else:
                finding_id = f"fnd_{uuid.uuid4().hex[:16]}"
                new_finding = FailureFinding(
                    id=finding_id,
                    finding_fingerprint=finding.fingerprint,
                    rule_version=finding.rule_version,
                    trace_id=payload.trace_id,
                    span_id=finding.span_id,
                    rule_type=finding.rule_type,
                    severity=finding.severity,
                    iteration_count=finding.iteration_count,
                    summary=finding.summary,
                    evidence_summary=finding.evidence_summary,
                    evidence_data=finding.evidence_data,
                )
                session.add(new_finding)

            await session.flush()

            for link in finding.evidence_links:
                ev_hash = FindingEvidenceLink.generate_evidence_hash(
                    finding_id=finding_id,
                    span_id=link.get("span_id"),
                    event_id=link.get("event_id"),
                    role=link.get("role", "primary"),
                )
                link_res = await session.execute(
                    select(FindingEvidenceLink).where(
                        FindingEvidenceLink.finding_id == finding_id,
                        FindingEvidenceLink.evidence_hash == ev_hash,
                    )
                )
                if not link_res.scalar_one_or_none():
                    new_link = FindingEvidenceLink(
                        finding_id=finding_id,
                        span_id=link.get("span_id"),
                        event_id=link.get("event_id"),
                        role=link.get("role", "primary"),
                        evidence_hash=ev_hash,
                    )
                    session.add(new_link)

        trace.has_failures = True
        await session.flush()

    await session.commit()
    return SpanIngestResponse(
        status="accepted",
        spans_processed=spans_upserted,
    )
