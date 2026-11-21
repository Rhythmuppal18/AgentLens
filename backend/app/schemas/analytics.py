from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel


class AnalyticsOverviewResponse(BaseModel):
    total_executions: int
    failed_executions: int
    error_rate: float
    p95_latency_ms: Optional[int] = None
    average_latency_ms: Optional[int] = None
    total_tokens: Optional[int] = None
    estimated_cost_usd: Optional[float] = None
    is_telemetry_standby: bool
    last_telemetry_at: Optional[datetime] = None
    total_spans: int = 0


class ActivityDataPoint(BaseModel):
    timestamp: str
    executions: int
    errors: int


class AnalyticsActivityResponse(BaseModel):
    time_range: str
    bucket_interval: str
    data_points: list[ActivityDataPoint]


class RuleMetric(BaseModel):
    rule_type: str
    name: str
    violations_count: int
    severity: str
    status: str
    configured_thresholds_ms: Optional[dict[str, int]] = None


class AnalyticsRulesResponse(BaseModel):
    rules: list[RuleMetric]


class AgentMetric(BaseModel):
    agent_name: str
    total_executions: int
    failed_executions: int
    error_rate: float
    average_duration_ms: Optional[int] = None
    total_tokens: Optional[int] = None


class ToolMetric(BaseModel):
    tool_name: str
    total_calls: int
    failed_calls: int
    error_rate: float
    average_duration_ms: Optional[int] = None


class AnalyticsPerformanceResponse(BaseModel):
    agents: list[AgentMetric]
    tools: list[ToolMetric]
