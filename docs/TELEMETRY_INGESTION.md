# AgentLens — Telemetry Ingestion Architecture & Reference

*Stage 3: Telemetry Ingestion & Python SDK*

---

## 1. Overview

The AgentLens Telemetry Ingestion API provides high-throughput, low-latency endpoints for streaming execution traces, hierarchical spans, and milestone events.

### Ingestion Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/telemetry/ingest` | Full batch ingestion (trace + spans + events) with server deduplication |
| `POST` | `/api/v1/telemetry/spans` | Incremental streaming of individual spans for long-running active traces |

---

## 2. Authentication & Authorization

All ingestion endpoints require API key authentication:

```http
Authorization: Bearer <agentlens_api_key>
```

### Verification Algorithm
1. The raw Bearer token is extracted from the `Authorization` header.
2. The SHA-256 hash is computed: `SHA256(raw_key.encode('utf-8'))`.
3. The project is retrieved where `projects.api_key_hash == computed_hash` and `is_active == true`.
4. If invalid or missing, an RFC 7807 `401 Unauthorized` response is returned.
5. If the request body's `project_id` does not match the authenticated project, an RFC 7807 `403 Forbidden` response is returned.

---

## 3. Gzip Request Decompression & Size Safeguards

- Requests may include `Content-Encoding: gzip`.
- Incoming bodies are decompressed transparently before Pydantic model validation.
- Maximum request payload size limit: **10 MB** (both raw and decompressed).
- Malformed Gzip payloads immediately return RFC 7807 `400 Bad Request`.
- Oversized payloads return RFC 7807 `413 Payload Too Large`.

---

## 4. Ingestion Idempotency & Safe Upsert

### 4.1 Trace Upsert & Terminal Status Protection
- Once a trace reaches a terminal status (`SUCCESS`, `ERROR`, `PARTIAL`), an incoming `RUNNING` status from a delayed packet will **not** overwrite the terminal status.
- Non-null fields (`end_time`, `duration_ms`, `total_tokens`, `cost`) and metadata are safely coalesced and updated.

### 4.2 Out-of-Order Parent-Child Span Safety
PostgreSQL enforces the compound foreign key:
```sql
CONSTRAINT fk_spans_parent_same_trace FOREIGN KEY (parent_span_id, trace_id)
REFERENCES spans(id, trace_id) ON DELETE SET NULL (parent_span_id);
```

To guarantee that child spans arriving before parent spans (or out-of-order) do not raise foreign key constraint violations:
- **Phase 1**: All spans in the batch are inserted or updated into `spans` with `parent_span_id = None` (or existing DB parent).
- **Phase 2**: Once all spans exist in the database table, `parent_span_id` is linked for all spans whose parents are present.
- If a child arrives before its parent across separate batches, the parent link is updated upon parent arrival without corrupting data.

---

## 5. Deterministic Failure Detection Rules Engine

Upon persistence, the backend evaluates the 5 deterministic failure detection rules:

1. **Rule 1 (`FAILED_SPAN`)**: Checks `span.status == 'ERROR'` or `error_message != null`.
2. **Rule 2 (`REPEATED_TOOL_CALL`)**: Detects $\ge 3$ tool calls with identical arguments (`input_hash`) in the trace, excluding whitelisted polling tools.
3. **Rule 3 (`EXCESSIVE_RETRIES`)**: Flags spans where `attributes.retry_count > 3`.
4. **Rule 4 (`SLOW_SPAN`)**: Checks if duration exceeds configured SLA thresholds (`LLM_CALL`: 30s, `TOOL_CALL`: 10s, `AGENT_STEP`: 60s).
5. **Rule 5 (`EMPTY_TOOL_RESULT`)**: Flags `TOOL_CALL` with status `OK` that return empty/null results, risking LLM context starvation (excluding whitelisted void tools).

### Finding Fingerprint Formula
$$\text{finding\_fingerprint} = \text{SHA256}(\text{rule\_type} + \text{":"} + \text{trace\_id} + \text{":"} + \text{COALESCE(span\_id, '')} + \text{":"} + \text{rule\_version})$$

Findings and evidence links are upserted idempotently via unique constraints.
