import React from 'react';
import {
  GitFork,
  ShieldAlert,
  BarChart3,
  Settings,
  ArrowLeft,
  Calendar,
  CheckCircle2,
  Terminal
} from 'lucide-react';
import type { NavigationTab } from '../../types';

interface UnimplementedViewProps {
  tab: NavigationTab;
  onBackToOverview: () => void;
}

interface ViewDetails {
  title: string;
  stage: string;
  icon: React.ElementType;
  summary: string;
  plannedFeatures: string[];
  techSpec: string;
}

const VIEW_CONFIG: Record<Exclude<NavigationTab, 'overview'>, ViewDetails> = {
  'traces': {
    title: 'Trace Explorer & Span Waterfall',
    stage: 'Milestone Stage 5',
    icon: GitFork,
    summary: 'Visual execution timeline and interactive parent-child span DAG trees for debugging agent reasoning journeys.',
    plannedFeatures: [
      'Interactive XYFlow DAG canvas representing parent-child spans (LLM -> Tool -> Child Run)',
      'High-resolution timeline waterfall with millisecond latency breakdowns',
      'Granular span drawer showing raw system prompts, user queries, completions, and token costs',
      'Instant filtering by agent name, session ID, execution status, and latency threshold',
    ],
    techSpec: 'Integrates @xyflow/react with FastAPI GET /api/v1/traces/{trace_id} and PostgreSQL indexed span hierarchies.',
  },
  'failures': {
    title: 'Deterministic Failure Detection',
    stage: 'Milestone Stage 3',
    icon: ShieldAlert,
    summary: 'Evidence-linked failure diagnostics engine enforcing five strict deterministic rules on agent execution.',
    plannedFeatures: [
      'Failed Span Rule: Catches unhandled exceptions and error statuses in tool/LLM steps',
      'Repeated Tool Call Rule: Detects identical arguments called repeatedly in loop traps',
      'Excessive Retries Rule: Flags operations exceeding configurable retry thresholds',
      'Slow Span Rule: Flags spans violating operational latency SLAs',
      'Empty Tool Result Rule: Identifies tools that return empty contexts starving downstream LLMs',
    ],
    techSpec: 'Evaluated synchronously during ingestion and asynchronously in backend/app/services/rules.py.',
  },
  'analytics': {
    title: 'Performance & Cost Analytics',
    stage: 'Milestone Stage 7',
    icon: BarChart3,
    summary: 'Aggregate metrics on token usage, model costs, latency distributions, and tool failure frequencies.',
    plannedFeatures: [
      'Token consumption trends over time grouped by model family (Gemini, Claude, GPT)',
      'Estimated dollar cost calculations based on exact prompt and completion token counts',
      'Latency percentiles (p50, p90, p95, p99) per tool and agent routine',
      'Failure rate correlation matrix highlighting the most brittle tool dependencies',
    ],
    techSpec: 'Powered by Recharts and PostgreSQL time-bucketed aggregations (GET /api/v1/analytics/summary).',
  },
  'ml-playground': {
    title: 'Machine Learning Observability Playground',
    stage: 'Production Live',
    icon: GitFork,
    summary: 'Interactive Scikit-learn Iris classifier training, live inference tracing, and automated 5-rule failure detection.',
    plannedFeatures: [
      'Real-time model training with live evaluation metrics and confusion matrix',
      'Single-sample flower classification with probability distribution',
      'Continuous trace and span generation through AgentLens Python SDK',
      '5-rule automated failure detection diagnostics with evidence inspection',
    ],
    techSpec: 'Integrates Scikit-learn Random Forest classifier with FastAPI /api/v1/ml endpoints and React UI.',
  },
  'settings': {
    title: 'Platform & Environment Settings',
    stage: 'Milestone Stage 2',
    icon: Settings,
    summary: 'Configure backend persistence, retention policies, deterministic rule thresholds, and API authentication.',
    plannedFeatures: [
      'PostgreSQL connection string and connection pool configuration',
      'Rule threshold customizations (retry limits, latency SLA millisecond bounds)',
      'Telemetry ingestion API keys and client rate limiting',
      'Data retention and span payload sanitization policies (PII filtering)',
    ],
    techSpec: 'Backed by backend/app/core/config.py and Pydantic BaseSettings environment variables.',
  },
};

export const UnimplementedView: React.FC<UnimplementedViewProps> = ({
  tab,
  onBackToOverview,
}) => {
  if (tab === 'overview') return null;

  const config = VIEW_CONFIG[tab];
  const Icon = config.icon;

  return (
    <div className="max-w-5xl mx-auto space-y-6 animate-in fade-in duration-200">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-lg bg-violet-600/10 border border-violet-500/30 flex items-center justify-center text-violet-400">
            <Icon className="h-5 w-5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-semibold text-slate-100 font-mono tracking-tight">
                {config.title}
              </h1>
              <span className="px-2 py-0.5 text-xs font-mono font-medium rounded-full bg-amber-500/10 text-amber-400 border border-amber-500/30">
                {config.stage}
              </span>
            </div>
            <p className="text-xs text-slate-400 mt-0.5">{config.summary}</p>
          </div>
        </div>

        <button
          onClick={onBackToOverview}
          className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-[#0F172A] border border-slate-800 hover:border-slate-700 text-xs font-mono text-slate-300 hover:text-white transition-all w-fit"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          <span>Back to Overview</span>
        </button>
      </div>

      <div className="p-6 rounded-xl bg-[#0F172A] border border-slate-800 space-y-6">
        <div className="flex items-start gap-4">
          <div className="h-10 w-10 rounded-lg bg-slate-800 flex items-center justify-center text-slate-400 shrink-0">
            <Calendar className="h-5 w-5" />
          </div>
          <div>
            <h2 className="text-sm font-semibold text-slate-200 uppercase tracking-wider font-mono">
              Development Phase Notice
            </h2>
            <p className="text-xs text-slate-400 mt-1 leading-relaxed">
              This module is formally scheduled in the AgentLens development roadmap.
            </p>
          </div>
        </div>

        <div className="pt-4 border-t border-slate-800/80">
          <h3 className="text-xs font-mono font-semibold text-slate-300 uppercase tracking-wider mb-3">
            Planned Technical Deliverables:
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {config.plannedFeatures.map((feat, idx) => (
              <div
                key={idx}
                className="p-3 rounded-lg bg-[#0B0F17] border border-slate-800/80 flex items-start gap-2.5"
              >
                <CheckCircle2 className="h-4 w-4 text-violet-400 shrink-0 mt-0.5" />
                <span className="text-xs text-slate-300 leading-normal">{feat}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="p-4 rounded-lg bg-[#0B0F17] border border-slate-800 font-mono text-xs space-y-2">
          <div className="flex items-center gap-2 text-violet-300">
            <Terminal className="h-4 w-4" />
            <span className="font-semibold">Architectural Integration Target</span>
          </div>
          <p className="text-slate-400 text-[11px] leading-relaxed">
            {config.techSpec}
          </p>
        </div>
      </div>
    </div>
  );
};
