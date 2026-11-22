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

abstract class DebugRoom
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DebugRoom._({
    this.id,
    required this.roomCode,
    required this.name,
    required this.createdBy,
    required this.ingestTokenHash,
    required this.createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  }) : currentSequenceNumber = currentSequenceNumber ?? 0,
       isActive = isActive ?? true;

  factory DebugRoom({
    int? id,
    required String roomCode,
    required String name,
    required String createdBy,
    required String ingestTokenHash,
    required DateTime createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  }) = _DebugRoomImpl;

  factory DebugRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return DebugRoom(
      id: jsonSerialization['id'] as int?,
      roomCode: jsonSerialization['roomCode'] as String,
      name: jsonSerialization['name'] as String,
      createdBy: jsonSerialization['createdBy'] as String,
      ingestTokenHash: jsonSerialization['ingestTokenHash'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      currentSequenceNumber: jsonSerialization['currentSequenceNumber'] as int?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String roomCode;

  String name;

  String createdBy;

  String ingestTokenHash;

  DateTime createdAt;

  int currentSequenceNumber;

  bool isActive;

  /// Returns a shallow copy of this [DebugRoom]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DebugRoom copyWith({
    int? id,
    String? roomCode,
    String? name,
    String? createdBy,
    String? ingestTokenHash,
    DateTime? createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DebugRoom',
      if (id != null) 'id': id,
      'roomCode': roomCode,
      'name': name,
      'createdBy': createdBy,
      'ingestTokenHash': ingestTokenHash,
      'createdAt': createdAt.toJson(),
      'currentSequenceNumber': currentSequenceNumber,
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DebugRoom',
      if (id != null) 'id': id,
      'roomCode': roomCode,
      'name': name,
      'createdBy': createdBy,
      'ingestTokenHash': ingestTokenHash,
      'createdAt': createdAt.toJson(),
      'currentSequenceNumber': currentSequenceNumber,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DebugRoomImpl extends DebugRoom {
  _DebugRoomImpl({
    int? id,
    required String roomCode,
    required String name,
    required String createdBy,
    required String ingestTokenHash,
    required DateTime createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  }) : super._(
         id: id,
         roomCode: roomCode,
         name: name,
         createdBy: createdBy,
         ingestTokenHash: ingestTokenHash,
         createdAt: createdAt,
         currentSequenceNumber: currentSequenceNumber,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [DebugRoom]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DebugRoom copyWith({
    Object? id = _Undefined,
    String? roomCode,
    String? name,
    String? createdBy,
    String? ingestTokenHash,
    DateTime? createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  }) {
    return DebugRoom(
      id: id is int? ? id : this.id,
      roomCode: roomCode ?? this.roomCode,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      ingestTokenHash: ingestTokenHash ?? this.ingestTokenHash,
      createdAt: createdAt ?? this.createdAt,
      currentSequenceNumber:
          currentSequenceNumber ?? this.currentSequenceNumber,
      isActive: isActive ?? this.isActive,
    );
  }
}
