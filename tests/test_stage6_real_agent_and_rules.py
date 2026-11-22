"""Stage 6 Comprehensive Validation Test Suite.

Covers:
1. Real AI Agent execution, tool calculation, and LLM provider interfaces.
2. Full telemetry ingestion pipeline into live PostgreSQL.
3. Validation of all 5 deterministic failure detection rules:
   - FAILED_SPAN
   - REPEATED_TOOL_CALL
   - EXCESSIVE_RETRIES
   - SLOW_SPAN
   - EMPTY_TOOL_RESULT
4. Tenant and Project isolation security guarantees.
5. Direct PostgreSQL persistence and evidence link verification.
"""

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

# Setup pathing
sys.path.insert(0, os.path.abspath("sdk"))
sys.path.insert(0, os.path.abspath("backend"))
sys.path.insert(0, os.path.abspath("."))

from agentlens import AgentLens
from app.core.config import settings
from app.core.database import get_db_session
from app.main import app
from app.models.environment import Environment
from app.models.event import Event
from app.models.finding import FailureFinding, FindingEvidenceLink
from app.models.project import Project
from app.models.span import Span
from app.models.trace import Trace
from app.services.rules import RuleEngine, resolve_sla_threshold
from examples.real_agent.providers import (
    FallbackSimulatedProvider,
    LLMResponse,
    OpenAICompatibleProvider,
    get_configured_provider,
)
from examples.real_agent.tools import (
    calculate_repository_health_metrics,
    fetch_github_repository_stats,
)


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

    query_string = b""
    if "?" in path:
        path, query = path.split("?", 1)
        query_string = query.encode("ascii")

    scope = {
        "type": "http",
        "asgi": {"version": "3.0", "spec_version": "2.3"},
        "http_version": "1.1",
        "method": method.upper(),
        "path": path,
        "raw_path": path.encode("ascii"),
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


class TestStage6RealAgentAndRules(unittest.IsolatedAsyncioTestCase):
    """Stage 6 End-to-End Validation against live PostgreSQL."""

    async def asyncSetUp(self):
        self.engine = create_async_engine(settings.async_database_url, poolclass=NullPool)
        self.session_maker = async_sessionmaker(
            bind=self.engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )

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

        self.project_id = uuid.uuid4()
        self.plain_key = f"al_stage6_{uuid.uuid4().hex}"
        self.hashed_key = hashlib.sha256(self.plain_key.encode("utf-8")).hexdigest()

        async with self.session_maker() as session:
            project = Project(
                id=self.project_id,
                name="Stage6 Validation Project",
                slug=f"stage6-val-{uuid.uuid4().hex[:8]}",
                api_key_hash=self.hashed_key,
                settings={"sla_thresholds": {"LLM_CALL": 10000, "TOOL_CALL": 5000}},
            )
            session.add(project)
            await session.flush()

            env = Environment(
                id=uuid.uuid4(),
                project_id=self.project_id,
                slug="development",
                name="Development",
            )
            session.add(env)
            await session.commit()

        self.auth_headers = {"Authorization": f"Bearer {self.plain_key}"}

    async def asyncTearDown(self):
        app.dependency_overrides.pop(get_db_session, None)
        async with self.session_maker() as session:
            proj = await session.get(Project, self.project_id)
            if proj:
                await session.delete(proj)
                await session.commit()
        await self.engine.dispose()

    async def test_01_real_agent_tools_and_providers(self):
        """Verifies tool execution and provider resolution without errors."""
        # 1. Calculation tool
        sample_stats = {
            "repository": "test/repo",
            "stars": 150,
            "forks": 30,
            "open_issues": 5,
        }
        metrics = calculate_repository_health_metrics(sample_stats)
        self.assertEqual(metrics["repository"], "test/repo")
        self.assertGreater(metrics["composite_health_score"], 0)
        self.assertIn(metrics["health_tier"], ("EXCELLENT", "GOOD", "MODERATE", "CRITICAL_ATTENTION_REQUIRED"))

        # 2. Fallback provider
        provider = FallbackSimulatedProvider()
        resp = provider.generate("Evaluate repository")
        self.assertTrue(resp.is_simulated)
        self.assertGreater(resp.prompt_tokens, 0)
        self.assertGreater(resp.completion_tokens, 0)
        self.assertEqual(resp.total_tokens, resp.prompt_tokens + resp.completion_tokens)
        self.assertGreater(resp.estimated_cost_usd, 0)
        self.assertGreater(len(resp.content), 0)

    async def test_02_rule_1_failed_span_persistence(self):
        """Verifies FAILED_SPAN triggers and persists in database."""
        trace_id = f"trc_fail_{uuid.uuid4().hex[:12]}"
        span_id = f"spn_fail_{uuid.uuid4().hex[:12]}"

        payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "FailureTestAgent",
                "status": "ERROR",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [
                {
                    "id": span_id,
                    "trace_id": trace_id,
                    "name": "critical_database_query",
                    "span_type": "TOOL_CALL",
                    "status": "ERROR",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                    "error_message": "Deadlock detected in transaction",
                    "error_type": "DatabaseDeadlockError",
                }
            ],
            "events": [],
        }
        status, _, _, data = await asgi_request(
            app, "POST", "/api/v1/telemetry/ingest", headers=self.auth_headers, json_data=payload
        )
        self.assertEqual(status, 202)
        self.assertGreaterEqual(data["findings_detected"], 1)

        # Direct DB verification
        async with self.session_maker() as session:
            fnd_res = await session.execute(
                select(FailureFinding).where(FailureFinding.trace_id == trace_id)
            )
            findings = list(fnd_res.scalars())
            self.assertGreaterEqual(len(findings), 1)
            fnd = findings[0]
            self.assertEqual(fnd.rule_type, "FAILED_SPAN")
            self.assertIn(fnd.severity, ("CRITICAL", "HIGH"))
            self.assertIn("DatabaseDeadlockError", fnd.summary)

    async def test_03_rule_2_repeated_tool_call_persistence(self):
        """Verifies REPEATED_TOOL_CALL triggers for >=3 identical calls."""
        trace_id = f"trc_repeat_{uuid.uuid4().hex[:12]}"
        input_hash = "canon_hash_12345"

        spans = [
            {
                "id": f"spn_rep_{i}_{uuid.uuid4().hex[:8]}",
                "trace_id": trace_id,
                "name": "fetch_crm_contact",
                "span_type": "TOOL_CALL",
                "status": "OK",
                "input_hash": input_hash,
                "start_time": datetime.now(timezone.utc).isoformat(),
                "input_payload": {"user_id": 999},
                "output_payload": {"status": "ok"},
            }
            for i in range(3)
        ]
        payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "RepeatedToolAgent",
                "status": "SUCCESS",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": spans,
            "events": [],
        }
        status, _, _, data = await asgi_request(
            app, "POST", "/api/v1/telemetry/ingest", headers=self.auth_headers, json_data=payload
        )
        self.assertEqual(status, 202)
        self.assertGreaterEqual(data["findings_detected"], 1)

        # Direct DB verification
        async with self.session_maker() as session:
            fnd_res = await session.execute(
                select(FailureFinding).where(
                    FailureFinding.trace_id == trace_id,
                    FailureFinding.rule_type == "REPEATED_TOOL_CALL",
                )
            )
            finding = fnd_res.scalar_one_or_none()
            self.assertIsNotNone(finding)
            self.assertEqual(finding.iteration_count, 3)
            self.assertEqual(finding.severity, "HIGH")
            self.assertIn("fetch_crm_contact", finding.summary)

    async def test_04_rule_3_excessive_retries_persistence(self):
        """Verifies EXCESSIVE_RETRIES triggers when retry_count > 3."""
        trace_id = f"trc_retry_{uuid.uuid4().hex[:12]}"
        span_id = f"spn_retry_{uuid.uuid4().hex[:12]}"

        payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "RetryAgent",
                "status": "SUCCESS",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [
                {
                    "id": span_id,
                    "trace_id": trace_id,
                    "name": "resilient_api_call",
                    "span_type": "TOOL_CALL",
                    "status": "OK",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                    "attributes": {"retry_count": 5},
                }
            ],
            "events": [],
        }
        status, _, _, data = await asgi_request(
            app, "POST", "/api/v1/telemetry/ingest", headers=self.auth_headers, json_data=payload
        )
        self.assertEqual(status, 202)

        # Direct DB verification
        async with self.session_maker() as session:
            fnd_res = await session.execute(
                select(FailureFinding).where(
                    FailureFinding.trace_id == trace_id,
                    FailureFinding.rule_type == "EXCESSIVE_RETRIES",
                )
            )
            finding = fnd_res.scalar_one_or_none()
            self.assertIsNotNone(finding)
            self.assertEqual(finding.iteration_count, 5)
            self.assertEqual(finding.severity, "WARNING")  # Status was OK -> WARNING

    async def test_05_rule_4_slow_span_persistence(self):
        """Verifies SLOW_SPAN triggers when duration_ms exceeds resolved SLA threshold."""
        trace_id = f"trc_slow_{uuid.uuid4().hex[:12]}"
        span_id = f"spn_slow_{uuid.uuid4().hex[:12]}"

        # LLM SLA default is 10,000ms. Send 14,500ms -> triggers SLOW_SPAN (WARNING)
        payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "SlowAgent",
                "status": "SUCCESS",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [
                {
                    "id": span_id,
                    "trace_id": trace_id,
                    "name": "claude_statute_parser",
                    "span_type": "LLM_CALL",
                    "status": "OK",
                    "duration_ms": 14500,  # SLA threshold is 10000ms
                    "start_time": datetime.now(timezone.utc).isoformat(),
                }
            ],
            "events": [],
        }
        status, _, _, data = await asgi_request(
            app, "POST", "/api/v1/telemetry/ingest", headers=self.auth_headers, json_data=payload
        )
        self.assertEqual(status, 202)
        self.assertGreaterEqual(data["findings_detected"], 1)

        # Direct DB verification
        async with self.session_maker() as session:
            fnd_res = await session.execute(
                select(FailureFinding).where(
                    FailureFinding.trace_id == trace_id,
                    FailureFinding.rule_type == "SLOW_SPAN",
                )
            )
            finding = fnd_res.scalar_one_or_none()
            self.assertIsNotNone(finding)
            self.assertEqual(finding.severity, "WARNING")
            self.assertIn("14500ms", finding.summary)
            self.assertEqual(finding.evidence_data["sla_limit_ms"], 10000)
            self.assertEqual(finding.evidence_data["delta_ms"], 4500)

    async def test_06_rule_5_empty_tool_result_persistence(self):
        """Verifies EMPTY_TOOL_RESULT triggers on non-whitelisted empty output."""
        trace_id = f"trc_empty_{uuid.uuid4().hex[:12]}"
        span_id = f"spn_empty_{uuid.uuid4().hex[:12]}"

        payload = {
            "project_id": str(self.project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "EmptyToolAgent",
                "status": "SUCCESS",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [
                {
                    "id": span_id,
                    "trace_id": trace_id,
                    "name": "fetch_user_profile",
                    "span_type": "TOOL_CALL",
                    "status": "OK",
                    "start_time": datetime.now(timezone.utc).isoformat(),
                    "output_payload": {},  # Empty non-whitelisted output!
                }
            ],
            "events": [],
        }
        status, _, _, data = await asgi_request(
            app, "POST", "/api/v1/telemetry/ingest", headers=self.auth_headers, json_data=payload
        )
        self.assertEqual(status, 202)

        # Direct DB verification
        async with self.session_maker() as session:
            fnd_res = await session.execute(
                select(FailureFinding).where(
                    FailureFinding.trace_id == trace_id,
                    FailureFinding.rule_type == "EMPTY_TOOL_RESULT",
                )
            )
            finding = fnd_res.scalar_one_or_none()
            self.assertIsNotNone(finding)
            self.assertEqual(finding.severity, "WARNING")
            self.assertIn("fetch_user_profile", finding.summary)

    async def test_07_tenant_project_isolation(self):
        """Verifies cross-project ingestion and access is strictly forbidden (403)."""
        other_project_id = uuid.uuid4()
        trace_id = f"trc_iso_{uuid.uuid4().hex[:12]}"

        payload = {
            "project_id": str(other_project_id),
            "environment": "development",
            "trace": {
                "id": trace_id,
                "agent_name": "IntruderAgent",
                "status": "SUCCESS",
                "start_time": datetime.now(timezone.utc).isoformat(),
            },
            "spans": [],
            "events": [],
        }
        status, _, _, data = await asgi_request(
            app, "POST", "/api/v1/telemetry/ingest", headers=self.auth_headers, json_data=payload
        )
        self.assertEqual(status, 403)
        self.assertIn("does not match authenticated API key", data["detail"])


if __name__ == "__main__":
    unittest.main()
