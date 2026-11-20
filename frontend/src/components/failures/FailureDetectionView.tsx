import React, { useState } from 'react';
import {
  ShieldAlert,
  CheckCircle2,
  FileText,
  Eye,
  EyeOff
} from 'lucide-react';
import type { FailureRuleDefinition, FailureViolation, FailureSeverity } from '../../types';
import { EvidenceDrawer } from './EvidenceDrawer';
import { EmptyState } from '../common/EmptyState';

const RULES_CATALOG: FailureRuleDefinition[] = [
  {
    id: 'FAILED_SPAN',
    name: 'Failed Span',
    description: 'Span execution terminates with an unhandled exception or status ERROR.',
    condition: "span.status == 'ERROR' or span.error_message != null",
    severity: 'CRITICAL',
    status: 'standby',
  },
  {
    id: 'REPEATED_TOOL_CALL',
    name: 'Repeated Tool Call',
    description: 'Identical tool is called repeatedly with identical parameters within span window.',
    condition: 'tool_name[t] == tool_name[t-1] and hash(input[t]) == hash(input[t-1])',
    severity: 'HIGH',
    status: 'standby',
  },
  {
    id: 'EXCESSIVE_RETRIES',
    name: 'Excessive Retries',
    description: 'Same operation, prompt generation, or tool call retried more than threshold (>3).',
    condition: 'retry_count > 3 within continuous execution window',
    severity: 'WARNING',
    status: 'standby',
  },
  {
    id: 'SLOW_SPAN',
    name: 'Slow Span',
    description: 'Span duration exceeds predefined latency SLA or statistical distribution threshold.',
    condition: 'span.duration_ms > sla_threshold (LLM > 10,000ms, Tool > 5,000ms)',
    severity: 'WARNING',
    status: 'standby',
  },
  {
    id: 'EMPTY_TOOL_RESULT',
    name: 'Empty Tool Result',
    description: 'Tool executes successfully (exit 0) but returns empty payload starving context.',
    condition: "span.type == 'tool' and output in ('', None, {}, [], 0 bytes)",
    severity: 'HIGH',
    status: 'standby',
  },
];

const SAMPLE_REFERENCE_VIOLATIONS: FailureViolation[] = [
  {
    id: 'viol_01',
    traceId: 'trc_9a4f7e21',
    spanId: 'spn_tool_04',
    spanName: 'fetch_sec_filing (duplicate)',
    ruleType: 'REPEATED_TOOL_CALL',
    severity: 'HIGH',
    timestamp: '2026-11-19T12:15:33.020Z',
    evidenceSummary: 'Agent called tool fetch_sec_filing twice with identical argument {ticker: NVDA, form_type: 10-Q}.',
    evidenceData: {
      tool_name: 'sec_edgar_client',
      arguments_hash: 'a4b89e12f0c7',
      previous_span_id: 'spn_tool_03',
      current_span_id: 'spn_tool_04',
      delta_ms: 1210,
    },
  },
  {
    id: 'viol_02',
    traceId: 'trc_9a4f7e21',
    spanId: 'spn_root_01',
    spanName: 'execute_financial_audit',
    ruleType: 'FAILED_SPAN',
    severity: 'CRITICAL',
    timestamp: '2026-11-19T12:15:33.540Z',
    evidenceSummary: 'Root span terminated with status ERROR due to repeated tool loop boundary trip.',
    evidenceData: {
      exit_status: 'ERROR',
      root_cause: 'Repeated tool loop on fetch_sec_filing',
      handled_by_fallback: true,
    },
  },
];

const SEVERITY_STYLES: Record<FailureSeverity, string> = {
  CRITICAL: 'bg-[#f06f68]/15 text-[#f06f68] border-[#f06f68]/30',
  HIGH: 'bg-[#e5ad55]/15 text-[#e5ad55] border-[#e5ad55]/30',
  WARNING: 'bg-[#e5ad55]/10 text-[#e5ad55] border-[#e5ad55]/20',
};

export const FailureDetectionView: React.FC = () => {
  const [showReferenceViolations, setShowReferenceViolations] = useState(true);
  const [selectedViolation, setSelectedViolation] = useState<FailureViolation | null>(null);
  const [isEvidenceOpen, setIsEvidenceOpen] = useState(false);
  const [selectedSeverity, setSelectedSeverity] = useState<string>('ALL');

  const activeViolations = showReferenceViolations
    ? selectedSeverity === 'ALL'
      ? SAMPLE_REFERENCE_VIOLATIONS
      : SAMPLE_REFERENCE_VIOLATIONS.filter((v) => v.severity === selectedSeverity)
    : [];

  const handleInspectEvidence = (v: FailureViolation) => {
    setSelectedViolation(v);
    setIsEvidenceOpen(true);
  };

  return (
    <div className="space-y-5 animate-in fade-in duration-150">
      {/* Top Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="p-1.5 rounded-md bg-[#171c19] text-[#e5ad55] border border-[#252d28]">
              <ShieldAlert className="h-4 w-4" />
            </div>
            <h1 className="text-base font-semibold text-[#f5f7f5] font-mono tracking-tight">
              Failure Detection & Rule Engine
            </h1>
            <span className="px-2 py-0.5 text-[9px] font-mono font-semibold uppercase tracking-wider rounded-xs bg-[#e5ad55]/10 text-[#e5ad55] border border-[#e5ad55]/30">
              5 Rules
            </span>
          </div>
        </div>

        {/* Reference Toggle */}
        <button
          onClick={() => setShowReferenceViolations(!showReferenceViolations)}
          aria-label="Toggle reference violations"
          className={`flex items-center gap-2 px-3 py-1.5 rounded-md text-xs font-mono border transition-all self-start sm:self-auto cursor-pointer ${
            showReferenceViolations
              ? 'bg-[#171c19] text-[#b8f56a] border-[#b8f56a]/40 shadow-xs'
              : 'bg-[#111512] text-[#88948a] border-[#252d28] hover:text-[#f5f7f5]'
          }`}
        >
          {showReferenceViolations ? (
            <>
              <Eye className="h-3.5 w-3.5 text-[#b8f56a]" />
              <span>Reference Violations</span>
            </>
          ) : (
            <>
              <EyeOff className="h-3.5 w-3.5 text-[#88948a]" />
              <span>Live State (0)</span>
            </>
          )}
        </button>
      </div>

      {/* The Five Established Detection Rules Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-3">
        {RULES_CATALOG.map((rule) => (
          <div
            key={rule.id}
            className="p-3.5 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-2 flex flex-col justify-between hover:bg-[#101311] transition-colors"
          >
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <span className="text-[10px] font-mono text-[#626b64] uppercase font-semibold">
                  Rule {rule.id.split('_')[0]}
                </span>
                <span
                  className={`text-[9px] font-mono px-1.5 py-0.5 rounded border uppercase font-medium ${
                    SEVERITY_STYLES[rule.severity]
                  }`}
                >
                  {rule.severity}
                </span>
              </div>
              <h3 className="text-xs font-semibold text-[#f5f7f5] font-mono">
                {rule.name}
              </h3>
              <p className="text-[10px] text-[#929b94] mt-1 leading-normal font-sans">
                {rule.description}
              </p>
            </div>

            <div className="pt-2 border-t border-[#252d28] text-[9px] font-mono text-[#626b64]">
              Status: Standby
            </div>
          </div>
        ))}
      </div>

      {/* Compact Professional Failure Violations Table */}
      <div className="p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
          <div className="flex items-center gap-2">
            <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Flagged Failure Violations
            </h2>
            <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-[#171c19] text-[#929b94] border border-[#252d28]">
              {activeViolations.length} records
            </span>
          </div>

          {/* Severity Filter */}
          <div className="flex items-center gap-1.5 text-xs font-mono">
            <span className="text-[#626b64] text-[11px] mr-1">Severity:</span>
            {['ALL', 'CRITICAL', 'HIGH', 'WARNING'].map((sev) => (
              <button
                key={sev}
                onClick={() => setSelectedSeverity(sev)}
                className={`px-2 py-0.5 rounded text-[10px] transition-colors ${
                  selectedSeverity === sev
                    ? 'bg-[#1c221e] text-[#f5f7f5] border border-[#303a33]'
                    : 'text-[#929b94] hover:text-[#f5f7f5]'
                }`}
              >
                {sev}
              </button>
            ))}
          </div>
        </div>

        {activeViolations.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs font-mono">
              <thead>
                <tr className="border-b border-[#252d28] text-[11px] text-[#626b64] uppercase tracking-wider">
                  <th className="pb-2.5 font-medium">Failure Type</th>
                  <th className="pb-2.5 font-medium">Severity</th>
                  <th className="pb-2.5 font-medium">Associated Trace</th>
                  <th className="pb-2.5 font-medium">Affected Span</th>
                  <th className="pb-2.5 font-medium">Timestamp</th>
                  <th className="pb-2.5 font-medium text-right">Evidence</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#252d28]/60">
                {activeViolations.map((violation) => (
                  <tr
                    key={violation.id}
                    onClick={() => handleInspectEvidence(violation)}
                    className="hover:bg-[#171c19] cursor-pointer transition-colors group"
                  >
                    <td className="py-3 font-semibold text-[#f5f7f5] flex items-center gap-2">
                      <ShieldAlert className="h-3.5 w-3.5 text-[#e5ad55]" />
                      <span>{violation.ruleType}</span>
                    </td>
                    <td className="py-3">
                      <span
                        className={`text-[9px] font-mono px-1.5 py-0.5 rounded border uppercase ${
                          SEVERITY_STYLES[violation.severity]
                        }`}
                      >
                        {violation.severity}
                      </span>
                    </td>
                    <td className="py-3 text-[#b8f56a] hover:underline">
                      {violation.traceId}
                    </td>
                    <td className="py-3 text-[#f5f7f5]">
                      <div className="truncate max-w-[200px]">{violation.spanName}</div>
                      <div className="text-[10px] text-[#626b64]">{violation.spanId}</div>
                    </td>
                    <td className="py-3 text-[#929b94]">
                      {new Date(violation.timestamp).toLocaleTimeString()}
                    </td>
                    <td className="py-3 text-right">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleInspectEvidence(violation);
                        }}
                        className="inline-flex items-center gap-1 px-2.5 py-1 rounded bg-[#b8f56a]/10 hover:bg-[#b8f56a]/20 border border-[#b8f56a]/30 text-[#b8f56a] text-[11px] transition-colors"
                      >
                        <FileText className="h-3 w-3" />
                        <span>Inspect Evidence</span>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <EmptyState
            icon={CheckCircle2}
            title="Zero Failure Violations"
            description="The deterministic failure rules are armed and monitoring telemetry. No violations have been detected in the selected project and environment."
            badgeText="0 Violations Detected"
            badgeVariant="neutral"
            action={{
              label: "Enable Reference Violations Preview",
              onClick: () => setShowReferenceViolations(true),
            }}
          />
        )}
      </div>

      {/* Supporting Evidence Drawer */}
      <EvidenceDrawer
        violation={selectedViolation}
        isOpen={isEvidenceOpen}
        onClose={() => setIsEvidenceOpen(false)}
      />
    </div>
  );
};
