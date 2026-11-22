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

abstract class CreateRoomResponse
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CreateRoomResponse._({
    required this.room,
    required this.ingestToken,
    required this.participantToken,
  });

  factory CreateRoomResponse({
    required _inu3c563.DebugRoom room,
    required String ingestToken,
    required String participantToken,
  }) = _CreateRoomResponseImpl;

  factory CreateRoomResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return CreateRoomResponse(
      room: _iymk3q9p.Protocol().deserialize<_inu3c563.DebugRoom>(
        jsonSerialization['room'],
      ),
      ingestToken: jsonSerialization['ingestToken'] as String,
      participantToken: jsonSerialization['participantToken'] as String,
    );
  }

  _inu3c563.DebugRoom room;

  String ingestToken;

  String participantToken;

  /// Returns a shallow copy of this [CreateRoomResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CreateRoomResponse copyWith({
    _inu3c563.DebugRoom? room,
    String? ingestToken,
    String? participantToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreateRoomResponse',
      'room': room.toJson(),
      'ingestToken': ingestToken,
      'participantToken': participantToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreateRoomResponse',
      'room': room.toJsonForProtocol(),
      'ingestToken': ingestToken,
      'participantToken': participantToken,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CreateRoomResponseImpl extends CreateRoomResponse {
  _CreateRoomResponseImpl({
    required _inu3c563.DebugRoom room,
    required String ingestToken,
    required String participantToken,
  }) : super._(
         room: room,
         ingestToken: ingestToken,
         participantToken: participantToken,
       );

  /// Returns a shallow copy of this [CreateRoomResponse]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CreateRoomResponse copyWith({
    _inu3c563.DebugRoom? room,
    String? ingestToken,
    String? participantToken,
  }) {
    return CreateRoomResponse(
      room: room ?? this.room.copyWith(),
      ingestToken: ingestToken ?? this.ingestToken,
      participantToken: participantToken ?? this.participantToken,
    );
  }
}
