import React, { useEffect, useState } from 'react';
import {
  BarChart3,
  Clock,
  Coins,
  Wrench,
  Bot
} from 'lucide-react';
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip
} from 'recharts';
import { useApp } from '../../context/useApp';
import {
  fetchAnalyticsOverview,
  fetchAnalyticsActivity,
  fetchAnalyticsRules,
  fetchAnalyticsPerformance
} from '../../services/api';
import type {
  ActivityDataPoint,
  AgentMetric,
  AnalyticsOverview,
  RuleMetric,
  ToolMetric
} from '../../types';

export const AnalyticsView: React.FC = () => {
  const { currentProject, environment, dateRange } = useApp();

  const [overview, setOverview] = useState<AnalyticsOverview>({
    totalExecutions: 0,
    failedExecutions: 0,
    errorRate: 0,
    p95LatencyMs: null,
    avgDurationMs: null,
    totalTokens: 0,
    estimatedCostUsd: 0,
    isTelemetryStandby: true,
  });

  const [activityData, setActivityData] = useState<ActivityDataPoint[]>([]);
  const [ruleMetrics, setRuleMetrics] = useState<RuleMetric[]>([]);
  const [agentMetrics, setAgentMetrics] = useState<AgentMetric[]>([]);
  const [toolMetrics, setToolMetrics] = useState<ToolMetric[]>([]);

  useEffect(() => {
    let isMounted = true;

    async function loadAnalytics() {
      try {
        const [ov, act, rls, perf] = await Promise.all([
          fetchAnalyticsOverview({
            project_id: currentProject?.id,
            environment,
            time_range: dateRange,
          }),
          fetchAnalyticsActivity({
            project_id: currentProject?.id,
            environment,
            time_range: dateRange,
          }),
          fetchAnalyticsRules({
            project_id: currentProject?.id,
            environment,
            time_range: dateRange,
          }),
          fetchAnalyticsPerformance({
            project_id: currentProject?.id,
            environment,
            time_range: dateRange,
          }),
        ]);

        if (isMounted) {
          setOverview(ov);
          setActivityData(act);
          setRuleMetrics(rls);
          setAgentMetrics(perf.agents);
          setToolMetrics(perf.tools);
        }
      } catch {
        // Fall back gracefully
      }
    }

    loadAnalytics();
    const interval = setInterval(loadAnalytics, 15000);
    return () => {
      isMounted = false;
      clearInterval(interval);
    };
  }, [currentProject?.id, environment, dateRange]);

  const hasActivityData = activityData.some((a) => a.total > 0);
  const hasRuleData = ruleMetrics.some((r) => r.count > 0);

  // Compute tool reliability %
  const totalToolCalls = toolMetrics.reduce((acc, t) => acc + t.calls, 0);
  const totalToolErrors = toolMetrics.reduce((acc, t) => acc + Math.round(t.calls * (t.errorRate > 1 ? t.errorRate / 100 : t.errorRate)), 0);
  const toolReliability = totalToolCalls > 0
    ? `${((1 - totalToolErrors / totalToolCalls) * 100).toFixed(1)}%`
    : '100.0%';

  const defaultRules = [
    { rule: 'Failed Span', count: 0 },
    { rule: 'Repeated Tool', count: 0 },
    { rule: 'Excessive Retries', count: 0 },
    { rule: 'Slow Span', count: 0 },
    { rule: 'Empty Tool', count: 0 },
  ];

  const ruleChartData = ruleMetrics.length > 0
    ? ruleMetrics.map((r) => ({
        rule: r.name.replace(' Call', '').replace(' Result', ''),
        count: r.count,
      }))
    : defaultRules;

  return (
    <div className="space-y-4 animate-in fade-in duration-150">
      {/* Top Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="p-1.5 rounded-md bg-[#171c19] text-[#b8f56a] border border-[#252d28]">
              <BarChart3 className="h-4 w-4" />
            </div>
            <h1 className="text-base font-semibold text-[#f5f7f5] font-mono tracking-tight">
              Performance & Cost Analytics
            </h1>
            <span className="px-2 py-0.5 text-[9px] font-mono font-semibold uppercase tracking-wider rounded-xs bg-[#b8f56a]/10 text-[#b8f56a] border border-[#b8f56a]/30">
              Analytics
            </span>
          </div>
        </div>

        <div className="text-xs font-mono text-[#626b64] self-start sm:self-auto bg-[#0c0e0d] px-3 py-1.5 rounded-md border border-[#252d28]">
          Range: <span className="text-[#b8f56a]">{dateRange}</span>
        </div>
      </div>

      {/* Top Metrics Strip */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 border border-[#252d28] bg-[#0c0e0d] divide-y sm:divide-y-0 sm:divide-x divide-[#252d28] rounded-md overflow-hidden">
        <div className="p-4 flex flex-col justify-between space-y-2 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#626b64]">
            <span className="text-[10px] uppercase tracking-wider">Total Tokens</span>
            <Coins className="h-3.5 w-3.5 text-[#6bc8c1]" />
          </div>
          <div>
            <div className="text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">
              {overview.totalTokens.toLocaleString()}
            </div>
            <p className="text-[10px] font-mono text-[#626b64] mt-0.5">Prompt & Completion tokens</p>
          </div>
        </div>

        <div className="p-4 flex flex-col justify-between space-y-2 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#626b64]">
            <span className="text-[10px] uppercase tracking-wider">Estimated Cost</span>
            <Coins className="h-3.5 w-3.5 text-[#b8f56a]" />
          </div>
          <div>
            <div className="text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">
              ${overview.estimatedCostUsd.toFixed(4)}
            </div>
            <p className="text-[10px] font-mono text-[#626b64] mt-0.5">Calculated from telemetry spans</p>
          </div>
        </div>

        <div className="p-4 flex flex-col justify-between space-y-2 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#626b64]">
            <span className="text-[10px] uppercase tracking-wider">P95 Latency</span>
            <Clock className="h-3.5 w-3.5 text-[#e5ad55]" />
          </div>
          <div>
            <div className="text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">
              {overview.p95LatencyMs !== null ? `${overview.p95LatencyMs} ms` : '-- ms'}
            </div>
            <p className="text-[10px] font-mono text-[#626b64] mt-0.5">95th percentile span time</p>
          </div>
        </div>

        <div className="p-4 flex flex-col justify-between space-y-2 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#626b64]">
            <span className="text-[10px] uppercase tracking-wider">Tool Reliability</span>
            <Wrench className="h-3.5 w-3.5 text-[#67c98a]" />
          </div>
          <div>
            <div className="text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">
              {toolReliability}
            </div>
            <p className="text-[10px] font-mono text-[#626b64] mt-0.5">
              {totalToolErrors} exceptions across {totalToolCalls} calls
            </p>
          </div>
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Chart 1: Execution Volume */}
        <div className="p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
            <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Execution Volume Trend
            </h2>
            <span className="text-[10px] font-mono text-[#626b64]">Time bucketed activity</span>
          </div>

          <div className="relative h-48 w-full pt-2">
            <ResponsiveContainer width="100%" height={180} minWidth={0} minHeight={180}>
              <AreaChart data={activityData} margin={{ top: 10, right: 10, left: -25, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#1c221e" vertical={false} />
                <XAxis dataKey="time" stroke="#626b64" fontSize={10} tickLine={false} fontFamily="monospace" />
                <YAxis stroke="#626b64" fontSize={10} tickLine={false} allowDecimals={false} fontFamily="monospace" />
                <Tooltip
                  contentStyle={{ backgroundColor: '#111512', borderColor: '#252d28', borderRadius: 4, fontFamily: 'monospace', fontSize: 11 }}
                  itemStyle={{ color: '#b8f56a' }}
                />
                <Area type="monotone" dataKey="total" name="Executions" stroke="#b8f56a" fill="#b8f56a" fillOpacity={0.12} strokeWidth={1.5} />
                <Area type="monotone" dataKey="failed" name="Failed" stroke="#f06f68" fill="#f06f68" fillOpacity={0.15} strokeWidth={1.5} />
              </AreaChart>
            </ResponsiveContainer>
            {!hasActivityData && (
              <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
                <span className="px-3 py-1 bg-[#111412] border border-[#252d28] text-xs font-mono text-[#626b64] rounded-xs">
                  Awaiting Execution Volume Telemetry
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Chart 2: Failure Trends by Rule */}
        <div className="p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
            <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Failure Distribution by Rule
            </h2>
            <span className="text-[10px] font-mono text-[#626b64]">5 Detection Rules</span>
          </div>

          <div className="relative h-48 w-full pt-2">
            <ResponsiveContainer width="100%" height={180} minWidth={0} minHeight={180}>
              <BarChart data={ruleChartData} margin={{ top: 10, right: 10, left: -25, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#1c221e" vertical={false} />
                <XAxis dataKey="rule" stroke="#626b64" fontSize={9} tickLine={false} fontFamily="monospace" />
                <YAxis stroke="#626b64" fontSize={10} tickLine={false} allowDecimals={false} fontFamily="monospace" />
                <Tooltip
                  contentStyle={{ backgroundColor: '#111512', borderColor: '#252d28', borderRadius: 4, fontFamily: 'monospace', fontSize: 11 }}
                  itemStyle={{ color: '#e5ad55' }}
                />
                <Bar dataKey="count" name="Violations" fill="#e5ad55" radius={[2, 2, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
            {!hasRuleData && (
              <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
                <span className="px-3 py-1 bg-[#111412] border border-[#252d28] text-xs font-mono text-[#626b64] rounded-xs">
                  0 Violations Flagged Across Rules
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Chart 3: Agent Performance Summary */}
        <div className="p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
            <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Agent Performance Summary
            </h2>
            <span className="text-[10px] font-mono text-[#626b64]">Executions & Duration</span>
          </div>

          {agentMetrics.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs font-mono">
                <thead>
                  <tr className="border-b border-[#1c221e] text-[10px] text-[#88948a] uppercase">
                    <th className="pb-2">Agent Name</th>
                    <th className="pb-2">Executions</th>
                    <th className="pb-2">Error Rate</th>
                    <th className="pb-2 text-right">Avg Duration</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#1c221e]">
                  {agentMetrics.map((a) => (
                    <tr key={a.agentName} className="hover:bg-[#111512]">
                      <td className="py-2 text-[#b8f56a] flex items-center gap-1.5">
                        <Bot className="h-3 w-3 text-[#6bc8c1]" />
                        <span>{a.agentName}</span>
                      </td>
                      <td className="py-2 text-[#f5f7f5]">{a.executions}</td>
                      <td className="py-2 text-[#e5ad55]">{a.errorRate.toFixed(1)}%</td>
                      <td className="py-2 text-[#9ba69e] text-right">{a.avgDurationMs}ms</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="py-12 text-center space-y-2">
              <Bot className="h-6 w-6 text-[#626b64] mx-auto" />
              <p className="text-xs font-mono text-[#f5f7f5]">No Agent Executions Recorded</p>
              <p className="text-[11px] text-[#929b94] font-sans max-w-sm mx-auto">
                Agent names, execution counts, error rates, and average durations will populate as agents execute.
              </p>
            </div>
          )}
        </div>

        {/* Chart 4: Tool Invocations & Frequency */}
        <div className="p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
            <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Tool Usage Breakdown
            </h2>
            <span className="text-[10px] font-mono text-[#626b64]">Frequency & Reliability</span>
          </div>

          {toolMetrics.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs font-mono">
                <thead>
                  <tr className="border-b border-[#1c221e] text-[10px] text-[#88948a] uppercase">
                    <th className="pb-2">Tool Name</th>
                    <th className="pb-2">Calls</th>
                    <th className="pb-2">Error Rate</th>
                    <th className="pb-2 text-right">Avg Duration</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#1c221e]">
                  {toolMetrics.map((t) => (
                    <tr key={t.toolName} className="hover:bg-[#111512]">
                      <td className="py-2 text-[#b8f56a] flex items-center gap-1.5">
                        <Wrench className="h-3 w-3 text-[#b8f56a]" />
                        <span>{t.toolName}</span>
                      </td>
                      <td className="py-2 text-[#f5f7f5]">{t.calls}</td>
                      <td className="py-2 text-[#e5ad55]">{t.errorRate.toFixed(1)}%</td>
                      <td className="py-2 text-[#9ba69e] text-right">{t.avgDurationMs}ms</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="py-12 text-center space-y-2">
              <Wrench className="h-6 w-6 text-[#626b64] mx-auto" />
              <p className="text-xs font-mono text-[#f5f7f5]">No Tool Invocations Recorded</p>
              <p className="text-[11px] text-[#929b94] font-sans max-w-sm mx-auto">
                Tool calling frequency, execution times, and return schema validations will populate as tools execute.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
