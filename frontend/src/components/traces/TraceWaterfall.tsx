import React from 'react';
import {
  Layers,
  Terminal,
  Sparkles,
  Wrench,
  Compass
} from 'lucide-react';
import type { Trace, Span, SpanType } from '../../types';

interface TraceWaterfallProps {
  trace: Trace;
  onSelectSpan: (span: Span) => void;
  selectedSpanId?: string;
}

const SPAN_ICONS: Record<SpanType, React.ElementType> = {
  AGENT_STEP: Compass,
  LLM_CALL: Sparkles,
  TOOL_CALL: Wrench,
  RETRIEVAL: Layers,
  ROUTING: Terminal,
};

const SPAN_BADGE_COLORS: Record<SpanType, string> = {
  AGENT_STEP: 'bg-[#171c19] text-[#929b94] border-[#252d28]',
  LLM_CALL: 'bg-[#6bc8c1]/10 text-[#6bc8c1] border-[#6bc8c1]/30',
  TOOL_CALL: 'bg-[#b8f56a]/10 text-[#b8f56a] border-[#b8f56a]/30',
  RETRIEVAL: 'bg-[#e5ad55]/10 text-[#e5ad55] border-[#e5ad55]/30',
  ROUTING: 'bg-[#171c19] text-[#929b94] border-[#252d28]',
};

export const TraceWaterfall: React.FC<TraceWaterfallProps> = ({
  trace,
  onSelectSpan,
  selectedSpanId,
}) => {
  const traceStartTime = new Date(trace.startTime).getTime();
  const totalDuration = Math.max(trace.durationMs, 1);

  return (
    <div className="rounded-md bg-[#0c0e0d] border border-[#252d28] overflow-hidden">
      {/* Waterfall Timeline Header */}
      <div className="p-3 bg-[#090b0a] border-b border-[#252d28] flex items-center justify-between text-[11px] font-mono text-[#626b64]">
        <div className="w-1/2 md:w-5/12 flex items-center gap-2">
          <span>Span Hierarchy & Type</span>
        </div>
        <div className="w-1/2 md:w-7/12 flex items-center justify-between pl-4">
          <span>0ms</span>
          <span>{Math.round(totalDuration / 2)}ms</span>
          <span>{totalDuration}ms</span>
        </div>
      </div>

      {/* Span Rows */}
      <div className="divide-y divide-[#252d28]/70">
        {trace.spans.map((span) => {
          const Icon = SPAN_ICONS[span.spanType] || Layers;
          const spanStart = new Date(span.startTime).getTime();
          const offsetMs = Math.max(0, spanStart - traceStartTime);
          const leftPercent = Math.min(100, (offsetMs / totalDuration) * 100);
          const widthPercent = Math.max(2, Math.min(100 - leftPercent, (span.durationMs / totalDuration) * 100));

          const isSelected = selectedSpanId === span.id;
          const isError = span.status === 'ERROR';

          // Indentation level
          const isChild = span.parentSpanId !== null;

          return (
            <div
              key={span.id}
              onClick={() => onSelectSpan(span)}
              className={`flex items-center px-3 py-2 cursor-pointer text-xs font-mono transition-colors group ${
                isSelected
                  ? 'bg-[#1a201c] shadow-[inset_2px_0_#b8f56a]'
                  : 'hover:bg-[#171d19]'
              }`}
            >
              {/* Left Column: Span Info */}
              <div className={`w-1/2 md:w-5/12 flex items-center gap-2 truncate pr-2 ${isChild ? 'pl-6' : 'pl-0'}`}>
                {isChild && (
                  <span className="text-[#354039] select-none text-[10px]">└─</span>
                )}
                <div
                  className={`p-1 rounded-xs shrink-0 ${
                    isError
                      ? 'bg-[#f06f68]/15 text-[#f06f68]'
                      : span.spanType === 'TOOL_CALL'
                      ? 'bg-[#b8f56a]/10 text-[#b8f56a]'
                      : span.spanType === 'LLM_CALL'
                      ? 'bg-[#6bc8c1]/10 text-[#6bc8c1]'
                      : 'bg-[#171c19] text-[#929b94]'
                  }`}
                >
                  <Icon className="h-3.5 w-3.5" />
                </div>

                <div className="truncate flex items-center gap-1.5">
                  <span className={`font-medium truncate ${isError ? 'text-[#f6928d]' : 'text-[#f5f7f5]'}`}>
                    {span.name}
                  </span>
                  <span
                    className={`text-[8px] font-mono uppercase tracking-wider px-1.5 py-0.2 rounded-xs border hidden sm:inline-block ${
                      SPAN_BADGE_COLORS[span.spanType]
                    }`}
                  >
                    {span.spanType}
                  </span>
                </div>
              </div>

              {/* Right Column: Timeline Bar */}
              <div className="w-1/2 md:w-7/12 relative h-5 flex items-center pl-4">
                {/* Background Grid Lines */}
                <div className="absolute inset-y-0 left-1/2 w-px bg-[#1c221e] pointer-events-none" />

                {/* Duration Bar */}
                <div
                  style={{
                    left: `${leftPercent}%`,
                    width: `${widthPercent}%`,
                  }}
                  className={`absolute h-3.5 rounded-xs flex items-center px-1 shadow-xs transition-all ${
                    isError
                      ? 'bg-[#f06f68] text-white'
                      : span.spanType === 'LLM_CALL'
                      ? 'bg-[#6bc8c1] text-[#090b0a] font-semibold'
                      : span.spanType === 'TOOL_CALL'
                      ? 'bg-[#b8f56a] text-[#090b0a] font-semibold'
                      : 'bg-[#303a33] text-[#f5f7f5]'
                  }`}
                >
                  <span className="text-[9px] font-mono font-bold truncate">
                    {span.durationMs}ms
                  </span>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
