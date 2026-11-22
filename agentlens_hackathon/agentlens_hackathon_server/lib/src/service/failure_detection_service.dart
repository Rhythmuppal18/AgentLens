import 'dart:convert';
import '../generated/protocol.dart';

class FailureDetectionService {
  static const int slowSpanThresholdMs = 4000;

  static List<RoomFinding> evaluate({
    required int roomId,
    required String roomCode,
    required String traceId,
    required List<RoomSpan> spans,
    bool isSample = false,
  }) {
    final findings = <RoomFinding>[];
    final now = DateTime.now();

    // 1. FAILED_SPAN & 4. SLOW_SPAN & 5. EMPTY_TOOL_RESULT
    for (final span in spans) {
      // Rule 1: FAILED_SPAN
      if (span.status.toLowerCase() == 'error' || (span.errorMessage != null && span.errorMessage!.isNotEmpty)) {
        findings.add(
          RoomFinding(
            roomId: roomId,
            roomCode: roomCode,
            traceId: traceId,
            spanId: span.spanId,
            spanName: span.name,
            ruleType: 'FAILED_SPAN',
            severity: 'CRITICAL',
            summary: 'Span "${span.name}" failed with error: ${span.errorMessage ?? "Unknown error"}',
            evidenceSummary: 'Error Type: ${span.errorType ?? "ExecutionError"}, Duration: ${span.durationMs}ms',
            evidenceDataJson: jsonEncode({
              'spanId': span.spanId,
              'spanName': span.name,
              'errorMessage': span.errorMessage,
              'errorType': span.errorType,
              'errorStack': span.errorStack,
              'input': span.inputPayloadJson,
            }),
            detectedAt: now,
            isSample: isSample,
          ),
        );
      }

      // Rule 4: SLOW_SPAN
      if (span.durationMs >= slowSpanThresholdMs) {
        findings.add(
          RoomFinding(
            roomId: roomId,
            roomCode: roomCode,
            traceId: traceId,
            spanId: span.spanId,
            spanName: span.name,
            ruleType: 'SLOW_SPAN',
            severity: 'MEDIUM',
            summary: 'Span "${span.name}" exceeded latency threshold (${span.durationMs}ms >= ${slowSpanThresholdMs}ms)',
            evidenceSummary: 'Latency: ${span.durationMs}ms, Threshold: ${slowSpanThresholdMs}ms',
            evidenceDataJson: jsonEncode({
              'spanId': span.spanId,
              'spanName': span.name,
              'durationMs': span.durationMs,
              'thresholdMs': slowSpanThresholdMs,
            }),
            detectedAt: now,
            isSample: isSample,
          ),
        );
      }

      // Rule 5: EMPTY_TOOL_RESULT
      if (span.spanType.toLowerCase() == 'tool') {
        final out = span.outputPayloadJson?.trim();
        final isEmpty = out == null || out.isEmpty || out == '{}' || out == '[]' || out == 'null' || out == '""';
        if (isEmpty) {
          findings.add(
            RoomFinding(
              roomId: roomId,
              roomCode: roomCode,
              traceId: traceId,
              spanId: span.spanId,
              spanName: span.name,
              ruleType: 'EMPTY_TOOL_RESULT',
              severity: 'MEDIUM',
              summary: 'Tool span "${span.name}" returned an empty or null result',
              evidenceSummary: 'Tool returned empty payload, which may cause downstream agent hallucinations',
              evidenceDataJson: jsonEncode({
                'spanId': span.spanId,
                'toolName': span.name,
                'input': span.inputPayloadJson,
                'output': span.outputPayloadJson,
              }),
              detectedAt: now,
              isSample: isSample,
            ),
          );
        }
      }
    }

    // Rule 2: REPEATED_TOOL_CALL
    final toolSpans = spans.where((s) => s.spanType.toLowerCase() == 'tool').toList();
    for (int i = 0; i < toolSpans.length - 1; i++) {
      final current = toolSpans[i];
      final next = toolSpans[i + 1];
      if (current.name == next.name &&
          current.inputPayloadJson != null &&
          current.inputPayloadJson == next.inputPayloadJson) {
        findings.add(
          RoomFinding(
            roomId: roomId,
            roomCode: roomCode,
            traceId: traceId,
            spanId: next.spanId,
            spanName: next.name,
            ruleType: 'REPEATED_TOOL_CALL',
            severity: 'HIGH',
            summary: 'Detected identical consecutive tool call "${next.name}" with matching arguments',
            evidenceSummary: 'Span "${current.spanId}" and "${next.spanId}" invoked "${next.name}" with identical parameters',
            evidenceDataJson: jsonEncode({
              'firstSpanId': current.spanId,
              'secondSpanId': next.spanId,
              'toolName': next.name,
              'inputPayload': next.inputPayloadJson,
            }),
            detectedAt: now,
            isSample: isSample,
          ),
        );
      }
    }

    // Rule 3: EXCESSIVE_RETRIES
    final errorSpans = spans.where((s) => s.status.toLowerCase() == 'error' || (s.errorMessage != null && s.errorMessage!.isNotEmpty)).toList();
    if (errorSpans.length >= 3) {
      findings.add(
        RoomFinding(
          roomId: roomId,
          roomCode: roomCode,
          traceId: traceId,
          spanId: errorSpans.last.spanId,
          spanName: errorSpans.last.name,
          ruleType: 'EXCESSIVE_RETRIES',
          severity: 'HIGH',
          summary: 'Trace exhibited excessive failure retries (${errorSpans.length} failed spans)',
          evidenceSummary: '${errorSpans.length} spans failed in trace "$traceId"',
          evidenceDataJson: jsonEncode({
            'failedSpanIds': errorSpans.map((s) => s.spanId).toList(),
            'failedSpanNames': errorSpans.map((s) => s.name).toList(),
          }),
          detectedAt: now,
          isSample: isSample,
        ),
      );
    }

    return findings;
  }
}
