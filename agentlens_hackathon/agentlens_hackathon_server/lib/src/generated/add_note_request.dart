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
import 'package:serverpod/serverpod.dart' as _is;

abstract class AddNoteRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AddNoteRequest._({
    required this.roomCode,
    required this.participantToken,
    this.findingId,
    required this.content,
  });

  factory AddNoteRequest({
    required String roomCode,
    required String participantToken,
    int? findingId,
    required String content,
  }) = _AddNoteRequestImpl;

  factory AddNoteRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return AddNoteRequest(
      roomCode: jsonSerialization['roomCode'] as String,
      participantToken: jsonSerialization['participantToken'] as String,
      findingId: jsonSerialization['findingId'] as int?,
      content: jsonSerialization['content'] as String,
    );
  }

  String roomCode;

  String participantToken;

  int? findingId;

  String content;

  /// Returns a shallow copy of this [AddNoteRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AddNoteRequest copyWith({
    String? roomCode,
    String? participantToken,
    int? findingId,
    String? content,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AddNoteRequest',
      'roomCode': roomCode,
      'participantToken': participantToken,
      if (findingId != null) 'findingId': findingId,
      'content': content,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AddNoteRequest',
      'roomCode': roomCode,
      'participantToken': participantToken,
      if (findingId != null) 'findingId': findingId,
      'content': content,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AddNoteRequestImpl extends AddNoteRequest {
  _AddNoteRequestImpl({
    required String roomCode,
    required String participantToken,
    int? findingId,
    required String content,
  }) : super._(
         roomCode: roomCode,
         participantToken: participantToken,
         findingId: findingId,
         content: content,
       );

  /// Returns a shallow copy of this [AddNoteRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AddNoteRequest copyWith({
    String? roomCode,
    String? participantToken,
    Object? findingId = _Undefined,
    String? content,
  }) {
    return AddNoteRequest(
      roomCode: roomCode ?? this.roomCode,
      participantToken: participantToken ?? this.participantToken,
      findingId: findingId is int? ? findingId : this.findingId,
      content: content ?? this.content,
    );
  }
}
