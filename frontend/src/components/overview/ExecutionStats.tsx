import React, { useEffect, useState } from 'react';
import { PlayCircle, AlertTriangle, Percent, Clock } from 'lucide-react';
import { useApp } from '../../context/useApp';
import { fetchAnalyticsOverview } from '../../services/api';
import type { AnalyticsOverview } from '../../types';

export const ExecutionStats: React.FC = () => {
  const { currentProject, environment, dateRange } = useApp();
  const [stats, setStats] = useState<AnalyticsOverview>({
    totalExecutions: 0,
    failedExecutions: 0,
    errorRate: 0,
    p95LatencyMs: null,
    avgDurationMs: null,
    totalTokens: 0,
    estimatedCostUsd: 0,
    isTelemetryStandby: true,
  });

  useEffect(() => {
    let isMounted = true;

    async function loadStats() {
      try {
        const data = await fetchAnalyticsOverview({
          project_id: currentProject?.id,
          environment,
          time_range: dateRange,
        });
        if (isMounted) {
          setStats(data);
        }
      } catch {
        // Fall back gracefully
      }
    }

    loadStats();
    const interval = setInterval(loadStats, 10000);
    return () => {
      isMounted = false;
      clearInterval(interval);
    };
  }, [currentProject?.id, environment, dateRange]);

  const errorRateFormatted = `${stats.errorRate.toFixed(1)}%`;
  const p95Formatted = stats.p95LatencyMs !== null ? `${stats.p95LatencyMs} ms` : '-- ms';

  return (
    <div className="border border-[#252d28] bg-[#0c0e0d] rounded-md overflow-hidden">
      {/* 4-Column Metric Strip */}
      <div className="grid grid-cols-2 lg:grid-cols-4 divide-y sm:divide-y-0 sm:divide-x divide-[#252d28]">
        {/* 1. Total Executions */}
        <div className="p-3 sm:p-3.5 flex flex-col justify-between space-y-1 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#88948a]">
            <span className="text-[10px] uppercase tracking-wider font-medium">Total Executions</span>
            <PlayCircle className="h-3.5 w-3.5 text-[#6bc8c1]" />
          </div>
          <div className="text-xl sm:text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">
            {stats.totalExecutions.toLocaleString()}
          </div>
        </div>

        {/* 2. Failed Executions */}
        <div className="p-3 sm:p-3.5 flex flex-col justify-between space-y-1 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#88948a]">
            <span className="text-[10px] uppercase tracking-wider font-medium">Failed Executions</span>
            <AlertTriangle className="h-3.5 w-3.5 text-[#f06f68]" />
          </div>
          <div className="text-xl sm:text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">
            {stats.failedExecutions.toLocaleString()}
          </div>
        </div>

        {/* 3. Error Rate */}
        <div className="p-3 sm:p-3.5 flex flex-col justify-between space-y-1 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#88948a]">
            <span className="text-[10px] uppercase tracking-wider font-medium">Error Rate</span>
            <Percent className="h-3.5 w-3.5 text-[#e5ad55]" />
          </div>
          <div className="text-xl sm:text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">
            {errorRateFormatted}
          </div>
        </div>

        {/* 4. Average Latency */}
        <div className="p-3 sm:p-3.5 flex flex-col justify-between space-y-1 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#88948a]">
            <span className="text-[10px] uppercase tracking-wider font-medium">P95 Latency</span>
            <Clock className="h-3.5 w-3.5 text-[#9ba69e]" />
          </div>
          <div className="text-xl sm:text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">
            {p95Formatted}
          </div>
        </div>
      </div>
    </div>
  );
};
