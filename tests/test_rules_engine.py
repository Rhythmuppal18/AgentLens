from datetime import datetime, timezone
import os
import sys
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from app.core.config import settings
from app.models.span import Span
from app.services.rules import RuleEngine, resolve_sla_threshold


class TestDeterministicRulesEngine(unittest.TestCase):
    """Unit tests for the 5 deterministic failure detection rules."""

    def test_rule_1_failed_span(self):
        """Rule 1 flags spans with status ERROR or error_message."""
        root_failed = Span(
            id="spn_root",
            trace_id="trc_01",
            parent_span_id=None,
            name="execute_agent",
            span_type="AGENT_STEP",
            status="ERROR",
            error_message="Unhandled execution failure",
            error_type="RuntimeError",
            start_time=datetime.now(timezone.utc),
        )
        child_failed = Span(
            id="spn_child",
            trace_id="trc_01",
            parent_span_id="spn_root",
            name="fetch_api",
            span_type="TOOL_CALL",
            status="ERROR",
            error_message="Connection timeout",
            error_type="TimeoutError",
            start_time=datetime.now(timezone.utc),
        )

        findings = RuleEngine.evaluate_spans("trc_01", [root_failed, child_failed])
        failed_findings = [f for f in findings if f.rule_type == "FAILED_SPAN"]

        self.assertEqual(len(failed_findings), 2)
        # Root span failure is CRITICAL severity
        self.assertEqual(failed_findings[0].severity, "CRITICAL")
        # Child span failure is HIGH severity
        self.assertEqual(failed_findings[1].severity, "HIGH")

    def test_rule_2_repeated_tool_calls(self):
        """Rule 2 flags >= 3 tool calls with identical input hash."""
        spans = [
            Span(
                id=f"spn_tool_{i}",
                trace_id="trc_02",
                parent_span_id="spn_root",
                name="query_status",
                span_type="TOOL_CALL",
                status="OK",
                input_hash="hash_same_arguments_123",
                start_time=datetime.now(timezone.utc),
                attributes={},
            )
            for i in range(3)
        ]

        findings = RuleEngine.evaluate_spans("trc_02", spans)
        repeated = [f for f in findings if f.rule_type == "REPEATED_TOOL_CALL"]
        self.assertEqual(len(repeated), 1)
        self.assertEqual(repeated[0].iteration_count, 3)
        self.assertEqual(repeated[0].severity, "HIGH")

    def test_rule_2_allows_polling_tool(self):
        """Rule 2 ignores tool calls with allow_polling=True."""
        spans = [
            Span(
                id=f"spn_poll_{i}",
                trace_id="trc_03",
                parent_span_id="spn_root",
                name="poll_job_status",
                span_type="TOOL_CALL",
                status="OK",
                input_hash="hash_poll_args",
                start_time=datetime.now(timezone.utc),
                attributes={"allow_polling": True},
            )
            for i in range(4)
        ]

        findings = RuleEngine.evaluate_spans("trc_03", spans)
        repeated = [f for f in findings if f.rule_type == "REPEATED_TOOL_CALL"]
        self.assertEqual(len(repeated), 0)

    def test_rule_3_excessive_retries(self):
        """Rule 3 flags spans with retry_count > 3, differentiating recovered vs unrecovered."""
        # Unrecovered retry: status ERROR -> severity HIGH
        unrecovered_span = Span(
            id="spn_retry_fail",
            trace_id="trc_04",
            name="fetch_data",
            span_type="TOOL_CALL",
            status="ERROR",
            start_time=datetime.now(timezone.utc),
            attributes={"retry_count": 5},
        )
        # Recovered retry: status OK -> severity WARNING
        recovered_span = Span(
            id="spn_retry_ok",
            trace_id="trc_04",
            name="fetch_data_fallback",
            span_type="TOOL_CALL",
            status="OK",
            start_time=datetime.now(timezone.utc),
            attributes={"retry_count": 4},
        )
        # Boundary normal: retry_count <= 3 -> no finding
        normal_span = Span(
            id="spn_norm",
            trace_id="trc_04",
            name="fetch_fast",
            span_type="TOOL_CALL",
            status="OK",
            start_time=datetime.now(timezone.utc),
            attributes={"retry_count": 3},
        )

        findings = RuleEngine.evaluate_spans("trc_04", [unrecovered_span, recovered_span, normal_span])
        retry_findings = [f for f in findings if f.rule_type == "EXCESSIVE_RETRIES"]
        self.assertEqual(len(retry_findings), 2)

        # Unrecovered has HIGH severity
        unrec = next(f for f in retry_findings if f.span_id == "spn_retry_fail")
        self.assertEqual(unrec.severity, "HIGH")
        self.assertEqual(unrec.iteration_count, 5)
        self.assertIn("failed after", unrec.summary)

        # Recovered has WARNING severity
        rec = next(f for f in retry_findings if f.span_id == "spn_retry_ok")
        self.assertEqual(rec.severity, "WARNING")
        self.assertEqual(rec.iteration_count, 4)
        self.assertIn("recovered after", rec.summary)

    def test_rule_4_slow_span_thresholds(self):
        """Rule 4 flags spans exceeding SLA thresholds (LLM: 10s, Tool: 5s, Retrieval: 2s, AgentStep: 15s)."""
        fast_llm = Span(
            id="spn_fast",
            trace_id="trc_05",
            name="generate_text",
            span_type="LLM_CALL",
            status="OK",
            duration_ms=2500,  # <= 10,000ms -> OK
            start_time=datetime.now(timezone.utc),
        )
        slow_llm = Span(
            id="spn_slow",
            trace_id="trc_05",
            name="generate_text",
            span_type="LLM_CALL",
            status="OK",
            duration_ms=15000,  # > 10,000ms, <= 20,000ms (2x) -> WARNING
            start_time=datetime.now(timezone.utc),
        )
        very_slow_llm = Span(
            id="spn_very_slow",
            trace_id="trc_05",
            name="generate_text_large",
            span_type="LLM_CALL",
            status="OK",
            duration_ms=25000,  # > 20,000ms (2x) -> HIGH
            start_time=datetime.now(timezone.utc),
        )
        slow_retrieval = Span(
            id="spn_retrieval",
            trace_id="trc_05",
            name="vector_search",
            span_type="RETRIEVAL",
            status="OK",
            duration_ms=3000,  # > 2,000ms threshold -> WARNING
            start_time=datetime.now(timezone.utc),
        )
        slow_tool = Span(
            id="spn_tool",
            trace_id="trc_05",
            name="execute_python",
            span_type="TOOL_CALL",
            status="OK",
            duration_ms=12000,  # > 5,000ms threshold and > 10,000ms (2x) -> HIGH
            start_time=datetime.now(timezone.utc),
        )

        findings = RuleEngine.evaluate_spans(
            "trc_05",
            [fast_llm, slow_llm, very_slow_llm, slow_retrieval, slow_tool],
        )
        slow_findings = [f for f in findings if f.rule_type == "SLOW_SPAN"]
        self.assertEqual(len(slow_findings), 4)

        # slow_llm -> WARNING (15s > 10s budget)
        f_slow = next(f for f in slow_findings if f.span_id == "spn_slow")
        self.assertEqual(f_slow.severity, "WARNING")

        # very_slow_llm -> HIGH (25s > 2 * 10s budget)
        f_vslow = next(f for f in slow_findings if f.span_id == "spn_very_slow")
        self.assertEqual(f_vslow.severity, "HIGH")

        # slow_retrieval -> WARNING (3s > 2s budget)
        f_ret = next(f for f in slow_findings if f.span_id == "spn_retrieval")
        self.assertEqual(f_ret.severity, "WARNING")

        # slow_tool -> HIGH (12s > 2 * 5s budget)
        f_tool = next(f for f in slow_findings if f.span_id == "spn_tool")
        self.assertEqual(f_tool.severity, "HIGH")

    def test_rule_4_sla_threshold_precedence(self):
        """Rule 4 respects precedence: span attribute > project settings > config defaults."""
        # 1. Config defaults
        self.assertEqual(resolve_sla_threshold("LLM_CALL"), 10000)
        self.assertEqual(resolve_sla_threshold("TOOL_CALL"), 5000)
        self.assertEqual(resolve_sla_threshold("RETRIEVAL"), 2000)
        self.assertEqual(resolve_sla_threshold("AGENT_STEP"), 15000)

        # 2. Project settings override
        project_settings = {"sla_thresholds": {"LLM_CALL": 30000, "TOOL_CALL": 8000}}
        self.assertEqual(resolve_sla_threshold("LLM_CALL", project_settings=project_settings), 30000)
        self.assertEqual(resolve_sla_threshold("TOOL_CALL", project_settings=project_settings), 8000)
        # Unspecified span type in project settings falls back to config default
        self.assertEqual(resolve_sla_threshold("RETRIEVAL", project_settings=project_settings), 2000)

        # 3. Span attribute overrides project settings and defaults
        span_attrs = {"sla_threshold_ms": 60000}
        self.assertEqual(
            resolve_sla_threshold("LLM_CALL", project_settings=project_settings, attributes=span_attrs),
            60000,
        )

    def test_rule_4_invalid_and_edge_case_thresholds(self):
        """Rule 4 safely rejects zero, negative, invalid, and excessively large thresholds and provides unknown fallback."""
        # 1. Zero threshold in attributes falls back to default
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": 0}), 10000)
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": "0"}), 10000)

        # 2. Negative threshold in attributes falls back to default
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": -5000}), 10000)
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": "-100"}), 10000)

        # 3. Invalid non-numeric values fall back to default
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": "invalid_number"}), 10000)
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": None}), 10000)
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": {"nested": "obj"}}), 10000)

        # 4. Excessively large threshold (> 86,400,000 ms = 24h) safely rejected, falls back to default
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": 999_999_999}), 10000)
        self.assertEqual(resolve_sla_threshold("LLM_CALL", attributes={"sla_threshold_ms": 10**18}), 10000)

        # 5. Invalid values in project settings fall back to default
        self.assertEqual(resolve_sla_threshold("TOOL_CALL", project_settings={"sla_thresholds": {"TOOL_CALL": 0}}), 5000)
        self.assertEqual(resolve_sla_threshold("TOOL_CALL", project_settings={"sla_thresholds": {"TOOL_CALL": -500}}), 5000)
        self.assertEqual(resolve_sla_threshold("TOOL_CALL", project_settings={"sla_thresholds": {"TOOL_CALL": "bad"}}), 5000)
        self.assertEqual(resolve_sla_threshold("TOOL_CALL", project_settings={"sla_thresholds": {"TOOL_CALL": 999_999_999}}), 5000)

        # 6. Unknown span types fall back to documented default (10,000 ms)
        self.assertEqual(resolve_sla_threshold("UNKNOWN_SPAN_TYPE"), 10000)
        self.assertEqual(resolve_sla_threshold("CUSTOM_VECTOR_INDEX"), 10000)

    def test_rule_5_empty_tool_result(self):
        """Rule 5 flags tool calls returning empty results unless whitelisted."""
        empty_search = Span(
            id="spn_empty",
            trace_id="trc_06",
            name="search_database",
            span_type="TOOL_CALL",
            status="OK",
            output_payload={},
            start_time=datetime.now(timezone.utc),
        )
        whitelisted_delete = Span(
            id="spn_delete",
            trace_id="trc_06",
            name="delete_temporary_file",
            span_type="TOOL_CALL",
            status="OK",
            output_payload=None,
            start_time=datetime.now(timezone.utc),
        )
        explicit_allow_empty = Span(
            id="spn_explicit",
            trace_id="trc_06",
            name="custom_void_op",
            span_type="TOOL_CALL",
            status="OK",
            output_payload="",
            attributes={"allow_empty": True},
            start_time=datetime.now(timezone.utc),
        )

        findings = RuleEngine.evaluate_spans(
            "trc_06",
            [empty_search, whitelisted_delete, explicit_allow_empty],
        )
        empty_findings = [f for f in findings if f.rule_type == "EMPTY_TOOL_RESULT"]
        self.assertEqual(len(empty_findings), 1)
        self.assertEqual(empty_findings[0].span_id, "spn_empty")
        self.assertEqual(empty_findings[0].severity, "WARNING")


if __name__ == "__main__":
    unittest.main()
