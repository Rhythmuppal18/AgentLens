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

abstract class RoomParticipant
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoomParticipant._({
    this.id,
    required this.roomId,
    required this.roomCode,
    required this.participantName,
    required this.deviceId,
    required this.participantTokenHash,
    required this.joinedAt,
    required this.lastSeenAt,
    bool? isOnline,
  }) : isOnline = isOnline ?? true;

  factory RoomParticipant({
    int? id,
    required int roomId,
    required String roomCode,
    required String participantName,
    required String deviceId,
    required String participantTokenHash,
    required DateTime joinedAt,
    required DateTime lastSeenAt,
    bool? isOnline,
  }) = _RoomParticipantImpl;

  factory RoomParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomParticipant(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      roomCode: jsonSerialization['roomCode'] as String,
      participantName: jsonSerialization['participantName'] as String,
      deviceId: jsonSerialization['deviceId'] as String,
      participantTokenHash: jsonSerialization['participantTokenHash'] as String,
      joinedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['joinedAt'],
      ),
      lastSeenAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastSeenAt'],
      ),
      isOnline: jsonSerialization['isOnline'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isOnline']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  String roomCode;

  String participantName;

  String deviceId;

  String participantTokenHash;

  DateTime joinedAt;

  DateTime lastSeenAt;

  bool isOnline;

  /// Returns a shallow copy of this [RoomParticipant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomParticipant copyWith({
    int? id,
    int? roomId,
    String? roomCode,
    String? participantName,
    String? deviceId,
    String? participantTokenHash,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
    bool? isOnline,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomParticipant',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'participantName': participantName,
      'deviceId': deviceId,
      'participantTokenHash': participantTokenHash,
      'joinedAt': joinedAt.toJson(),
      'lastSeenAt': lastSeenAt.toJson(),
      'isOnline': isOnline,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomParticipant',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'participantName': participantName,
      'deviceId': deviceId,
      'participantTokenHash': participantTokenHash,
      'joinedAt': joinedAt.toJson(),
      'lastSeenAt': lastSeenAt.toJson(),
      'isOnline': isOnline,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomParticipantImpl extends RoomParticipant {
  _RoomParticipantImpl({
    int? id,
    required int roomId,
    required String roomCode,
    required String participantName,
    required String deviceId,
    required String participantTokenHash,
    required DateTime joinedAt,
    required DateTime lastSeenAt,
    bool? isOnline,
  }) : super._(
         id: id,
         roomId: roomId,
         roomCode: roomCode,
         participantName: participantName,
         deviceId: deviceId,
         participantTokenHash: participantTokenHash,
         joinedAt: joinedAt,
         lastSeenAt: lastSeenAt,
         isOnline: isOnline,
       );

  /// Returns a shallow copy of this [RoomParticipant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomParticipant copyWith({
    Object? id = _Undefined,
    int? roomId,
    String? roomCode,
    String? participantName,
    String? deviceId,
    String? participantTokenHash,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
    bool? isOnline,
  }) {
    return RoomParticipant(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      participantName: participantName ?? this.participantName,
      deviceId: deviceId ?? this.deviceId,
      participantTokenHash: participantTokenHash ?? this.participantTokenHash,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
