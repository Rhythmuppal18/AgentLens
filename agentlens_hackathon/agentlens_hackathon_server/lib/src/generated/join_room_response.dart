/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:agentlens_hackathon_server/src/generated/protocol.dart'
    as _iymk3q9p;
import 'package:serverpod/serverpod.dart' as _is;
import 'debug_room.dart' as _inu3c563;
import 'room_participant.dart' as _iw8zamkd;

abstract class JoinRoomResponse
    implements _is.SerializableModel, _is.ProtocolSerialization {
  JoinRoomResponse._({
    required this.room,
    required this.participant,
    required this.participantToken,
  });

  factory JoinRoomResponse({
    required _inu3c563.DebugRoom room,
    required _iw8zamkd.RoomParticipant participant,
    required String participantToken,
  }) = _JoinRoomResponseImpl;

  factory JoinRoomResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return JoinRoomResponse(
      room: _iymk3q9p.Protocol().deserialize<_inu3c563.DebugRoom>(
        jsonSerialization['room'],
      ),
      participant: _iymk3q9p.Protocol().deserialize<_iw8zamkd.RoomParticipant>(
        jsonSerialization['participant'],
      ),
      participantToken: jsonSerialization['participantToken'] as String,
    );
  }

  _inu3c563.DebugRoom room;

  _iw8zamkd.RoomParticipant participant;

  String participantToken;

  /// Returns a shallow copy of this [JoinRoomResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  JoinRoomResponse copyWith({
    _inu3c563.DebugRoom? room,
    _iw8zamkd.RoomParticipant? participant,
    String? participantToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JoinRoomResponse',
      'room': room.toJson(),
      'participant': participant.toJson(),
      'participantToken': participantToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JoinRoomResponse',
      'room': room.toJsonForProtocol(),
      'participant': participant.toJsonForProtocol(),
      'participantToken': participantToken,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _JoinRoomResponseImpl extends JoinRoomResponse {
  _JoinRoomResponseImpl({
    required _inu3c563.DebugRoom room,
    required _iw8zamkd.RoomParticipant participant,
    required String participantToken,
  }) : super._(
         room: room,
         participant: participant,
         participantToken: participantToken,
       );

  /// Returns a shallow copy of this [JoinRoomResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  JoinRoomResponse copyWith({
    _inu3c563.DebugRoom? room,
    _iw8zamkd.RoomParticipant? participant,
    String? participantToken,
  }) {
    return JoinRoomResponse(
      room: room ?? this.room.copyWith(),
      participant: participant ?? this.participant.copyWith(),
      participantToken: participantToken ?? this.participantToken,
    );
  }
}
