# AgentLens Python SDK Guide

The `agentlens` Python SDK provides high-performance, non-blocking telemetry capture for autonomous AI agents, tool calls, and LLM chains.

---

## 1. Design Principles

1. **Zero Impact**: An observability SDK must never crash, stall, or noticeably degrade the host AI agent.
2. **Zero Dependencies**: Core SDK runs on pure Python 3.10+ standard library (`urllib.request`, `json`, `gzip`, `threading`, `contextvars`).
3. **Privacy by Default**: Sensitive credentials (`api_key`, `secret`, `password`) are automatically redacted, and payloads exceeding 64KB are truncated.
4. **Resilient Background Transport**: Bounded in-memory queue (10,000 items), Gzip batch dispatch, exponential backoff, and circuit breaker protection.

---

## 2. Installation

```bash
pip install agentlens
```

---

## 3. Quickstart

```python
from agentlens import AgentLens

client = AgentLens(
    api_key="al_live_your_api_key",
    project_id="11111111-2222-3333-4444-555555555555",
    environment="production",
    api_url="http://localhost:8000",
    capture_payloads=True,
)

with client.trace(agent_name="ResearchAgent", session_id="sess_123") as trace:
    with trace.span(name="search_documents", span_type="TOOL_CALL") as span:
        results = search_docs("AgentLens architecture")
        span.set_output({"match_count": len(results)})
```

---

## 4. Context Managers & Decorators

### Traces

Traces define the root execution session of an agent.

```python
with client.trace(
    agent_name="MyAgent",
    session_id="user_session_99",
    user_identifier="usr_alice",
    metadata={"model": "gpt-4o", "version": "1.2.0"},
) as trace:
    ...
```

Or using the decorator:

```python
@client.trace_function(agent_name="MyAgent")
def run_agent(task_prompt: str):
    ...
```

### Spans

Spans represent discrete hierarchical units of work (`AGENT_STEP`, `TOOL_CALL`, `LLM_CALL`, `CHAIN`, `ROUTER`).

```python
with trace.span(
    name="query_vector_db",
    span_type="TOOL_CALL",
    input_payload={"query": "financials 2025"},
    attributes={"collection": "sec_filings"},
) as span:
    output = query_db(...)
    span.set_output(output)
```

### Token & Cost Tracking

```python
span.set_tokens(
    prompt_tokens=1500,
    completion_tokens=350,
    cost=0.0037,
)
```

### Milestone Events

Point-in-time instantaneous occurrences within a span or trace:

```python
span.event("cache_hit", {"key": "sec_nvda_2025"})
```

---

## 5. Automatic Error & Exception Capture

When an unhandled exception occurs inside a span or trace block:
1. `status` is marked as `ERROR`.
2. `error_message`, `error_type`, and complete `error_stack` are recorded.
3. The exception is **re-raised** so the host application's control flow remains unaffected.

```python
try:
    with trace.span("flaky_api_call", span_type="TOOL_CALL") as span:
        raise TimeoutError("Endpoint unreachable")
except TimeoutError:
    pass  # Exception was captured in telemetry and propagated to host
```

---

## 6. Privacy & Sensitive Data Redaction

Keys matching `(?i)(api[_-]?key|auth|bearer|secret|password|token|private|credentials)` are automatically replaced with `"[REDACTED]"`.

```python
span = trace.span(
    name="call_api",
    span_type="TOOL_CALL",
    input_payload={
        "api_key": "sk-secret-12345",  # -> "[REDACTED]"
        "action": "list_users",
    },
)
```

Payloads exceeding 64KB are truncated with a 1KB preview:

```json
{
  "_truncated": true,
  "original_bytes": 1048576,
  "preview": "...first 1KB... [TRUNCATED]"
}
```

---

## 7. Configuration Reference

| Option | Env Variable | Default | Description |
| :--- | :--- | :--- | :--- |
| `api_key` | `AGENTLENS_API_KEY` | `""` | AgentLens Project API key |
| `project_id` | `AGENTLENS_PROJECT_ID` | `""` | Target Project UUID |
| `environment` | `AGENTLENS_ENVIRONMENT` | `"development"` | Environment slug |
| `api_url` | `AGENTLENS_API_URL` | `"http://localhost:8000"` | AgentLens backend endpoint |
| `capture_payloads`| `AGENTLENS_CAPTURE_PAYLOADS` | `False` | Opt-in to input/output payload capture |
| `batch_size` | — | `50` | Maximum items per dispatch batch |
| `flush_interval`| — | `0.5` | Flush interval in seconds |
| `max_queue_size`| — | `10000` | Bounded memory queue capacity |
| `disabled` | `AGENTLENS_DISABLED` | `False` | Disable all telemetry dispatch |
