import React from 'react';
import { ShieldAlert, ArrowUpRight, Info } from 'lucide-react';
import { useApp } from '../../context/useApp';

export const FailureInsightsSummary: React.FC = () => {
  const { setActiveTab } = useApp();

  const RULES = [
    { name: 'Failed Span', desc: 'Runtime exceptions & error status' },
    { name: 'Repeated Tool Call', desc: 'Identical tool argument loop trap' },
    { name: 'Excessive Retries', desc: 'Retry exhaustion threshold > 3' },
    { name: 'Slow Span', desc: 'Latency budget & SLA breach' },
    { name: 'Empty Tool Result', desc: 'Empty output context starvation' },
  ];

  return (
    <div className="p-5 rounded-lg bg-[#111512] border border-[#252d28] space-y-4">
      <div className="flex items-center justify-between pb-3 border-b border-[#252d28]">
        <div className="flex items-center gap-2">
          <ShieldAlert className="h-4 w-4 text-[#e5ad55]" />
          <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
            Deterministic Failure Detection
          </h2>
        </div>

        <button
          onClick={() => setActiveTab('failures')}
          className="text-xs font-mono text-[#e5ad55] hover:text-[#ddc395] flex items-center gap-1 transition-colors"
        >
          <span>View Rules & Violations</span>
          <ArrowUpRight className="h-3 w-3" />
        </button>
      </div>

      {/* Rules list */}
      <div className="space-y-2">
        {RULES.map((rule, idx) => (
          <div
            key={idx}
            className="p-2.5 rounded-md bg-[#0f1310] border border-[#252d28] flex items-center justify-between text-xs font-mono"
          >
            <div className="flex items-center gap-2.5">
              <span className="h-1.5 w-1.5 rounded-full bg-[#67c98a]" />
              <div>
                <span className="font-semibold text-[#f5f7f5]">{rule.name}</span>
                <span className="hidden sm:inline text-[#626b64] ml-2">&bull; {rule.desc}</span>
              </div>
            </div>
            <span className="text-[9px] font-mono px-1.5 py-0.2 rounded-xs bg-[#67c98a]/10 text-[#83cda0] border border-[#67c98a]/30 font-medium">
              0 Violations
            </span>
          </div>
        ))}
      </div>

      <div className="pt-2 border-t border-[#252d28] flex items-center justify-between text-[10px] font-mono text-[#929b94]">
        <div className="flex items-center gap-1.5">
          <Info className="h-3.5 w-3.5 text-[#b8f56a]" />
          <span>Rule Engine: Standby (Awaiting Stage 3 Ingestion)</span>
        </div>
        <span className="text-[#626b64]">5 Active Rules</span>
      </div>
    </div>
  );
};
