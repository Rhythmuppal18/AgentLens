# AgentLens - Development Roadmap

This roadmap outlines the implementation trajectory for AgentLens, tracking completed baselines, active development in Task 1, and forthcoming technical milestones.

---

## Current Status Overview

| Component | Status | Details |
| :--- | :--- | :--- |
| **Repository Structure** | Completed | Clean monorepo structure with `backend/`, `frontend/`, `sdk/`, `docs/`, `examples/`, `tests/`. |
| **Backend API Core** | Baseline Completed | FastAPI app initialized with `/` and `/health` endpoints. Uvicorn operational. |
| **CORS Middleware** | Active / In Progress | Configuring allowed origin for `http://localhost:5173`. |
| **Frontend Foundation** | Active (Task 1) | React 19, TypeScript, Tailwind CSS v4, Lucide React, Framer Motion, Recharts, XYFlow. |
| **Task 1 Dashboard** | Active (Task 1) | Developer-focused SaaS dashboard, live backend health check, honest empty state. |
| **Database Persistence** | Pending | PostgreSQL schema, SQLAlchemy models, and Alembic migrations. |
| **Deterministic Rules** | Planned | 5 failure-detection rules engine in backend. |
| **Python SDK** | Planned | `agentlens` package with decorators, context managers, and async ingestion. |
| **Trace Explorer UI** | Planned | Timeline view and interactive span DAG tree using `@xyflow/react`. |
| **Failure Diagnosis UI** | Planned | Evidence-linked failure attribution and run comparison diff view. |

---

## Detailed Milestone Roadmap

```
  [Stage 1: Foundation & Dashboard] <--- CURRENT STAGE
                 │
                 ▼
  [Stage 2: Backend Persistence & Models]
                 │
                 ▼
  [Stage 3: Ingestion API & Rule Engine]
                 │
                 ▼
  [Stage 4: Python SDK Package]
                 │
                 ▼
  [Stage 5: Trace Explorer & Span Visualizer]
                 │
                 ▼
  [Stage 6: Evidence Failure Diagnosis & Replay]
                 │
                 ▼
  [Stage 7: Production Analytics & Hardening]
```

---

### Stage 1: Foundation & Developer Dashboard (Current)
- [x] Initialize Git repository and directory tree.
- [x] Configure backend FastAPI service with `/health` and `/` endpoints.
- [x] Scaffold frontend with React 19, TypeScript, Vite, Tailwind CSS v4, and core visualization libraries.
- [x] Author core documentation (`PROJECT_CONTEXT.md`, `ARCHITECTURE.md`, `DEVELOPMENT_ROADMAP.md`).
- [ ] Configure CORS in FastAPI for `http://localhost:5173`.
- [ ] Implement dark-mode developer-focused dashboard with deep charcoal backgrounds and restrained violet accents.
- [ ] Wire live backend health check against `GET http://localhost:8000/health`.
- [ ] Implement honest empty states distinguishing absent telemetry from zero values.
- [ ] Implement responsive sidebar navigation with transparent placeholder views for future stages.
- [ ] Verify build and type-checking pass (`npm run build`).

---

### Stage 2: Backend Data Persistence & Modeling (Next)
- [ ] Set up PostgreSQL database and async connection pool via AsyncPG & SQLAlchemy.
- [ ] Implement database models for `traces`, `spans`, `events`, and `failure_violations`.
- [ ] Configure Alembic for database schema migrations.
- [ ] Author database repository layer with async CRUD operations.
- [ ] Update `/health` endpoint to verify PostgreSQL connectivity and response latency.

---

### Stage 3: Ingestion API & Deterministic Rule Engine
- [ ] Build REST ingestion endpoints:
  - `POST /api/v1/traces/ingest` (batch ingestion of traces and child spans).
  - `POST /api/v1/spans/batch` (streamed span ingestion).
- [ ] Build query endpoints:
  - `GET /api/v1/traces` (paginated list with filter by agent, status, time range).
  - `GET /api/v1/traces/{trace_id}` (full trace hierarchy with span tree).
  - `GET /api/v1/violations` (list of detected failure violations).
- [ ] Implement the five deterministic failure detection rules:
  - Rule 1: **Failed Span** (checks `status == 'ERROR'` or unhandled exception).
  - Rule 2: **Repeated Tool Call** (hash identical tool name + arguments across sliding window).
  - Rule 3: **Excessive Retries** (consecutive retry counts exceeding threshold).
  - Rule 4: **Slow Span** (span duration exceeding SLA thresholds).
  - Rule 5: **Empty Tool Result** (tool returned empty payload starving context).
- [ ] Write automated pytest suite covering all 5 rule evaluations.

---

### Stage 4: Python Instrumentation SDK (`agentlens`)
- [ ] Initialize Python package under `sdk/` (`pyproject.toml`, standard packaging).
- [ ] Implement `@agentlens.trace()` decorator for top-level agent routines.
- [ ] Implement `@agentlens.span()` decorator for sub-tasks, LLM calls, and tools.
- [ ] Implement `agentlens.start_span()` context manager for granular blocks.
- [ ] Implement background worker thread with thread-safe queue for non-blocking telemetry dispatch.
- [ ] Provide auto-instrumentation hooks for popular frameworks (LangChain, LlamaIndex, OpenAI client).
- [ ] Build end-to-end integration test running a sample agent in `examples/` sending traces to local backend.

---

### Stage 5: Trace Explorer & Span Visualizer
- [ ] Build interactive Trace Explorer table with sorting, status badges, and duration filters.
- [ ] Build interactive DAG span tree visualization using `@xyflow/react`.
- [ ] Build timeline waterfall component showing sequential execution, concurrency, and latency bottlenecks.
- [ ] Implement span details drawer showing raw inputs, outputs, system prompts, and token counts.

---

### Stage 6: Evidence-Linked Failure Diagnosis & Execution Replay
- [ ] Build Failure Diagnosis view grouping traces by violation type.
- [ ] Implement "Evidence Drawer" highlighting the exact span and payload that triggered each rule.
- [ ] Build Run Comparison view allowing side-by-side diffing of a successful execution vs. a failed execution.
- [ ] Add execution replay step-by-step playback slider.

---

### Stage 7: Analytics, Hardening & Deployment
- [ ] Implement Analytics dashboard with real aggregated charts using Recharts:
  - Latency percentiles (p50, p95, p99).
  - Cost tracking (estimated USD by model and agent).
  - Token consumption trends over time.
  - Failure rate breakdown by rule.
- [ ] Containerize application with `docker-compose.yml` (FastAPI backend + PostgreSQL + Vite production build).
- [ ] Comprehensive documentation and setup guides for developer onboarding.
