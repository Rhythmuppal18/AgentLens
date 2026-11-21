"""01_basic_agent.py - Basic Agent Tracing with AgentLens

Demonstrates tracing a simple agent workflow with LLM call and Tool execution spans.
"""

import os
import time

from agentlens import AgentLens

# Initialize AgentLens client
client = AgentLens(
    api_key=os.getenv("AGENTLENS_API_KEY", "al_dev_mock_key"),
    project_id=os.getenv("AGENTLENS_PROJECT_ID", "11111111-2222-3333-4444-555555555555"),
    environment="development",
    api_url=os.getenv("AGENTLENS_API_URL", "http://localhost:8000"),
    capture_payloads=True,
)


def mock_llm_call(prompt: str) -> str:
    time.sleep(0.1)  # Simulate API latency
    return "The stock price of NVDA is currently $145.50."


def mock_calculator_tool(expression: str) -> float:
    time.sleep(0.05)
    return 145.50 * 10


def run_financial_agent(ticker: str):
    print(f"Starting financial research agent for {ticker}...")

    with client.trace(
        agent_name="FinancialResearchAgent",
        session_id="sess_demo_01",
        user_identifier="usr_analyst_1",
        metadata={"version": "1.0.0", "framework": "agentlens-native"},
    ) as trace:
        # Step 1: Agent Reasoning Step
        with trace.span(name="analyze_query", span_type="AGENT_STEP") as step_span:
            step_span.event("intent_classified", {"intent": "price_lookup", "ticker": ticker})

            # Step 2: LLM Call
            with step_span.span(
                name="generate_financial_summary",
                span_type="LLM_CALL",
                input_payload={"prompt": f"Summarize current market valuation for {ticker}"},
            ) as llm_span:
                response = mock_llm_call(ticker)
                llm_span.set_output({"response": response})
                llm_span.set_tokens(prompt_tokens=45, completion_tokens=15, cost=0.00012)

            # Step 3: Tool Call
            with step_span.span(
                name="calculate_portfolio_value",
                span_type="TOOL_CALL",
                input_payload={"expression": "145.50 * 10"},
                attributes={"tool_name": "calculator"},
            ) as tool_span:
                calc_result = mock_calculator_tool("145.50 * 10")
                tool_span.set_output({"result": calc_result})

        trace.set_tokens(prompt_tokens=45, completion_tokens=15, cost=0.00012)
        print("Agent execution completed successfully!")


if __name__ == "__main__":
    run_financial_agent("NVDA")
    # Flush remaining telemetry before exit
    client.flush(timeout=5.0)
