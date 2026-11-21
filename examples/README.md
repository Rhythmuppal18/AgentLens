# AgentLens SDK Examples

This directory provides interactive reference examples demonstrating how to instrument AI agents using the zero-dependency `agentlens` Python SDK.

---

## Prerequisites

1. Ensure the AgentLens backend is running (default: `http://localhost:8000`).
2. Have a registered project and valid API key.

---

## Configuration

Set the following environment variables (or pass them directly into `AgentLens(...)`):

```bash
export AGENTLENS_API_KEY="your_api_key_here"
export AGENTLENS_PROJECT_ID="your_project_uuid_here"
export AGENTLENS_API_URL="http://localhost:8000"
export AGENTLENS_ENVIRONMENT="development"
```

---

## Example Walkthroughs

### 1. `01_basic_agent.py` — Basic Tracing
Demonstrates creating a discrete trace, measuring agent steps, child LLM calls, and tool execution spans with token counts and duration metrics.

```bash
python examples/01_basic_agent.py
```

### 2. `02_nested_spans.py` — Multi-Agent Hierarchies
Demonstrates automatic parent-child context propagation across multi-agent workflows (Supervisor -> Sub-agents -> Tools).

```bash
python examples/02_nested_spans.py
```

### 3. `03_error_capture.py` — Failure & Exception Capture
Demonstrates automatic capture of unhandled exceptions, error messages, and full stack traces without crashing the host agent process.

```bash
python examples/03_error_capture.py
```

### 4. `04_payload_capture.py` — Privacy Redaction & Truncation
Demonstrates safe payload capture: sensitive tokens (`api_key`, `secret`, `password`) are automatically redacted to `[REDACTED]`, payloads exceeding 64KB are safely truncated, and canonical SHA-256 hashes are computed for duplicate detection.

```bash
python examples/04_payload_capture.py
```
