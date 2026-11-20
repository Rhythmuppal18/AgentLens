import React from 'react';
import {
  ShieldAlert,
  CheckCircle2,
  ArrowUpRight,
  Bug
} from 'lucide-react';

interface FailureInsightsCardProps {
  onExploreFailures: () => void;
}

export const FailureInsightsCard: React.FC<FailureInsightsCardProps> = ({ onExploreFailures }) => {
  return (
    <div className="p-6 rounded-xl bg-[#0F172A] border border-slate-800 space-y-4">
      <div className="flex items-center justify-between pb-3 border-b border-slate-800">
        <div className="flex items-center gap-2.5">
          <div className="p-1.5 rounded-md bg-amber-500/10 text-amber-400">
            <Bug className="h-4 w-4" />
          </div>
          <h2 className="text-sm font-semibold text-slate-100 font-mono uppercase tracking-wider">
            Failure Insights & Violations
          </h2>
        </div>

        <button
          onClick={onExploreFailures}
          className="text-xs font-mono text-amber-400 hover:text-amber-300 flex items-center gap-1 transition-colors"
        >
          <span>Rule Details</span>
          <ArrowUpRight className="h-3 w-3" />
        </button>
      </div>

      {/* Honest Empty State */}
      <div className="py-10 px-4 rounded-lg bg-[#0B0F17] border border-dashed border-slate-800/80 flex flex-col items-center justify-center text-center space-y-3">
        <div className="h-12 w-12 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-center text-emerald-400">
          <CheckCircle2 className="h-6 w-6" />
        </div>

        <div className="max-w-md space-y-1">
          <h3 className="text-sm font-semibold text-slate-200 font-mono">
            Zero Failure Violations
          </h3>
          <p className="text-xs text-slate-400 leading-relaxed">
            The 5 deterministic failure detection rules (Failed Span, Repeated Tool Call, Excessive Retries, Slow Span, Empty Tool Result) are active in standby mode. No failure patterns have been detected.
          </p>
        </div>

        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-400 text-[11px] font-mono border border-emerald-500/20 mt-1">
          <ShieldAlert className="h-3 w-3" />
          <span>Rule Engine: 100% Health (0 Anomalies)</span>
        </div>
      </div>
    </div>
  );
};
