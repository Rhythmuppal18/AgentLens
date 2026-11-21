import React, { useState } from 'react';
import {
  Sparkles,
  Copy,
  Check,
  AlertTriangle,
  Lightbulb,
  Code2,
  ShieldCheck,
  Flame
} from 'lucide-react';
import type { FailureViolation } from '../../types';
import { ModalDrawer } from '../common/ModalDrawer';
import { generateAiDiagnosis } from '../../services/aiDiagnostician';

interface AiDiagnosisModalProps {
  violation: FailureViolation | null;
  isOpen: boolean;
  onClose: () => void;
}

export const AiDiagnosisModal: React.FC<AiDiagnosisModalProps> = ({
  violation,
  isOpen,
  onClose,
}) => {
  const [copiedPrompt, setCopiedPrompt] = useState(false);
  const [copiedCode, setCopiedCode] = useState(false);

  if (!violation) return null;

  const diagnosis = generateAiDiagnosis(violation);

  const handleCopyPrompt = () => {
    navigator.clipboard.writeText(diagnosis.recommendedPromptFix);
    setCopiedPrompt(true);
    setTimeout(() => setCopiedPrompt(false), 2000);
  };

  const handleCopyCode = () => {
    navigator.clipboard.writeText(diagnosis.recommendedCodeFix);
    setCopiedCode(true);
    setTimeout(() => setCopiedCode(false), 2000);
  };

  return (
    <ModalDrawer
      isOpen={isOpen}
      onClose={onClose}
      title="✨ AI Root-Cause Diagnosis"
      subtitle={`Trace: ${violation.traceId} • Span: ${violation.spanName || violation.spanId}`}
      badge={`${diagnosis.confidenceScore}% AI Confidence`}
      width="max-w-2xl"
    >
      <div className="space-y-4 font-mono text-xs">
        {/* Headline Banner */}
        <div className="p-4 rounded-xl bg-[linear-gradient(90deg,rgba(184,245,106,0.1)_0%,rgba(17,21,18,0.9)_70%,transparent)] border border-[#b8f56a]/30 space-y-1.5">
          <div className="flex items-center gap-2 text-[#b8f56a] font-semibold text-xs tracking-tight">
            <Sparkles className="h-4 w-4" />
            <span>{diagnosis.headline}</span>
          </div>
          <p className="text-xs text-[#929b94] font-sans leading-relaxed">
            {diagnosis.whatHappened}
          </p>
        </div>

        {/* 2-Column Root Cause & Impact Strip */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {/* Root Cause */}
          <div className="p-3.5 rounded-xl bg-[#111512] border border-[#252d28] space-y-1.5">
            <div className="flex items-center gap-1.5 text-[#e5ad55] text-[11px] font-semibold">
              <AlertTriangle className="h-3.5 w-3.5" />
              <span>Root Cause Diagnosis</span>
            </div>
            <p className="text-[11px] text-[#929b94] font-sans leading-relaxed">
              {diagnosis.rootCause}
            </p>
          </div>

          {/* Operational Impact */}
          <div className="p-3.5 rounded-xl bg-[#111512] border border-[#252d28] space-y-1.5">
            <div className="flex items-center gap-1.5 text-[#f06f68] text-[11px] font-semibold">
              <Flame className="h-3.5 w-3.5" />
              <span>Production Impact ({diagnosis.impactLevel})</span>
            </div>
            <p className="text-[11px] text-[#929b94] font-sans leading-relaxed">
              {diagnosis.impactDescription}
            </p>
          </div>
        </div>

        {/* Recommended System Prompt Fix (The Hero Section!) */}
        <div className="p-4 rounded-xl bg-[#0c100d] border border-[#b8f56a]/40 space-y-3 shadow-lg shadow-[#b8f56a]/5">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 text-[#b8f56a]">
              <ShieldCheck className="h-4 w-4" />
              <span className="font-semibold text-xs">Recommended Guardrail Prompt Fix</span>
            </div>

            <button
              onClick={handleCopyPrompt}
              className="flex items-center gap-1.5 px-3 py-1 rounded-md bg-[#b8f56a] hover:bg-[#a6e655] text-[#090b0a] font-bold text-[11px] transition-all cursor-pointer shadow-xs"
            >
              {copiedPrompt ? (
                <>
                  <Check className="h-3 w-3" />
                  <span>Copied to Clipboard!</span>
                </>
              ) : (
                <>
                  <Copy className="h-3 w-3" />
                  <span>Copy Prompt Fix</span>
                </>
              )}
            </button>
          </div>

          <p className="text-[11px] text-[#626b64] font-sans">
            Paste this instruction into your agent&apos;s system prompt to deterministically prevent this failure loop:
          </p>

          <div className="p-3 rounded-lg bg-[#070908] border border-[#252d28] text-[11px] text-[#b8f56a] leading-relaxed whitespace-pre-wrap font-mono">
            {diagnosis.recommendedPromptFix}
          </div>
        </div>

        {/* Defensive Code Guardrail */}
        <div className="p-3.5 rounded-xl bg-[#111512] border border-[#252d28] space-y-2">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1.5 text-[#6bc8c1]">
              <Code2 className="h-3.5 w-3.5" />
              <span className="font-semibold text-xs">Defensive Python SDK Guardrail</span>
            </div>

            <button
              onClick={handleCopyCode}
              className="flex items-center gap-1 px-2.5 py-0.5 rounded bg-[#171c19] hover:bg-[#1f2622] border border-[#252d28] text-[#f5f7f5] text-[10px] transition-colors cursor-pointer"
            >
              {copiedCode ? <Check className="h-3 w-3 text-[#67c98a]" /> : <Copy className="h-3 w-3" />}
              <span>{copiedCode ? 'Copied' : 'Copy Code'}</span>
            </button>
          </div>

          <div className="p-3 rounded-lg bg-[#070908] border border-[#252d28] text-[11px] text-[#6bc8c1] overflow-x-auto leading-relaxed">
            <pre><code>{diagnosis.recommendedCodeFix}</code></pre>
          </div>
        </div>

        {/* Footer Note */}
        <div className="pt-2 border-t border-[#252d28] flex items-center justify-between text-[10px] text-[#626b64]">
          <span className="flex items-center gap-1">
            <Lightbulb className="h-3 w-3 text-[#e5ad55]" />
            Generated deterministically by AgentLens AI Diagnostician
          </span>
          <button
            onClick={onClose}
            className="hover:text-[#f5f7f5] transition-colors cursor-pointer"
          >
            Close Diagnosis
          </button>
        </div>
      </div>
    </ModalDrawer>
  );
};
