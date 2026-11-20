import React from 'react';
import {
  GitFork,
  ArrowUpRight,
  Layers,
  Database
} from 'lucide-react';

interface RecentTracesCardProps {
  onExploreTraces: () => void;
}

export const RecentTracesCard: React.FC<RecentTracesCardProps> = ({ onExploreTraces }) => {
  return (
    <div className="p-6 rounded-xl bg-[#0F172A] border border-slate-800 space-y-4">
      <div className="flex items-center justify-between pb-3 border-b border-slate-800">
        <div className="flex items-center gap-2.5">
          <div className="p-1.5 rounded-md bg-violet-500/10 text-violet-400">
            <GitFork className="h-4 w-4" />
          </div>
          <h2 className="text-sm font-semibold text-slate-100 font-mono uppercase tracking-wider">
            Recent Agent Traces
          </h2>
        </div>

        <button
          onClick={onExploreTraces}
          className="text-xs font-mono text-violet-400 hover:text-violet-300 flex items-center gap-1 transition-colors"
        >
          <span>Trace Explorer</span>
          <ArrowUpRight className="h-3 w-3" />
        </button>
      </div>

      {/* Honest Empty State */}
      <div className="py-10 px-4 rounded-lg bg-[#0B0F17] border border-dashed border-slate-800/80 flex flex-col items-center justify-center text-center space-y-3">
        <div className="h-12 w-12 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-center text-slate-500">
          <Layers className="h-6 w-6" />
        </div>

        <div className="max-w-md space-y-1">
          <h3 className="text-sm font-semibold text-slate-200 font-mono">
            No Execution Traces Recorded
          </h3>
          <p className="text-xs text-slate-400 leading-relaxed">
            The platform is ready to record agent runs. Once your agent workflow is instrumented with the AgentLens SDK, execution timelines, parent-child span graphs, and tool I/O will appear here automatically.
          </p>
        </div>

        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-800/50 text-slate-400 text-[11px] font-mono border border-slate-700/60 mt-1">
          <Database className="h-3 w-3 text-slate-500" />
          <span>Ingestion Buffer: 0 pending traces</span>
        </div>
      </div>
    </div>
  );
};
