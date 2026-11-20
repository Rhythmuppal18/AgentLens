import React, { useState } from 'react';
import { GitFork, ArrowRight, Eye, EyeOff } from 'lucide-react';
import { useApp } from '../../context/useApp';

interface ExecutionRow {
  id: string;
  agent: string;
  rootSpan: string;
  status: 'SUCCESS' | 'ERROR' | 'PARTIAL';
  spansCount: number;
  durationMs: number;
}

const SAMPLE_REFERENCE_RUNS: ExecutionRow[] = [
  {
    id: 'trc_9a4f7e21',
    agent: 'sec_edgar_client',
    rootSpan: 'execute_financial_audit',
    status: 'ERROR',
    spansCount: 9,
    durationMs: 3420,
  },
  {
    id: 'trc_0012_demo',
    agent: 'research_agent',
    rootSpan: 'plan_and_execute_task',
    status: 'PARTIAL',
    spansCount: 7,
    durationMs: 4180,
  },
  {
    id: 'trc_3b8a1c90',
    agent: 'support_triage_agent',
    rootSpan: 'classify_customer_ticket',
    status: 'SUCCESS',
    spansCount: 4,
    durationMs: 820,
  },
];

export const RecentTracesTable: React.FC = () => {
  const { setActiveTab } = useApp();
  // By default, stay truthful to zero live executions
  const [showSampleRuns, setShowSampleRuns] = useState(false);

  const runs = showSampleRuns ? SAMPLE_REFERENCE_RUNS : [];

  return (
    <div className="p-3.5 sm:p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-2.5 [content-visibility:auto] [contain-intrinsic-size:0_280px]">
      <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
        <div className="flex items-center gap-2">
          <GitFork className="h-3.5 w-3.5 text-[#b8f56a]" />
          <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
            Recent Executions
          </h2>
          {showSampleRuns ? (
            <span className="text-[9px] font-mono uppercase px-1.5 py-0.2 rounded-xs bg-[#e5ad55]/15 text-[#e5ad55] border border-[#e5ad55]/30 font-semibold">
              Sample Data (3)
            </span>
          ) : (
            <span className="text-[10px] font-mono text-[#88948a]">
              (0 Live)
            </span>
          )}
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => setShowSampleRuns(!showSampleRuns)}
            className="text-[10px] font-mono text-[#88948a] hover:text-[#f5f7f5] flex items-center gap-1 transition-colors cursor-pointer"
            title="Toggle between live telemetry empty state and reference sample traces"
          >
            {showSampleRuns ? (
              <>
                <EyeOff className="h-3 w-3 text-[#e5ad55]" />
                <span className="text-[#e5ad55]">Hide Sample Data</span>
              </>
            ) : (
              <>
                <Eye className="h-3 w-3 text-[#88948a]" />
                <span>Preview Sample Data</span>
              </>
            )}
          </button>

          <button
            onClick={() => setActiveTab('traces')}
            className="text-xs font-mono text-[#88948a] hover:text-[#b8f56a] flex items-center gap-1 transition-colors group cursor-pointer"
          >
            <span>Explorer</span>
            <ArrowRight className="h-3 w-3 group-hover:translate-x-0.5 transition-transform" />
          </button>
        </div>
      </div>

      {/* Discrepancy Clarification Banner When Sample Data Is Visible */}
      {showSampleRuns && (
        <div className="px-2.5 py-1.5 bg-[#17140e] border border-[#e5ad55]/30 rounded-xs flex items-center justify-between text-[10px] font-mono text-[#e5ad55]">
          <span className="flex items-center gap-1.5">
            <span className="h-1.5 w-1.5 rounded-full bg-[#e5ad55]" />
            <span>Reference Sample Telemetry (Live agent execution count is 0)</span>
          </span>
          <button
            onClick={() => setShowSampleRuns(false)}
            className="text-[#9ba69e] hover:text-[#f5f7f5] underline cursor-pointer"
          >
            Show Live
          </button>
        </div>
      )}

      {/* Table or Empty State */}
      {runs.length > 0 ? (
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs font-mono">
            <thead>
              <tr className="border-b border-[#1c221e] text-[10px] text-[#9ba69e] uppercase tracking-wider">
                <th className="pb-2 font-medium">Trace ID</th>
                <th className="pb-2 font-medium">Agent</th>
                <th className="pb-2 font-medium">Root Span</th>
                <th className="pb-2 font-medium">Status</th>
                <th className="pb-2 font-medium">Spans</th>
                <th className="pb-2 font-medium text-right">Duration</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#1c221e]">
              {runs.map((r) => (
                <tr
                  key={r.id}
                  onClick={() => setActiveTab('traces')}
                  className="hover:bg-[#111412] cursor-pointer transition-colors group"
                >
                  <td className="py-2 text-[#b8f56a] font-medium group-hover:underline">
                    <div className="flex items-center gap-1.5">
                      <span>{r.id}</span>
                      <span className="text-[8px] font-mono uppercase px-1 py-0.2 rounded-xs bg-[#1a1710] text-[#e5ad55] border border-[#e5ad55]/20">
                        Demo
                      </span>
                    </div>
                  </td>
                  <td className="py-2 text-[#9ba69e]">{r.agent}</td>
                  <td className="py-2 text-[#f5f7f5]">{r.rootSpan}</td>
                  <td className="py-2">
                    <span
                      className={`text-[9px] font-mono px-1.5 py-0.2 rounded-xs border uppercase font-medium ${
                        r.status === 'SUCCESS'
                          ? 'bg-[#67c98a]/10 text-[#67c98a] border-[#67c98a]/30'
                          : r.status === 'ERROR'
                          ? 'bg-[#f06f68]/10 text-[#f06f68] border-[#f06f68]/30'
                          : 'bg-[#e5ad55]/10 text-[#e5ad55] border-[#e5ad55]/30'
                      }`}
                    >
                      {r.status}
                    </span>
                  </td>
                  <td className="py-2 text-[#88948a]">{r.spansCount}</td>
                  <td className="py-2 text-[#9ba69e] text-right">{r.durationMs}ms</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="py-6 text-center text-xs font-mono text-[#88948a] space-y-2">
          <p className="text-[#f5f7f5] font-semibold text-xs">0 Live Executions Ingested</p>
          <p className="text-[11px] text-[#88948a] max-w-sm mx-auto">
            Telemetry stream standby. Connect the Python SDK to view live agent traces.
          </p>
          <button
            onClick={() => setShowSampleRuns(true)}
            className="mt-1 inline-flex items-center gap-1.5 px-3 py-1 rounded-sm bg-[#141815] hover:bg-[#1b221d] text-[#b8f56a] border border-[#252d28] hover:border-[#b8f56a]/40 text-[10px] transition-colors cursor-pointer"
          >
            <Eye className="h-3 w-3" />
            <span>Preview 3 Sample Traces</span>
          </button>
        </div>
      )}
    </div>
  );
};
