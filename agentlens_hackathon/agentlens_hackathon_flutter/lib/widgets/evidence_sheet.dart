import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agentlens_hackathon_client/agentlens_hackathon_client.dart';
import '../theme.dart';

class EvidenceSheet extends StatelessWidget {
  final RoomFinding? finding;
  final RoomSpan? span;
  final VoidCallback onClose;

  const EvidenceSheet({
    super.key,
    this.finding,
    this.span,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AgentLensTheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: AgentLensTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                finding != null ? Icons.warning_amber_rounded : Icons.code_rounded,
                color: finding != null ? _getSeverityColor(finding!.severity) : AgentLensTheme.info,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  finding != null ? 'Failure Evidence Inspector' : 'Span Payload Inspector',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const Divider(color: AgentLensTheme.border, height: 24),
          if (finding != null) ...[
            _buildBadgeRow(
              ruleType: finding!.ruleType,
              severity: finding!.severity,
              isSample: finding!.isSample,
            ),
            const SizedBox(height: 12),
            Text(
              finding!.summary,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AgentLensTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              finding!.evidenceSummary,
              style: const TextStyle(fontSize: 13, color: AgentLensTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'REDACTED EXECUTION EVIDENCE:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: AgentLensTheme.textMuted),
            ),
            const SizedBox(height: 8),
            _buildJsonViewer(context, finding!.evidenceDataJson ?? '{}'),
          ] else if (span != null) ...[
            Row(
              children: [
                Chip(
                  label: Text(span!.spanType.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  backgroundColor: AgentLensTheme.surface,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${span!.durationMs} ms', style: const TextStyle(fontSize: 11)),
                  backgroundColor: span!.durationMs > 4000 ? AgentLensTheme.warning.withValues(alpha: 0.2) : AgentLensTheme.surface,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(span!.status.toUpperCase(), style: TextStyle(fontSize: 11, color: span!.status == 'error' ? AgentLensTheme.error : AgentLensTheme.success)),
                  backgroundColor: span!.status == 'error' ? AgentLensTheme.error.withValues(alpha: 0.15) : AgentLensTheme.success.withValues(alpha: 0.15),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Span: ${span!.name}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            if (span!.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AgentLensTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AgentLensTheme.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Error: ${span!.errorMessage}',
                  style: const TextStyle(color: AgentLensTheme.error, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Text(
              'INPUT PAYLOAD (SANITIZED):',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: AgentLensTheme.textMuted),
            ),
            const SizedBox(height: 6),
            _buildJsonViewer(context, span!.inputPayloadJson ?? 'null'),
            const SizedBox(height: 12),
            const Text(
              'OUTPUT PAYLOAD (SANITIZED):',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: AgentLensTheme.textMuted),
            ),
            const SizedBox(height: 6),
            _buildJsonViewer(context, span!.outputPayloadJson ?? 'null'),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeRow({
    required String ruleType,
    required String severity,
    required bool isSample,
  }) {
    return Wrap(
      spacing: 8,
      children: [
        Chip(
          label: Text(severity, style: TextStyle(color: _getSeverityColor(severity), fontWeight: FontWeight.bold, fontSize: 11)),
          backgroundColor: _getSeverityColor(severity).withValues(alpha: 0.15),
          side: BorderSide(color: _getSeverityColor(severity).withValues(alpha: 0.4)),
        ),
        Chip(
          label: Text(ruleType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          backgroundColor: AgentLensTheme.surface,
          side: const BorderSide(color: AgentLensTheme.border),
        ),
        if (isSample)
          Chip(
            label: const Text('[SAMPLE DIAGNOSTIC TELEMETRY]', style: TextStyle(color: AgentLensTheme.warning, fontSize: 10, fontWeight: FontWeight.bold)),
            backgroundColor: AgentLensTheme.warning.withValues(alpha: 0.15),
            side: BorderSide(color: AgentLensTheme.warning.withValues(alpha: 0.4)),
          ),
      ],
    );
  }

  Widget _buildJsonViewer(BuildContext context, String jsonRaw) {
    String formatted;
    try {
      final parsed = jsonDecode(jsonRaw);
      formatted = const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (_) {
      formatted = jsonRaw;
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AgentLensTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AgentLensTheme.border),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: SelectableText(
              formatted,
              style: AgentLensTheme.monoTextStyle,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: AgentLensTheme.textSecondary),
              tooltip: 'Copy JSON',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: formatted));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied evidence JSON to clipboard')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return AgentLensTheme.error;
      case 'HIGH':
        return const Color(0xFFF97316);
      case 'MEDIUM':
        return AgentLensTheme.warning;
      default:
        return AgentLensTheme.info;
    }
  }
}
