import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agentlens_hackathon_client/agentlens_hackathon_client.dart';
import '../client.dart';

class RoomState {
  final DebugRoom? room;
  final RoomParticipant? currentParticipant;
  final String? participantToken;
  final String? ingestToken;
  final List<RoomParticipant> participants;
  final List<RoomTrace> traces;
  final List<RoomSpan> spans;
  final List<RoomFinding> findings;
  final List<InvestigationNote> notes;
  final int lastSequenceNumber;
  final bool isConnected;
  final bool isLoading;
  final String? errorMessage;
  final RoomFinding? selectedFinding;
  final RoomSpan? selectedSpan;

  const RoomState({
    this.room,
    this.currentParticipant,
    this.participantToken,
    this.ingestToken,
    this.participants = const [],
    this.traces = const [],
    this.spans = const [],
    this.findings = const [],
    this.notes = const [],
    this.lastSequenceNumber = 0,
    this.isConnected = false,
    this.isLoading = false,
    this.errorMessage,
    this.selectedFinding,
    this.selectedSpan,
  });

  RoomState copyWith({
    DebugRoom? room,
    RoomParticipant? currentParticipant,
    String? participantToken,
    String? ingestToken,
    List<RoomParticipant>? participants,
    List<RoomTrace>? traces,
    List<RoomSpan>? spans,
    List<RoomFinding>? findings,
    List<InvestigationNote>? notes,
    int? lastSequenceNumber,
    bool? isConnected,
    bool? isLoading,
    String? errorMessage,
    RoomFinding? selectedFinding,
    RoomSpan? selectedSpan,
    bool clearSelectedFinding = false,
    bool clearSelectedSpan = false,
  }) {
    return RoomState(
      room: room ?? this.room,
      currentParticipant: currentParticipant ?? this.currentParticipant,
      participantToken: participantToken ?? this.participantToken,
      ingestToken: ingestToken ?? this.ingestToken,
      participants: participants ?? this.participants,
      traces: traces ?? this.traces,
      spans: spans ?? this.spans,
      findings: findings ?? this.findings,
      notes: notes ?? this.notes,
      lastSequenceNumber: lastSequenceNumber ?? this.lastSequenceNumber,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedFinding: clearSelectedFinding ? null : (selectedFinding ?? this.selectedFinding),
      selectedSpan: clearSelectedSpan ? null : (selectedSpan ?? this.selectedSpan),
    );
  }
}

class RoomNotifier extends StateNotifier<RoomState> {
  RoomNotifier() : super(const RoomState());

  StreamSubscription<RoomStreamMessage>? _streamSubscription;
  Timer? _heartbeatTimer;
  final List<RoomStreamMessage> _pendingEvents = [];
  bool _snapshotLoaded = false;

  Future<void> createRoom({
    required String roomName,
    required String creatorName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await client.room.createRoom(
        CreateRoomRequest(
          roomName: roomName,
          creatorName: creatorName,
          deviceId: 'web_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      state = state.copyWith(
        room: res.room,
        currentParticipant: RoomParticipant(
          roomId: res.room.id!,
          roomCode: res.room.roomCode,
          participantName: creatorName,
          deviceId: 'web_creator',
          participantTokenHash: '',
          joinedAt: DateTime.now(),
          lastSeenAt: DateTime.now(),
          isOnline: true,
        ),
        participantToken: res.participantToken,
        ingestToken: res.ingestToken,
        isLoading: false,
      );

      await _subscribeAndReconcile(res.room.roomCode, res.participantToken);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> joinRoom({
    required String roomCode,
    required String participantName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await client.room.joinRoom(
        JoinRoomRequest(
          roomCode: roomCode,
          participantName: participantName,
          deviceId: 'web_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      state = state.copyWith(
        room: res.room,
        currentParticipant: res.participant,
        participantToken: res.participantToken,
        isLoading: false,
      );

      await _subscribeAndReconcile(res.room.roomCode, res.participantToken);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> _subscribeAndReconcile(String roomCode, String token) async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _heartbeatTimer?.cancel();
    _pendingEvents.clear();
    _snapshotLoaded = false;

    // 1. Establish Stream Subscription FIRST to avoid missing intermediate events
    final stream = client.roomStream.watchRoom(roomCode, token);
    _streamSubscription = stream.listen(
      (message) {
        if (!_snapshotLoaded) {
          _pendingEvents.add(message);
        } else {
          _handleStreamEvent(message);
        }
      },
      onError: (err) {
        state = state.copyWith(isConnected: false, errorMessage: 'Stream disconnected: $err');
      },
      onDone: () {
        state = state.copyWith(isConnected: false);
      },
    );

    // 2. Fetch full Room Snapshot
    try {
      final snapshot = await client.room.getRoomSnapshot(roomCode, token);
      _snapshotLoaded = true;

      state = state.copyWith(
        room: snapshot.room,
        participants: snapshot.participants,
        traces: snapshot.traces,
        spans: snapshot.spans,
        findings: snapshot.findings,
        notes: snapshot.notes,
        lastSequenceNumber: snapshot.lastSequenceNumber,
        isConnected: true,
      );

      // 3. Reconcile buffered events where sequenceNumber > snapshot.lastSequenceNumber
      for (final event in _pendingEvents) {
        if (event.sequenceNumber > snapshot.lastSequenceNumber) {
          _handleStreamEvent(event);
        }
      }
      _pendingEvents.clear();

      // 4. Start 15s Heartbeat Timer
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
        try {
          await client.room.heartbeat(roomCode, token);
        } catch (_) {}
      });
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load room snapshot: $e');
    }
  }

  void _handleStreamEvent(RoomStreamMessage msg) {
    if (msg.sequenceNumber <= state.lastSequenceNumber) {
      // Idempotent deduplication
      return;
    }

    final newSeq = msg.sequenceNumber;

    switch (msg.eventType) {
      case 'PARTICIPANT_JOINED':
      case 'PARTICIPANT_LEFT':
        if (msg.participant != null) {
          final p = msg.participant!;
          final updated = List<RoomParticipant>.from(state.participants);
          final idx = updated.indexWhere((item) => item.id == p.id || item.deviceId == p.deviceId);
          if (idx >= 0) {
            updated[idx] = p;
          } else {
            updated.add(p);
          }
          state = state.copyWith(participants: updated, lastSequenceNumber: newSeq);
        }
        break;

      case 'TRACE_INGESTED':
        if (msg.trace != null) {
          final t = msg.trace!;
          final updated = List<RoomTrace>.from(state.traces);
          final idx = updated.indexWhere((item) => item.traceId == t.traceId);
          if (idx >= 0) {
            updated[idx] = t;
          } else {
            updated.insert(0, t);
          }
          state = state.copyWith(traces: updated, lastSequenceNumber: newSeq);
        }
        break;

      case 'SPAN_INGESTED':
        if (msg.span != null) {
          final s = msg.span!;
          final updated = List<RoomSpan>.from(state.spans);
          final idx = updated.indexWhere((item) => item.spanId == s.spanId);
          if (idx >= 0) {
            updated[idx] = s;
          } else {
            updated.add(s);
          }
          state = state.copyWith(spans: updated, lastSequenceNumber: newSeq);
        }
        break;

      case 'FINDING_DETECTED':
        if (msg.finding != null) {
          final f = msg.finding!;
          final updated = List<RoomFinding>.from(state.findings);
          final idx = updated.indexWhere((item) => item.id == f.id);
          if (idx >= 0) {
            updated[idx] = f;
          } else {
            updated.insert(0, f);
          }
          state = state.copyWith(findings: updated, lastSequenceNumber: newSeq);
        }
        break;

      case 'NOTE_ADDED':
        if (msg.note != null) {
          final n = msg.note!;
          final updated = List<InvestigationNote>.from(state.notes);
          final idx = updated.indexWhere((item) => item.id == n.id);
          if (idx >= 0) {
            updated[idx] = n;
          } else {
            updated.add(n);
          }
          state = state.copyWith(notes: updated, lastSequenceNumber: newSeq);
        }
        break;

      default:
        state = state.copyWith(lastSequenceNumber: newSeq);
    }
  }

  Future<void> addNote(String content, {int? findingId}) async {
    final room = state.room;
    final token = state.participantToken;
    if (room == null || token == null) return;

    try {
      await client.investigation.addNote(
        AddNoteRequest(
          roomCode: room.roomCode,
          participantToken: token,
          findingId: findingId,
          content: content,
        ),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to post note: $e');
    }
  }

  Future<void> simulateScenario(String scenario) async {
    final room = state.room;
    final token = state.participantToken;
    if (room == null || token == null) return;

    try {
      await client.telemetry.simulateAgentTrace(
        room.roomCode,
        token,
        scenario,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Simulation failed: $e');
    }
  }

  void selectFinding(RoomFinding? finding) {
    state = state.copyWith(
      selectedFinding: finding,
      clearSelectedFinding: finding == null,
    );
  }

  void selectSpan(RoomSpan? span) {
    state = state.copyWith(
      selectedSpan: span,
      clearSelectedSpan: span == null,
    );
  }

  Future<void> leaveRoom() async {
    final room = state.room;
    final token = state.participantToken;
    if (room != null && token != null) {
      try {
        await client.room.leaveRoom(room.roomCode, token);
      } catch (_) {}
    }
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    state = const RoomState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}

final roomProvider = StateNotifierProvider<RoomNotifier, RoomState>((ref) {
  return RoomNotifier();
});
