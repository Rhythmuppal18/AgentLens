import React from 'react';
import { AlertTriangle, ArrowRight } from 'lucide-react';
import { useApp } from '../../context/useApp';

export const HeroTraceFlightRecorder: React.FC = () => {
  const { setActiveTab } = useApp();

  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-5 items-center pt-1 pb-1">
      {/* Left Column: Hero Mission & Value Proposition */}
      <div className="lg:col-span-5 space-y-2.5">
        <div className="flex items-center gap-2 text-xs font-mono tracking-wider uppercase text-[#b8f56a]">
          <span className="w-3.5 h-0.5 bg-[#b8f56a] inline-block" />
          <span>AI Agent Observability</span>
        </div>

        <h1 className="text-2xl sm:text-3xl lg:text-[34px] font-bold text-[#f5f7f5] leading-[1.14] tracking-tight font-sans">
          Your AI Agent Says{' '}
          <span className="text-[#b8f56a]">Success.</span>
          <br />
          Its Execution Says Otherwise.
        </h1>

        <p className="text-xs sm:text-sm text-[#9ba69e] font-sans leading-relaxed max-w-md">
          Evidence-backed failure debugging for autonomous AI agents.
        </p>

        <div className="flex flex-wrap items-center gap-2.5 pt-0.5">
          <button
            onClick={() => setActiveTab('traces')}
            aria-label="Open Trace Explorer"
            className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-md bg-[#b8f56a] hover:bg-[#a6e656] text-[#080908] font-mono font-semibold text-xs transition-colors shadow-xs"
          >
            <span>Trace Explorer</span>
            <ArrowRight className="h-3.5 w-3.5" />
          </button>

          <button
            onClick={() => setActiveTab('failures')}
            aria-label="Inspect Failure Rules"
            className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-md bg-[#111412] hover:bg-[#171c19] text-[#f5f7f5] border border-[#252d28] font-mono text-xs transition-colors"
          >
            <span>Failure Rules</span>
          </button>
        </div>
      </div>

      {/* Right Column: Signature Flight Recorder Box (Matching Figma Reference) */}
      <div className="lg:col-span-7">
        <div className="rounded-md bg-[#0c0e0d] border border-[#252d28] overflow-hidden shadow-2xl">
          {/* Box Header - Explicitly Labeled as Demo / Sample Recording */}
          <div className="px-3.5 py-2 border-b border-[#252d28] flex items-center justify-between text-xs font-mono bg-[#090b0a]">
            <div className="flex items-center gap-2">
              <span className="text-[9px] font-mono uppercase tracking-wider px-1.5 py-0.2 rounded-xs border bg-[#e5ad55]/15 text-[#e5ad55] border-[#e5ad55]/30 font-semibold">
                Demo
              </span>
              <span className="text-[#9ba69e]">
                trace_0012 / <span className="text-[#f5f7f5]">research_agent</span>
              </span>
            </div>

            <div className="flex items-center gap-1.5 text-[10px] text-[#e5ad55]">
              <span className="h-1.5 w-1.5 rounded-full bg-[#e5ad55]" />
              <span className="tracking-widest uppercase font-semibold">Sample Recording</span>
            </div>
          </div>

          {/* 3-Column Discrepancy Comparison Bar */}
          <div className="grid grid-cols-3 border-b border-[#252d28] divide-x divide-[#252d28] text-xs font-mono bg-[#0d100e]">
            <div className="px-3 py-2 space-y-0.5">
              <span className="text-[9px] uppercase tracking-wider text-[#9ba69e] font-medium block">Agent Report</span>
              <div className="flex items-center gap-1.5 text-[#67c98a] font-semibold text-[11px]">
                <span className="h-1.5 w-1.5 rounded-full bg-[#67c98a]" />
                <span>SUCCESS</span>
              </div>
            </div>

            <div className="px-3 py-2 space-y-0.5">
              <span className="text-[9px] uppercase tracking-wider text-[#9ba69e] font-medium block">AgentLens Evidence</span>
              <div className="flex items-center gap-1.5 text-[#f06f68] font-semibold text-[11px]">
                <span className="h-1.5 w-1.5 rounded-full bg-[#f06f68]" />
                <span>3 TIMEOUTS</span>
              </div>
            </div>

            <div className="px-3 py-2 space-y-0.5">
              <span className="text-[9px] uppercase tracking-wider text-[#9ba69e] font-medium block">Actual Result</span>
              <div className="flex items-center gap-1.5 text-[#e5ad55] font-semibold text-[11px]">
                <span className="h-1.5 w-1.5 rounded-full bg-[#e5ad55]" />
                <span>PARTIAL</span>
              </div>
            </div>
          </div>

          {/* Center Visual Graph: Agent Execution Journey */}
          <div className="px-4 py-2 relative bg-[#0a0c0b] flex items-center justify-center overflow-x-auto">
            <svg className="w-full max-w-[540px] h-[130px]" viewBox="0 0 540 130" fill="none">
              {/* Connecting Curves */}
              {/* 1 -> 2 */}
              <path d="M 44 65 L 94 65" stroke="#252d28" strokeWidth="1.5" strokeDasharray="3 3" />
              {/* 2 -> 3 (upper branch) */}
              <path d="M 118 65 C 145 65, 145 32, 180 32" stroke="#252d28" strokeWidth="1.5" strokeDasharray="3 3" />
              {/* 2 -> 4 (lower loop branch) */}
              <path d="M 118 65 C 145 65, 145 96, 180 96" stroke="#f06f68" strokeWidth="1.5" strokeDasharray="3 3" opacity="0.6" />
              {/* 4 -> 5 */}
              <path d="M 210 96 L 254 96" stroke="#f06f68" strokeWidth="1.5" strokeDasharray="3 3" opacity="0.6" />
              {/* 5 -> 6 */}
              <path d="M 286 96 L 330 96" stroke="#f06f68" strokeWidth="1.5" strokeDasharray="3 3" opacity="0.6" />
              {/* 3 -> 7 */}
              <path d="M 210 32 C 260 32, 350 32, 396 65" stroke="#252d28" strokeWidth="1.5" strokeDasharray="3 3" />
              {/* 6 -> 7 */}
              <path d="M 362 96 C 382 96, 385 65, 396 65" stroke="#252d28" strokeWidth="1.5" strokeDasharray="3 3" />

              {/* Node 1: plan_task */}
              <g transform="translate(28, 65)">
                <circle r="15" fill="#111512" stroke="#303a33" strokeWidth="1.5" />
                <text textAnchor="middle" dy="4" fill="#f5f7f5" fontSize="10" fontFamily="monospace">1</text>
                <text textAnchor="middle" y="-20" fill="#9ba69e" fontSize="9" fontFamily="monospace">plan_task</text>
              </g>

              {/* Node 2: search_web */}
              <g transform="translate(106, 65)">
                <circle r="15" fill="#111512" stroke="#303a33" strokeWidth="1.5" />
                <text textAnchor="middle" dy="4" fill="#f5f7f5" fontSize="10" fontFamily="monospace">2</text>
                <text textAnchor="middle" y="-20" fill="#9ba69e" fontSize="9" fontFamily="monospace">search_web</text>
              </g>

              {/* Node 3: fetch_source(A) */}
              <g transform="translate(195, 32)">
                <circle r="15" fill="#111512" stroke="#303a33" strokeWidth="1.5" />
                <text textAnchor="middle" dy="4" fill="#f5f7f5" fontSize="10" fontFamily="monospace">3</text>
                <text textAnchor="middle" y="-20" fill="#9ba69e" fontSize="9" fontFamily="monospace">fetch_source(A)</text>
              </g>

              {/* Node 4: fetch_source(B) - Loop 1 */}
              <g transform="translate(195, 96)">
                <circle r="15" fill="#1c1112" stroke="#f06f68" strokeWidth="1.5" />
                <text textAnchor="middle" dy="4" fill="#f06f68" fontSize="10" fontFamily="monospace">4</text>
                <text textAnchor="middle" y="22" fill="#9ba69e" fontSize="8" fontFamily="monospace">fetch_source(B)</text>
                <text textAnchor="middle" y="31" fill="#f06f68" fontSize="7" fontFamily="monospace" fontWeight="bold">TIMEOUT</text>
              </g>

              {/* Node 5: fetch_source(B) - Loop 2 */}
              <g transform="translate(270, 96)">
                <circle r="15" fill="#1c1112" stroke="#f06f68" strokeWidth="1.5" />
                <text textAnchor="middle" dy="4" fill="#f06f68" fontSize="10" fontFamily="monospace">5</text>
                <text textAnchor="middle" y="22" fill="#9ba69e" fontSize="8" fontFamily="monospace">fetch_source(B)</text>
                <text textAnchor="middle" y="31" fill="#f06f68" fontSize="7" fontFamily="monospace" fontWeight="bold">TIMEOUT</text>
              </g>

              {/* Node 6: fetch_source(B) - Loop 3 */}
              <g transform="translate(346, 96)">
                <circle r="15" fill="#1c1112" stroke="#f06f68" strokeWidth="1.5" />
                <text textAnchor="middle" dy="4" fill="#f06f68" fontSize="10" fontFamily="monospace">6</text>
                <text textAnchor="middle" y="22" fill="#9ba69e" fontSize="8" fontFamily="monospace">fetch_source(B)</text>
                <text textAnchor="middle" y="31" fill="#f06f68" fontSize="7" fontFamily="monospace" fontWeight="bold">TIMEOUT</text>
              </g>

              {/* Node 7: generate_answer */}
              <g transform="translate(412, 65)">
                <circle r="15" fill="#171510" stroke="#e5ad55" strokeWidth="1.5" strokeDasharray="2 2" />
                <text textAnchor="middle" dy="4" fill="#e5ad55" fontSize="10" fontFamily="monospace">7</text>
                <text textAnchor="middle" y="-20" fill="#9ba69e" fontSize="9" fontFamily="monospace">generate_answer</text>
              </g>
            </svg>
          </div>

          {/* Inconsistency Detected Alert Footer */}
          <div className="px-3.5 py-2.5 bg-[#120e0e] border-t border-[#f06f68]/30 flex items-center justify-between text-xs font-mono">
            <div className="flex items-center gap-2.5">
              <div className="p-1 rounded-xs bg-[#1f1213] border border-[#f06f68]/40 text-[#f06f68]">
                <AlertTriangle className="h-3.5 w-3.5" />
              </div>
              <div>
                <span className="text-[9px] uppercase tracking-wider text-[#f06f68] font-bold block">
                  Inconsistency Detected
                </span>
                <span className="text-[#f5f7f5] text-xs font-sans">
                  Reported success, incomplete evidence (3 repeated tool timeouts)
                </span>
              </div>
            </div>

            <button
              onClick={() => setActiveTab('traces')}
              aria-label="View diagnosis"
              className="inline-flex items-center gap-1.5 text-xs text-[#9ba69e] hover:text-[#f5f7f5] transition-colors group cursor-pointer"
            >
              <span>View diagnosis</span>
              <ArrowRight className="h-3 w-3 group-hover:translate-x-0.5 transition-transform" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
