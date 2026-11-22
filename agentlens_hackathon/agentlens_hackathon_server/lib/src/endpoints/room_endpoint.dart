import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../util/crypto_util.dart';

class RoomEndpoint extends Endpoint {
  /// Create a new collaborative debug room.
  /// Returns the room model, raw ingestToken (shown once), and raw participantToken.
  Future<CreateRoomResponse> createRoom(
    Session session,
    CreateRoomRequest request,
  ) async {
    final roomName = request.roomName.trim().isEmpty
        ? 'Agent Debug Session'
        : request.roomName.trim();
    final creatorName = request.creatorName.trim().isEmpty
        ? 'Creator'
        : request.creatorName.trim();

    final roomCode = CryptoUtil.generateRoomCode();
    final rawIngestToken = CryptoUtil.generateIngestToken();
    final rawParticipantToken = CryptoUtil.generateParticipantToken();

    final ingestTokenHash = CryptoUtil.hashToken(rawIngestToken);
    final participantTokenHash = CryptoUtil.hashToken(rawParticipantToken);

    final now = DateTime.now();

    final response = await session.db.transaction<CreateRoomResponse>((tx) async {
      final room = DebugRoom(
        roomCode: roomCode,
        name: roomName,
        createdBy: creatorName,
        ingestTokenHash: ingestTokenHash,
        createdAt: now,
        currentSequenceNumber: 1,
        isActive: true,
      );
      final savedRoom = await DebugRoom.db.insertRow(session, room, transaction: tx);

      final participant = RoomParticipant(
        roomId: savedRoom.id!,
        roomCode: roomCode,
        participantName: creatorName,
        deviceId: request.deviceId,
        participantTokenHash: participantTokenHash,
        joinedAt: now,
        lastSeenAt: now,
        isOnline: true,
      );
      await RoomParticipant.db.insertRow(session, participant, transaction: tx);

      return CreateRoomResponse(
        room: savedRoom,
        ingestToken: rawIngestToken,
        participantToken: rawParticipantToken,
      );
    });

    session.log('Created room $roomCode by $creatorName');
    return response;
  }

  /// Join an existing debug room using roomCode.
  Future<JoinRoomResponse> joinRoom(
    Session session,
    JoinRoomRequest request,
  ) async {
    final normalizedCode = request.roomCode.trim().toUpperCase();
    final room = await DebugRoom.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode) & t.isActive.equals(true),
    );

    if (room == null) {
      throw RoomException(message: 'Debug room "$normalizedCode" was not found or is closed.', statusCode: 404);
    }

    final participantName = request.participantName.trim().isEmpty
        ? 'Collaborator'
        : request.participantName.trim();

    final rawToken = CryptoUtil.generateParticipantToken();
    final tokenHash = CryptoUtil.hashToken(rawToken);
    final now = DateTime.now();

    final response = await session.db.transaction<JoinRoomResponse>((tx) async {
      // Increment room sequence number
      final nextSeq = room.currentSequenceNumber + 1;
      room.currentSequenceNumber = nextSeq;
      final updatedRoom = await DebugRoom.db.updateRow(session, room, transaction: tx);

      final participant = RoomParticipant(
        roomId: room.id!,
        roomCode: normalizedCode,
        participantName: participantName,
        deviceId: request.deviceId,
        participantTokenHash: tokenHash,
        joinedAt: now,
        lastSeenAt: now,
        isOnline: true,
      );
      final savedParticipant = await RoomParticipant.db.insertRow(session, participant, transaction: tx);

      return JoinRoomResponse(
        room: updatedRoom,
        participant: savedParticipant,
        participantToken: rawToken,
      );
    });

    // Broadcast participant joined
    await session.messages.postMessage(
      'room_$normalizedCode',
      RoomStreamMessage(
        sequenceNumber: response.room.currentSequenceNumber,
        eventType: 'PARTICIPANT_JOINED',
        roomCode: normalizedCode,
        timestamp: now,
        participant: response.participant,
      ),
    );

    return response;
  }

  /// Fetch full initial room state snapshot for synchronization.
  Future<RoomSnapshot> getRoomSnapshot(
    Session session,
    String roomCode,
    String participantToken,
  ) async {
    final normalizedCode = roomCode.trim().toUpperCase();
    final tokenHash = CryptoUtil.hashToken(participantToken);

    final participant = await RoomParticipant.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode) & t.participantTokenHash.equals(tokenHash),
    );
    if (participant == null) {
      throw RoomException(message: 'Invalid participant authorization token.', statusCode: 401);
    }

    final room = await DebugRoom.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
    );
    if (room == null) {
      throw RoomException(message: 'Debug room not found.', statusCode: 404);
    }

    // Refresh participant lastSeenAt
    participant.lastSeenAt = DateTime.now();
    participant.isOnline = true;
    await RoomParticipant.db.updateRow(session, participant);

    final participants = await RoomParticipant.db.find(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
      orderBy: (t) => t.joinedAt,
    );

    final traces = await RoomTrace.db.find(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
      orderBy: (t) => t.startTime,
    );

    final spans = await RoomSpan.db.find(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
      orderBy: (t) => t.startTime,
    );

    final findings = await RoomFinding.db.find(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
      orderBy: (t) => t.detectedAt,
    );

    final notes = await InvestigationNote.db.find(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
      orderBy: (t) => t.createdAt,
    );

    return RoomSnapshot(
      room: room,
      lastSequenceNumber: room.currentSequenceNumber,
      participants: participants,
      traces: traces,
      spans: spans,
      findings: findings,
      notes: notes,
    );
  }

  /// Keepalive heartbeat to track active users.
  Future<bool> heartbeat(
    Session session,
    String roomCode,
    String participantToken,
  ) async {
    final normalizedCode = roomCode.trim().toUpperCase();
    final tokenHash = CryptoUtil.hashToken(participantToken);

    final participant = await RoomParticipant.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode) & t.participantTokenHash.equals(tokenHash),
    );
    if (participant == null) return false;

    participant.lastSeenAt = DateTime.now();
    participant.isOnline = true;
    await RoomParticipant.db.updateRow(session, participant);
    return true;
  }

  /// Mark participant as offline upon exit.
  Future<bool> leaveRoom(
    Session session,
    String roomCode,
    String participantToken,
  ) async {
    final normalizedCode = roomCode.trim().toUpperCase();
    final tokenHash = CryptoUtil.hashToken(participantToken);

    final participant = await RoomParticipant.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode) & t.participantTokenHash.equals(tokenHash),
    );
    if (participant == null) return false;

    participant.isOnline = false;
    participant.lastSeenAt = DateTime.now();
    await RoomParticipant.db.updateRow(session, participant);

    final room = await DebugRoom.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
    );
    final nextSeq = (room?.currentSequenceNumber ?? 0) + 1;
    if (room != null) {
      room.currentSequenceNumber = nextSeq;
      await DebugRoom.db.updateRow(session, room);
    }

    await session.messages.postMessage(
      'room_$normalizedCode',
      RoomStreamMessage(
        sequenceNumber: nextSeq,
        eventType: 'PARTICIPANT_LEFT',
        roomCode: normalizedCode,
        timestamp: DateTime.now(),
        participant: participant,
      ),
    );
    return true;
  }
}
