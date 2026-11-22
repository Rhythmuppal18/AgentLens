import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../util/crypto_util.dart';
import '../util/redaction_util.dart';

class InvestigationEndpoint extends Endpoint {
  /// Post a collaborative investigation note linked to a debug room and optional finding.
  /// Enforces participant authorization, 1000 char limit, secret redaction, and atomic broadcast.
  Future<InvestigationNote> addNote(
    Session session,
    AddNoteRequest request,
  ) async {
    final normalizedCode = request.roomCode.trim().toUpperCase();
    final tokenHash = CryptoUtil.hashToken(request.participantToken);

    final participant = await RoomParticipant.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode) & t.participantTokenHash.equals(tokenHash),
    );

    if (participant == null) {
      throw RoomException(message: 'Unauthorized participant for room "$normalizedCode".', statusCode: 401);
    }

    final trimmedContent = request.content.trim();
    if (trimmedContent.isEmpty) {
      throw RoomException(message: 'Note content cannot be empty.', statusCode: 400);
    }
    if (trimmedContent.length > 1000) {
      throw RoomException(message: 'Note content cannot exceed 1000 characters.', statusCode: 400);
    }

    final room = await DebugRoom.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode),
    );
    if (room == null) {
      throw RoomException(message: 'Room "$normalizedCode" not found.', statusCode: 404);
    }

    final sanitizedContent = RedactionUtil.redact(trimmedContent);
    final now = DateTime.now();

    final savedNote = await session.db.transaction<InvestigationNote>((tx) async {
      final nextSeq = room.currentSequenceNumber + 1;
      room.currentSequenceNumber = nextSeq;
      await DebugRoom.db.updateRow(session, room, transaction: tx);

      final note = InvestigationNote(
        roomId: room.id!,
        roomCode: normalizedCode,
        findingId: request.findingId,
        authorName: participant.participantName,
        content: sanitizedContent,
        createdAt: now,
      );

      return await InvestigationNote.db.insertRow(session, note, transaction: tx);
    });

    // Broadcast real-time note update to all room members
    await session.messages.postMessage(
      'room_$normalizedCode',
      RoomStreamMessage(
        sequenceNumber: room.currentSequenceNumber,
        eventType: 'NOTE_ADDED',
        roomCode: normalizedCode,
        timestamp: now,
        note: savedNote,
      ),
    );

    return savedNote;
  }
}
