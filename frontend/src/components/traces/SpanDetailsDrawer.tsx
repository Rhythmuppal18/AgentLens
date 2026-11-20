import React, { useState } from 'react';
import {
  Check,
  Copy,
  AlertTriangle,
  GitCommit
} from 'lucide-react';
import type { Span } from '../../types';
import { ModalDrawer } from '../common/ModalDrawer';

interface SpanDetailsDrawerProps {
  span: Span | null;
  isOpen: boolean;
  onClose: () => void;
}

export const SpanDetailsDrawer: React.FC<SpanDetailsDrawerProps> = ({
  span,
  isOpen,
  onClose,
}) => {
  const [activeTab, setActiveTab] = useState<'input' | 'output' | 'error' | 'events'>('input');
  const [copied, setCopied] = useState(false);

  if (!span) return null;

  const handleCopy = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const formattedInput = typeof span.inputPayload === 'object'
    ? JSON.stringify(span.inputPayload, null, 2)
    : String(span.inputPayload || 'null');

  const formattedOutput = typeof span.outputPayload === 'object'
    ? JSON.stringify(span.outputPayload, null, 2)
    : String(span.outputPayload || 'null');

  return (
    <ModalDrawer
      isOpen={isOpen}
      onClose={onClose}
      title={span.name}
      subtitle={`Span ID: ${span.id} • ${span.spanType}`}
      badge={span.status}
      width="max-w-2xl"
    >
      {/* Top Metadata Strip */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-xs font-mono">
        <div className="p-2.5 rounded-md bg-[#111512] border border-[#252d28]">
          <span className="text-[9px] text-[#929b94] uppercase tracking-wider block">Duration</span>
          <span className="text-[#f5f7f5] font-semibold">{span.durationMs}ms</span>
        </div>

        <div className="p-2.5 rounded-md bg-[#111512] border border-[#252d28]">
          <span className="text-[9px] text-[#929b94] uppercase tracking-wider block">Status</span>
          <span className={`font-semibold ${span.status === 'OK' ? 'text-[#83cda0]' : 'text-[#f6928d]'}`}>
            {span.status}
          </span>
        </div>

        <div className="p-2.5 rounded-md bg-[#111512] border border-[#252d28]">
          <span className="text-[9px] text-[#929b94] uppercase tracking-wider block">Model / Tool</span>
          <span className="text-[#f5f7f5] font-semibold truncate block">
            {span.attributes.model || span.attributes.toolName || 'Native Agent'}
          </span>
        </div>

        <div className="p-2.5 rounded-md bg-[#111512] border border-[#252d28]">
          <span className="text-[9px] text-[#929b94] uppercase tracking-wider block">Tokens</span>
          <span className="text-[#f5f7f5] font-semibold">
            {span.attributes.totalTokens ? `${span.attributes.totalTokens}` : '--'}
          </span>
        </div>
      </div>

      {/* Parent-Child Relation Badge */}
      <div className="p-2.5 rounded-md bg-[#111512] border border-[#252d28] text-xs font-mono flex items-center justify-between text-[#929b94]">
        <div className="flex items-center gap-1.5 truncate">
          <GitCommit className="h-3.5 w-3.5 text-[#b8f56a]" />
          <span>Parent Span:</span>
          <span className="text-[#f5f7f5] truncate">{span.parentSpanId || 'Root (None)'}</span>
        </div>
        <span className="text-[10px] text-[#626b64] shrink-0">
          Trace: {span.traceId}
        </span>
      </div>

      {/* Tabs */}
      <div className="space-y-3">
        <div className="flex items-center gap-1 border-b border-[#252d28] pb-1 text-xs font-mono">
          <button
            onClick={() => setActiveTab('input')}
            className={`px-3 py-1.5 rounded-md transition-colors ${
              activeTab === 'input'
                ? 'bg-[#1a201c] text-[#b8f56a] font-medium border-b-2 border-[#b8f56a]'
                : 'text-[#929b94] hover:text-[#f5f7f5]'
            }`}
          >
            Input Payload
          </button>
          <button
            onClick={() => setActiveTab('output')}
            className={`px-3 py-1.5 rounded-md transition-colors ${
              activeTab === 'output'
                ? 'bg-[#1a201c] text-[#b8f56a] font-medium border-b-2 border-[#b8f56a]'
                : 'text-[#929b94] hover:text-[#f5f7f5]'
            }`}
          >
            Output Payload
          </button>
          {span.errorMessage && (
            <button
              onClick={() => setActiveTab('error')}
              className={`px-3 py-1.5 rounded-md transition-colors flex items-center gap-1 ${
                activeTab === 'error'
                  ? 'bg-[#f06f68]/15 text-[#f6928d] font-medium border-b-2 border-[#f06f68]'
                  : 'text-[#f06f68] hover:text-[#f6928d]'
              }`}
            >
              <span>Error Details</span>
              <span className="h-1.5 w-1.5 rounded-full bg-[#f06f68]" />
            </button>
          )}
          <button
            onClick={() => setActiveTab('events')}
            className={`px-3 py-1.5 rounded-md transition-colors ${
              activeTab === 'events'
                ? 'bg-[#1a201c] text-[#b8f56a] font-medium border-b-2 border-[#b8f56a]'
                : 'text-[#929b94] hover:text-[#f5f7f5]'
            }`}
          >
            Events ({span.events.length})
          </button>
        </div>

        {/* Tab Content: Input */}
        {activeTab === 'input' && (
          <div className="relative rounded-md bg-[#0c100d] border border-[#252d28] p-4">
            <button
              onClick={() => handleCopy(formattedInput)}
              className="absolute top-3 right-3 p-1.5 rounded bg-[#171c19] hover:bg-[#202621] text-[#929b94] hover:text-[#f5f7f5] transition-colors text-xs font-mono flex items-center gap-1 border border-[#252d28]"
              title="Copy input JSON"
            >
              {copied ? <Check className="h-3.5 w-3.5 text-[#67c98a]" /> : <Copy className="h-3.5 w-3.5" />}
              <span className="text-[10px]">{copied ? 'Copied' : 'Copy'}</span>
            </button>
            <pre className="text-xs font-mono text-[#d6ddd7] overflow-x-auto max-h-96 leading-relaxed">
              <code>{formattedInput}</code>
            </pre>
          </div>
        )}

        {/* Tab Content: Output */}
        {activeTab === 'output' && (
          <div className="relative rounded-md bg-[#0c100d] border border-[#252d28] p-4">
            <button
              onClick={() => handleCopy(formattedOutput)}
              className="absolute top-3 right-3 p-1.5 rounded bg-[#171c19] hover:bg-[#202621] text-[#929b94] hover:text-[#f5f7f5] transition-colors text-xs font-mono flex items-center gap-1 border border-[#252d28]"
              title="Copy output JSON"
            >
              {copied ? <Check className="h-3.5 w-3.5 text-[#67c98a]" /> : <Copy className="h-3.5 w-3.5" />}
              <span className="text-[10px]">{copied ? 'Copied' : 'Copy'}</span>
            </button>
            <pre className="text-xs font-mono text-[#d6ddd7] overflow-x-auto max-h-96 leading-relaxed">
              <code>{formattedOutput}</code>
            </pre>
          </div>
        )}

        {/* Tab Content: Error */}
        {activeTab === 'error' && (
          <div className="p-4 rounded-md bg-[#f06f68]/10 border border-[#f06f68]/30 space-y-3 font-mono text-xs">
            <div className="flex items-center gap-2 text-[#f6928d] font-semibold">
              <AlertTriangle className="h-4 w-4" />
              <span>Diagnostic Failure Message</span>
            </div>
            <div className="p-3 rounded bg-[#090b0a] border border-[#f06f68]/20 text-[#f6928d] leading-relaxed overflow-x-auto">
              <code>{span.errorMessage}</code>
            </div>
          </div>
        )}

        {/* Tab Content: Events */}
        {activeTab === 'events' && (
          <div className="space-y-2">
            {span.events.length === 0 ? (
              <div className="p-4 rounded-md bg-[#111512] text-xs font-mono text-[#626b64] text-center">
                No intermediate events logged for this span.
              </div>
            ) : (
              span.events.map((evt, idx) => (
                <div
                  key={idx}
                  className="p-3 rounded-md bg-[#111512] border border-[#252d28] text-xs font-mono space-y-1.5"
                >
                  <div className="flex items-center justify-between text-[#929b94]">
                    <span className="font-semibold text-[#6bc8c1]">{evt.name}</span>
                    <span className="text-[10px] text-[#626b64]">
                      {new Date(evt.timestamp).toLocaleTimeString()}
                    </span>
                  </div>
                  <pre className="text-[11px] text-[#d6ddd7] overflow-x-auto">
                    <code>{JSON.stringify(evt.data, null, 2)}</code>
                  </pre>
                </div>
              ))
            )}
          </div>
        )}
      </div>
    </ModalDrawer>
  );
};
