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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class JoinRoomRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  JoinRoomRequest._({
    required this.roomCode,
    required this.participantName,
    required this.deviceId,
  });

  factory JoinRoomRequest({
    required String roomCode,
    required String participantName,
    required String deviceId,
  }) = _JoinRoomRequestImpl;

  factory JoinRoomRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return JoinRoomRequest(
      roomCode: jsonSerialization['roomCode'] as String,
      participantName: jsonSerialization['participantName'] as String,
      deviceId: jsonSerialization['deviceId'] as String,
    );
  }

  String roomCode;

  String participantName;

  String deviceId;

  /// Returns a shallow copy of this [JoinRoomRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  JoinRoomRequest copyWith({
    String? roomCode,
    String? participantName,
    String? deviceId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JoinRoomRequest',
      'roomCode': roomCode,
      'participantName': participantName,
      'deviceId': deviceId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JoinRoomRequest',
      'roomCode': roomCode,
      'participantName': participantName,
      'deviceId': deviceId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _JoinRoomRequestImpl extends JoinRoomRequest {
  _JoinRoomRequestImpl({
    required String roomCode,
    required String participantName,
    required String deviceId,
  }) : super._(
         roomCode: roomCode,
         participantName: participantName,
         deviceId: deviceId,
       );

  /// Returns a shallow copy of this [JoinRoomRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  JoinRoomRequest copyWith({
    String? roomCode,
    String? participantName,
    String? deviceId,
  }) {
    return JoinRoomRequest(
      roomCode: roomCode ?? this.roomCode,
      participantName: participantName ?? this.participantName,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
