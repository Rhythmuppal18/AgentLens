import React from 'react';
import {
  BarChart3,
  Clock,
  Coins,
  Wrench
} from 'lucide-react';
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer
} from 'recharts';
import { useApp } from '../../context/useApp';

const EMPTY_VOLUME_DATA = [
  { time: '00:00', total: 0, failed: 0 },
  { time: '04:00', total: 0, failed: 0 },
  { time: '08:00', total: 0, failed: 0 },
  { time: '12:00', total: 0, failed: 0 },
  { time: '16:00', total: 0, failed: 0 },
  { time: '20:00', total: 0, failed: 0 },
];

const EMPTY_RULE_DATA = [
  { rule: 'Failed Span', count: 0 },
  { rule: 'Repeated Tool', count: 0 },
  { rule: 'Excessive Retries', count: 0 },
  { rule: 'Slow Span', count: 0 },
  { rule: 'Empty Tool', count: 0 },
];

export const AnalyticsView: React.FC = () => {
  const { dateRange } = useApp();

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
            <div className="text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">0</div>
            <p className="text-[10px] font-mono text-[#626b64] mt-0.5">Prompt & Completion tokens</p>
          </div>
        </div>

        <div className="p-4 flex flex-col justify-between space-y-2 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#626b64]">
            <span className="text-[10px] uppercase tracking-wider">Estimated Cost</span>
            <Coins className="h-3.5 w-3.5 text-[#b8f56a]" />
          </div>
          <div>
            <div className="text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">$0.00</div>
            <p className="text-[10px] font-mono text-[#626b64] mt-0.5">Based on model pricing rates</p>
          </div>
        </div>

        <div className="p-4 flex flex-col justify-between space-y-2 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#626b64]">
            <span className="text-[10px] uppercase tracking-wider">P95 Latency</span>
            <Clock className="h-3.5 w-3.5 text-[#e5ad55]" />
          </div>
          <div>
            <div className="text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">-- ms</div>
            <p className="text-[10px] font-mono text-[#626b64] mt-0.5">95th percentile span time</p>
          </div>
        </div>

        <div className="p-4 flex flex-col justify-between space-y-2 hover:bg-[#101311] transition-colors">
          <div className="flex items-center justify-between text-xs font-mono text-[#626b64]">
            <span className="text-[10px] uppercase tracking-wider">Tool Reliability</span>
            <Wrench className="h-3.5 w-3.5 text-[#67c98a]" />
          </div>
          <div>
            <div className="text-2xl font-bold font-mono text-[#f5f7f5] tracking-tight">100.0%</div>
            <p className="text-[10px] font-mono text-[#626b64] mt-0.5">0 tool exceptions recorded</p>
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
            <span className="text-[10px] font-mono text-[#626b64]">Hourly aggregation</span>
          </div>

          <div className="relative h-48 w-full pt-2">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={EMPTY_VOLUME_DATA} margin={{ top: 10, right: 10, left: -25, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#1c221e" vertical={false} />
                <XAxis dataKey="time" stroke="#626b64" fontSize={10} tickLine={false} fontFamily="monospace" />
                <YAxis stroke="#626b64" fontSize={10} tickLine={false} domain={[0, 10]} ticks={[0, 5, 10]} fontFamily="monospace" />
                <Area type="monotone" dataKey="total" stroke="#b8f56a" fill="#b8f56a" fillOpacity={0.12} strokeWidth={1.5} />
              </AreaChart>
            </ResponsiveContainer>
            <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
              <span className="px-3 py-1 bg-[#111412] border border-[#252d28] text-xs font-mono text-[#626b64] rounded-xs">
                Awaiting Execution Volume Telemetry
              </span>
            </div>
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
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={EMPTY_RULE_DATA} margin={{ top: 10, right: 10, left: -25, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#1c221e" vertical={false} />
                <XAxis dataKey="rule" stroke="#626b64" fontSize={9} tickLine={false} fontFamily="monospace" />
                <YAxis stroke="#626b64" fontSize={10} tickLine={false} domain={[0, 5]} ticks={[0, 2, 5]} fontFamily="monospace" />
                <Bar dataKey="count" fill="#e5ad55" radius={[2, 2, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
            <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
              <span className="px-3 py-1 bg-[#111412] border border-[#252d28] text-xs font-mono text-[#626b64] rounded-xs">
                0 Violations Flagged Across Rules
              </span>
            </div>
          </div>
        </div>

        {/* Chart 3: Latency Distribution Percentiles */}
        <div className="p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
            <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Latency Percentile Distribution
            </h2>
            <span className="text-[10px] font-mono text-[#626b64]">p50, p90, p95, p99</span>
          </div>

          <div className="py-12 text-center space-y-2">
            <Clock className="h-6 w-6 text-[#626b64] mx-auto" />
            <p className="text-xs font-mono text-[#f5f7f5]">No Latency Samples Collected</p>
            <p className="text-[11px] text-[#929b94] font-sans max-w-sm mx-auto">
              Once executions occur, statistical percentile distributions will calculate latency across agent chains and LLM API calls.
            </p>
          </div>
        </div>

        {/* Chart 4: Tool Invocations & Frequency */}
        <div className="p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
            <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Tool Usage Breakdown
            </h2>
            <span className="text-[10px] font-mono text-[#626b64]">Frequency & Failures</span>
          </div>

          <div className="py-12 text-center space-y-2">
            <Wrench className="h-6 w-6 text-[#626b64] mx-auto" />
            <p className="text-xs font-mono text-[#f5f7f5]">No Tool Invocations Recorded</p>
            <p className="text-[11px] text-[#929b94] font-sans max-w-sm mx-auto">
              Tool calling frequency, execution times, and return schema validations will populate as tools execute.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};