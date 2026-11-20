import React, { useState } from 'react';
import {
  GitFork,
  Search,
  Clock,
  Layers,
  Network,
  ListTree,
  Info,
  Eye,
  EyeOff
} from 'lucide-react';
import type { Trace, Span } from '../../types';
import { SAMPLE_SPECIFICATION_TRACE } from './traceData';
import { TraceWaterfall } from './TraceWaterfall';
import { TraceGraphView } from './TraceGraphView';
import { SpanDetailsDrawer } from './SpanDetailsDrawer';
import { EmptyState } from '../common/EmptyState';

export const TraceExplorerView: React.FC = () => {
  // Mode toggle: waterfall vs graph
  const [viewMode, setViewMode] = useState<'waterfall' | 'graph'>('waterfall');

  // Data integrity: Specification preview toggle
  const [showSpecPreview, setShowSpecPreview] = useState<boolean>(true);

  // Search & Filter state
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'ALL' | 'SUCCESS' | 'FAILED'>('ALL');

  // Selected span for drawer
  const [selectedSpan, setSelectedSpan] = useState<Span | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  // Active trace being inspected
  const activeTrace: Trace | null = showSpecPreview ? SAMPLE_SPECIFICATION_TRACE : null;

  const handleSpanSelect = (span: Span) => {
    setSelectedSpan(span);
    setIsDrawerOpen(true);
  };

  return (
    <div className="space-y-4 animate-in fade-in duration-150">
      {/* Top Bar: Title & Specification Toggle */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="p-1.5 rounded-md bg-[#171c19] text-[#b8f56a] border border-[#252d28]">
              <GitFork className="h-4 w-4" />
            </div>
            <h1 className="text-base font-semibold text-[#f5f7f5] font-mono tracking-tight">
              Trace Explorer
            </h1>
            <span className="px-2 py-0.5 text-[9px] font-mono font-semibold uppercase tracking-wider rounded-xs bg-[#b8f56a]/10 text-[#b8f56a] border border-[#b8f56a]/30">
              Observability
            </span>
          </div>
        </div>

        {/* Interactive Specification Preview Switcher (Ensures Data Integrity) */}
        <div className="flex items-center gap-2 self-start sm:self-auto">
          <button
            onClick={() => setShowSpecPreview(!showSpecPreview)}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-md text-xs font-mono border transition-all ${
              showSpecPreview
                ? 'bg-[#1a201c] text-[#b8f56a] border-[#b8f56a]/40 shadow-xs'
                : 'bg-[#111512] text-[#929b94] border-[#252d28] hover:text-[#f5f7f5]'
            }`}
            title="Toggle between live zero-state and trace specification reference"
          >
            {showSpecPreview ? (
              <>
                <Eye className="h-3.5 w-3.5 text-[#b8f56a]" />
                <span>Reference Trace Active</span>
              </>
            ) : (
              <>
                <EyeOff className="h-3.5 w-3.5 text-[#626b64]" />
                <span>Live State (0 Traces)</span>
              </>
            )}
          </button>
        </div>
      </div>

      {/* Filter and Control Bar */}
      <div className="p-2.5 rounded-md bg-[#0c0e0d] border border-[#252d28] flex flex-wrap items-center justify-between gap-3">
        {/* Search */}
        <div className="relative flex-1 min-w-[200px] max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-[#929b94]" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Filter spans by name, type, or error..."
            className="w-full pl-8 pr-4 py-1.5 bg-[#090b0a] border border-[#252d28] rounded-md text-xs text-[#f5f7f5] placeholder:text-[#626b64] focus:outline-hidden focus:border-[#b8f56a]/60 font-mono"
          />
        </div>

        {/* View Mode Toggle: Waterfall vs DAG Graph */}
        <div className="flex items-center gap-1 p-1 rounded-md bg-[#090b0a] border border-[#252d28] text-xs font-mono">
          <button
            onClick={() => setViewMode('waterfall')}
            className={`flex items-center gap-1.5 px-3 py-1 rounded transition-colors ${
              viewMode === 'waterfall'
                ? 'bg-[#1a201c] text-[#b8f56a] font-semibold border border-[#b8f56a]/30'
                : 'text-[#929b94] hover:text-[#f5f7f5]'
            }`}
          >
            <ListTree className="h-3.5 w-3.5" />
            <span>Waterfall</span>
          </button>

          <button
            onClick={() => setViewMode('graph')}
            className={`flex items-center gap-1.5 px-3 py-1 rounded transition-colors ${
              viewMode === 'graph'
                ? 'bg-[#1a201c] text-[#b8f56a] font-semibold border border-[#b8f56a]/30'
                : 'text-[#929b94] hover:text-[#f5f7f5]'
            }`}
          >
            <Network className="h-3.5 w-3.5" />
            <span>DAG Graph</span>
          </button>
        </div>

        {/* Status Filter */}
        <div className="flex items-center gap-1 text-xs font-mono">
          {(['ALL', 'SUCCESS', 'FAILED'] as const).map((filter) => (
            <button
              key={filter}
              onClick={() => setStatusFilter(filter)}
              className={`px-2.5 py-1 rounded-md text-[10px] uppercase tracking-wider transition-colors ${
                statusFilter === filter
                  ? 'bg-[#1a201c] text-[#f5f7f5] border border-[#252d28]'
                  : 'text-[#626b64] hover:text-[#929b94]'
              }`}
            >
              {filter}
            </button>
          ))}
        </div>
      </div>

      {/* Main Investigation Area */}
      {showSpecPreview && activeTrace ? (
        <div className="space-y-4">
          {/* Active Trace Summary Card */}
          <div className="p-3.5 rounded-lg bg-[#111512] border border-[#252d28] flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs font-mono">
            <div className="flex flex-wrap items-center gap-2.5">
              <span className="text-[#929b94]">Trace:</span>
              <span className="text-[#b8f56a] font-bold">{activeTrace.id}</span>
              <span className="text-[#354039]">&bull;</span>
              <span className="text-[#f5f7f5]">{activeTrace.agentName}</span>
              <span className="text-[#354039]">&bull;</span>
              <span className="px-1.5 py-0.2 rounded-xs bg-[#f06f68]/15 text-[#f6928d] border border-[#f06f68]/30 font-medium">
                {activeTrace.status}
              </span>
              <span className="text-[#626b64]">({activeTrace.spanCount} Spans)</span>
            </div>

            <div className="flex items-center gap-4 text-[#929b94]">
              <div className="flex items-center gap-1">
                <Clock className="h-3.5 w-3.5 text-[#626b64]" />
                <span>{activeTrace.durationMs}ms</span>
              </div>
              <div>
                <span>{activeTrace.totalTokens} Tokens</span>
              </div>
              <div className="px-2 py-0.5 rounded-xs bg-[#b8f56a]/10 text-[#b8f56a] border border-[#b8f56a]/30 text-[9px] uppercase tracking-wider font-semibold">
                Reference Mode
              </div>
            </div>
          </div>

          {/* View: Waterfall or Graph */}
          {viewMode === 'waterfall' ? (
            <TraceWaterfall
              trace={activeTrace}
              onSelectSpan={handleSpanSelect}
              selectedSpanId={selectedSpan?.id}
            />
          ) : (
            <TraceGraphView
              trace={activeTrace}
              onSelectSpan={handleSpanSelect}
              selectedSpanId={selectedSpan?.id}
            />
          )}

          {/* Helper notice */}
          <div className="p-3 rounded-md bg-[#111512] border border-[#252d28] text-[11px] font-mono text-[#929b94] flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Info className="h-4 w-4 text-[#b8f56a] shrink-0" />
              <span>
                Click any span row or graph node to inspect raw input payloads, output responses, and execution events.
              </span>
            </div>
            <span className="text-[#626b64] hidden sm:inline">Telemetry Architecture</span>
          </div>
        </div>
      ) : (
        /* Honest Empty State when preview is disabled */
        <EmptyState
          icon={Layers}
          title="No Active Execution Traces"
          description="The platform is awaiting telemetry ingestion from your agent runtime. Once instrumented with the AgentLens SDK, execution journeys, span waterfalls, and DAG graphs will stream here automatically."
          badgeText="Awaiting SDK Ingestion"
          badgeVariant="info"
          action={{
            label: "Enable Trace Specification Preview",
            onClick: () => setShowSpecPreview(true),
          }}
        >
          <div className="max-w-md mx-auto text-left p-3 rounded-md bg-[#090b0a] border border-[#252d28] font-mono text-xs text-[#929b94] space-y-1 mt-2">
            <div className="text-[9px] text-[#626b64] uppercase font-semibold">How to Stream Traces:</div>
            <p className="text-[11px] text-[#d6ddd7]">
              1. Connect your agent with <code className="text-[#b8f56a] font-semibold">@agentlens.trace</code>
            </p>
            <p className="text-[11px] text-[#d6ddd7]">
              2. Execute your agent tasks to populate timeline waterfalls
            </p>
          </div>
        </EmptyState>
      )}

      {/* Expandable Span Details Drawer */}
      <SpanDetailsDrawer
        span={selectedSpan}
        isOpen={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
      />
    </div>
  );
};
