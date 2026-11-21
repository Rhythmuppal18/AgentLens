from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime
import fnmatch
from typing import Any, Optional
import uuid

from app.core.config import settings
from app.models.finding import FailureFinding, FindingEvidenceLink
from app.models.span import Span


@dataclass
class DetectedFinding:
    """Intermediate container for a rule violation finding before database persistence."""

    rule_type: str
    severity: str
    summary: str
    evidence_summary: str
    evidence_data: dict[str, Any]
    trace_id: str
    span_id: Optional[str] = None
    rule_version: str = "v1.0.0"
    iteration_count: int = 1
    evidence_links: list[dict[str, Any]] = field(default_factory=list)

    @property
    def fingerprint(self) -> str:
        return FailureFinding.generate_fingerprint(
            rule_type=self.rule_type,
            trace_id=self.trace_id,
            span_id=self.span_id,
            rule_version=self.rule_version,
        )


MAX_SLA_THRESHOLD_MS: int = 86_400_000  # 24 hours maximum SLA limit
DEFAULT_UNKNOWN_SPAN_SLA_MS: int = 10_000  # Documented fallback default for unknown span types


def _validate_threshold(val: Any) -> Optional[int]:
    """Validates and parses a threshold integer in milliseconds.
    Safely rejects zero, negative, invalid non-numeric, or excessively large (>24h) values.
    """
    if val is None:
        return None
    try:
        int_val = int(val)
        if 0 < int_val <= MAX_SLA_THRESHOLD_MS:
            return int_val
    except (ValueError, TypeError, OverflowError):
        return None
    return None


def get_default_sla_thresholds() -> dict[str, int]:
    """Returns application default SLA thresholds in milliseconds from settings."""
    return {
        "LLM_CALL": settings.AGENTLENS_SLA_LLM_MS,
        "TOOL_CALL": settings.AGENTLENS_SLA_TOOL_MS,
        "RETRIEVAL": settings.AGENTLENS_SLA_RETRIEVAL_MS,
        "AGENT_STEP": settings.AGENTLENS_SLA_AGENT_STEP_MS,
        "CHAIN": 15_000,
        "ROUTER": 5_000,
    }


def resolve_sla_threshold(
    span_type: str,
    project_settings: Optional[dict[str, Any]] = None,
    attributes: Optional[dict[str, Any]] = None,
) -> int:
    """Resolves SLA threshold in milliseconds using the approved precedence hierarchy:
    1. Span-level attribute `sla_threshold_ms` (highest precedence)
    2. Project settings `sla_thresholds[span_type]`
    3. Application environment settings (AGENTLENS_SLA_*_MS)
    4. Documented fallback default (10,000 ms) for unknown span types
    """
    # 1. Span attribute
    if attributes:
        valid = _validate_threshold(attributes.get("sla_threshold_ms"))
        if valid is not None:
            return valid

    # 2. Project settings
    if project_settings:
        sla_dict = project_settings.get("sla_thresholds")
        if isinstance(sla_dict, dict):
            valid = _validate_threshold(sla_dict.get(span_type))
            if valid is not None:
                return valid

    # 3. Application environment settings
    defaults = get_default_sla_thresholds()
    if span_type in defaults:
        return defaults[span_type]

    # 4. Documented fallback default for unknown span types
    return DEFAULT_UNKNOWN_SPAN_SLA_MS


DEFAULT_ALLOWED_EMPTY_TOOL_PATTERNS = [
    "delete_*",
    "remove_*",
    "send_*",
    "write_*",
    "clear_*",
    "notify_*",
    "save_*",
    "publish_*",
]


def tool_allows_empty_result(
    tool_name: str,
    project_settings: Optional[dict[str, Any]] = None,
    attributes: Optional[dict[str, Any]] = None,
) -> bool:
    """Checks whether a tool is whitelisted to return empty/null results on status OK."""
    attrs = attributes or {}
    if attrs.get("allow_empty") is True:
        return True

    settings_dict = project_settings or {}
    custom_patterns = settings_dict.get("allowed_empty_tools", DEFAULT_ALLOWED_EMPTY_TOOL_PATTERNS)

    tool_lower = tool_name.lower()
    for pattern in custom_patterns:
        if fnmatch.fnmatch(tool_lower, pattern.lower()):
            return True

    return False


class RuleEngine:
    """Evaluates the 5 deterministic failure detection rules against spans within a trace."""

    @classmethod
    def evaluate_spans(
        cls,
        trace_id: str,
        spans: list[Span],
        project_settings: Optional[dict[str, Any]] = None,
    ) -> list[DetectedFinding]:
        """Evaluates all 5 deterministic failure rules on the given spans."""
        findings: list[DetectedFinding] = []
        if not spans:
            return findings

        # Group tool calls for repetition analysis
        tool_calls_by_hash: dict[tuple[str, str], list[Span]] = defaultdict(list)

        for span in spans:
            # Rule 1: FAILED_SPAN
            cls._check_failed_span(span, findings)

            # Rule 3: EXCESSIVE_RETRIES
            cls._check_excessive_retries(span, findings)

            # Rule 4: SLOW_SPAN
            cls._check_slow_span(span, findings, project_settings)

            # Rule 5: EMPTY_TOOL_RESULT
            cls._check_empty_tool_result(span, findings, project_settings)

            # Accumulate for Rule 2: REPEATED_TOOL_CALL
            if span.span_type == "TOOL_CALL" and span.input_hash:
                tool_calls_by_hash[(span.name, span.input_hash)].append(span)

        # Rule 2: REPEATED_TOOL_CALL evaluation across trace
        cls._check_repeated_tool_calls(trace_id, tool_calls_by_hash, findings)

        return findings

    @classmethod
    def _check_failed_span(cls, span: Span, findings: list[DetectedFinding]) -> None:
        """Rule 1: FAILED_SPAN."""
        if span.status == "ERROR" or span.error_message is not None:
            severity = "CRITICAL" if span.parent_span_id is None else "HIGH"
            err_type = span.error_type or "Error"
            err_msg = span.error_message or "Span terminated with ERROR status"
            finding = DetectedFinding(
                rule_type="FAILED_SPAN",
                severity=severity,
                summary=f"Span '{span.name}' failed with {err_type}: {err_msg}",
                evidence_summary=f"Unhandled exception in span {span.id} at {span.start_time.isoformat() if span.start_time else 'unknown'}",
                evidence_data={
                    "error_message": span.error_message,
                    "error_type": span.error_type,
                    "error_stack": span.error_stack,
                    "duration_ms": span.duration_ms,
                    "span_name": span.name,
                    "span_type": span.span_type,
                },
                trace_id=span.trace_id,
                span_id=span.id,
            )
            finding.evidence_links.append({"span_id": span.id, "event_id": None, "role": "failure_origin"})
            findings.append(finding)

    @classmethod
    def _check_repeated_tool_calls(
        cls,
        trace_id: str,
        tool_calls_by_hash: dict[tuple[str, str], list[Span]],
        findings: list[DetectedFinding],
    ) -> None:
        """Rule 2: REPEATED_TOOL_CALL (>= 3 identical tool calls without polling allowed)."""
        for (tool_name, input_hash), span_list in tool_calls_by_hash.items():
            if len(span_list) >= 3:
                # Check if any span permits polling
                if any(s.attributes.get("allow_polling") is True for s in span_list if s.attributes):
                    continue

                # Check if all spans are legitimate retries handled by Rule 3
                if all(
                    (s.attributes and s.attributes.get("retry_count", 0) > 0)
                    for s in span_list
                ):
                    continue

                count = len(span_list)
                span_ids = [s.id for s in span_list]
                # Associate with the latest span in repetition
                latest_span = max(
                    span_list,
                    key=lambda s: s.start_time if s.start_time else datetime.min,
                )
                finding = DetectedFinding(
                    rule_type="REPEATED_TOOL_CALL",
                    severity="HIGH",
                    summary=f"Tool '{tool_name}' was executed {count} times with identical arguments",
                    evidence_summary=f"Tool '{tool_name}' repeated {count} times with input hash {input_hash[:16]}...",
                    evidence_data={
                        "tool_name": tool_name,
                        "input_hash": input_hash,
                        "repetition_count": count,
                        "span_ids": span_ids,
                        "sample_input": span_list[0].input_payload,
                    },
                    trace_id=trace_id,
                    span_id=latest_span.id,
                    iteration_count=count,
                )
                for s in span_list:
                    finding.evidence_links.append({"span_id": s.id, "event_id": None, "role": "repetition_instance"})
                findings.append(finding)

    @classmethod
    def _check_excessive_retries(cls, span: Span, findings: list[DetectedFinding]) -> None:
        """Rule 3: EXCESSIVE_RETRIES (retry_count > 3)."""
        retry_count = None
        if span.attributes:
            val = span.attributes.get("retry_count")
            if val is not None:
                try:
                    retry_count = int(val)
                except (ValueError, TypeError):
                    pass

        # Fallback to counting retry_attempt events if attributes['retry_count'] was absent
        # Check instance dictionary to avoid triggering async lazy-load MissingGreenlet in SQLAlchemy
        if retry_count is None:
            loaded_events = span.__dict__.get("events")
            if loaded_events:
                retry_count = len([e for e in loaded_events if getattr(e, "name", None) == "retry_attempt"])
            else:
                retry_count = 0

        if retry_count > 3:
            is_recovered = (span.status == "OK")
            severity = "WARNING" if is_recovered else "HIGH"
            outcome_phrase = "recovered after" if is_recovered else "failed after"
            finding = DetectedFinding(
                rule_type="EXCESSIVE_RETRIES",
                severity=severity,
                summary=f"Operation '{span.name}' {outcome_phrase} {retry_count} retries (limit: 3)",
                evidence_summary=f"Span {span.id} executed {retry_count} retries. Final outcome: {span.status}",
                evidence_data={
                    "retry_count": retry_count,
                    "limit": 3,
                    "final_status": span.status,
                    "is_recovered": is_recovered,
                    "span_id": span.id,
                    "span_name": span.name,
                    "duration_ms": span.duration_ms,
                },
                trace_id=span.trace_id,
                span_id=span.id,
                iteration_count=retry_count,
            )
            finding.evidence_links.append({"span_id": span.id, "event_id": None, "role": "excessive_retry"})
            findings.append(finding)

    @classmethod
    def _check_slow_span(
        cls,
        span: Span,
        findings: list[DetectedFinding],
        project_settings: Optional[dict[str, Any]] = None,
    ) -> None:
        """Rule 4: SLOW_SPAN (duration_ms > resolved SLA threshold)."""
        if span.duration_ms is None:
            return

        threshold = resolve_sla_threshold(span.span_type, project_settings, span.attributes)

        if span.duration_ms > threshold:
            severity = "HIGH" if span.duration_ms > (threshold * 2) else "WARNING"
            delta = span.duration_ms - threshold
            finding = DetectedFinding(
                rule_type="SLOW_SPAN",
                severity=severity,
                summary=f"Span '{span.name}' took {span.duration_ms}ms (exceeded {span.span_type} threshold of {threshold}ms)",
                evidence_summary=f"Execution latency {span.duration_ms}ms is {delta}ms over the {threshold}ms budget",
                evidence_data={
                    "duration_ms": span.duration_ms,
                    "sla_limit_ms": threshold,
                    "delta_ms": delta,
                    "span_type": span.span_type,
                    "span_name": span.name,
                },
                trace_id=span.trace_id,
                span_id=span.id,
            )
            finding.evidence_links.append({"span_id": span.id, "event_id": None, "role": "slow_execution"})
            findings.append(finding)

    @classmethod
    def _check_empty_tool_result(
        cls,
        span: Span,
        findings: list[DetectedFinding],
        project_settings: Optional[dict[str, Any]] = None,
    ) -> None:
        """Rule 5: EMPTY_TOOL_RESULT (status OK but output is empty on non-whitelisted tool)."""
        if span.span_type != "TOOL_CALL" or span.status != "OK":
            return

        out = span.output_payload
        is_empty = (
            out is None
            or out == ""
            or out == {}
            or out == []
            or (isinstance(out, str) and out.strip() == "")
        )

        if is_empty and not tool_allows_empty_result(span.name, project_settings, span.attributes):
            finding = DetectedFinding(
                rule_type="EMPTY_TOOL_RESULT",
                severity="WARNING",
                summary=f"Tool '{span.name}' returned an empty result payload upon status OK",
                evidence_summary=f"Tool '{span.name}' executed in {span.duration_ms or 0}ms and returned empty output, risking context starvation",
                evidence_data={
                    "tool_name": span.name,
                    "input_payload": span.input_payload,
                    "output_payload": span.output_payload,
                    "duration_ms": span.duration_ms,
                },
                trace_id=span.trace_id,
                span_id=span.id,
            )
            finding.evidence_links.append({"span_id": span.id, "event_id": None, "role": "empty_result"})
            findings.append(finding)
