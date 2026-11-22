import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../service/failure_detection_service.dart';
import '../util/crypto_util.dart';
import '../util/redaction_util.dart';

class TelemetryEndpoint extends Endpoint {
  /// Ingest raw agent trace and span telemetry authenticated by secret ingestToken.
  /// Redacts sensitive keys, evaluates 5 deterministic failure rules, persists to PostgreSQL,
  /// and broadcasts updates in real-time.
  Future<bool> ingestTrace(
    Session session,
    TelemetryTraceDto dto,
  ) async {
    final normalizedCode = dto.roomCode.trim().toUpperCase();
    final tokenHash = CryptoUtil.hashToken(dto.ingestToken);

    final room = await DebugRoom.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode) & t.ingestTokenHash.equals(tokenHash) & t.isActive.equals(true),
    );

    if (room == null) {
      throw RoomException(
        message: 'Invalid ingestion credential for room "$normalizedCode".',
        statusCode: 403,
      );
    }

    final now = DateTime.now();
    final List<RoomSpan> persistedSpans = [];
    late RoomTrace persistedTrace;
    List<RoomFinding> persistedFindings = [];
    int newSeq = room.currentSequenceNumber + 1;

    await session.db.transaction((tx) async {
      // 1. Persist Trace
      final trace = RoomTrace(
        roomId: room.id!,
        roomCode: normalizedCode,
        traceId: dto.traceId,
        agentName: dto.agentName,
        status: dto.status,
        durationMs: dto.durationMs,
        totalTokens: dto.totalTokens,
        startTime: dto.startTime,
        endTime: dto.endTime,
        isSample: dto.isSample,
      );
      persistedTrace = await RoomTrace.db.insertRow(session, trace, transaction: tx);

      // 2. Persist Redacted Spans
      for (final s in dto.spans) {
        final span = RoomSpan(
          roomId: room.id!,
          roomCode: normalizedCode,
          traceId: dto.traceId,
          spanId: s.spanId,
          parentSpanId: s.parentSpanId,
          name: s.name,
          spanType: s.spanType,
          status: s.status,
          durationMs: s.durationMs,
          inputPayloadJson: RedactionUtil.redact(s.inputPayloadJson),
          outputPayloadJson: RedactionUtil.redact(s.outputPayloadJson),
          errorMessage: RedactionUtil.redact(s.errorMessage),
          errorType: s.errorType,
          errorStack: RedactionUtil.redact(s.errorStack),
          startTime: s.startTime,
          endTime: s.endTime,
        );
        final saved = await RoomSpan.db.insertRow(session, span, transaction: tx);
        persistedSpans.add(saved);
      }

      // 3. Evaluate 5 Deterministic Failure Rules
      final findings = FailureDetectionService.evaluate(
        roomId: room.id!,
        roomCode: normalizedCode,
        traceId: dto.traceId,
        spans: persistedSpans,
        isSample: dto.isSample,
      );

      for (final f in findings) {
        final savedFinding = await RoomFinding.db.insertRow(session, f, transaction: tx);
        persistedFindings.add(savedFinding);
      }

      // 4. Update room sequence number
      newSeq = room.currentSequenceNumber + 1 + persistedFindings.length;
      room.currentSequenceNumber = newSeq;
      await DebugRoom.db.updateRow(session, room, transaction: tx);
    });

    // 5. Broadcast to room stream
    int eventSeq = room.currentSequenceNumber - persistedFindings.length;
    await session.messages.postMessage(
      'room_$normalizedCode',
      RoomStreamMessage(
        sequenceNumber: eventSeq,
        eventType: 'TRACE_INGESTED',
        roomCode: normalizedCode,
        timestamp: now,
        trace: persistedTrace,
      ),
    );

    for (final span in persistedSpans) {
      await session.messages.postMessage(
        'room_$normalizedCode',
        RoomStreamMessage(
          sequenceNumber: eventSeq,
          eventType: 'SPAN_INGESTED',
          roomCode: normalizedCode,
          timestamp: now,
          span: span,
        ),
      );
    }

    for (final finding in persistedFindings) {
      eventSeq++;
      await session.messages.postMessage(
        'room_$normalizedCode',
        RoomStreamMessage(
          sequenceNumber: eventSeq,
          eventType: 'FINDING_DETECTED',
          roomCode: normalizedCode,
          timestamp: now,
          finding: finding,
        ),
      );
    }

    return true;
  }

  /// Trigger a live diagnostic failure simulation scenario labeled [SAMPLE DIAGNOSTIC TELEMETRY].
  Future<bool> simulateAgentTrace(
    Session session,
    String roomCode,
    String participantToken,
    String scenario,
  ) async {
    final normalizedCode = roomCode.trim().toUpperCase();
    final tokenHash = CryptoUtil.hashToken(participantToken);

    final participant = await RoomParticipant.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode) & t.participantTokenHash.equals(tokenHash),
    );

    if (participant == null) {
      throw RoomException(message: 'Unauthorized participant.', statusCode: 401);
    }

    final room = await DebugRoom.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
    );
    if (room == null) {
      throw RoomException(message: 'Room not found.', statusCode: 404);
    }

    final now = DateTime.now();
    final traceId = 'trc_sample_${DateTime.now().millisecondsSinceEpoch}';

    TelemetryTraceDto sampleDto;

    if (scenario == 'LOOPING_SQL_AGENT') {
      sampleDto = TelemetryTraceDto(
        roomCode: normalizedCode,
        ingestToken: '', // Server-side bypass
        traceId: traceId,
        agentName: '[SAMPLE DIAGNOSTIC TELEMETRY] DataQueryAgent',
        status: 'error',
        durationMs: 7850,
        totalTokens: 1420,
        startTime: now.subtract(const Duration(milliseconds: 7850)),
        endTime: now,
        isSample: true,
        spans: [
          TelemetrySpanDto(
            spanId: 'spn_plan_01',
            name: 'Planner: Decompose Query',
            spanType: 'chain',
            status: 'success',
            durationMs: 240,
            inputPayloadJson: jsonEncode({'prompt': 'Find top customer spend with API key: Bearer sec_tok_99887766'}),
            outputPayloadJson: jsonEncode({'plan': ['query_postgres', 'summarize']}),
            startTime: now.subtract(const Duration(milliseconds: 7800)),
            endTime: now.subtract(const Duration(milliseconds: 7560)),
          ),
          TelemetrySpanDto(
            spanId: 'spn_tool_01',
            name: 'PostgreSQLQueryTool',
            spanType: 'tool',
            status: 'error',
            durationMs: 2200,
            inputPayloadJson: jsonEncode({'query': 'SELECT * FROM users WHERE active = true', 'limit': 50}),
            outputPayloadJson: null,
            errorMessage: 'QueryExecutionException: connection pool exhausted after 2000ms',
            errorType: 'QueryExecutionException',
            errorStack: 'pg_driver.dart:142\nconnection_pool.dart:88',
            startTime: now.subtract(const Duration(milliseconds: 7500)),
            endTime: now.subtract(const Duration(milliseconds: 5300)),
          ),
          TelemetrySpanDto(
            spanId: 'spn_tool_02',
            name: 'PostgreSQLQueryTool',
            spanType: 'tool',
            status: 'error',
            durationMs: 2100,
            inputPayloadJson: jsonEncode({'query': 'SELECT * FROM users WHERE active = true', 'limit': 50}),
            outputPayloadJson: null,
            errorMessage: 'QueryExecutionException: connection pool exhausted after 2000ms',
            errorType: 'QueryExecutionException',
            errorStack: 'pg_driver.dart:142\nconnection_pool.dart:88',
            startTime: now.subtract(const Duration(milliseconds: 5200)),
            endTime: now.subtract(const Duration(milliseconds: 3100)),
          ),
          TelemetrySpanDto(
            spanId: 'spn_tool_03',
            name: 'PostgreSQLQueryTool',
            spanType: 'tool',
            status: 'error',
            durationMs: 2150,
            inputPayloadJson: jsonEncode({'query': 'SELECT * FROM users WHERE active = true', 'limit': 50}),
            outputPayloadJson: null,
            errorMessage: 'QueryExecutionException: connection pool exhausted after 2000ms',
            errorType: 'QueryExecutionException',
            errorStack: 'pg_driver.dart:142\nconnection_pool.dart:88',
            startTime: now.subtract(const Duration(milliseconds: 3000)),
            endTime: now.subtract(const Duration(milliseconds: 850)),
          ),
        ],
      );
    } else if (scenario == 'EMPTY_DOC_SUMMARIZER') {
      sampleDto = TelemetryTraceDto(
        roomCode: normalizedCode,
        ingestToken: '',
        traceId: traceId,
        agentName: '[SAMPLE DIAGNOSTIC TELEMETRY] DocumentSummarizerAgent',
        status: 'completed',
        durationMs: 1450,
        totalTokens: 680,
        startTime: now.subtract(const Duration(milliseconds: 1450)),
        endTime: now,
        isSample: true,
        spans: [
          TelemetrySpanDto(
            spanId: 'spn_doc_fetch',
            name: 'FetchDocumentTool',
            spanType: 'tool',
            status: 'success',
            durationMs: 350,
            inputPayloadJson: jsonEncode({'documentId': 'doc_contracts_2026.pdf'}),
            outputPayloadJson: jsonEncode({'pages': 14, 'sizeKb': 420}),
            startTime: now.subtract(const Duration(milliseconds: 1400)),
            endTime: now.subtract(const Duration(milliseconds: 1050)),
          ),
          TelemetrySpanDto(
            spanId: 'spn_summarize_tool',
            name: 'LLMDocumentExtractor',
            spanType: 'tool',
            status: 'success',
            durationMs: 980,
            inputPayloadJson: jsonEncode({'docId': 'doc_contracts_2026.pdf', 'apiKey': 'sk-sample-test-key-1234567890'}),
            outputPayloadJson: '{}', // Triggers EMPTY_TOOL_RESULT
            startTime: now.subtract(const Duration(milliseconds: 1000)),
            endTime: now.subtract(const Duration(milliseconds: 20)),
          ),
        ],
      );
    } else {
      // Default: SEARCH_TIMEOUT_AND_FAILED_SPAN
      sampleDto = TelemetryTraceDto(
        roomCode: normalizedCode,
        ingestToken: '',
        traceId: traceId,
        agentName: '[SAMPLE DIAGNOSTIC TELEMETRY] WebSearchAgent',
        status: 'error',
        durationMs: 5800,
        totalTokens: 950,
        startTime: now.subtract(const Duration(milliseconds: 5800)),
        endTime: now,
        isSample: true,
        spans: [
          TelemetrySpanDto(
            spanId: 'spn_browser_query',
            name: 'GoogleSearchScraper',
            spanType: 'tool',
            status: 'error',
            durationMs: 5120, // Triggers SLOW_SPAN & FAILED_SPAN
            inputPayloadJson: jsonEncode({
              'query': 'Serverpod 4.1.2 live collaborative debugging',
              'token': 'agt_internal_simulation_token_11223344',
            }),
            outputPayloadJson: null,
            errorMessage: 'TimeoutException: Gateway request exceeded 5000ms deadline',
            errorType: 'TimeoutException',
            errorStack: 'http_client.dart:214\nsearch_driver.dart:67',
            startTime: now.subtract(const Duration(milliseconds: 5500)),
            endTime: now.subtract(const Duration(milliseconds: 380)),
          ),
        ],
      );
    }

    // Persist and broadcast internally
    final persistedSpans = <RoomSpan>[];
    late RoomTrace persistedTrace;
    final persistedFindings = <RoomFinding>[];

    await session.db.transaction((tx) async {
      final trace = RoomTrace(
        roomId: room.id!,
        roomCode: normalizedCode,
        traceId: sampleDto.traceId,
        agentName: sampleDto.agentName,
        status: sampleDto.status,
        durationMs: sampleDto.durationMs,
        totalTokens: sampleDto.totalTokens,
        startTime: sampleDto.startTime,
        endTime: sampleDto.endTime,
        isSample: true,
      );
      persistedTrace = await RoomTrace.db.insertRow(session, trace, transaction: tx);

      for (final s in sampleDto.spans) {
        final span = RoomSpan(
          roomId: room.id!,
          roomCode: normalizedCode,
          traceId: sampleDto.traceId,
          spanId: s.spanId,
          parentSpanId: s.parentSpanId,
          name: s.name,
          spanType: s.spanType,
          status: s.status,
          durationMs: s.durationMs,
          inputPayloadJson: RedactionUtil.redact(s.inputPayloadJson),
          outputPayloadJson: RedactionUtil.redact(s.outputPayloadJson),
          errorMessage: RedactionUtil.redact(s.errorMessage),
          errorType: s.errorType,
          errorStack: RedactionUtil.redact(s.errorStack),
          startTime: s.startTime,
          endTime: s.endTime,
        );
        final saved = await RoomSpan.db.insertRow(session, span, transaction: tx);
        persistedSpans.add(saved);
      }

      final findings = FailureDetectionService.evaluate(
        roomId: room.id!,
        roomCode: normalizedCode,
        traceId: sampleDto.traceId,
        spans: persistedSpans,
        isSample: true,
      );

      for (final f in findings) {
        final savedFinding = await RoomFinding.db.insertRow(session, f, transaction: tx);
        persistedFindings.add(savedFinding);
      }

      final newSeq = room.currentSequenceNumber + 1 + persistedFindings.length;
      room.currentSequenceNumber = newSeq;
      await DebugRoom.db.updateRow(session, room, transaction: tx);
    });

    int eventSeq = room.currentSequenceNumber - persistedFindings.length;
    await session.messages.postMessage(
      'room_$normalizedCode',
      RoomStreamMessage(
        sequenceNumber: eventSeq,
        eventType: 'TRACE_INGESTED',
        roomCode: normalizedCode,
        timestamp: now,
        trace: persistedTrace,
      ),
    );

    for (final span in persistedSpans) {
      await session.messages.postMessage(
        'room_$normalizedCode',
        RoomStreamMessage(
          sequenceNumber: eventSeq,
          eventType: 'SPAN_INGESTED',
          roomCode: normalizedCode,
          timestamp: now,
          span: span,
        ),
      );
    }

    for (final finding in persistedFindings) {
      eventSeq++;
      await session.messages.postMessage(
        'room_$normalizedCode',
        RoomStreamMessage(
          sequenceNumber: eventSeq,
          eventType: 'FINDING_DETECTED',
          roomCode: normalizedCode,
          timestamp: now,
          finding: finding,
        ),
      );
    }

    session.log('Simulated diagnostic trace $traceId in room $normalizedCode');
    return true;
  }
}
