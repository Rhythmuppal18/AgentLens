# AgentLens - Project Context

## Product Vision

> **"See the trace. Find the failure. Debug with evidence."**

AgentLens is a developer-focused observability and failure debugging platform designed specifically for AI agents.

Comparable to a flight recorder for AI agents, AgentLens captures the end-to-end execution journey of an agentic workflow—including Large Language Model (LLM) calls, tool invocations, execution timings, inputs, outputs, errors, retries, and intermediate events. When an agent deviates, halts, loops, or fails, AgentLens provides deterministic diagnostic evidence so developers can pinpoint the root cause in seconds rather than sifting through unformatted terminal logs.

---

## Problem Statement

Modern AI agents are dynamic, non-deterministic software systems. Unlike traditional monolithic or microservice architectures:
- **Non-Deterministic Control Flow**: Agents decide their next actions based on probabilistic LLM responses.
- **Silent Failures**: Agents often fail without throwing standard exceptions—they enter infinite tool loops, generate empty outputs, repeatedly retry failing external API calls, or exceed acceptable latency budgets.
- **Complex Hierarchical Causality**: A single high-level user goal spans multiple chains, sub-agents, tool executions, and retrieval queries. Diagnosing an error at step 14 requires inspecting the prompt, context, and tool output of step 2.
- **Lack of Specialized Tooling**: Generic application performance monitoring (APM) tools (Datadog, New Relic) lack native understanding of agent constructs (prompts, completions, tool calling schemas, token costs, hallucination cycles).

AgentLens bridges this gap with deterministic rule evaluation, evidence-linked span graphs, and deep runtime inspection.

---

## Target Users

1. **AI Engineers & LLM Developers**: Building autonomous or semi-autonomous agents with frameworks like LangChain, LlamaIndex, CrewAI, AutoGen, or custom agent loops.
2. **Full-Stack & Backend Engineers**: Integrating agentic microservices into production products requiring reliability guarantees and latency/cost observability.
3. **Product & Operations Teams**: Requiring auditability, cost attribution, and reliability reporting across agent operations.

---

## Core Platform Features

1. **Python SDK**: Lightweight, non-intrusive client library for instrumenting agent applications using decorators, context managers, and automated interceptors. *(Planned)*
2. **Trace Explorer**: Interactive execution timelines and parent-child span trees illustrating the hierarchy of agent decisions. *(Planned)*
3. **Deterministic Failure Detection**: Built-in rules engine analyzing executions against five critical failure modes. *(Planned)*
4. **Evidence-Linked Failure Diagnosis**: Direct attribution pointing to the exact span, input payload, or external tool output responsible for the failure. *(Planned)*
5. **Cost & Performance Analytics**: Real aggregated tracking of prompt/completion tokens, model costs, execution latencies, and tool invocation frequencies. *(Planned)*
6. **Execution Replay & Run Comparison**: Side-by-side diffing of successful vs. failed executions for identical prompts and task goals. *(Planned)*
7. **Developer-Focused Dashboard**: High-density, professional control plane built with an enterprise dark developer-tool aesthetic. *(Task 1 Foundation)*

---

## The Five Deterministic Failure-Detection Rules

AgentLens rejects vague heuristic guesses in favor of five deterministic, verifiable rules:

| Rule Name | Failure Condition | Diagnostic Meaning |
| :--- | :--- | :--- |
| **Failed Span** | Span execution terminates with an unhandled exception or status `ERROR`. | Hard system failure, unhandled API error, or code bug in tool/agent logic. |
| **Repeated Tool Call** | An identical tool is called repeatedly with identical parameters within a defined span window. | Agent is trapped in a reasoning loop or unable to interpret the previous tool output. |
| **Excessive Retries** | The same operation, prompt generation, or tool call is retried more than the threshold (e.g. >3 attempts). | Transient upstream failure, unresolvable rate limits, or persistent validation rejection. |
| **Slow Span** | Span duration exceeds a predefined latency SLA or statistical distribution threshold. | Upstream provider throttling, slow external network dependency, or inefficient tool execution. |
| **Empty Tool Result** | A tool executes successfully (exit 0) but returns empty string, `None`, empty array, or zero bytes. | Downstream LLM is starved of context, causing hallucinations or repeated queries. |

---

## Technology Stack

### Frontend
- **Framework**: React 19 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS v4
- **Icons**: Lucide React
- **Animations**: Framer Motion
- **Data Visualization**: Recharts
- **Graph & Flow Visualizations**: React Flow (`@xyflow/react`)

### Backend
- **Language**: Python 3.13
- **Framework**: FastAPI
- **Data Validation & Schemas**: Pydantic v2
- **Database**: PostgreSQL (planned for persistence)
- **ASGI Server**: Uvicorn

### SDK
- **Language**: Python 3.10+
- **Telemetry Protocol**: Standardized JSON over HTTP / WebSocket batching (planned)

---

## Development Constraints & Principles

1. **Absolute Data Integrity**: Never present fabricated operational metrics or mock counts as real data. If no agents are connected, the platform explicitly states that telemetry is awaiting SDK instrumentation.
2. **Distinguish Unavailable from Zero**: Distinguish clearly between missing telemetry (unavailable / not instrumented) and genuine zero values (e.g., zero failures across 100 recorded traces).
3. **No Decorative Placeholders**: Do not build fake interactive functionality merely to look complete; unimplemented areas must clearly indicate their status and development phase.
4. **Resilient Communication**: Gracefully manage connection states, network latency, and backend health status with live diagnostics.
5. **Clean & Reusable Architecture**: Component-driven design, strong TypeScript typings, modular backend routes, and rigorous documentation.
