from datetime import datetime, timedelta, timezone
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy import case, desc, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.models.environment import Environment
from app.models.finding import FailureFinding
from app.models.span import Span
from app.models.trace import Trace
from app.schemas.analytics import (
    ActivityDataPoint,
    AgentMetric,
    AnalyticsActivityResponse,
    AnalyticsOverviewResponse,
    AnalyticsPerformanceResponse,
    AnalyticsRulesResponse,
    RuleMetric,
    ToolMetric,
)
from app.services.rules import get_default_sla_thresholds

router = APIRouter(tags=["Analytics"])


def _calculate_time_window(time_range: Optional[str]) -> Optional[datetime]:
    if not time_range:
        return None
    now = datetime.now(timezone.utc)
    tr = time_range.lower()
    if tr == "1h":
        return now - timedelta(hours=1)
    elif tr == "24h":
        return now - timedelta(hours=24)
    elif tr == "7d":
        return now - timedelta(days=7)
    elif tr == "30d":
        return now - timedelta(days=30)
    return None


@router.get("/overview", response_model=AnalyticsOverviewResponse)
async def get_analytics_overview(
    project_id: Optional[UUID] = Query(None, description="Filter by Project UUID"),
    environment: Optional[str] = Query(None, description="Filter by environment name"),
    time_range: Optional[str] = Query("24h", description="Time window: 1h, 24h, 7d, 30d, all"),
    session: AsyncSession = Depends(get_db_session),
) -> AnalyticsOverviewResponse:
    """Calculates aggregated overview statistics from actual database records."""
    since = _calculate_time_window(time_range)

    # 1. Total executions, failed executions, token totals, cost totals, last telemetry timestamp
    agg_query = (
        select(
            func.count(Trace.id).label("total_executions"),
            func.count(
                case(
                    (Trace.status.in_(["ERROR", "FAILED"]), 1),
                    (Trace.has_failures.is_(True), 1),
                    else_=None,
                )
            ).label("failed_executions"),
            func.avg(Trace.duration_ms).label("avg_duration"),
            func.sum(Trace.total_tokens).label("total_tokens"),
            func.sum(Trace.estimated_cost_usd).label("total_cost"),
            func.max(Trace.start_time).label("last_telemetry_at"),
        )
        .outerjoin(Environment, Trace.environment_id == Environment.id)
    )

    if project_id is not None:
        agg_query = agg_query.where(Trace.project_id == project_id)
    if environment:
        agg_query = agg_query.where(
            or_(
                Environment.name.ilike(environment),
                Environment.slug.ilike(environment),
            )
        )
    if since is not None:
        agg_query = agg_query.where(Trace.start_time >= since)

    agg_res = (await session.execute(agg_query)).first()

    total_executions = agg_res.total_executions or 0
    failed_executions = agg_res.failed_executions or 0
    avg_duration = int(agg_res.avg_duration) if agg_res.avg_duration is not None else None
    total_tokens = int(agg_res.total_tokens) if agg_res.total_tokens is not None else None
    total_cost = float(agg_res.total_cost) if agg_res.total_cost is not None else None
    last_telemetry = agg_res.last_telemetry_at

    error_rate = (
        round((failed_executions / total_executions) * 100, 1)
        if total_executions > 0
        else 0.0
    )

    # 2. P95 latency calculation via percentile_cont
    p95_latency = None
    if total_executions > 0:
        p95_query = (
            select(
                func.percentile_cont(0.95).within_group(Trace.duration_ms)
            )
            .outerjoin(Environment, Trace.environment_id == Environment.id)
            .where(Trace.duration_ms.isnot(None))
        )
        if project_id is not None:
            p95_query = p95_query.where(Trace.project_id == project_id)
        if environment:
            p95_query = p95_query.where(
                or_(
                    Environment.name.ilike(environment),
                    Environment.slug.ilike(environment),
                )
            )
        if since is not None:
            p95_query = p95_query.where(Trace.start_time >= since)

        p95_val = (await session.execute(p95_query)).scalar_one_or_none()
        if p95_val is not None:
            p95_latency = int(p95_val)

    # 3. Total spans count
    span_query = select(func.count(Span.id)).join(Trace, Span.trace_id == Trace.id)
    if project_id is not None:
        span_query = span_query.where(Trace.project_id == project_id)
    if environment:
        span_query = span_query.join(Environment, Trace.environment_id == Environment.id).where(
            or_(
                Environment.name.ilike(environment),
                Environment.slug.ilike(environment),
            )
        )
    if since is not None:
        span_query = span_query.where(Trace.start_time >= since)

    total_spans = (await session.execute(span_query)).scalar_one() or 0

    return AnalyticsOverviewResponse(
        total_executions=total_executions,
        failed_executions=failed_executions,
        error_rate=error_rate,
        p95_latency_ms=p95_latency,
        average_latency_ms=avg_duration,
        total_tokens=total_tokens,
        estimated_cost_usd=total_cost,
        is_telemetry_standby=(total_executions == 0),
        last_telemetry_at=last_telemetry,
        total_spans=total_spans,
    )


@router.get("/activity", response_model=AnalyticsActivityResponse)
async def get_analytics_activity(
    project_id: Optional[UUID] = Query(None, description="Filter by Project UUID"),
    environment: Optional[str] = Query(None, description="Filter by environment name"),
    time_range: Optional[str] = Query("24h", description="Time window: 1h, 24h, 7d, 30d"),
    session: AsyncSession = Depends(get_db_session),
) -> AnalyticsActivityResponse:
    """Returns time-bucketed activity timeseries for execution and error charts."""
    now = datetime.now(timezone.utc)
    tr = (time_range or "24h").lower()

    if tr == "1h":
        bucket_count = 6
        step = timedelta(minutes=10)
        start = now - timedelta(hours=1)
        fmt = "%H:%M"
        bucket_interval = "10m"
    elif tr == "7d":
        bucket_count = 7
        step = timedelta(days=1)
        start = now - timedelta(days=7)
        fmt = "%b %d"
        bucket_interval = "1d"
    elif tr == "30d":
        bucket_count = 10
        step = timedelta(days=3)
        start = now - timedelta(days=30)
        fmt = "%b %d"
        bucket_interval = "3d"
    else:  # default 24h
        bucket_count = 8
        step = timedelta(hours=3)
        start = now - timedelta(hours=24)
        fmt = "%H:%M"
        bucket_interval = "3h"

    # Query matching traces
    query = (
        select(Trace.start_time, Trace.status, Trace.has_failures)
        .outerjoin(Environment, Trace.environment_id == Environment.id)
        .where(Trace.start_time >= start)
    )
    if project_id is not None:
        query = query.where(Trace.project_id == project_id)
    if environment:
        query = query.where(
            or_(
                Environment.name.ilike(environment),
                Environment.slug.ilike(environment),
            )
        )

    traces = (await session.execute(query)).all()

    # Bucket data points
    buckets: list[ActivityDataPoint] = []
    for i in range(bucket_count):
        b_start = start + (i * step)
        b_end = b_start + step
        b_label = b_end.strftime(fmt)

        exec_count = 0
        err_count = 0
        for t_start, t_status, t_fail in traces:
            if b_start <= t_start < b_end:
                exec_count += 1
                if t_status in ("ERROR", "FAILED") or t_fail is True:
                    err_count += 1

        buckets.append(
            ActivityDataPoint(
                timestamp=b_label,
                executions=exec_count,
                errors=err_count,
            )
        )

    return AnalyticsActivityResponse(
        time_range=time_range or "24h",
        bucket_interval=bucket_interval,
        data_points=buckets,
    )


@router.get("/rules", response_model=AnalyticsRulesResponse)
async def get_analytics_rules(
    project_id: Optional[UUID] = Query(None, description="Filter by Project UUID"),
    environment: Optional[str] = Query(None, description="Filter by environment name"),
    time_range: Optional[str] = Query("24h", description="Time window: 1h, 24h, 7d, 30d, all"),
    session: AsyncSession = Depends(get_db_session),
) -> AnalyticsRulesResponse:
    """Returns violation statistics across the five deterministic failure detection rules."""
    query = select(
        FailureFinding.rule_type,
        func.count(FailureFinding.id).label("count"),
    ).join(Trace, FailureFinding.trace_id == Trace.id)

    if project_id is not None:
        query = query.where(Trace.project_id == project_id)
    if environment:
        query = query.join(Environment, Trace.environment_id == Environment.id).where(
            or_(
                Environment.name.ilike(environment),
                Environment.slug.ilike(environment),
            )
        )
    since = _calculate_time_window(time_range)
    if since is not None:
        query = query.where(FailureFinding.first_detected_at >= since)

    query = query.group_by(FailureFinding.rule_type)
    counts = dict((await session.execute(query)).all())

    sla_thresholds = get_default_sla_thresholds()

    rules_meta = [
        {
            "rule_type": "FAILED_SPAN",
            "name": "Failed Span",
            "severity": "CRITICAL",
        },
        {
            "rule_type": "REPEATED_TOOL_CALL",
            "name": "Repeated Tool Call",
            "severity": "HIGH",
        },
        {
            "rule_type": "EXCESSIVE_RETRIES",
            "name": "Excessive Retries",
            "severity": "HIGH",
        },
        {
            "rule_type": "SLOW_SPAN",
            "name": "Slow Span",
            "severity": "WARNING",
            "configured_thresholds_ms": sla_thresholds,
        },
        {
            "rule_type": "EMPTY_TOOL_RESULT",
            "name": "Empty Tool Result",
            "severity": "WARNING",
        },
    ]

    rules = [
        RuleMetric(
            rule_type=rm["rule_type"],
            name=rm["name"],
            violations_count=counts.get(rm["rule_type"], 0),
            severity=rm["severity"],
            status="active",
            configured_thresholds_ms=rm.get("configured_thresholds_ms"),
        )
        for rm in rules_meta
    ]

    return AnalyticsRulesResponse(rules=rules)


@router.get("/performance", response_model=AnalyticsPerformanceResponse)
async def get_analytics_performance(
    project_id: Optional[UUID] = Query(None, description="Filter by Project UUID"),
    environment: Optional[str] = Query(None, description="Filter by environment name"),
    time_range: Optional[str] = Query("24h", description="Time window: 1h, 24h, 7d, 30d, all"),
    session: AsyncSession = Depends(get_db_session),
) -> AnalyticsPerformanceResponse:
    """Calculates agent execution metrics and tool call performance breakdown."""
    since = _calculate_time_window(time_range)

    # 1. Agent metrics
    agent_query = (
        select(
            Trace.agent_name,
            func.count(Trace.id).label("total_executions"),
            func.count(
                case((Trace.status.in_(["ERROR", "FAILED"]), 1), (Trace.has_failures.is_(True), 1), else_=None)
            ).label("failed_executions"),
            func.avg(Trace.duration_ms).label("avg_duration"),
            func.sum(Trace.total_tokens).label("total_tokens"),
        )
        .outerjoin(Environment, Trace.environment_id == Environment.id)
        .group_by(Trace.agent_name)
    )

    if project_id is not None:
        agent_query = agent_query.where(Trace.project_id == project_id)
    if environment:
        agent_query = agent_query.where(
            or_(
                Environment.name.ilike(environment),
                Environment.slug.ilike(environment),
            )
        )
    if since is not None:
        agent_query = agent_query.where(Trace.start_time >= since)

    agent_rows = (await session.execute(agent_query)).all()
    agents = [
        AgentMetric(
            agent_name=r.agent_name,
            total_executions=r.total_executions,
            failed_executions=r.failed_executions,
            error_rate=round((r.failed_executions / r.total_executions) * 100, 1) if r.total_executions else 0.0,
            average_duration_ms=int(r.avg_duration) if r.avg_duration is not None else None,
            total_tokens=int(r.total_tokens) if r.total_tokens is not None else None,
        )
        for r in agent_rows
    ]

    # 2. Tool metrics
    tool_query = (
        select(
            Span.name.label("tool_name"),
            func.count(Span.id).label("total_calls"),
            func.count(case((Span.status == "ERROR", 1), else_=None)).label("failed_calls"),
            func.avg(Span.duration_ms).label("avg_duration"),
        )
        .join(Trace, Span.trace_id == Trace.id)
        .where(Span.span_type == "TOOL_CALL")
        .group_by(Span.name)
    )

    if project_id is not None:
        tool_query = tool_query.where(Trace.project_id == project_id)
    if environment:
        tool_query = tool_query.join(Environment, Trace.environment_id == Environment.id).where(
            or_(
                Environment.name.ilike(environment),
                Environment.slug.ilike(environment),
            )
        )
    if since is not None:
        tool_query = tool_query.where(Span.start_time >= since)

    tool_rows = (await session.execute(tool_query)).all()
    tools = [
        ToolMetric(
            tool_name=r.tool_name,
            total_calls=r.total_calls,
            failed_calls=r.failed_calls,
            error_rate=round((r.failed_calls / r.total_calls) * 100, 1) if r.total_calls else 0.0,
            average_duration_ms=int(r.avg_duration) if r.avg_duration is not None else None,
        )
        for r in tool_rows
    ]

    return AnalyticsPerformanceResponse(agents=agents, tools=tools)
