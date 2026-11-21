import asyncio
from datetime import datetime, timezone
import hashlib
import os
import sys
import threading
import time
import unittest
import uuid
import uvicorn

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "sdk")))

from agentlens import AgentLens
from app.core.config import settings
from app.main import app
from app.models.event import Event
from app.models.finding import FailureFinding, FindingEvidenceLink
from app.models.project import Project
from app.models.span import Span
from app.models.trace import Trace

TEST_SERVER_PORT = 8889


class TestSDKLiveIntegration(unittest.IsolatedAsyncioTestCase):
    """Live end-to-end integration test verifying SDK dispatch against live backend and PostgreSQL."""

    @classmethod
    def setUpClass(cls):
        """Starts a background Uvicorn server running FastAPI app on port 8889."""
        cls.config = uvicorn.Config(
            app=app,
            host="127.0.0.1",
            port=TEST_SERVER_PORT,
            log_level="error",
        )
        cls.server = uvicorn.Server(cls.config)
        cls.server_thread = threading.Thread(target=cls.server.run, daemon=True)
        cls.server_thread.start()

        # Wait for server to bind
        time.sleep(1.0)

    @classmethod
    def tearDownClass(cls):
        """Shuts down background Uvicorn server."""
        cls.server.should_exit = True
        cls.server_thread.join(timeout=2.0)

    async def asyncSetUp(self):
        """Creates an isolated test project and API key in PostgreSQL."""
        self.engine = create_async_engine(settings.async_database_url, poolclass=NullPool)
        self.session_maker = async_sessionmaker(
            bind=self.engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )

        self.test_api_key = f"al_live_sdk_{uuid.uuid4().hex[:16]}"
        self.test_api_key_hash = hashlib.sha256(self.test_api_key.encode("utf-8")).hexdigest()
        self.project_id = uuid.uuid4()
        self.project_slug = f"proj-sdk-{uuid.uuid4().hex[:8]}"

        async with self.session_maker() as session:
            project = Project(
                id=self.project_id,
                name="SDK End-to-End Test Project",
                slug=self.project_slug,
                api_key_hash=self.test_api_key_hash,
                is_active=True,
            )
            session.add(project)
            await session.commit()

        # Initialize AgentLens SDK client targeting test server
        self.client = AgentLens(
            api_key=self.test_api_key,
            project_id=str(self.project_id),
            environment="integration",
            api_url=f"http://127.0.0.1:{TEST_SERVER_PORT}",
            capture_payloads=True,
            flush_interval=0.1,  # Fast flush for testing
        )

    async def asyncTearDown(self):
        """Disposes SDK worker and cleans up PostgreSQL records."""
        self.client.shutdown(timeout=2.0)

        async with self.session_maker() as session:
            await session.execute(delete(Project).where(Project.id == self.project_id))
            await session.commit()

        await self.engine.dispose()

    async def test_end_to_end_sdk_trace_and_spans(self):
        """Instruments an agent workflow with SDK and verifies all records in PostgreSQL."""
        agent_name = "LiveIntegrationAgent"
        session_id = f"sess_{uuid.uuid4().hex[:8]}"

        with self.client.trace(
            agent_name=agent_name,
            session_id=session_id,
            metadata={"sdk_test": True},
        ) as trace:
            trace_id = trace.id

            with trace.span(name="step_reasoning", span_type="AGENT_STEP") as step_span:
                step_span_id = step_span.id
                step_span.event("model_selected", {"model": "claude-3-opus"})

                with step_span.span(
                    name="tool_search",
                    span_type="TOOL_CALL",
                    input_payload={"query": "quantum computing"},
                    attributes={"tool_name": "search_engine"},
                ) as tool_span:
                    tool_span_id = tool_span.id
                    tool_span.set_output({"status": "found", "count": 12})
                    tool_span.set_tokens(prompt_tokens=120, completion_tokens=30, cost=0.00045)

            trace.set_tokens(prompt_tokens=120, completion_tokens=30, cost=0.00045)

        # Flush SDK queue to backend
        self.client.flush(timeout=3.0)

        # Allow backend transaction to complete
        await asyncio.sleep(0.5)

        # Verify in PostgreSQL
        async with self.session_maker() as session:
            tr = (await session.execute(select(Trace).where(Trace.id == trace_id))).scalar_one_or_none()
            self.assertIsNotNone(tr, f"Trace {trace_id} not found in database")
            self.assertEqual(tr.agent_name, agent_name)
            self.assertEqual(tr.status, "SUCCESS")
            self.assertEqual(tr.session_id, session_id)
            self.assertEqual(tr.total_tokens, 150)

            # Verify spans
            spans_res = await session.execute(select(Span).where(Span.trace_id == trace_id))
            spans_by_id = {s.id: s for s in spans_res.scalars().all()}
            self.assertIn(step_span_id, spans_by_id)
            self.assertIn(tool_span_id, spans_by_id)

            # Verify parent-child relationship
            child = spans_by_id[tool_span_id]
            self.assertEqual(child.parent_span_id, step_span_id)
            self.assertEqual(child.status, "OK")
            self.assertIsNotNone(child.input_hash)
            self.assertEqual(child.output_payload, {"status": "found", "count": 12})

            # Verify event
            evt_res = await session.execute(select(Event).where(Event.span_id == step_span_id))
            event = evt_res.scalar_one_or_none()
            self.assertIsNotNone(event)
            self.assertEqual(event.name, "model_selected")

    async def test_end_to_end_failure_detection(self):
        """Verifies an agent exception is captured by SDK and triggers deterministic failure findings in DB."""
        agent_name = "FailingWorkflowAgent"

        try:
            with self.client.trace(agent_name=agent_name) as trace:
                fail_trace_id = trace.id
                with trace.span(name="failing_tool", span_type="TOOL_CALL") as tool:
                    tool_id = tool.id
                    raise ConnectionResetError("Connection abruptly terminated by peer")
        except ConnectionResetError:
            pass  # Expected exception propagated to caller

        # Flush SDK queue
        self.client.flush(timeout=3.0)
        await asyncio.sleep(0.5)

        # Verify in PostgreSQL
        async with self.session_maker() as session:
            tr = (await session.execute(select(Trace).where(Trace.id == fail_trace_id))).scalar_one_or_none()
            self.assertIsNotNone(tr)
            self.assertEqual(tr.status, "ERROR")
            self.assertTrue(tr.has_failures)

            sp = (await session.execute(select(Span).where(Span.id == tool_id))).scalar_one_or_none()
            self.assertIsNotNone(sp)
            self.assertEqual(sp.status, "ERROR")
            self.assertEqual(sp.error_type, "ConnectionResetError")
            self.assertIn("Connection abruptly terminated by peer", sp.error_message)

            # Verify FailureFinding was generated and persisted
            finding_res = await session.execute(
                select(FailureFinding).where(FailureFinding.trace_id == fail_trace_id)
            )
            finding = finding_res.scalar_one_or_none()
            self.assertIsNotNone(finding, "Expected deterministic failure finding was not created")
            self.assertEqual(finding.rule_type, "FAILED_SPAN")

            # Verify FindingEvidenceLink was created
            link_res = await session.execute(
                select(FindingEvidenceLink).where(FindingEvidenceLink.finding_id == finding.id)
            )
            link = link_res.scalar_one_or_none()
            self.assertIsNotNone(link)
            self.assertEqual(link.span_id, tool_id)


if __name__ == "__main__":
    unittest.main()
