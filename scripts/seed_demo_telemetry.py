import asyncio
import os
import sys
import time
import json
import urllib.request
import urllib.error

sys.path.insert(0, os.path.abspath("sdk"))

import agentlens

API_URL = "http://localhost:8000"

def http_json(method: str, path: str, data: dict = None, headers: dict = None):
    url = f"{API_URL}{path}"
    req_headers = {"Accept": "application/json"}
    if headers:
        req_headers.update(headers)
    
    body = None
    if data is not None:
        body = json.dumps(data).encode("utf-8")
        req_headers["Content-Type"] = "application/json"
    
    req = urllib.request.Request(url, data=body, headers=req_headers, method=method)
    with urllib.request.urlopen(req, timeout=5) as res:
        res_data = res.read().decode("utf-8")
        return json.loads(res_data) if res_data else {}

def main():
    print("1. Creating or fetching demo project: 'Autonomous Agent Service'...")
    # Check if project already exists
    projects = http_json("GET", "/api/v1/projects")
    demo_proj = next((p for p in projects if p["name"] == "Autonomous Agent Service"), None)

    if not demo_proj:
        demo_proj = http_json(
            "POST",
            "/api/v1/projects",
            data={"name": "Autonomous Agent Service", "slug": "autonomous-agent-service"},
        )
        api_key = demo_proj["api_key"]
        print(f"Created new demo project: ID={demo_proj['id']}, API_KEY={api_key[:12]}...")
    else:
        # Regenerate API key so we have the plaintext key
        key_data = http_json("POST", f"/api/v1/projects/{demo_proj['id']}/api-key")
        api_key = key_data["api_key"]
        print(f"Found existing demo project: ID={demo_proj['id']}, refreshed API_KEY={api_key[:12]}...")

    proj_id = demo_proj["id"]

    print("\n2. Initializing AgentLens SDK with live project credentials...")
    client = agentlens.init(
        api_key=api_key,
        project_id=proj_id,
        environment="development",
        api_url=API_URL,
        capture_payloads=True,
    )

    print("\n3. Generating Trace 1: Successful multi-step Market Research Agent...")
    with client.trace(
        agent_name="MarketResearchAgent",
        session_id="sess_demo_001",
        user_identifier="analyst_sarah",
        metadata={"domain": "equities", "priority": "high"},
    ) as t1:
        with client.span(
            name="gather_company_intelligence",
            span_type="AGENT_STEP",
            input_payload={"company": "NVDA", "depth": "detailed"},
        ):
            time.sleep(0.05)
            with client.span(
                name="sec_filings_api",
                span_type="TOOL_CALL",
                input_payload={"ticker": "NVDA", "form": "10-K", "year": 2024},
                attributes={"tool_name": "sec_filings_api"},
            ) as s_tool:
                time.sleep(0.04)
                s_tool.event("query_initiated", {"endpoint": "sec_edgar_v2"})
                s_tool.set_output({"status": "success", "filing_found": True, "pages": 142})

            with client.span(
                name="llm_financial_summary",
                span_type="LLM_CALL",
                input_payload={"prompt": "Summarize revenue drivers from NVDA 10-K..."},
                attributes={"model": "gpt-4o", "prompt_tokens": 1250, "completion_tokens": 320},
            ) as s_llm:
                time.sleep(0.08)
                s_llm.set_output({"analysis": "Robust 122% data center revenue acceleration observed."})

        t1.set_tokens(prompt_tokens=1250, completion_tokens=320, cost=0.0345)

    print("\n4. Generating Trace 2: Failing Customer Support Agent (Triggers FAILED_SPAN & REPEATED_TOOL_CALL)...")
    with client.trace(
        agent_name="SupportTriageAgent",
        session_id="sess_demo_002",
        user_identifier="user_enterprise_99",
        metadata={"queue": "critical_incidents", "ticket_id": "INC-8891"},
    ) as t2:
        with client.span(
            name="triage_workflow",
            span_type="AGENT_STEP",
            input_payload={"ticket_id": "INC-8891", "subject": "Billing service outage"},
        ):
            time.sleep(0.03)

            # Repeated failing tool call 1
            try:
                with client.span(
                    name="crm_customer_lookup",
                    span_type="TOOL_CALL",
                    input_payload={"account_id": "acc_77182", "service": "crm_gateway"},
                    attributes={"tool_name": "crm_customer_lookup", "retry_count": 1},
                ) as s_f1:
                    time.sleep(0.03)
                    s_f1.event("http_error", {"status_code": 503, "gateway": "crm-prod-us-east"})
                    raise ConnectionResetError("503 Service Unavailable: CRM gateway connection refused")
            except Exception:
                pass

            # Repeated failing tool call 2 (identical input)
            try:
                with client.span(
                    name="crm_customer_lookup",
                    span_type="TOOL_CALL",
                    input_payload={"account_id": "acc_77182", "service": "crm_gateway"},
                    attributes={"tool_name": "crm_customer_lookup", "retry_count": 2},
                ) as s_f2:
                    time.sleep(0.03)
                    s_f2.event("http_error", {"status_code": 503, "gateway": "crm-prod-us-east"})
                    raise ConnectionResetError("503 Service Unavailable: CRM gateway connection refused")
            except Exception:
                pass

            # Repeated failing tool call 3 (identical input >= 3 times triggers Rule 2)
            try:
                with client.span(
                    name="crm_customer_lookup",
                    span_type="TOOL_CALL",
                    input_payload={"account_id": "acc_77182", "service": "crm_gateway"},
                    attributes={"tool_name": "crm_customer_lookup", "retry_count": 3},
                ) as s_f3:
                    time.sleep(0.03)
                    s_f3.event("http_error", {"status_code": 503, "gateway": "crm-prod-us-east"})
                    raise ConnectionResetError("503 Service Unavailable: CRM gateway connection refused")
            except Exception:
                pass

        t2.set_tokens(prompt_tokens=450, completion_tokens=0, cost=0.0090)
        t2.status = "ERROR"

    print("\n5. Generating Trace 3: SLA Latency Violation (Triggers SLOW_SPAN)...")
    with client.trace(
        agent_name="LegalComplianceAgent",
        session_id="sess_demo_003",
        user_identifier="compliance_officer_dan",
    ) as t3:
        with client.span(
            name="parse_regulatory_statutes",
            span_type="AGENT_STEP",
            input_payload={"document_pages": 450},
        ) as s_step:
            s_step.set_duration(16500)  # SLA is 15000ms

            with client.span(
                name="claude_statute_parser",
                span_type="LLM_CALL",
                input_payload={"prompt": "Extract regulatory non-compliance risks..."},
                attributes={"model": "claude-3-opus"},
            ) as s_slow_llm:
                s_slow_llm.set_duration(11800)  # LLM SLA is 10000ms
                s_slow_llm.set_output({"clauses_extracted": 34})

        t3.set_tokens(prompt_tokens=2800, completion_tokens=400, cost=0.0780)

    print("\n6. Flushing SDK background telemetry queue to backend...")
    flushed = client.flush(timeout=5.0)
    print(f"Flush completed: {flushed}")

    # Allow brief moment for server async transaction
    time.sleep(1.0)

    print("\n7. Verifying ingested telemetry in Backend APIs:")
    # 7a. Overview
    overview = http_json(
        "GET",
        f"/api/v1/analytics/overview?project_id={proj_id}&environment=development",
    )
    print(f"Overview Analytics: {overview}")

    # 7b. Traces
    traces_data = http_json(
        "GET",
        f"/api/v1/traces?project_id={proj_id}&environment=development",
    )
    print(f"Traces count: {traces_data.get('total')} traces returned.")
    for tr in traces_data.get("items", []):
        print(f" - [{tr['status']}] {tr['agent_name']} ({tr['duration_ms']}ms, {tr['total_tokens']} tokens, ${tr['estimated_cost_usd']})")

    # 7c. Failures
    fail_data = http_json(
        "GET",
        f"/api/v1/failures?project_id={proj_id}&environment=development",
    )
    print(f"Failure Findings count: {fail_data.get('total')} findings detected.")
    for f in fail_data.get("items", []):
        print(f" - [{f['severity']}] {f['rule_type']}: {f['summary']}")

    # 7d. Rules Metrics
    rules_data = http_json(
        "GET",
        f"/api/v1/analytics/rules?project_id={proj_id}&environment=development",
    )
    print("Deterministic Rules Breakdown:")
    for r in rules_data.get("rules", []):
        print(f" - {r['name']} ({r['rule_type']}): violations={r['violations_count']}, status={r['status']}")

if __name__ == "__main__":
    main()
