import 'dart:async';
import 'dart:convert';
import 'package:agentlens_hackathon_client/agentlens_hackathon_client.dart';
import 'package:test/test.dart';

void main() {
  test('Complete AgentLens Collaborative Debugging E2E Flow', () async {
    final clientA = Client('http://localhost:8080/');
    final clientB = Client('http://localhost:8080/');

    // 1. Feature 1: Create Debug Room
    final createRes = await clientA.room.createRoom(
      CreateRoomRequest(
        roomName: 'Incident War Room - Checkout Agent Failure',
        creatorName: 'Alice Ops',
        deviceId: 'dev_alice_browser_01',
      ),
    );

    expect(createRes.room.roomCode, startsWith('AL-'));
    expect(createRes.ingestToken, startsWith('agt_'));
    expect(createRes.participantToken, startsWith('ptk_'));
    final roomCode = createRes.room.roomCode;
    final ingestToken = createRes.ingestToken;
    final aliceToken = createRes.participantToken;
    print('[TEST] Created Room: $roomCode with Ingest Token: $ingestToken');

    // 2. Setup Real-time Stream for Alice
    final receivedEvents = <RoomStreamMessage>[];
    final streamCompleter = Completer<void>();
    final noteCompleter = Completer<void>();

    final streamA = clientA.roomStream.watchRoom(roomCode, aliceToken);
    final subscription = streamA.listen((msg) {
      print('[STREAM EVENT] seq=${msg.sequenceNumber} type=${msg.eventType}');
      receivedEvents.add(msg);
      if (msg.eventType == 'PARTICIPANT_JOINED') {
        if (!streamCompleter.isCompleted) streamCompleter.complete();
      }
      if (msg.eventType == 'NOTE_ADDED') {
        if (!noteCompleter.isCompleted) noteCompleter.complete();
      }
    });

    // Small delay to allow subscription registration on server
    await Future.delayed(const Duration(milliseconds: 300));

    // 3. Feature 2: Join Room (Bob joins)
    final joinRes = await clientB.room.joinRoom(
      JoinRoomRequest(
        roomCode: roomCode,
        participantName: 'Bob Lead Debugger',
        deviceId: 'dev_bob_browser_02',
      ),
    );
    expect(joinRes.room.roomCode, equals(roomCode));
    expect(joinRes.participant.participantName, equals('Bob Lead Debugger'));
    final bobToken = joinRes.participantToken;
    print('[TEST] Bob joined room: $roomCode');

    // Wait for PARTICIPANT_JOINED stream message
    await streamCompleter.future.timeout(const Duration(seconds: 5));
    expect(receivedEvents.any((e) => e.eventType == 'PARTICIPANT_JOINED'), isTrue);

    // 4. Feature 3: Ingest Trace with Secret Redaction & 5 Failure Rules Evaluation
    final now = DateTime.now();
    final traceSuccess = await clientA.telemetry.ingestTrace(
      TelemetryTraceDto(
        roomCode: roomCode,
        ingestToken: ingestToken,
        traceId: 'trc_e2e_prod_8899',
        agentName: 'CheckoutAgent',
        status: 'error',
        durationMs: 5400,
        totalTokens: 1850,
        startTime: now.subtract(const Duration(milliseconds: 5400)),
        endTime: now,
        isSample: false,
        spans: [
          TelemetrySpanDto(
            spanId: 'spn_auth_01',
            name: 'ValidateUserAuth',
            spanType: 'tool',
            status: 'success',
            durationMs: 120,
            inputPayloadJson: jsonEncode({
              'authHeader': 'Bearer sec_token_secret_1234567890',
              'apiKey': 'sk-proj-sensitive-998877665544',
            }),
            outputPayloadJson: jsonEncode({'valid': true, 'userId': 'usr_443'}),
            startTime: now.subtract(const Duration(milliseconds: 5350)),
            endTime: now.subtract(const Duration(milliseconds: 5230)),
          ),
          TelemetrySpanDto(
            spanId: 'spn_charge_01',
            name: 'StripeChargePayment',
            spanType: 'tool',
            status: 'error',
            durationMs: 5100, // triggers SLOW_SPAN (>4000ms) and FAILED_SPAN
            inputPayloadJson: jsonEncode({'amount': 9900, 'currency': 'usd'}),
            outputPayloadJson: null,
            errorMessage: 'PaymentGatewayTimeout: Stripe gateway failed to respond within 5000ms',
            errorType: 'PaymentGatewayTimeout',
            errorStack: 'stripe_client.dart:45\npayment_service.dart:112',
            startTime: now.subtract(const Duration(milliseconds: 5200)),
            endTime: now.subtract(const Duration(milliseconds: 100)),
          ),
        ],
      ),
    );
    expect(traceSuccess, isTrue);
    print('[TEST] Ingested telemetry trace');

    // 5. Feature 4: Shared Investigation Note
    final note = await clientB.investigation.addNote(
      AddNoteRequest(
        roomCode: roomCode,
        participantToken: bobToken,
        findingId: null,
        content: 'I noticed Stripe gateway timed out at 5100ms. Checking Stripe status dashboard.',
      ),
    );
    expect(note.authorName, equals('Bob Lead Debugger'));
    expect(note.content, contains('Stripe gateway'));
    print('[TEST] Added investigation note');

    await noteCompleter.future.timeout(const Duration(seconds: 5));
    expect(receivedEvents.any((e) => e.eventType == 'NOTE_ADDED'), isTrue);

    // 6. Test Simulation Scenario
    final simSuccess = await clientA.telemetry.simulateAgentTrace(
      roomCode,
      aliceToken,
      'LOOPING_SQL_AGENT',
    );
    expect(simSuccess, isTrue);
    print('[TEST] Simulated diagnostic trace');

    // 7. Verify Snapshot Reconciliation
    final snapshot = await clientA.room.getRoomSnapshot(roomCode, aliceToken);
    expect(snapshot.room.roomCode, equals(roomCode));
    expect(snapshot.participants.length, greaterThanOrEqualTo(2));
    expect(snapshot.traces.length, greaterThanOrEqualTo(2));
    expect(snapshot.findings.length, greaterThanOrEqualTo(2));
    expect(snapshot.notes.length, greaterThanOrEqualTo(1));

    // Verify secret redaction in persisted spans
    final authSpan = snapshot.spans.firstWhere((s) => s.spanId == 'spn_auth_01');
    expect(authSpan.inputPayloadJson, contains('Bearer [REDACTED_TOKEN]'));
    expect(authSpan.inputPayloadJson, contains('[REDACTED]'));
    expect(authSpan.inputPayloadJson, isNot(contains('sec_token_secret_1234567890')));
    expect(authSpan.inputPayloadJson, isNot(contains('sk-proj-sensitive-998877665544')));
    print('[TEST] Redaction verified: all credentials securely masked.');

    // Verify deterministic failure rule findings
    final failedFinding = snapshot.findings.firstWhere((f) => f.ruleType == 'FAILED_SPAN');
    expect(failedFinding.severity, equals('CRITICAL'));
    expect(failedFinding.summary, contains('StripeChargePayment'));

    final slowFinding = snapshot.findings.firstWhere((f) => f.ruleType == 'SLOW_SPAN');
    expect(slowFinding.severity, equals('MEDIUM'));

    print('[TEST] ALL END-TO-END CRITERIA VERIFIED SUCCESSFULLY!');
    await subscription.cancel();
  });
}
