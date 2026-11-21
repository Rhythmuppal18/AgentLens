import asyncio
from datetime import datetime, timezone
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
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "sdk")))

from app.core.config import settings
from app.core.database import get_db_session
from app.main import app
from app.models.environment import Environment
from app.models.finding import FailureFinding
from app.models.project import Project
from app.models.span import Span
from app.models.trace import Trace

from agentlens import AgentLens


async def asgi_request(
    app,
    method: str,
    path: str,
    headers: dict[str, str] | None = None,
    json_data: dict | None = None,
    body_bytes: bytes | None = None,
) -> tuple[int, dict[str, str], bytes, dict | None]:
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

    if "?" in path:
        req_path, qs = path.split("?", 1)
        query_string = qs.encode("ascii")
    else:
        req_path = path
        query_string = b""

    scope = {
        "type": "http",
        "asgi": {"version": "3.0", "spec_version": "2.3"},
        "http_version": "1.1",
        "method": method.upper(),
        "path": req_path,
        "raw_path": req_path.encode("ascii"),
        "query_string": query_string,
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


class TestEndToEndDashboardFlow(unittest.IsolatedAsyncioTestCase):
    """End-to-end integration test: SDK -> Ingestion API -> PostgreSQL -> Rules Engine -> Dashboard APIs."""

    async def asyncSetUp(self):
        self.engine = create_async_engine(settings.async_database_url, poolclass=NullPool)
        self.session_factory = async_sessionmaker(self.engine, expire_on_commit=False, class_=AsyncSession)
        self.test_suffix = uuid.uuid4().hex[:8]

        async def override_get_db():
            async with self.session_factory() as session:
                try:
                    yield session
                except Exception:
                    await session.rollback()
                    raise
                finally:
                    await session.close()

        app.dependency_overrides[get_db_session] = override_get_db

    async def asyncTearDown(self):
        app.dependency_overrides.clear()
        async with self.session_factory() as session:
            await session.execute(
                delete(Project).where(Project.name.like(f"%{self.test_suffix}%"))
            )
            await session.commit()
        await self.engine.dispose()

    async def test_full_pipeline_flow(self):
        """Exercises complete pipeline: Project -> Ingest -> Failure Detection -> Dashboard APIs."""
        # 1. Create a Project via Dashboard API
        proj_name = f"Flight Recorder E2E {self.test_suffix}"
        code, _, _, proj = await asgi_request(
            app,
            "POST",
            "/api/v1/projects",
            json_data={"name": proj_name},
        )
        self.assertEqual(code, 201)
        proj_id = proj["id"]
        api_key = proj["api_key"]
        self.assertTrue(api_key.startswith("al_live_"))

        # 2. Ingest telemetry batch with a failure condition (Tool Call timeout / error)
        trace_id = f"trc_e2e_{self.test_suffix}"
        span_root_id = f"spn_e2e_root_{self.test_suffix}"
        span_tool_id = f"spn_e2e_tool_{self.test_suffix}"
        now = datetime.now(timezone.utc).isoformat()

        batch_payload = {
            "project_id": proj_id,
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "AutonomousFinancialAuditor",
                "status": "FAILED",
                "start_time": now,
                "duration_ms": 3200,
                "total_tokens": 1250,
                "estimated_cost_usd": 0.035,
                "root_span_name": "audit_filings",
            },
            "spans": [
                {
                    "id": span_root_id,
                    "trace_id": trace_id,
                    "name": "audit_filings",
                    "span_type": "AGENT_STEP",
                    "status": "ERROR",
                    "start_time": now,
                    "duration_ms": 3200,
                    "error_message": "Child tool call failed with 504 Gateway Timeout",
                },
                {
                    "id": span_tool_id,
                    "trace_id": trace_id,
                    "parent_span_id": span_root_id,
                    "name": "sec_filing_fetcher",
                    "span_type": "TOOL_CALL",
                    "status": "ERROR",
                    "start_time": now,
                    "duration_ms": 1100,
                    "input_payload": {"ticker": "NVDA", "form": "10-K"},
                    "error_message": "504 Gateway Timeout",
                    "attributes": {"tool_name": "sec_filing_fetcher"},
                },
            ],
            "events": [
                {
                    "id": f"evt_e2e_{self.test_suffix}",
                    "span_id": span_tool_id,
                    "trace_id": trace_id,
                    "name": "network_retry",
                    "timestamp": now,
                    "data": {"attempt": 1, "status": 504},
                }
            ],
        }

        # Submit to Ingestion API
        ingest_code, _, _, ingest_res = await asgi_request(
            app,
            "POST",
            "/api/v1/telemetry/ingest",
            headers={"Authorization": f"Bearer {api_key}"},
            json_data=batch_payload,
        )
        self.assertEqual(ingest_code, 202)
        self.assertEqual(ingest_res["status"], "accepted")
        self.assertEqual(ingest_res["trace_id"], trace_id)
        self.assertEqual(ingest_res["spans_upserted"], 2)

        # 3. Verify PostgreSQL Storage & Failure Detection
        async with self.session_factory() as session:
            # Verify Trace
            db_trace = await session.get(Trace, trace_id)
            self.assertIsNotNone(db_trace)
            self.assertEqual(db_trace.agent_name, "AutonomousFinancialAuditor")
            self.assertTrue(db_trace.has_failures)

            # Verify Spans
            db_spans_res = await session.execute(select(Span).where(Span.trace_id == trace_id))
            db_spans = db_spans_res.scalars().all()
            self.assertEqual(len(db_spans), 2)

            # Verify FailureFinding was generated by Rules Engine
            findings_res = await session.execute(
                select(FailureFinding).where(FailureFinding.trace_id == trace_id)
            )
            findings = findings_res.scalars().all()
            self.assertGreaterEqual(len(findings), 1)
            failed_span_finding = next((f for f in findings if f.rule_type == "FAILED_SPAN"), None)
            self.assertIsNotNone(failed_span_finding)
            self.assertEqual(failed_span_finding.severity, "CRITICAL")

        # 4. Verify Dashboard APIs return the new telemetry and findings
        # 4a. Overview
        code, _, _, overview = await asgi_request(
            app,
            "GET",
            f"/api/v1/analytics/overview?project_id={proj_id}&environment=development",
        )
        self.assertEqual(code, 200)
        self.assertEqual(overview["total_executions"], 1)
        self.assertEqual(overview["failed_executions"], 1)
        self.assertEqual(overview["error_rate"], 100.0)
        self.assertFalse(overview["is_telemetry_standby"])

        # 4b. Traces Explorer
        code, _, _, traces_list = await asgi_request(
            app,
            "GET",
            f"/api/v1/traces?project_id={proj_id}&environment=development",
        )
        self.assertEqual(code, 200)
        self.assertEqual(traces_list["total"], 1)
        self.assertEqual(traces_list["items"][0]["id"], trace_id)

        # 4c. Trace Detail Tree
        code, _, _, trace_tree = await asgi_request(app, "GET", f"/api/v1/traces/{trace_id}")
        self.assertEqual(code, 200)
        self.assertEqual(len(trace_tree["spans"]), 1)
        root = trace_tree["spans"][0]
        self.assertEqual(root["id"], span_root_id)
        self.assertEqual(len(root["children"]), 1)
        self.assertEqual(root["children"][0]["id"], span_tool_id)

        # 4d. Failures List
        code, _, _, failures_list = await asgi_request(
            app,
            "GET",
            f"/api/v1/failures?project_id={proj_id}&environment=development",
        )
        self.assertEqual(code, 200)
        self.assertGreaterEqual(failures_list["total"], 1)
        self.assertEqual(failures_list["items"][0]["trace_id"], trace_id)

        # 4e. Rules Analytics
        code, _, _, rules_metrics = await asgi_request(
            app,
            "GET",
            f"/api/v1/analytics/rules?project_id={proj_id}&environment=development",
        )
        self.assertEqual(code, 200)
        failed_rule = next((r for r in rules_metrics["rules"] if r["rule_type"] == "FAILED_SPAN"), None)
        self.assertIsNotNone(failed_rule)
        self.assertGreaterEqual(failed_rule["violations_count"], 1)


if __name__ == "__main__":
    unittest.main()
