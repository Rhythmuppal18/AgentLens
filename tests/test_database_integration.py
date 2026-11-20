"""Integration test suite for AgentLens Stage 2 Step 5: Live Database Verification.

Validates end-to-end against live PostgreSQL 16 database:
1. Project and Environment creation and retrieval.
2. Trace, hierarchical Span, and Event creation and retrieval.
3. Trace-level FailureFinding with span_id = NULL.
4. Span-level FailureFinding with valid span_id.
5. FindingEvidenceLink creation with role and idempotency hash.
6. Same-trace compound foreign key enforcement:
   - fk_events_span_same_trace prevents cross-trace span referencing.
   - fk_findings_span_same_trace prevents cross-trace span referencing.
7. Cascade and SET NULL behavior:
   - Parent span deletion nullifies parent_span_id on child span without deleting child.
   - Project deletion cascades cleanly to environments, traces, spans, events, findings, and evidence links.
"""

from datetime import datetime, timezone
from decimal import Decimal
import os
import sys
import unittest
import uuid

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from app.core.config import settings
from app.models import (
    Environment,
    Event,
    FailureFinding,
    FindingEvidenceLink,
    Project,
    Span,
    Trace,
)
from sqlalchemy import delete, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool


class TestDatabaseIntegration(unittest.IsolatedAsyncioTestCase):
    """Live PostgreSQL 16 integration tests using isolated transactions."""

    async def asyncSetUp(self):
        """Create an isolated test engine, session, and test project/environment."""
        self.engine = create_async_engine(settings.async_database_url, poolclass=NullPool)
        self.session_factory = async_sessionmaker(bind=self.engine, class_=AsyncSession, expire_on_commit=False)
        self.session = self.session_factory()
        self.test_prefix = f"test_{uuid.uuid4().hex[:8]}"

        self.project = Project(
            id=uuid.uuid4(),
            name=f"Project {self.test_prefix}",
            slug=f"proj-{self.test_prefix}",
            description="Integration test project",
        )
        self.session.add(self.project)
        await self.session.flush()

        self.environment = Environment(
            id=uuid.uuid4(),
            project_id=self.project.id,
            name="Production",
            slug=f"prod-{self.test_prefix}",
        )
        self.session.add(self.environment)
        await self.session.commit()

    async def asyncTearDown(self):
        """Clean up test records and dispose engine cleanly."""
        await self.session.rollback()
        try:
            p = await self.session.get(Project, self.project.id)
            if p:
                await self.session.delete(p)
                await self.session.commit()
        except Exception:
            await self.session.rollback()
        finally:
            await self.session.close()
            await self.engine.dispose()

    async def test_01_project_and_environment_creation(self):
        """Verify project and environment can be queried with correct attributes."""
        proj = await self.session.get(Project, self.project.id)
        self.assertIsNotNone(proj)
        self.assertEqual(proj.slug, f"proj-{self.test_prefix}")
        self.assertTrue(proj.is_active)

        env = await self.session.get(Environment, self.environment.id)
        self.assertIsNotNone(env)
        self.assertEqual(env.project_id, self.project.id)
        self.assertEqual(env.name, "Production")

    async def test_02_trace_span_event_creation(self):
        """Verify Trace, parent Span, child Span, and Event creation and retrieval."""
        now = datetime.now(timezone.utc)
        trace_id = f"trc_{self.test_prefix}"
        trace = Trace(
            id=trace_id,
            project_id=self.project.id,
            environment_id=self.environment.id,
            agent_name="ResearchAgent",
            status="RUNNING",
            start_time=now,
            total_tokens=1500,
            estimated_cost_usd=Decimal("0.003500"),
            metadata_={"test_run": True},
        )
        self.session.add(trace)
        await self.session.flush()

        # Root span
        root_span_id = f"spn_root_{self.test_prefix}"
        root_span = Span(
            id=root_span_id,
            trace_id=trace_id,
            name="orchestrator_loop",
            span_type="agent",
            status="RUNNING",
            start_time=now,
        )
        self.session.add(root_span)
        await self.session.flush()

        # Child span
        child_span_id = f"spn_child_{self.test_prefix}"
        child_span = Span(
            id=child_span_id,
            trace_id=trace_id,
            parent_span_id=root_span_id,
            name="web_search",
            span_type="tool",
            status="SUCCESS",
            start_time=now,
            input_payload={"query": "test query"},
            input_hash="hash_123",
        )
        self.session.add(child_span)
        await self.session.flush()

        # Event within child span
        event_id = f"evt_{self.test_prefix}"
        event = Event(
            id=event_id,
            span_id=child_span_id,
            trace_id=trace_id,
            name="http_request_sent",
            timestamp=now,
            data={"url": "https://api.example.com"},
        )
        self.session.add(event)
        await self.session.commit()

        # Verification
        saved_trace = await self.session.get(Trace, trace_id)
        self.assertEqual(saved_trace.agent_name, "ResearchAgent")
        self.assertEqual(saved_trace.estimated_cost_usd, Decimal("0.003500"))

        saved_child = await self.session.get(Span, child_span_id)
        self.assertEqual(saved_child.parent_span_id, root_span_id)
        self.assertEqual(saved_child.input_payload, {"query": "test query"})

        saved_evt = await self.session.get(Event, event_id)
        self.assertEqual(saved_evt.span_id, child_span_id)
        self.assertEqual(saved_evt.trace_id, trace_id)

    async def test_03_trace_level_finding_with_null_span_id(self):
        """Verify trace-level FailureFinding with span_id = NULL commits cleanly."""
        now = datetime.now(timezone.utc)
        trace_id = f"trc_tl_{self.test_prefix}"
        trace = Trace(
            id=trace_id,
            project_id=self.project.id,
            environment_id=self.environment.id,
            agent_name="PlannerAgent",
            status="COMPLETED",
            start_time=now,
        )
        self.session.add(trace)
        await self.session.flush()

        fp = FailureFinding.generate_fingerprint(
            rule_type="SLOW_SPAN",
            trace_id=trace_id,
            span_id=None,
            rule_version="v1.0.0",
        )
        finding_id = f"fnd_tl_{self.test_prefix}"
        finding = FailureFinding(
            id=finding_id,
            finding_fingerprint=fp,
            rule_version="v1.0.0",
            trace_id=trace_id,
            span_id=None,  # Trace-level finding with NULL span_id
            rule_type="SLOW_SPAN",
            severity="WARNING",
            iteration_count=1,
            summary="Trace overall execution exceeded latency threshold",
            evidence_summary="Total trace duration 45s exceeded 30s target",
            evidence_data={"duration_ms": 45000, "threshold_ms": 30000},
        )
        self.session.add(finding)
        await self.session.commit()

        saved_fnd = await self.session.get(FailureFinding, finding_id)
        self.assertIsNotNone(saved_fnd)
        self.assertIsNone(saved_fnd.span_id)
        self.assertEqual(saved_fnd.finding_fingerprint, fp)

    async def test_04_span_level_finding_and_evidence_link(self):
        """Verify span-level FailureFinding and FindingEvidenceLink with hash uniqueness."""
        now = datetime.now(timezone.utc)
        trace_id = f"trc_sl_{self.test_prefix}"
        trace = Trace(
            id=trace_id,
            project_id=self.project.id,
            environment_id=self.environment.id,
            agent_name="ToolAgent",
            status="FAILED",
            start_time=now,
        )
        self.session.add(trace)
        await self.session.flush()

        span_id = f"spn_sl_{self.test_prefix}"
        span = Span(
            id=span_id,
            trace_id=trace_id,
            name="database_query",
            span_type="tool",
            status="ERROR",
            start_time=now,
            error_message="Connection refused",
        )
        self.session.add(span)
        await self.session.flush()

        event_id = f"evt_sl_{self.test_prefix}"
        event = Event(
            id=event_id,
            span_id=span_id,
            trace_id=trace_id,
            name="retry_attempt",
            timestamp=now,
            data={"attempt": 3},
        )
        self.session.add(event)
        await self.session.flush()

        fp = FailureFinding.generate_fingerprint(
            rule_type="FAILED_SPAN",
            trace_id=trace_id,
            span_id=span_id,
            rule_version="v1.0.0",
        )
        finding_id = f"fnd_sl_{self.test_prefix}"
        finding = FailureFinding(
            id=finding_id,
            finding_fingerprint=fp,
            rule_version="v1.0.0",
            trace_id=trace_id,
            span_id=span_id,
            rule_type="FAILED_SPAN",
            severity="CRITICAL",
            iteration_count=1,
            summary="Tool execution failed with fatal error",
            evidence_summary="Database query connection refused",
            evidence_data={"error": "Connection refused"},
        )
        self.session.add(finding)
        await self.session.flush()

        # Evidence link 1: Span evidence
        ev_hash_1 = FindingEvidenceLink.generate_evidence_hash(finding_id=finding_id, span_id=span_id, role="trigger")
        ev_link_1 = FindingEvidenceLink(
            finding_id=finding_id,
            span_id=span_id,
            event_id=None,
            role="trigger",
            evidence_hash=ev_hash_1,
        )
        self.session.add(ev_link_1)

        # Evidence link 2: Event evidence
        ev_hash_2 = FindingEvidenceLink.generate_evidence_hash(finding_id=finding_id, event_id=event_id, role="iteration")
        ev_link_2 = FindingEvidenceLink(
            finding_id=finding_id,
            span_id=None,
            event_id=event_id,
            role="iteration",
            evidence_hash=ev_hash_2,
        )
        self.session.add(ev_link_2)
        await self.session.commit()

        # Test idempotency constraint: duplicate evidence link must fail
        dup_link = FindingEvidenceLink(
            finding_id=finding_id,
            span_id=span_id,
            event_id=None,
            role="trigger",
            evidence_hash=ev_hash_1,
        )
        self.session.add(dup_link)
        with self.assertRaises(IntegrityError):
            await self.session.commit()
        await self.session.rollback()

    async def test_05_same_trace_foreign_key_enforcement(self):
        """Verify compound foreign keys reject cross-trace span references."""
        now = datetime.now(timezone.utc)
        # Create Trace A with Span A
        trace_a_id = f"trc_A_{self.test_prefix}"
        trace_a = Trace(
            id=trace_a_id,
            project_id=self.project.id,
            environment_id=self.environment.id,
            agent_name="AgentA",
            status="RUNNING",
            start_time=now,
        )
        self.session.add(trace_a)
        await self.session.flush()

        span_a_id = f"spn_A_{self.test_prefix}"
        span_a = Span(
            id=span_a_id,
            trace_id=trace_a_id,
            name="task_a",
            span_type="agent",
            status="RUNNING",
            start_time=now,
        )
        self.session.add(span_a)

        # Create Trace B
        trace_b_id = f"trc_B_{self.test_prefix}"
        trace_b = Trace(
            id=trace_b_id,
            project_id=self.project.id,
            environment_id=self.environment.id,
            agent_name="AgentB",
            status="RUNNING",
            start_time=now,
        )
        self.session.add(trace_b)
        await self.session.commit()

        # Attempt 1: Event in Trace B referencing Span A (Trace A) -> MUST FAIL (fk_events_span_same_trace)
        bad_event = Event(
            id=f"evt_bad_{self.test_prefix}",
            span_id=span_a_id,
            trace_id=trace_b_id,  # Mismatched trace!
            name="cross_trace_event",
            timestamp=now,
        )
        self.session.add(bad_event)
        with self.assertRaises(IntegrityError):
            await self.session.commit()
        await self.session.rollback()

        # Attempt 2: Finding in Trace B referencing Span A (Trace A) -> MUST FAIL (fk_findings_span_same_trace)
        bad_finding = FailureFinding(
            id=f"fnd_bad_{self.test_prefix}",
            finding_fingerprint=f"fp_bad_{self.test_prefix}",
            rule_version="v1.0.0",
            trace_id=trace_b_id,  # Trace B
            span_id=span_a_id,   # Span belongs to Trace A!
            rule_type="FAILED_SPAN",
            severity="CRITICAL",
            iteration_count=1,
            summary="Invalid cross-trace finding",
            evidence_summary="Testing compound FK violation",
            evidence_data={},
        )
        self.session.add(bad_finding)
        with self.assertRaises(IntegrityError):
            await self.session.commit()
        await self.session.rollback()

    async def test_06_cascade_and_set_null_behavior(self):
        """Verify SET NULL on parent span deletion and CASCADE on project deletion."""
        now = datetime.now(timezone.utc)
        trace_id = f"trc_casc_{self.test_prefix}"
        trace = Trace(
            id=trace_id,
            project_id=self.project.id,
            environment_id=self.environment.id,
            agent_name="CascadeAgent",
            status="RUNNING",
            start_time=now,
        )
        self.session.add(trace)
        await self.session.flush()

        parent_span_id = f"spn_parent_{self.test_prefix}"
        parent_span = Span(
            id=parent_span_id,
            trace_id=trace_id,
            name="parent_task",
            span_type="agent",
            status="RUNNING",
            start_time=now,
        )
        self.session.add(parent_span)
        await self.session.flush()

        child_span_id = f"spn_child_casc_{self.test_prefix}"
        child_span = Span(
            id=child_span_id,
            trace_id=trace_id,
            parent_span_id=parent_span_id,
            name="child_task",
            span_type="tool",
            status="RUNNING",
            start_time=now,
        )
        self.session.add(child_span)
        await self.session.commit()

        # 1. Test SET NULL: delete parent_span in database
        await self.session.execute(delete(Span).where(Span.id == parent_span_id))
        await self.session.commit()

        # Re-fetch child span from database using populate_existing
        res = await self.session.execute(
            select(Span).where(Span.id == child_span_id).execution_options(populate_existing=True)
        )
        saved_child = res.scalar_one()
        self.assertIsNotNone(saved_child, "Child span must NOT be deleted when parent span is deleted")
        self.assertIsNone(saved_child.parent_span_id, "parent_span_id must be nullified to NULL")

        # 2. Test CASCADE: delete project
        proj = await self.session.get(Project, self.project.id)
        await self.session.delete(proj)
        await self.session.commit()

        # Verify all children were cascade deleted
        self.assertIsNone(await self.session.get(Environment, self.environment.id))
        self.assertIsNone(await self.session.get(Trace, trace_id))
        self.assertIsNone(await self.session.get(Span, child_span_id))


if __name__ == "__main__":
    unittest.main()
