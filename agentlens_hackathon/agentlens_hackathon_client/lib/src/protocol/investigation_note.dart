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

abstract class InvestigationNote
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  InvestigationNote._({
    this.id,
    required this.roomId,
    required this.roomCode,
    this.findingId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory InvestigationNote({
    int? id,
    required int roomId,
    required String roomCode,
    int? findingId,
    required String authorName,
    required String content,
    required DateTime createdAt,
  }) = _InvestigationNoteImpl;

  factory InvestigationNote.fromJson(Map<String, dynamic> jsonSerialization) {
    return InvestigationNote(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      roomCode: jsonSerialization['roomCode'] as String,
      findingId: jsonSerialization['findingId'] as int?,
      authorName: jsonSerialization['authorName'] as String,
      content: jsonSerialization['content'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  String roomCode;

  int? findingId;

  String authorName;

  String content;

  DateTime createdAt;

  /// Returns a shallow copy of this [InvestigationNote]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  InvestigationNote copyWith({
    int? id,
    int? roomId,
    String? roomCode,
    int? findingId,
    String? authorName,
    String? content,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InvestigationNote',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      if (findingId != null) 'findingId': findingId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InvestigationNote',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      if (findingId != null) 'findingId': findingId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InvestigationNoteImpl extends InvestigationNote {
  _InvestigationNoteImpl({
    int? id,
    required int roomId,
    required String roomCode,
    int? findingId,
    required String authorName,
    required String content,
    required DateTime createdAt,
  }) : super._(
         id: id,
         roomId: roomId,
         roomCode: roomCode,
         findingId: findingId,
         authorName: authorName,
         content: content,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [InvestigationNote]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  InvestigationNote copyWith({
    Object? id = _Undefined,
    int? roomId,
    String? roomCode,
    Object? findingId = _Undefined,
    String? authorName,
    String? content,
    DateTime? createdAt,
  }) {
    return InvestigationNote(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      findingId: findingId is int? ? findingId : this.findingId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
