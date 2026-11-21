import React, { useEffect, useState } from 'react';
import {
  AlertTriangle,
  Repeat,
  RotateCcw,
  Clock,
  Code2,
  ArrowRight
} from 'lucide-react';
import { useApp } from '../../context/useApp';
import { fetchAnalyticsRules } from '../../services/api';
import type { RuleMetric } from '../../types';

interface RuleCard {
  id: string;
  index: string;
  name: string;
  description: string;
  icon: React.ElementType;
  condition: string;
}

const RULES: RuleCard[] = [
  {
    id: 'FAILED_SPAN',
    index: '01',
    name: 'Failed Span',
    description: 'Uncaught exceptions or status ERROR',
    icon: AlertTriangle,
    condition: "span.status == 'ERROR'",
  },
  {
    id: 'REPEATED_TOOL_CALL',
    index: '02',
    name: 'Repeated Tool Call',
    description: 'Identical tool arguments in a loop',
    icon: Repeat,
    condition: 'hash(args[t]) == hash(args[t-1])',
  },
  {
    id: 'EXCESSIVE_RETRIES',
    index: '03',
    name: 'Excessive Retries',
    description: 'Retries exceeding threshold (> 3)',
    icon: RotateCcw,
    condition: 'retry_count > 3',
  },
  {
    id: 'SLOW_SPAN',
    index: '04',
    name: 'Slow Span',
    description: 'Execution exceeding SLA latency budget',
    icon: Clock,
    condition: 'duration > sla_threshold',
  },
  {
    id: 'EMPTY_TOOL_RESULT',
    index: '05',
    name: 'Empty Tool Result',
    description: 'Tool exit 0 with empty return payload',
    icon: Code2,
    condition: "output in ('', None, {})",
  },
];

export const DeterministicRulesGrid: React.FC = () => {
  const { currentProject, environment, dateRange, setActiveTab } = useApp();
  const [ruleMetrics, setRuleMetrics] = useState<Record<string, number>>({});

  useEffect(() => {
    let isMounted = true;

    async function loadRules() {
      try {
        const data: RuleMetric[] = await fetchAnalyticsRules({
          project_id: currentProject?.id,
          environment,
          time_range: dateRange,
        });
        if (isMounted) {
          const counts: Record<string, number> = {};
          data.forEach((r) => {
            counts[r.id] = r.count;
          });
          setRuleMetrics(counts);
        }
      } catch {
        // Fall back gracefully
      }
    }

    loadRules();
    const interval = setInterval(loadRules, 10000);
    return () => {
      isMounted = false;
      clearInterval(interval);
    };
  }, [currentProject?.id, environment, dateRange]);

  return (
    <div className="space-y-2.5 pt-1 [content-visibility:auto] [contain-intrinsic-size:0_320px]">
      {/* Header */}
      <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
        <div className="flex items-center gap-2">
          <span className="w-3 h-0.5 bg-[#b8f56a] inline-block" />
          <h2 className="text-xs font-bold text-[#f5f7f5] font-mono uppercase tracking-wider">
            Deterministic Rules Engine
          </h2>
        </div>

        <button
          onClick={() => setActiveTab('failures')}
          aria-label="View Rules"
          className="inline-flex items-center gap-1.5 text-xs font-mono text-[#88948a] hover:text-[#b8f56a] transition-colors group cursor-pointer"
        >
          <span>View Rules</span>
          <ArrowRight className="h-3 w-3 group-hover:translate-x-0.5 transition-transform" />
        </button>
      </div>

      {/* 5-Column Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 border border-[#252d28] bg-[#0c0e0d] divide-y sm:divide-y-0 sm:divide-x divide-[#252d28] rounded-md overflow-hidden">
        {RULES.map((rule) => {
          const Icon = rule.icon;
          const count = ruleMetrics[rule.id] ?? 0;
          return (
            <div
              key={rule.id}
              onClick={() => setActiveTab('failures')}
              className="p-3.5 flex flex-col justify-between space-y-2.5 hover:bg-[#101311] transition-colors cursor-pointer group"
            >
              <div>
                <div className="flex items-center justify-between text-xs font-mono text-[#88948a]">
                  <Icon className="h-3.5 w-3.5 text-[#9ba69e] group-hover:text-[#b8f56a] transition-colors" />
                  <div className="flex items-center gap-1.5">
                    {count > 0 && (
                      <span className="text-[9px] font-mono px-1.5 py-0.2 rounded-xs bg-[#f06f68]/15 text-[#f06f68] border border-[#f06f68]/30 font-semibold">
                        {count} violations
                      </span>
                    )}
                    <span className="text-[10px] text-[#88948a] font-mono">{rule.index}</span>
                  </div>
                </div>

                <h3 className="text-xs font-semibold text-[#f5f7f5] font-mono mt-1.5 group-hover:text-[#b8f56a] transition-colors">
                  {rule.name}
                </h3>

                <p className="text-[10px] text-[#88948a] font-sans leading-normal mt-0.5">
                  {rule.description}
                </p>
              </div>

              <div className="pt-2 border-t border-[#1c221e] text-[9px] font-mono text-[#88948a] truncate">
                <code>{rule.condition}</code>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
