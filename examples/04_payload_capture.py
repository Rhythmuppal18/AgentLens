"""04_payload_capture.py - Opt-In Payload Capture & Sensitive Data Redaction

Demonstrates:
1. Automatic redaction of sensitive credentials (api_key, bearer, secret, password).
2. Large payload string truncation (>64KB preview).
3. Canonical input hashing for O(1) duplicate tool call detection.
"""

import os

from agentlens import AgentLens

client = AgentLens(
    api_key=os.getenv("AGENTLENS_API_KEY", "al_dev_mock_key"),
    project_id=os.getenv("AGENTLENS_PROJECT_ID", "11111111-2222-3333-4444-555555555555"),
    environment="development",
    api_url=os.getenv("AGENTLENS_API_URL", "http://localhost:8000"),
    capture_payloads=True,  # Explicitly opt-in to payload capture
)


def run_redaction_demo():
    print("Running agent with sensitive parameters and large payloads...")

    # Sensitive inputs that should be redacted
    sensitive_input = {
        "api_key": "sk-secret-prod-1234567890",
        "auth_token": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "db_password": "super_secret_db_password",
        "query": "SELECT * FROM customer_accounts",
    }

    # Extremely large payload exceeding 64KB
    large_payload_text = "A" * (80 * 1024)

    with client.trace(agent_name="SecureDataIngestAgent") as trace:
        with trace.span(
            name="query_customer_api",
            span_type="TOOL_CALL",
            input_payload=sensitive_input,
        ) as tool_span:
            # Notice that input_hash was still computed deterministically!
            print(f"Deterministic input_hash computed: {tool_span.input_hash}")

            # Return large output payload
            tool_span.set_output({
                "status": "success",
                "raw_response": large_payload_text,
            })

    print("Demonstration completed. Sensitive fields are redacted to '[REDACTED]' and oversized strings are truncated.")


if __name__ == "__main__":
    run_redaction_demo()
    client.flush(timeout=5.0)
