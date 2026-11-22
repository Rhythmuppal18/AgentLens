import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../util/crypto_util.dart';

class RoomStreamEndpoint extends Endpoint {
  /// Establish a real-time typed stream subscription for a debug room.
  /// Serverpod 4.1.2 creates a stream from session.messages and broadcasts typed messages.
  Stream<RoomStreamMessage> watchRoom(
    Session session,
    String roomCode,
    String participantToken,
  ) async* {
    final normalizedCode = roomCode.trim().toUpperCase();
    final tokenHash = CryptoUtil.hashToken(participantToken);

    final participant = await RoomParticipant.db.findFirstRow(
      session,
      where: (t) => t.roomCode.equals(normalizedCode) & t.participantTokenHash.equals(tokenHash),
    );

    if (participant == null) {
      throw RoomException(
        message: 'Unauthorized participant token for room "$normalizedCode".',
        statusCode: 401,
      );
    }

    session.log('Client connected to watchRoom channel: room_$normalizedCode');
    yield* session.messages.createStream<RoomStreamMessage>('room_$normalizedCode');
  }
}
