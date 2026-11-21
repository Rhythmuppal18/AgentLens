import React from 'react';
import {
  ShieldAlert,
  RotateCcw,
  Repeat,
  Clock,
  FileQuestion,
  XCircle,
  Info
} from 'lucide-react';
import type { FailureRuleDefinition } from '../../types';

const FAILURE_RULES: FailureRuleDefinition[] = [
  {
    id: 'FAILED_SPAN',
    name: 'Failed Span',
    description: 'Catches unhandled exceptions, network timeouts, and spans marked with ERROR status.',
    condition: "span.status == 'ERROR' or span.error_message != null",
    status: 'standby',
    severity: 'CRITICAL',
  },
  {
    id: 'REPEATED_TOOL_CALL',
    name: 'Repeated Tool Call',
    description: 'Detects reasoning loops where an agent calls the identical tool with identical parameters.',
    condition: 'tool_name[t] == tool_name[t-1] and hash(input[t]) == hash(input[t-1])',
    status: 'standby',
    severity: 'HIGH',
  },
  {
    id: 'EXCESSIVE_RETRIES',
    name: 'Excessive Retries',
    description: 'Flags operations that fail repeatedly and trigger retry exhaustion exceeding threshold.',
    condition: 'retry_count > 3 within continuous execution window',
    status: 'standby',
    severity: 'WARNING',
  },
  {
    id: 'SLOW_SPAN',
    name: 'Slow Span',
    description: 'Flags LLM or tool spans violating operational latency budgets or SLA thresholds.',
    condition: 'span.duration_ms > sla_threshold (default: LLM > 10,000ms, Tool > 5,000ms)',
    status: 'standby',
    severity: 'WARNING',
  },
  {
    id: 'EMPTY_TOOL_RESULT',
    name: 'Empty Tool Result',
    description: 'Flags tools that execute without error but return empty payloads starving LLM context.',
    condition: "span.type == 'tool' and output in ('', None, {}, [], 0 bytes)",
    status: 'standby',
    severity: 'HIGH',
  },
];

const SEVERITY_BADGES: Record<string, string> = {
  CRITICAL: 'bg-rose-500/10 text-rose-400 border-rose-500/30',
  HIGH: 'bg-amber-500/10 text-amber-400 border-amber-500/30',
  WARNING: 'bg-yellow-500/10 text-yellow-300 border-yellow-500/30',
};

const RULE_ICONS: Record<string, React.ElementType> = {
  FAILED_SPAN: XCircle,
  REPEATED_TOOL_CALL: Repeat,
  EXCESSIVE_RETRIES: RotateCcw,
  SLOW_SPAN: Clock,
  EMPTY_TOOL_RESULT: FileQuestion,
};

export const FailureRulesPreview: React.FC = () => {
  return (
    <div className="p-6 rounded-xl bg-[#0F172A] border border-slate-800 space-y-5">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-violet-500/10 text-violet-400 border border-violet-500/20">
            <ShieldAlert className="h-5 w-5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-sm font-semibold text-slate-100 font-mono uppercase tracking-wider">
                Deterministic Failure Detection Rules
              </h2>
              <span className="px-2 py-0.5 text-[10px] font-mono rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">
                5 Rules Active
              </span>
            </div>
            <p className="text-xs text-slate-400 mt-0.5">
              Deterministic rule evaluation catches agent failure modes without heuristic guesswork.
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2 text-xs font-mono text-slate-400">
          <span className="h-2 w-2 rounded-full bg-emerald-400" />
          <span>0 Active Violations</span>
        </div>
      </div>

      {/* Rules Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3.5">
        {FAILURE_RULES.map((rule) => {
          const Icon = RULE_ICONS[rule.id];
          return (
            <div
              key={rule.id}
              className="p-4 rounded-lg bg-[#0B0F17] border border-slate-800/80 hover:border-slate-700 transition-all flex flex-col justify-between space-y-3"
            >
              <div className="space-y-2">
                <div className="flex items-center justify-between gap-2">
                  <div className="flex items-center gap-2">
                    <Icon className="h-4 w-4 text-violet-400 shrink-0" />
                    <span className="text-xs font-mono font-semibold text-slate-200">
                      {rule.name}
                    </span>
                  </div>
                  <span
                    className={`text-[9px] font-mono px-1.5 py-0.5 rounded border uppercase font-medium ${
                      SEVERITY_BADGES[rule.severity]
                    }`}
                  >
                    {rule.severity}
                  </span>
                </div>

                <p className="text-[11px] text-slate-400 leading-relaxed">
                  {rule.description}
                </p>
              </div>

              <div className="pt-2 border-t border-slate-800/60 font-mono">
                <div className="text-[10px] text-slate-500 uppercase font-semibold mb-1">
                  Evaluation Logic
                </div>
                <code className="text-[10px] text-violet-300/90 bg-slate-900 px-1.5 py-1 rounded block truncate">
                  {rule.condition}
                </code>
              </div>
            </div>
          );
        })}

        {/* Sixth Card: Custom Rule Engine Info */}
        <div className="p-4 rounded-lg bg-gradient-to-br from-[#0B0F17] to-violet-950/20 border border-dashed border-violet-500/30 flex flex-col justify-between space-y-3">
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-violet-300">
              <Info className="h-4 w-4" />
              <span className="text-xs font-mono font-semibold">
                Evidence Attribution
              </span>
            </div>
            <p className="text-[11px] text-slate-400 leading-relaxed">
              When triggered, each rule flags the exact offending span, serializes the input payload, and links the causal parent chain for instant debugging.
            </p>
          </div>

          <div className="pt-2 border-t border-violet-500/20 text-[11px] font-mono text-violet-400 flex items-center justify-between">
            <span>Stage 3 Deliverable</span>
            <span className="text-[10px] text-slate-500">FastAPI Engine</span>
          </div>
        </div>
      </div>
    </div>
  );
};
