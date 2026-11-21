import asyncio
from datetime import datetime, timezone
from decimal import Decimal
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
    """Pure in-process ASGI 3.0 request helper."""
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


class TestDashboardAPI(unittest.IsolatedAsyncioTestCase):
    """Integration test suite for Dashboard & Observability APIs."""

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
        # Clean up any test records created with test_suffix
        async with self.session_factory() as session:
            # Delete projects created with test_suffix (cascades to envs, traces, spans, findings)
            await session.execute(
                delete(Project).where(Project.name.like(f"%{self.test_suffix}%"))
            )
            await session.commit()
        await self.engine.dispose()

    async def test_projects_crud_and_api_key(self):
        """Tests project creation, listing, detail, patch, and API key regeneration."""
        proj_name = f"Test Project {self.test_suffix}"

        # 1. POST /api/v1/projects
        code, _, _, body = await asgi_request(
            app,
            "POST",
            "/api/v1/projects",
            json_data={"name": proj_name},
        )
        self.assertEqual(code, 201)
        self.assertIn("id", body)
        self.assertIn("api_key", body)
        self.assertTrue(body["api_key"].startswith("al_live_"))
        proj_id = body["id"]

        # 2. Verify default environments were provisioned
        async with self.session_factory() as session:
            envs_res = await session.execute(
                select(Environment).where(Environment.project_id == uuid.UUID(proj_id))
            )
            envs = envs_res.scalars().all()
            env_slugs = {e.slug for e in envs}
            self.assertIn("development", env_slugs)
            self.assertIn("production", env_slugs)

        # 3. GET /api/v1/projects
        code, _, _, list_body = await asgi_request(app, "GET", "/api/v1/projects")
        self.assertEqual(code, 200)
        found = any(p["id"] == proj_id for p in list_body)
        self.assertTrue(found)

        # 4. GET /api/v1/projects/{id}
        code, _, _, detail_body = await asgi_request(app, "GET", f"/api/v1/projects/{proj_id}")
        self.assertEqual(code, 200)
        self.assertEqual(detail_body["name"], proj_name)

        # 5. PATCH /api/v1/projects/{id}
        updated_name = f"Renamed Project {self.test_suffix}"
        code, _, _, patch_body = await asgi_request(
            app,
            "PATCH",
            f"/api/v1/projects/{proj_id}",
            json_data={"name": updated_name},
        )
        self.assertEqual(code, 200)
        self.assertEqual(patch_body["name"], updated_name)

        # 6. POST /api/v1/projects/{id}/api-key (Regenerate)
        code, _, _, key_body = await asgi_request(
            app,
            "POST",
            f"/api/v1/projects/{proj_id}/api-key",
        )
        self.assertEqual(code, 200)
        self.assertIn("api_key", key_body)
        self.assertTrue(key_body["api_key"].startswith("al_live_"))

    async def test_environments_api(self):
        """Tests environment listing and custom on-demand environment creation."""
        proj_name = f"Env Test Proj {self.test_suffix}"
        code, _, _, body = await asgi_request(
            app,
            "POST",
            "/api/v1/projects",
            json_data={"name": proj_name},
        )
        self.assertEqual(code, 201)
        proj_id = body["id"]

        # 1. GET /api/v1/environments?project_id=...
        code, _, _, envs = await asgi_request(app, "GET", f"/api/v1/environments?project_id={proj_id}")
        self.assertEqual(code, 200)
        self.assertGreaterEqual(len(envs), 2)

        # 2. POST /api/v1/environments
        code, _, _, new_env = await asgi_request(
            app,
            "POST",
            "/api/v1/environments",
            json_data={"project_id": proj_id, "name": "Staging Sandbox"},
        )
        self.assertEqual(code, 201)
        self.assertEqual(new_env["name"], "Staging Sandbox")
        self.assertEqual(new_env["slug"], "staging-sandbox")

    async def test_traces_and_spans_api(self):
        """Tests listing traces with filters, trace detail tree, spans, and span events."""
        proj_name = f"Traces Test Proj {self.test_suffix}"
        code, _, _, proj = await asgi_request(
            app,
            "POST",
            "/api/v1/projects",
            json_data={"name": proj_name},
        )
        self.assertEqual(code, 201)
        proj_id = uuid.UUID(proj["id"])

        # Fetch dev env
        async with self.session_factory() as session:
            env_res = await session.execute(
                select(Environment).where(Environment.project_id == proj_id, Environment.slug == "development")
            )
            env = env_res.scalar_one()
            env_id = env.id

            # Seed a trace with root span and child span
            trace_id = f"trc_test_{self.test_suffix}"
            now = datetime.now(timezone.utc)
            trace = Trace(
                id=trace_id,
                project_id=proj_id,
                environment_id=env_id,
                agent_name="financial_analyst_agent",
                status="FAILED",
                start_time=now,
                duration_ms=4500,
                total_tokens=1500,
                estimated_cost_usd=Decimal("0.045"),
                root_span_name="run_audit",
                span_count=2,
                has_failures=True,
            )
            session.add(trace)
            await session.flush()

            span_root_id = f"spn_root_{self.test_suffix}"
            span_root = Span(
                id=span_root_id,
                trace_id=trace_id,
                name="run_audit",
                span_type="AGENT_STEP",
                status="ERROR",
                start_time=now,
                duration_ms=4500,
                input_payload={"query": "analyze earnings"},
                output_payload=None,
                error_message="Tool loop exception",
                attributes={"model": "claude-3-opus"},
            )
            session.add(span_root)
            await session.flush()

            span_child_id = f"spn_child_{self.test_suffix}"
            span_child = Span(
                id=span_child_id,
                trace_id=trace_id,
                parent_span_id=span_root_id,
                name="fetch_edgar_filing",
                span_type="TOOL_CALL",
                status="OK",
                start_time=now,
                duration_ms=800,
                input_payload={"ticker": "AAPL"},
                output_payload={"filing": "10-K"},
                attributes={"tool_name": "edgar_api"},
            )
            session.add(span_child)
            await session.flush()

            event = Event(
                id=f"evt_{self.test_suffix}",
                span_id=span_child_id,
                trace_id=trace_id,
                name="api_handshake",
                timestamp=now,
                data={"status": 200},
            )
            session.add(event)
            await session.commit()

        # 1. GET /api/v1/traces (with filters)
        code, _, _, traces_res = await asgi_request(
            app,
            "GET",
            f"/api/v1/traces?project_id={proj_id}&environment=development&status=FAILED&has_failures=true",
        )
        self.assertEqual(code, 200)
        self.assertEqual(traces_res["total"], 1)
        self.assertEqual(traces_res["items"][0]["id"], trace_id)

        # 2. GET /api/v1/traces/{trace_id} (Hierarchical span tree)
        code, _, _, trace_detail = await asgi_request(app, "GET", f"/api/v1/traces/{trace_id}")
        self.assertEqual(code, 200)
        self.assertEqual(trace_detail["id"], trace_id)
        self.assertEqual(len(trace_detail["spans"]), 1)  # 1 root node
        root_node = trace_detail["spans"][0]
        self.assertEqual(root_node["id"], span_root_id)
        self.assertEqual(len(root_node["children"]), 1)  # 1 child node
        self.assertEqual(root_node["children"][0]["id"], span_child_id)

        # 3. GET /api/v1/traces/{trace_id}/spans
        code, _, _, flat_spans = await asgi_request(app, "GET", f"/api/v1/traces/{trace_id}/spans")
        self.assertEqual(code, 200)
        self.assertEqual(len(flat_spans), 2)

        # 4. GET /api/v1/spans/{span_id}
        code, _, _, span_res = await asgi_request(app, "GET", f"/api/v1/spans/{span_child_id}")
        self.assertEqual(code, 200)
        self.assertEqual(span_res["name"], "fetch_edgar_filing")
        self.assertEqual(len(span_res["events"]), 1)
        self.assertEqual(span_res["events"][0]["name"], "api_handshake")

        # 5. GET /api/v1/spans/{span_id}/events
        code, _, _, events_res = await asgi_request(app, "GET", f"/api/v1/spans/{span_child_id}/events")
        self.assertEqual(code, 200)
        self.assertEqual(len(events_res), 1)

    async def test_failure_findings_and_analytics_api(self):
        """Tests failure findings list and detail, along with analytics overview, activity, and rules."""
        proj_name = f"Analytics Test Proj {self.test_suffix}"
        code, _, _, proj = await asgi_request(
            app,
            "POST",
            "/api/v1/projects",
            json_data={"name": proj_name},
        )
        self.assertEqual(code, 201)
        proj_id = uuid.UUID(proj["id"])

        async with self.session_factory() as session:
            env_res = await session.execute(
                select(Environment).where(Environment.project_id == proj_id, Environment.slug == "development")
            )
            env = env_res.scalar_one()
            env_id = env.id

            trace_id = f"trc_fail_{self.test_suffix}"
            now = datetime.now(timezone.utc)
            trace = Trace(
                id=trace_id,
                project_id=proj_id,
                environment_id=env_id,
                agent_name="autonomous_search_agent",
                status="FAILED",
                start_time=now,
                duration_ms=6200,
                total_tokens=2200,
                estimated_cost_usd=Decimal("0.088"),
                root_span_name="search_query",
                span_count=1,
                has_failures=True,
            )
            session.add(trace)
            await session.flush()

            span_id = f"spn_fail_{self.test_suffix}"
            span = Span(
                id=span_id,
                trace_id=trace_id,
                name="execute_search",
                span_type="TOOL_CALL",
                status="ERROR",
                start_time=now,
                duration_ms=6200,
                input_payload={"q": "market news"},
                output_payload=None,
                error_message="Gateway timeout",
                attributes={"tool_name": "web_search"},
            )
            session.add(span)
            await session.flush()

            finding_id = f"fnd_{self.test_suffix}"
            fingerprint = FailureFinding.generate_fingerprint("FAILED_SPAN", trace_id, span_id)
            finding = FailureFinding(
                id=finding_id,
                finding_fingerprint=fingerprint,
                trace_id=trace_id,
                span_id=span_id,
                rule_type="FAILED_SPAN",
                severity="CRITICAL",
                summary="Failed span detected",
                evidence_summary="Span terminated with status ERROR: Gateway timeout",
                evidence_data={"error_message": "Gateway timeout", "status": "ERROR"},
                first_detected_at=now,
            )
            session.add(finding)
            await session.flush()

            evidence_hash = FindingEvidenceLink.generate_evidence_hash(
                finding_id=finding_id,
                span_id=span_id,
                role="primary_culprit",
            )
            evidence_link = FindingEvidenceLink(
                finding_id=finding_id,
                span_id=span_id,
                event_id=None,
                role="primary_culprit",
                evidence_hash=evidence_hash,
            )
            session.add(evidence_link)
            await session.commit()

        # 1. GET /api/v1/failures
        code, _, _, failures_res = await asgi_request(
            app,
            "GET",
            f"/api/v1/failures?project_id={proj_id}&environment=development&severity=CRITICAL",
        )
        self.assertEqual(code, 200)
        self.assertEqual(failures_res["total"], 1)
        self.assertEqual(failures_res["items"][0]["span_name"], "execute_search")

        # 2. GET /api/v1/failures/{id}
        code, _, _, finding_detail = await asgi_request(app, "GET", f"/api/v1/failures/{finding_id}")
        self.assertEqual(code, 200)
        self.assertEqual(finding_detail["rule_type"], "FAILED_SPAN")
        self.assertIn("evidence_links", finding_detail)
        self.assertEqual(len(finding_detail["evidence_links"]), 1)

        # 3. GET /api/v1/analytics/overview
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
        self.assertEqual(overview["total_tokens"], 2200)

        # 4. GET /api/v1/analytics/activity
        code, _, _, activity = await asgi_request(
            app,
            "GET",
            f"/api/v1/analytics/activity?project_id={proj_id}&environment=development",
        )
        self.assertEqual(code, 200)
        self.assertIn("data_points", activity)
        self.assertGreaterEqual(len(activity["data_points"]), 1)

        # 5. GET /api/v1/analytics/rules
        code, _, _, rules_res = await asgi_request(
            app,
            "GET",
            f"/api/v1/analytics/rules?project_id={proj_id}&environment=development",
        )
        self.assertEqual(code, 200)
        self.assertIn("rules", rules_res)
        failed_span_rule = next((r for r in rules_res["rules"] if r["rule_type"] == "FAILED_SPAN"), None)
        self.assertIsNotNone(failed_span_rule)
        self.assertEqual(failed_span_rule["violations_count"], 1)

        # 6. GET /api/v1/analytics/performance
        code, _, _, perf = await asgi_request(
            app,
            "GET",
            f"/api/v1/analytics/performance?project_id={proj_id}&environment=development",
        )
        self.assertEqual(code, 200)
        self.assertIn("agents", perf)
        self.assertIn("tools", perf)
        self.assertEqual(len(perf["agents"]), 1)
        self.assertEqual(perf["agents"][0]["agent_name"], "autonomous_search_agent")


if __name__ == "__main__":
    unittest.main()
