"""05_real_ai_agent.py — Real-World AI Agent with AgentLens Observability.

Demonstrates:
1. Live outbound external API tool execution (GitHub REST API).
2. Structured mathematical metric computation tool.
3. Pluggable LLM completion (Groq / OpenAI / Ollama / Fallback).
4. Full AgentLens SDK instrumentation with nested spans:
   - Root Trace: SoftwareIntelligenceAgent
     - AGENT_STEP: gather_live_repository_intelligence
       - TOOL_CALL: github_api_lookup
     - AGENT_STEP: compute_health_analytics
       - TOOL_CALL: health_score_calculator
     - AGENT_STEP: synthesize_executive_report
       - LLM_CALL: llm_generate_evaluation
5. Token tracking and accurate cost attribution.
6. Real-time telemetry delivery to the AgentLens backend.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request

# Ensure sdk and current directory are on sys.path
sys.path.insert(0, os.path.abspath("sdk"))
sys.path.insert(0, os.path.abspath("."))

from agentlens import AgentLens
from examples.real_agent.providers import get_configured_provider
from examples.real_agent.tools import (
    calculate_repository_health_metrics,
    fetch_github_repository_stats,
)

API_URL = os.getenv("AGENTLENS_API_URL", "http://localhost:8000").rstrip("/")


def get_or_create_project(api_url: str) -> tuple[str, str]:
    """Retrieves or auto-provisions a demo project and valid API key from the backend."""
    req = urllib.request.Request(
        f"{api_url}/api/v1/projects",
        headers={"Accept": "application/json"},
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=5) as res:
            projects = json.loads(res.read().decode("utf-8"))
    except Exception:
        # Fallback to local default UUID if server is not directly accessible
        return (
            os.getenv("AGENTLENS_PROJECT_ID", "11111111-2222-3333-4444-555555555555"),
            os.getenv("AGENTLENS_API_KEY", "al_live_demo_key"),
        )

    # Check for existing project
    demo = next((p for p in projects if p["name"] == "Autonomous Agent Service"), None)
    if not demo:
        # Create project
        create_data = json.dumps(
            {"name": "Autonomous Agent Service", "slug": "autonomous-agent-service"}
        ).encode("utf-8")
        creq = urllib.request.Request(
            f"{api_url}/api/v1/projects",
            data=create_data,
            headers={"Content-Type": "application/json", "Accept": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(creq, timeout=5) as cres:
            created = json.loads(cres.read().decode("utf-8"))
            return created["id"], created["api_key"]
    else:
        # Generate new plaintext API key for the project
        kreq = urllib.request.Request(
            f"{api_url}/api/v1/projects/{demo['id']}/api-key",
            data=b"",
            headers={"Accept": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(kreq, timeout=5) as kres:
            kdata = json.loads(kres.read().decode("utf-8"))
            return demo["id"], kdata["api_key"]


def run_real_ai_agent(target_repository: str = "Rhythmuppal18/AgentLens"):
    print("=" * 70)
    print("AgentLens — Real AI Agent Execution & Telemetry Pipeline")
    print("=" * 70)

    # 1. Resolve Credentials
    api_key = os.getenv("AGENTLENS_API_KEY")
    proj_id = os.getenv("AGENTLENS_PROJECT_ID")

    if not api_key or not proj_id:
        print(f"\n[1/5] Resolving project credentials from AgentLens API ({API_URL})...")
        proj_id, api_key = get_or_create_project(API_URL)
        print(f"      Project ID: {proj_id}")
        print(f"      API Key:    {api_key[:12]}...")
    else:
        print(f"\n[1/5] Using configured project {proj_id}...")

    # 2. Initialize AgentLens SDK
    print("\n[2/5] Initializing AgentLens SDK client...")
    client = AgentLens(
        api_key=api_key,
        project_id=proj_id,
        environment=os.getenv("AGENTLENS_ENVIRONMENT", "development"),
        api_url=API_URL,
        capture_payloads=True,
    )

    # 3. Resolve LLM Provider
    llm_provider = get_configured_provider()
    print(f"\n[3/5] Active LLM Provider: {llm_provider.provider_name}")
    if getattr(llm_provider, "is_simulated", False) or "Simulated" in llm_provider.provider_name:
        print("      * Tip: Set GROQ_API_KEY (free) or OPENAI_API_KEY to execute genuine external LLM requests.")

    # 4. Execute Agent Workflow
    print(f"\n[4/5] Executing AI Agent for repository: '{target_repository}'...")

    with client.trace(
        agent_name="SoftwareIntelligenceAgent",
        session_id=f"sess_real_{int(time.time())}",
        user_identifier="lead_architect_alex",
        metadata={
            "domain": "open_source_observability",
            "target_repo": target_repository,
            "provider": llm_provider.provider_name,
        },
    ) as trace:

        # Step 1: Query live GitHub REST API
        print("      -> Step 1: Querying live GitHub REST API...")
        with trace.span(
            name="gather_live_repository_intelligence",
            span_type="AGENT_STEP",
            input_payload={"repository": target_repository},
        ) as step_gather:

            with step_gather.span(
                name="fetch_github_repository_stats",
                span_type="TOOL_CALL",
                input_payload={"owner_repo": target_repository},
                attributes={"tool_name": "github_rest_api", "version": "v3"},
            ) as tool_github:
                step_gather.event("outbound_http_initiated", {"endpoint": "api.github.com"})
                repo_data = fetch_github_repository_stats(target_repository)
                tool_github.set_output(repo_data)
                tool_github.set_attributes({"network_latency_ms": repo_data.get("network_latency_ms", 0)})

            step_gather.set_output({
                "stars": repo_data.get("stars", 0),
                "forks": repo_data.get("forks", 0),
                "open_issues": repo_data.get("open_issues", 0),
            })

        # Step 2: Compute structured analytical metrics
        print("      -> Step 2: Computing health metrics...")
        with trace.span(
            name="compute_health_analytics",
            span_type="AGENT_STEP",
            input_payload={"raw_stats": repo_data},
        ) as step_compute:

            with step_compute.span(
                name="calculate_repository_health_metrics",
                span_type="TOOL_CALL",
                input_payload={"repo_stats": repo_data},
                attributes={"tool_name": "health_score_calculator"},
            ) as tool_calc:
                health_metrics = calculate_repository_health_metrics(repo_data)
                tool_calc.set_output(health_metrics)

            step_compute.set_output({"composite_health_score": health_metrics["composite_health_score"]})

        # Step 3: LLM Synthesis
        print(f"      -> Step 3: Invoking LLM ({llm_provider.provider_name})...")
        prompt = (
            f"Analyze the following software repository metrics and provide an executive summary:\n"
            f"Repository: {target_repository}\n"
            f"Primary Language: {repo_data.get('primary_language')}\n"
            f"Stars: {repo_data.get('stars')}, Forks: {repo_data.get('forks')}, Issues: {repo_data.get('open_issues')}\n"
            f"Health Tier: {health_metrics.get('health_tier')} ({health_metrics.get('composite_health_score')}/100)\n"
            f"Provide 2-3 strategic observations regarding code health, community adoption, and maintainability."
        )

        with trace.span(
            name="synthesize_executive_report",
            span_type="AGENT_STEP",
            input_payload={"prompt_summary": f"Evaluation for {target_repository}"},
        ) as step_llm:

            with step_llm.span(
                name="llm_generate_evaluation",
                span_type="LLM_CALL",
                input_payload={"prompt": prompt},
                attributes={
                    "model": getattr(llm_provider, "model", "default"),
                    "provider": llm_provider.provider_name,
                },
            ) as span_llm:
                step_llm.event("llm_dispatch_started", {"provider": llm_provider.provider_name})
                llm_resp = llm_provider.generate(
                    prompt=prompt,
                    system_prompt="You are an expert Principal Systems Engineer and Open-Source Analyst.",
                )
                span_llm.set_output({"analysis": llm_resp.content})
                span_llm.set_tokens(
                    prompt_tokens=llm_resp.prompt_tokens,
                    completion_tokens=llm_resp.completion_tokens,
                    cost=llm_resp.estimated_cost_usd,
                )
                span_llm.set_attributes({
                    "is_simulated": llm_resp.is_simulated,
                    "model": llm_resp.model,
                })

            step_llm.set_output({"status": "analysis_generated", "length_chars": len(llm_resp.content)})

        # Record aggregate tokens and cost on root trace
        trace.set_tokens(
            prompt_tokens=llm_resp.prompt_tokens,
            completion_tokens=llm_resp.completion_tokens,
            cost=llm_resp.estimated_cost_usd,
        )

    # 5. Flush Telemetry
    print("\n[5/5] Flushing telemetry batch to AgentLens backend...")
    client.flush(timeout=5.0)
    client.shutdown(timeout=2.0)

    print("\n" + "=" * 70)
    print("SUCCESS: Real AI Agent Execution Completed & Ingested!")
    print(f"Trace ID:            {trace.id}")
    print(f"Agent Name:          SoftwareIntelligenceAgent")
    print(f"Target Repo:         {target_repository}")
    print(f"Health Score:        {health_metrics['composite_health_score']}/100 ({health_metrics['health_tier']})")
    print(f"LLM Provider:        {llm_provider.provider_name}")
    print(f"Tokens Recorded:     {llm_resp.total_tokens} ({llm_resp.prompt_tokens} prompt / {llm_resp.completion_tokens} completion)")
    print(f"Estimated Cost:      ${llm_resp.estimated_cost_usd:.6f}")
    print(f"Trace Duration:      {trace.duration_ms}ms")
    print("=" * 70)


if __name__ == "__main__":
    repo_arg = sys.argv[1] if len(sys.argv) > 1 else "Rhythmuppal18/AgentLens"
    run_real_ai_agent(repo_arg)
