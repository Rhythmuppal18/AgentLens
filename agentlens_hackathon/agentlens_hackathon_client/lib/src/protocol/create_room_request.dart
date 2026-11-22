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

abstract class CreateRoomRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CreateRoomRequest._({
    required this.roomName,
    required this.creatorName,
    required this.deviceId,
  });

  factory CreateRoomRequest({
    required String roomName,
    required String creatorName,
    required String deviceId,
  }) = _CreateRoomRequestImpl;

  factory CreateRoomRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return CreateRoomRequest(
      roomName: jsonSerialization['roomName'] as String,
      creatorName: jsonSerialization['creatorName'] as String,
      deviceId: jsonSerialization['deviceId'] as String,
    );
  }

  String roomName;

  String creatorName;

  String deviceId;

  /// Returns a shallow copy of this [CreateRoomRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CreateRoomRequest copyWith({
    String? roomName,
    String? creatorName,
    String? deviceId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreateRoomRequest',
      'roomName': roomName,
      'creatorName': creatorName,
      'deviceId': deviceId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreateRoomRequest',
      'roomName': roomName,
      'creatorName': creatorName,
      'deviceId': deviceId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CreateRoomRequestImpl extends CreateRoomRequest {
  _CreateRoomRequestImpl({
    required String roomName,
    required String creatorName,
    required String deviceId,
  }) : super._(
         roomName: roomName,
         creatorName: creatorName,
         deviceId: deviceId,
       );

  /// Returns a shallow copy of this [CreateRoomRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CreateRoomRequest copyWith({
    String? roomName,
    String? creatorName,
    String? deviceId,
  }) {
    return CreateRoomRequest(
      roomName: roomName ?? this.roomName,
      creatorName: creatorName ?? this.creatorName,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
