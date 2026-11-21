"""03_error_capture.py - Exception and Failure Tracing with AgentLens

Demonstrates how AgentLens automatically captures unhandled exceptions, error stacks,
and failure findings without breaking host application execution.
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


class DatabaseConnectionTimeout(Exception):
    """Simulated database connection failure."""
    pass


def execute_failing_task():
    print("Running agent task that encounters an unhandled exception...")

    try:
        with client.trace(
            agent_name="DataMigrationAgent",
            session_id="sess_error_demo",
        ) as trace:
            with trace.span(name="migrate_table_records", span_type="AGENT_STEP") as step:
                with step.span(
                    name="connect_remote_database",
                    span_type="TOOL_CALL",
                    input_payload={"host": "db.internal.cloud", "port": 5432},
                    attributes={"retry_count": 4},  # Triggers Rule 3: EXCESSIVE_RETRIES
                ) as tool_span:
                    time.sleep(0.05)
                    # Simulate failure
                    raise DatabaseConnectionTimeout("Connection to db.internal.cloud timed out after 5000ms")

    except DatabaseConnectionTimeout as exc:
        print(f"Caught expected application exception: {exc}")
        print("AgentLens captured error_message, error_type, and error_stack automatically!")


if __name__ == "__main__":
    execute_failing_task()
    client.flush(timeout=5.0)
