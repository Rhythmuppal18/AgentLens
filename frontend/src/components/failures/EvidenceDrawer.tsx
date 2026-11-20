import React, { useState } from 'react';
import {
  Copy,
  Check,
  ArrowUpRight,
  AlertTriangle,
  GitFork,
  FileCode
} from 'lucide-react';
import type { FailureViolation } from '../../types';
import { ModalDrawer } from '../common/ModalDrawer';
import { useApp } from '../../context/useApp';

interface EvidenceDrawerProps {
  violation: FailureViolation | null;
  isOpen: boolean;
  onClose: () => void;
}

export const EvidenceDrawer: React.FC<EvidenceDrawerProps> = ({
  violation,
  isOpen,
  onClose,
}) => {
  const { setActiveTab } = useApp();
  const [copied, setCopied] = useState(false);

  if (!violation) return null;

  const handleCopy = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const formattedEvidence = JSON.stringify(violation.evidenceData, null, 2);

  return (
    <ModalDrawer
      isOpen={isOpen}
      onClose={onClose}
      title={`Failure Evidence: ${violation.ruleType}`}
      subtitle={`Trace: ${violation.traceId} • Span: ${violation.spanId}`}
      badge={violation.severity}
      width="max-w-2xl"
    >
      {/* Evidence Summary Alert */}
      <div className="p-4 rounded-xl bg-[linear-gradient(90deg,rgba(229,173,85,0.08)_0%,rgba(17,21,18,0.9)_70%,transparent)] border border-[#e5ad55]/30 space-y-2">
        <div className="flex items-center gap-2 text-[#e5ad55] font-mono text-xs font-semibold">
          <AlertTriangle className="h-4 w-4" />
          <span>Diagnostic Attribution Summary</span>
        </div>
        <p className="text-xs text-[#929b94] font-sans leading-relaxed">
          {violation.evidenceSummary}
        </p>
      </div>

      {/* Target Meta Grid */}
      <div className="grid grid-cols-2 gap-3 text-xs font-mono">
        <div className="p-3.5 rounded-xl bg-[#111512] border border-[#252d28] space-y-1">
          <span className="text-[10px] text-[#626b64] uppercase block font-semibold">Affected Span</span>
          <span className="text-[#f5f7f5] font-semibold">{violation.spanName}</span>
          <span className="text-[10px] text-[#626b64] block">ID: {violation.spanId}</span>
        </div>

        <div className="p-3.5 rounded-xl bg-[#111512] border border-[#252d28] space-y-1">
          <span className="text-[10px] text-[#626b64] uppercase block font-semibold">Detected Timestamp</span>
          <span className="text-[#f5f7f5] font-semibold">
            {new Date(violation.timestamp).toLocaleTimeString()}
          </span>
          <span className="text-[10px] text-[#626b64] block">
            {new Date(violation.timestamp).toLocaleDateString()}
          </span>
        </div>
      </div>

      {/* Raw Serialized Evidence Payload */}
      <div className="space-y-2 font-mono">
        <div className="flex items-center justify-between text-xs text-[#929b94]">
          <div className="flex items-center gap-1.5">
            <FileCode className="h-3.5 w-3.5 text-[#6bc8c1]" />
            <span className="font-semibold text-[#f5f7f5]">Supporting Evidence Payload</span>
          </div>

          <button
            onClick={() => handleCopy(formattedEvidence)}
            className="flex items-center gap-1 px-2.5 py-1 rounded bg-[#171c19] hover:bg-[#1c221e] border border-[#252d28] text-[#f5f7f5] text-xs transition-colors"
          >
            {copied ? <Check className="h-3 w-3 text-[#67c98a]" /> : <Copy className="h-3 w-3" />}
            <span className="text-[10px]">{copied ? 'Copied' : 'Copy Payload'}</span>
          </button>
        </div>

        <div className="p-4 rounded-xl bg-[#0c100d] border border-[#252d28] text-xs text-[#6bc8c1] overflow-x-auto max-h-72 leading-relaxed">
          <pre><code>{formattedEvidence}</code></pre>
        </div>
      </div>

      {/* Cross Navigation Action */}
      <div className="pt-3 border-t border-[#252d28] flex items-center justify-between">
        <button
          onClick={() => {
            onClose();
            setActiveTab('traces');
          }}
          className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-[#b8f56a]/15 hover:bg-[#b8f56a]/25 border border-[#b8f56a]/30 text-xs font-mono text-[#b8f56a] transition-colors"
        >
          <GitFork className="h-3.5 w-3.5" />
          <span>Inspect Span in Trace Explorer</span>
          <ArrowUpRight className="h-3 w-3" />
        </button>

        <span className="text-[10px] font-mono text-[#626b64]">
          Rule: {violation.ruleType}
        </span>
      </div>
    </ModalDrawer>
  );
};
