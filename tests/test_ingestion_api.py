import asyncio
from datetime import datetime, timezone
import gzip
import hashlib
import json
import os
import sys
import unittest
import uuid

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from app.core.config import settings
from app.core.database import get_db_session
from app.main import app
from app.models.environment import Environment
from app.models.event import Event
from app.models.finding import FailureFinding, FindingEvidenceLink
from app.models.project import Project
from app.models.span import Span
from app.models.trace import Trace


async def asgi_request(
    app,
    method: str,
    path: str,
    headers: dict[str, str] | None = None,
    json_data: dict | None = None,
    body_bytes: bytes | None = None,
) -> tuple[int, dict[str, str], bytes, dict | None]:
    """Pure in-process ASGI 3.0 request helper avoiding external HTTP dependencies."""
    req_headers = dict(headers or {})

    if json_data is not None:
        content = json.dumps(json_data).encode("utf-8")
        if "content-type" not in [k.lower() for k in req_headers]:
            req_headers["Content-Type"] = "application/json"
    elif body_bytes is not None:
        content = body_bytes
    else:
        content = b""

    if "content-length" not in [k.lower() for k in req_headers]:
        req_headers["Content-Length"] = str(len(content))

    raw_headers = [
        (k.lower().encode("latin1"), v.encode("latin1"))
        for k, v in req_headers.items()
    ]

    sent_messages = []
    disconnect_event = asyncio.Event()

    async def send(message):
        sent_messages.append(message)
        if message["type"] == "http.response.body" and not message.get("more_body", False):
            disconnect_event.set()

    sent_body = False

    async def receive():
        nonlocal sent_body
        if not sent_body:
            sent_body = True
            return {"type": "http.request", "body": content, "more_body": False}
        await disconnect_event.wait()
        return {"type": "http.disconnect"}

    scope = {
        "type": "http",
        "asgi": {"version": "3.0", "spec_version": "2.3"},
        "http_version": "1.1",
        "method": method.upper(),
        "path": path,
        "raw_path": path.encode("ascii"),
        "query_string": b"",
        "headers": raw_headers,
        "client": ("127.0.0.1", 12345),
        "server": ("127.0.0.1", 80),
    }

    await app(scope, receive, send)

    status_code = 500
    res_headers = {}
    res_body = b""

    for msg in sent_messages:
        if msg["type"] == "http.response.start":
            status_code = msg["status"]
            res_headers = {k.decode("latin1"): v.decode("latin1") for k, v in msg.get("headers", [])}
        elif msg["type"] == "http.response.body":
            res_body += msg.get("body", b"")

    parsed_json = None
    try:
        if res_body:
            parsed_json = json.loads(res_body.decode("utf-8"))
    except Exception:
        pass

    return status_code, res_headers, res_body, parsed_json


class TestTelemetryIngestionAPI(unittest.IsolatedAsyncioTestCase):
    """Integration test suite for Telemetry Ingestion API with live PostgreSQL database."""

    async def asyncSetUp(self):
        # Configure isolated async engine with NullPool
        self.engine = create_async_engine(settings.async_database_url, poolclass=NullPool)
        self.session_maker = async_sessionmaker(
            bind=self.engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )

        # Override FastAPI get_db_session dependency to use our isolated session
        async def override_get_db():
            async with self.session_maker() as session:
                try:
                    yield session
                except Exception:
                    await session.rollback()
                    raise
                finally:
                    await session.close()

        app.dependency_overrides[get_db_session] = override_get_db

        # Create isolated test project with known API key
        self.test_api_key = f"al_live_test_{uuid.uuid4().hex[:16]}"
        self.test_api_key_hash = hashlib.sha256(self.test_api_key.encode("utf-8")).hexdigest()
        self.project_id = uuid.uuid4()
        self.project_slug = f"proj-test-{uuid.uuid4().hex[:8]}"

        async with self.session_maker() as session:
            project = Project(
                id=self.project_id,
                name="Telemetry Test Project",
                slug=self.project_slug,
                api_key_hash=self.test_api_key_hash,
                is_active=True,
            )
            session.add(project)
            await session.commit()

        self.auth_headers = {"Authorization": f"Bearer {self.test_api_key}"}

    async def asyncTearDown(self):
        app.dependency_overrides.clear()
        # Clean up test project (cascades to environments, traces, spans, findings)
        async with self.session_maker() as session:
            await session.execute(delete(Project).where(Project.id == self.project_id))
            await session.commit()
        await self.engine.dispose()

    async def test_authentication_missing_token(self):
        """Verifies 401 Unauthorized with RFC 7807 when Authorization header is missing."""
        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers={},
            json_data={},
        )
        self.assertEqual(status_code, 401)
        self.assertIsNotNone(body)
        self.assertEqual(body.get("status"), 401)
        self.assertEqual(body.get("title"), "Unauthorized")
        self.assertIn("Missing Authorization header", body.get("detail", ""))

    async def test_authentication_invalid_token(self):
        """Verifies 401 Unauthorized when an invalid or revoked API key is provided."""
        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers={"Authorization": "Bearer al_live_wrong_invalid_key_999"},
            json_data={},
        )
        self.assertEqual(status_code, 401)
        self.assertEqual(body.get("status"), 401)
        self.assertIn("Invalid or revoked API key", body.get("detail", ""))

    async def test_tenant_isolation_project_id_mismatch(self):
        """Verifies 403 Forbidden when request project_id does not match authenticated project."""
        foreign_project_id = str(uuid.uuid4())
        payload = {
            "project_id": foreign_project_id,
            "environment": "development",
            "trace": {
                "id": f"trc_{uuid.uuid4().hex[:12]}",
                "agent_name": "TestAgent",
                "status": "RUNNING",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [],
            "events": [],
        }

        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=self.auth_headers,
            json_data=payload,
        )
        self.assertEqual(status_code, 403)
        self.assertEqual(body.get("title"), "Forbidden")
        self.assertIn("does not match authenticated API key", body.get("detail", ""))

    async def test_rfc_7807_validation_error(self):
        """Verifies 422 Unprocessable Entity returns RFC 7807 Problem Details."""
        # Missing required field 'trace'
        bad_payload = {
            "project_id": str(self.project_id),
            "environment": "development",
        }
        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=self.auth_headers,
            json_data=bad_payload,
        )
        self.assertEqual(status_code, 422)
        self.assertEqual(body.get("title"), "Invalid Telemetry Batch")
        self.assertEqual(body.get("status"), 422)
        self.assertIn("trace", body.get("detail", ""))
        self.assertEqual(body.get("instance"), "/api/v1/telemetry/ingest")

    async def test_gzip_decompression_and_ingestion(self):
        """Verifies gzip-compressed request body is decompressed and ingested successfully."""
        trace_id = f"trc_gzip_{uuid.uuid4().hex[:8]}"
        payload = {
            "project_id": str(self.project_id),
            "environment": "production",
            "trace": {
                "id": trace_id,
                "agent_name": "GzipAgent",
                "status": "SUCCESS",
                "start_time": datetime.now(timezone.utc).isoformat(),
                "duration_ms": 250,
            },
            "spans": [],
            "events": [],
        }

        compressed = gzip.compress(json.dumps(payload).encode("utf-8"))
        headers = {
            **self.auth_headers,
            "Content-Type": "application/json",
            "Content-Encoding": "gzip",
        }

        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=headers,
            body_bytes=compressed,
        )
        self.assertEqual(status_code, 202)
        self.assertEqual(body.get("status"), "accepted")
        self.assertEqual(body.get("trace_id"), trace_id)

    async def test_corrupted_gzip_rejection(self):
        """Verifies 400 Bad Request when gzip body is corrupted."""
        corrupted_bytes = b"\x1f\x8b\x08not-a-valid-gzip-stream"
        headers = {
            **self.auth_headers,
            "Content-Type": "application/json",
            "Content-Encoding": "gzip",
        }

        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=headers,
            body_bytes=corrupted_bytes,
        )
        self.assertEqual(status_code, 400)
        self.assertEqual(body.get("title"), "Malformed Gzip Payload")

    async def test_full_batch_ingest_and_environment_resolution(self):
        """Verifies batch ingestion creates environment, trace, spans, and events."""
        trace_id = f"trc_{uuid.uuid4().hex[:12]}"
        root_span_id = f"spn_root_{uuid.uuid4().hex[:8]}"
        tool_span_id = f"spn_tool_{uuid.uuid4().hex[:8]}"
        event_id = f"evt_{uuid.uuid4().hex[:8]}"

        payload = {
            "project_id": str(self.project_id),
            "environment": "staging",
            "trace": {
                "id": trace_id,
                "agent_name": "PipelineAgent",
                "session_id": "sess_integration",
                "status": "SUCCESS",
                "start_time": datetime.now(timezone.utc).isoformat(),
                "end_time": datetime.now(timezone.utc).isoformat(),
                "duration_ms": 1200,
                "total_tokens": 500,
                "prompt_tokens": 400,
                "completion_tokens": 100,
                "estimated_cost_usd": 0.0015,
                "metadata": {"framework": "crewai"},
            },
            "spans": [
                {
                    "id": root_span_id,
                    "trace_id": trace_id,
                    "parent_span_id": None,
                    "name": "root_execution",
                    "span_type": "AGENT_STEP",
                    "status": "OK",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                    "duration_ms": 1200,
                },
                {
                    "id": tool_span_id,
                    "trace_id": trace_id,
                    "parent_span_id": root_span_id,
                    "name": "fetch_data",
                    "span_type": "TOOL_CALL",
                    "status": "OK",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                    "duration_ms": 300,
                    "input_payload": {"query": "test"},
                    "input_hash": "hash_test_123",
                    "output_payload": {"results": [1, 2, 3]},
                },
            ],
            "events": [
                {
                    "id": event_id,
                    "span_id": root_span_id,
                    "trace_id": trace_id,
                    "name": "milestone_reached",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "data": {"step": 1},
                }
            ],
        }

        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=self.auth_headers,
            json_data=payload,
        )

        self.assertEqual(status_code, 202)
        self.assertEqual(body["status"], "accepted")
        self.assertEqual(body["trace_id"], trace_id)
        self.assertEqual(body["spans_upserted"], 2)
        self.assertEqual(body["events_inserted"], 1)

        # Inspect database directly
        async with self.session_maker() as session:
            # Environment should have been auto-created
            env_res = await session.execute(
                select(Environment).where(
                    Environment.project_id == self.project_id,
                    Environment.slug == "staging",
                )
            )
            env = env_res.scalar_one_or_none()
            self.assertIsNotNone(env)

            # Trace persisted
            tr_res = await session.execute(select(Trace).where(Trace.id == trace_id))
            db_trace = tr_res.scalar_one_or_none()
            self.assertIsNotNone(db_trace)
            self.assertEqual(db_trace.agent_name, "PipelineAgent")
            self.assertEqual(db_trace.status, "SUCCESS")
            self.assertEqual(db_trace.total_tokens, 500)

            # Spans persisted and linked
            spn_res = await session.execute(select(Span).where(Span.trace_id == trace_id))
            db_spans = {s.id: s for s in spn_res.scalars().all()}
            self.assertEqual(len(db_spans), 2)
            self.assertEqual(db_spans[tool_span_id].parent_span_id, root_span_id)

            # Event persisted
            evt_res = await session.execute(select(Event).where(Event.id == event_id))
            db_event = evt_res.scalar_one_or_none()
            self.assertIsNotNone(db_event)
            self.assertEqual(db_event.name, "milestone_reached")

    async def test_out_of_order_parent_child_span_safety(self):
        """Verifies ingestion succeeds without foreign key violation when child span precedes parent in batch."""
        trace_id = f"trc_order_{uuid.uuid4().hex[:8]}"
        parent_id = f"spn_parent_{uuid.uuid4().hex[:8]}"
        child_id = f"spn_child_{uuid.uuid4().hex[:8]}"

        # Notice: child span is FIRST in the list, parent span is SECOND!
        payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "OutOfOrderAgent",
                "status": "RUNNING",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [
                {
                    "id": child_id,
                    "trace_id": trace_id,
                    "parent_span_id": parent_id,  # Points to parent not yet inserted!
                    "name": "child_step",
                    "span_type": "TOOL_CALL",
                    "status": "OK",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                },
                {
                    "id": parent_id,
                    "trace_id": trace_id,
                    "parent_span_id": None,
                    "name": "parent_step",
                    "span_type": "AGENT_STEP",
                    "status": "OK",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                },
            ],
            "events": [],
        }

        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=self.auth_headers,
            json_data=payload,
        )

        self.assertEqual(status_code, 202)
        self.assertEqual(body["spans_upserted"], 2)

        # Verify child span is correctly linked to parent in database
        async with self.session_maker() as session:
            res = await session.execute(select(Span).where(Span.id == child_id))
            child_db = res.scalar_one_or_none()
            self.assertIsNotNone(child_db)
            self.assertEqual(child_db.parent_span_id, parent_id)

    async def test_terminal_status_preservation(self):
        """Verifies an existing terminal trace/span status cannot be overwritten by RUNNING."""
        trace_id = f"trc_term_{uuid.uuid4().hex[:8]}"
        span_id = f"spn_term_{uuid.uuid4().hex[:8]}"

        # Step 1: Ingest batch with terminal status SUCCESS and OK
        initial_payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "TerminalAgent",
                "status": "SUCCESS",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [
                {
                    "id": span_id,
                    "trace_id": trace_id,
                    "name": "completed_span",
                    "span_type": "AGENT_STEP",
                    "status": "OK",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                }
            ],
            "events": [],
        }
        status_code, _, _, _ = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=self.auth_headers,
            json_data=initial_payload,
        )
        self.assertEqual(status_code, 202)

        # Step 2: Delayed packet arrives reporting status=RUNNING
        delayed_payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "TerminalAgent",
                "status": "RUNNING",  # Must be ignored!
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [
                {
                    "id": span_id,
                    "trace_id": trace_id,
                    "name": "completed_span",
                    "span_type": "AGENT_STEP",
                    "status": "RUNNING",  # Must be ignored!
                    "start_time": datetime.now(timezone.utc).isoformat(),
                }
            ],
            "events": [],
        }
        status_code, _, _, _ = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=self.auth_headers,
            json_data=delayed_payload,
        )
        self.assertEqual(status_code, 202)

        # Verify database still has terminal statuses
        async with self.session_maker() as session:
            tr = (await session.execute(select(Trace).where(Trace.id == trace_id))).scalar_one()
            sp = (await session.execute(select(Span).where(Span.id == span_id))).scalar_one()
            self.assertEqual(tr.status, "SUCCESS")
            self.assertEqual(sp.status, "OK")

    async def test_incremental_streaming_spans(self):
        """Verifies POST /api/v1/telemetry/spans increments spans for an active trace."""
        trace_id = f"trc_stream_{uuid.uuid4().hex[:8]}"

        # Step 1: Create running trace
        init_payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "StreamAgent",
                "status": "RUNNING",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [],
            "events": [],
        }
        await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=self.auth_headers,
            json_data=init_payload,
        )

        # Step 2: Stream span incrementally
        streamed_span_id = f"spn_stream_{uuid.uuid4().hex[:8]}"
        spans_payload = {
            "trace_id": trace_id,
            "spans": [
                {
                    "id": streamed_span_id,
                    "trace_id": trace_id,
                    "name": "streamed_tool",
                    "span_type": "TOOL_CALL",
                    "status": "OK",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                    "duration_ms": 400,
                }
            ],
        }

        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/spans",
            headers=self.auth_headers,
            json_data=spans_payload,
        )
        self.assertEqual(status_code, 202)
        self.assertEqual(body.get("spans_processed"), 1)

        # Check in DB
        async with self.session_maker() as session:
            sp = (await session.execute(select(Span).where(Span.id == streamed_span_id))).scalar_one_or_none()
            self.assertIsNotNone(sp)
            self.assertEqual(sp.name, "streamed_tool")

    async def test_failure_finding_detection_and_evidence(self):
        """Verifies deterministic failure rule triggers and persists finding and evidence links."""
        trace_id = f"trc_fail_{uuid.uuid4().hex[:8]}"
        span_id = f"spn_fail_{uuid.uuid4().hex[:8]}"

        payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "FailingAgent",
                "status": "ERROR",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [
                {
                    "id": span_id,
                    "trace_id": trace_id,
                    "name": "database_query",
                    "span_type": "TOOL_CALL",
                    "status": "ERROR",
                    "error_message": "Query execution timed out after 3000ms",
                    "error_type": "TimeoutError",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                    "duration_ms": 3000,
                }
            ],
            "events": [],
        }

        status_code, _, _, body = await asgi_request(
            app=app,
            method="POST",
            path="/api/v1/telemetry/ingest",
            headers=self.auth_headers,
            json_data=payload,
        )
        self.assertEqual(status_code, 202)
        self.assertEqual(body.get("findings_detected"), 1)

        # Check failure_findings and finding_evidence_links in DB
        async with self.session_maker() as session:
            finding_res = await session.execute(
                select(FailureFinding).where(FailureFinding.trace_id == trace_id)
            )
            finding = finding_res.scalar_one_or_none()
            self.assertIsNotNone(finding)
            self.assertEqual(finding.rule_type, "FAILED_SPAN")
            self.assertEqual(finding.severity, "CRITICAL")

            # Check evidence link
            link_res = await session.execute(
                select(FindingEvidenceLink).where(FindingEvidenceLink.finding_id == finding.id)
            )
            link = link_res.scalar_one_or_none()
            self.assertIsNotNone(link)
            self.assertEqual(link.span_id, span_id)
            self.assertEqual(link.role, "failure_origin")


if __name__ == "__main__":
    unittest.main()
