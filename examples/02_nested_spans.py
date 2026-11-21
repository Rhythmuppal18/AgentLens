"""02_nested_spans.py - Hierarchical Multi-Agent and Nested Tool Tracing

Demonstrates multi-level hierarchical execution:
Root Coordinator -> Sub-Agent Planner -> Parallel Worker -> Tool Calls.
"""

import os
import time

from agentlens import AgentLens

client = AgentLens(
    api_key=os.getenv("AGENTLENS_API_KEY", "al_dev_mock_key"),
    project_id=os.getenv("AGENTLENS_PROJECT_ID", "11111111-2222-3333-4444-555555555555"),
    environment="development",
    api_url=os.getenv("AGENTLENS_API_URL", "http://localhost:8000"),
    capture_payloads=True,
)


def run_hierarchical_workflow():
    print("Executing hierarchical multi-agent workflow...")

    with client.trace(
        agent_name="SupervisorAgent",
        session_id="sess_multi_agent_02",
        metadata={"architecture": "hierarchical-swarm"},
    ) as trace:
        # Top-level Planner Agent Step
        with trace.span(name="coordinator_plan", span_type="AGENT_STEP") as plan_span:
            plan_span.event("subtasks_created", {"count": 2})

            # Sub-Agent 1: Research Agent
            with plan_span.span(name="research_worker", span_type="AGENT_STEP") as worker_1:
                worker_1.set_attributes({"worker_id": "wrk_01", "role": "sec_retrieval"})

                # Child Tool Call 1
                with worker_1.span(
                    name="fetch_sec_filing",
                    span_type="TOOL_CALL",
                    input_payload={"ticker": "AAPL", "form": "10-K"},
                    attributes={"tool_name": "sec_edgar"},
                ) as tool_1:
                    time.sleep(0.05)
                    tool_1.set_output({"status": "filing_found", "pages": 142})

            # Sub-Agent 2: Sentiment Analysis Agent
            with plan_span.span(name="sentiment_worker", span_type="AGENT_STEP") as worker_2:
                worker_2.set_attributes({"worker_id": "wrk_02", "role": "sentiment_score"})

                with worker_2.span(
                    name="analyze_earnings_transcript",
                    span_type="LLM_CALL",
                    input_payload={"transcript_id": "q4_2025_earnings"},
                ) as llm_span:
                    time.sleep(0.08)
                    llm_span.set_output({"sentiment": "positive", "score": 0.88})
                    llm_span.set_tokens(prompt_tokens=850, completion_tokens=120, cost=0.0019)

    print("Hierarchical workflow completed.")


if __name__ == "__main__":
    run_hierarchical_workflow()
    client.flush(timeout=5.0)
