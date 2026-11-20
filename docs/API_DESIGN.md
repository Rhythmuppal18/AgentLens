# AgentLens — REST API Specification

**Stage 2: Technical Architecture & API Design**
*Document Version: 2.1.0*
*Status: Architecture Specification (Incorporating Stage 2 Technical Corrections)*

---

## 1. Overview & Protocol Principles

The AgentLens API provides two distinct operational interfaces:
1. **Telemetry Ingestion Interface**: Low-latency, high-throughput endpoints called by the Python SDK (`agentlens`) or third-party webhooks to stream traces, spans, and events with full idempotency.
2. **Dashboard Query Interface**: Rich, filterable, paginated query endpoints used by the React 19 frontend to render execution waterfalls, DAG graphs, failure diagnostics, and analytics.

### Protocol Standards
- **Base URL**: `/api/v1`
- **Data Format**: `application/json` (UTF-8, with Gzip compression support on request bodies)
- **Time Representation**: ISO 8601 UTC strings (e.g. `2026-11-20T04:30:00.120Z`)
- **Authentication**:
  - SDK Ingestion: `Authorization: Bearer <agentlens_api_key>` header (resolved against `projects.api_key_hash`).
  - Dashboard Queries: Session cookie or JWT header (development supports local unauthenticated requests).
- **Error Standard**: RFC 7807 Problem Details for HTTP APIs (`type`, `title`, `status`, `detail`, `instance`).
- **Idempotency**: All ingestion endpoints are idempotent via unique IDs (`trace.id`, `span.id`, `event.id`, `finding_fingerprint`).

---

## 2. API Endpoints Summary

| Category | Method | Path | Description |
| :--- | :--- | :--- | :--- |
| **System** | `GET` | `/health` | Backend and database connectivity health probe |
| **Ingestion** | `POST` | `/api/v1/telemetry/ingest` | Batch ingest full trace, spans, and events with server deduplication |
| **Ingestion** | `POST` | `/api/v1/telemetry/spans` | Incremental streaming of individual spans for running traces |
| **Traces** | `GET` | `/api/v1/traces` | Filtered, paginated list of execution traces |
| **Traces** | `GET` | `/api/v1/traces/{trace_id}` | Retrieve full trace tree with nested spans |
| **Spans** | `GET` | `/api/v1/traces/{trace_id}/spans` | Flat list of all spans belonging to a trace |
| **Spans** | `GET` | `/api/v1/spans/{span_id}` | Detailed single span payload with events |
| **Events** | `GET` | `/api/v1/spans/{span_id}/events` | Chronological event list within a span |
| **Failures** | `GET` | `/api/v1/failures` | Filtered list of failure findings across projects |
| **Failures** | `GET` | `/api/v1/failures/{finding_id}` | Detailed failure finding with evidence payload and links |
| **Failures** | `GET` | `/api/v1/traces/{trace_id}/failures` | All failure findings detected within a trace |
| **Analytics**| `GET` | `/api/v1/analytics/overview` | Aggregated KPI statistics (executions, error rate, p95) |
| **Analytics**| `GET` | `/api/v1/analytics/activity` | Time-bucketed execution and error timeseries for charts |
| **Analytics**| `GET` | `/api/v1/analytics/rules` | Breakdown of violations across the 5 deterministic rules |

---

## 3. Telemetry Ingestion Endpoints

### 3.1 `POST /api/v1/telemetry/ingest`
Primary high-throughput batch ingestion endpoint called by the SDK worker when an agent completes a trace or periodically flushes batched execution buffers.

#### Request Headers
```http
Content-Type: application/json
Content-Encoding: gzip (optional)
Authorization: Bearer al_live_9a4f7e2189b0...
```

#### Request Payload
```json
{
  "project_id": "11111111-2222-3333-4444-555555555555",
  "environment": "production",
  "trace": {
    "id": "trc_9a4f7e21",
    "agent_name": "FinancialResearchAgent",
    "session_id": "sess_8921",
    "user_identifier": "usr_anon_442",
    "status": "ERROR",
    "start_time": "2026-11-20T04:15:30.120Z",
    "end_time": "2026-11-20T04:15:33.540Z",
    "duration_ms": 3420,
    "total_tokens": 1840,
    "prompt_tokens": 1400,
    "completion_tokens": 440,
    "estimated_cost_usd": 0.00368,
    "metadata": {
      "framework": "crewai",
      "framework_version": "0.45.0",
      "python_version": "3.13.0"
    }
  },
  "spans": [
    {
      "id": "spn_root_01",
      "trace_id": "trc_9a4f7e21",
      "parent_span_id": null,
      "name": "execute_financial_audit",
      "span_type": "AGENT_STEP",
      "status": "ERROR",
      "start_time": "2026-11-20T04:15:30.120Z",
      "end_time": "2026-11-20T04:15:33.540Z",
      "duration_ms": 3420,
      "input_payload": {
        "ticker": "NVDA",
        "fiscal_year": 2025
      },
      "output_payload": {
        "error": "Repeated tool timeout on fetch_sec_filing"
      },
      "error_message": "Repeated tool timeout on fetch_sec_filing",
      "error_type": "ToolExecutionLoopError",
      "attributes": {
        "model": "gemini-1.5-pro",
        "total_tokens": 1840
      }
    },
    {
      "id": "spn_tool_02",
      "trace_id": "trc_9a4f7e21",
      "parent_span_id": "spn_root_01",
      "name": "fetch_sec_filing",
      "span_type": "TOOL_CALL",
      "status": "ERROR",
      "start_time": "2026-11-20T04:15:31.000Z",
      "end_time": "2026-11-20T04:15:32.000Z",
      "duration_ms": 1000,
      "input_payload": { "form": "10-Q", "ticker": "NVDA" },
      "input_hash": "3b8f10a2d48c8b1a8f9024c13a019e782f913d014bc08912ef39d8912a812bf1",
      "output_payload": null,
      "error_message": "Connection timed out after 1000ms",
      "error_type": "TimeoutError",
      "attributes": {
        "tool_name": "fetch_sec_filing",
        "retry_count": 1,
        "allow_empty": false,
        "allow_polling": false
      }
    }
  ],
  "events": [
    {
      "id": "evt_01",
      "span_id": "spn_root_01",
      "trace_id": "trc_9a4f7e21",
      "name": "agent_initialized",
      "timestamp": "2026-11-20T04:15:30.130Z",
      "data": { "agent_version": "2.4.0" }
    }
  ]
}
```

#### Response: `202 Accepted`
```json
{
  "status": "accepted",
  "trace_id": "trc_9a4f7e21",
  "spans_upserted": 2,
  "events_inserted": 1,
  "rules_evaluated": 5,
  "findings_detected": 1,
  "findings_updated": 0,
  "ingested_at": "2026-11-20T04:15:34.010Z"
}
```

#### Error Response: `422 Unprocessable Entity` (RFC 7807)
```json
{
  "type": "https://agentlens.dev/errors/validation-failed",
  "title": "Invalid Telemetry Batch",
  "status": 422,
  "detail": "Span 'spn_tool_02' references non-existent parent_span_id 'spn_missing' that does not match any span in trace 'trc_9a4f7e21'",
  "instance": "/api/v1/telemetry/ingest"
}
```

---

### 3.2 `POST /api/v1/telemetry/spans`
Used for streaming spans incrementally during long-running agent workflows while the root trace remains in `RUNNING` status.

#### Request Payload
```json
{
  "trace_id": "trc_9a4f7e21",
  "spans": [
    {
      "id": "spn_tool_03",
      "trace_id": "trc_9a4f7e21",
      "parent_span_id": "spn_root_01",
      "name": "fetch_sec_filing",
      "span_type": "TOOL_CALL",
      "status": "OK",
      "start_time": "2026-11-20T04:15:32.100Z",
      "end_time": "2026-11-20T04:15:33.100Z",
      "duration_ms": 1000,
      "input_payload": { "form": "10-Q", "ticker": "NVDA" },
      "input_hash": "3b8f10a2d48c8b1a8f9024c13a019e782f913d014bc08912ef39d8912a812bf1",
      "output_payload": { "filing_id": "0001045810-24-000100" },
      "attributes": {
        "tool_name": "fetch_sec_filing",
        "retry_count": 2
      }
    }
  ]
}
```

#### Response: `202 Accepted`
```json
{
  "status": "accepted",
  "spans_processed": 1
}
```

---

## 4. Trace & Span Query Endpoints

### 4.1 `GET /api/v1/traces`
Returns a paginated list of traces filtered by project, environment, status, date range, or agent name.

#### Query Parameters
| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `project_id` | `UUID` | No | Active project | Filter by project UUID |
| `environment` | `string` | No | `development` | Filter: `development`, `staging`, `production` |
| `status` | `string` | No | All | Filter: `SUCCESS`, `ERROR`, `PARTIAL`, `RUNNING` |
| `has_failures` | `boolean`| No | All | `true` returns only traces with flagged rule findings |
| `agent_name` | `string` | No | All | Filter by specific agent class or function |
| `search` | `string` | No | None | Substring search across trace ID, session ID, or root span |
| `time_range` | `string` | No | `24h` | Window: `1h`, `24h`, `7d`, `30d`, or custom |
| `limit` | `integer`| No | `20` | Max items per page (1 to 100) |
| `offset` | `integer`| No | `0` | Pagination offset |

#### Response: `200 OK`
```json
{
  "total": 1,
  "limit": 20,
  "offset": 0,
  "items": [
    {
      "id": "trc_9a4f7e21",
      "project_id": "11111111-2222-3333-4444-555555555555",
      "environment": "production",
      "agent_name": "FinancialResearchAgent",
      "session_id": "sess_8921",
      "root_span_name": "execute_financial_audit",
      "status": "ERROR",
      "start_time": "2026-11-20T04:15:30.120Z",
      "end_time": "2026-11-20T04:15:33.540Z",
      "duration_ms": 3420,
      "span_count": 5,
      "has_failures": true,
      "total_tokens": 1840,
      "estimated_cost_usd": 0.00368,
      "created_at": "2026-11-20T04:15:34.010Z"
    }
  ]
}
```

---

### 4.2 `GET /api/v1/traces/{trace_id}`
Returns complete details for an individual trace, including its hierarchical span tree with parent-child nesting.

#### Response: `200 OK`
```json
{
  "id": "trc_9a4f7e21",
  "project_id": "11111111-2222-3333-4444-555555555555",
  "environment": "production",
  "agent_name": "FinancialResearchAgent",
  "session_id": "sess_8921",
  "user_identifier": "usr_anon_442",
  "status": "ERROR",
  "start_time": "2026-11-20T04:15:30.120Z",
  "end_time": "2026-11-20T04:15:33.540Z",
  "duration_ms": 3420,
  "total_tokens": 1840,
  "prompt_tokens": 1400,
  "completion_tokens": 440,
  "estimated_cost_usd": 0.00368,
  "span_count": 2,
  "has_failures": true,
  "metadata": {
    "framework": "crewai",
    "python_version": "3.13.0"
  },
  "root_span": {
    "id": "spn_root_01",
    "trace_id": "trc_9a4f7e21",
    "parent_span_id": null,
    "name": "execute_financial_audit",
    "span_type": "AGENT_STEP",
    "status": "ERROR",
    "start_time": "2026-11-20T04:15:30.120Z",
    "end_time": "2026-11-20T04:15:33.540Z",
    "duration_ms": 3420,
    "input_payload": { "ticker": "NVDA", "fiscal_year": 2025 },
    "output_payload": { "error": "Repeated tool timeout" },
    "error_message": "Repeated tool timeout on fetch_sec_filing",
    "attributes": { "model": "gemini-1.5-pro" },
    "events": [
      {
        "id": "evt_01",
        "name": "agent_initialized",
        "timestamp": "2026-11-20T04:15:30.130Z",
        "data": { "agent_version": "2.4.0" }
      }
    ],
    "children": [
      {
        "id": "spn_tool_02",
        "trace_id": "trc_9a4f7e21",
        "parent_span_id": "spn_root_01",
        "name": "fetch_sec_filing",
        "span_type": "TOOL_CALL",
        "status": "ERROR",
        "start_time": "2026-11-20T04:15:31.000Z",
        "end_time": "2026-11-20T04:15:32.000Z",
        "duration_ms": 1000,
        "input_payload": { "form": "10-Q", "ticker": "NVDA" },
        "input_hash": "3b8f10a2d48c8b1a8f9024c13a019e782f913d014bc08912ef39d8912a812bf1",
        "output_payload": null,
        "error_message": "Connection timed out after 1000ms",
        "attributes": { "tool_name": "fetch_sec_filing", "retry_count": 1 },
        "events": [],
        "children": []
      }
    ]
  }
}
```

---

## 5. Failure Findings Endpoints

### 5.1 `GET /api/v1/failures`
Retrieves detected failure findings across executions, filtered by rule type, severity, or date range.

#### Query Parameters
- `rule_type`: Filter by rule (`FAILED_SPAN`, `REPEATED_TOOL_CALL`, `EXCESSIVE_RETRIES`, `SLOW_SPAN`, `EMPTY_TOOL_RESULT`).
- `severity`: Filter by severity (`CRITICAL`, `HIGH`, `WARNING`).
- `environment`: Filter by environment (`production`, `development`, etc.).
- `limit`, `offset`: Pagination.

#### Response: `200 OK`
```json
{
  "total": 1,
  "limit": 20,
  "offset": 0,
  "items": [
    {
      "id": "flr_01jk8f9a2",
      "finding_fingerprint": "a4f8910b8921df01ba492c10928e41a9024cba8912d014bc08912ef39d8912a8",
      "rule_version": "v1.0.0",
      "trace_id": "trc_9a4f7e21",
      "span_id": "spn_tool_02",
      "span_name": "fetch_sec_filing",
      "rule_type": "REPEATED_TOOL_CALL",
      "severity": "HIGH",
      "iteration_count": 3,
      "summary": "Tool 'fetch_sec_filing' called 3 times consecutively with identical parameters",
      "evidence_summary": "Identical input_hash (3b8f10a2d48c...) across 3 spans within 2,400ms window",
      "first_detected_at": "2026-11-20T04:15:34.020Z",
      "last_updated_at": "2026-11-20T04:15:34.020Z"
    }
  ]
}
```

---

### 5.2 `GET /api/v1/failures/{finding_id}`
Returns detailed evidence for a specific finding, including structured diffs, linked spans, and diagnostic proof.

#### Response: `200 OK`
```json
{
  "id": "flr_01jk8f9a2",
  "finding_fingerprint": "a4f8910b8921df01ba492c10928e41a9024cba8912d014bc08912ef39d8912a8",
  "rule_version": "v1.0.0",
  "trace_id": "trc_9a4f7e21",
  "span_id": "spn_tool_02",
  "rule_type": "REPEATED_TOOL_CALL",
  "severity": "HIGH",
  "iteration_count": 3,
  "summary": "Tool 'fetch_sec_filing' called 3 times consecutively with identical parameters",
  "evidence_summary": "Identical input_hash (3b8f10a2d48c...) across 3 spans within 2,400ms window",
  "evidence_data": {
    "tool_name": "fetch_sec_filing",
    "repeated_count": 3,
    "input_hash": "3b8f10a2d48c8b1a8f9024c13a019e782f913d014bc08912ef39d8912a812bf1",
    "canonical_input": {
      "form": "10-Q",
      "ticker": "NVDA"
    },
    "contributing_spans": [
      { "span_id": "spn_tool_02", "start_time": "2026-11-20T04:15:31.000Z", "duration_ms": 1000 },
      { "span_id": "spn_tool_03", "start_time": "2026-11-20T04:15:32.100Z", "duration_ms": 1000 },
      { "span_id": "spn_tool_04", "start_time": "2026-11-20T04:15:33.200Z", "duration_ms": 1000 }
    ]
  },
  "first_detected_at": "2026-11-20T04:15:34.020Z",
  "last_updated_at": "2026-11-20T04:15:34.020Z"
}
```

---

## 6. Dashboard Analytics Endpoints

### 6.1 `GET /api/v1/analytics/overview`
Provides high-level KPI cards for the dashboard header strip.

#### Query Parameters
- `environment`: `production`, `staging`, `development`
- `time_range`: `1h`, `24h`, `7d`, `30d`

#### Response: `200 OK`
```json
{
  "total_executions": 0,
  "failed_executions": 0,
  "error_rate": 0.0,
  "p95_latency_ms": null,
  "average_latency_ms": null,
  "total_tokens": null,
  "estimated_cost_usd": null,
  "is_telemetry_standby": true,
  "last_telemetry_at": null
}
```
*Note: When no telemetry has been ingested, `total_executions` is `0`, and latency/tokens are explicitly `null` (not fabricated).*

---

### 6.2 `GET /api/v1/analytics/activity`
Returns time-bucketed execution counts and error rates for rendering the area chart on the Overview and Analytics views.

#### Query Parameters
- `environment`: `development`
- `time_range`: `24h`
- `bucket_interval`: `1h` (or `15m`, `3h`, `1d`)

#### Response: `200 OK`
```json
{
  "time_range": "24h",
  "bucket_interval": "3h",
  "data_points": [
    { "timestamp": "2026-11-20T00:00:00Z", "executions": 0, "errors": 0 },
    { "timestamp": "2026-20-20T03:00:00Z", "executions": 0, "errors": 0 },
    { "timestamp": "2026-11-20T06:00:00Z", "executions": 0, "errors": 0 },
    { "timestamp": "2026-11-20T09:00:00Z", "executions": 0, "errors": 0 },
    { "timestamp": "2026-11-20T12:00:00Z", "executions": 0, "errors": 0 },
    { "timestamp": "2026-11-20T15:00:00Z", "executions": 0, "errors": 0 },
    { "timestamp": "2026-11-20T18:00:00Z", "executions": 0, "errors": 0 },
    { "timestamp": "2026-11-20T21:00:00Z", "executions": 0, "errors": 0 }
  ]
}
```

---

### 6.3 `GET /api/v1/analytics/rules`
Returns summary metrics for each of the five deterministic failure detection rules, including active SLA thresholds.

#### Response: `200 OK`
```json
{
  "rules": [
    {
      "rule_type": "FAILED_SPAN",
      "name": "Failed Span",
      "violations_count": 0,
      "severity": "CRITICAL",
      "status": "active"
    },
    {
      "rule_type": "REPEATED_TOOL_CALL",
      "name": "Repeated Tool Call",
      "violations_count": 0,
      "severity": "HIGH",
      "status": "active"
    },
    {
      "rule_type": "EXCESSIVE_RETRIES",
      "name": "Excessive Retries",
      "violations_count": 0,
      "severity": "HIGH",
      "status": "active"
    },
    {
      "rule_type": "SLOW_SPAN",
      "name": "Slow Span",
      "violations_count": 0,
      "severity": "WARNING",
      "status": "active",
      "configured_thresholds_ms": {
        "LLM_CALL": 10000,
        "TOOL_CALL": 5000,
        "RETRIEVAL": 2000,
        "AGENT_STEP": 15000
      }
    },
    {
      "rule_type": "EMPTY_TOOL_RESULT",
      "name": "Empty Tool Result",
      "violations_count": 0,
      "severity": "WARNING",
      "status": "active"
    }
  ]
}
```
