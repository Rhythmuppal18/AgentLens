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

abstract class RoomTrace
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoomTrace._({
    this.id,
    required this.roomId,
    required this.roomCode,
    required this.traceId,
    required this.agentName,
    required this.status,
    required this.durationMs,
    int? totalTokens,
    required this.startTime,
    this.endTime,
    bool? isSample,
  }) : totalTokens = totalTokens ?? 0,
       isSample = isSample ?? false;

  factory RoomTrace({
    int? id,
    required int roomId,
    required String roomCode,
    required String traceId,
    required String agentName,
    required String status,
    required int durationMs,
    int? totalTokens,
    required DateTime startTime,
    DateTime? endTime,
    bool? isSample,
  }) = _RoomTraceImpl;

  factory RoomTrace.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomTrace(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      roomCode: jsonSerialization['roomCode'] as String,
      traceId: jsonSerialization['traceId'] as String,
      agentName: jsonSerialization['agentName'] as String,
      status: jsonSerialization['status'] as String,
      durationMs: jsonSerialization['durationMs'] as int,
      totalTokens: jsonSerialization['totalTokens'] as int?,
      startTime: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      isSample: jsonSerialization['isSample'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isSample']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  String roomCode;

  String traceId;

  String agentName;

  String status;

  int durationMs;

  int totalTokens;

  DateTime startTime;

  DateTime? endTime;

  bool isSample;

  /// Returns a shallow copy of this [RoomTrace]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomTrace copyWith({
    int? id,
    int? roomId,
    String? roomCode,
    String? traceId,
    String? agentName,
    String? status,
    int? durationMs,
    int? totalTokens,
    DateTime? startTime,
    DateTime? endTime = const _isc.$UndefinedDateTime(),
    bool? isSample,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomTrace',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'traceId': traceId,
      'agentName': agentName,
      'status': status,
      'durationMs': durationMs,
      'totalTokens': totalTokens,
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
      'isSample': isSample,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomTrace',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'traceId': traceId,
      'agentName': agentName,
      'status': status,
      'durationMs': durationMs,
      'totalTokens': totalTokens,
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
      'isSample': isSample,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomTraceImpl extends RoomTrace {
  _RoomTraceImpl({
    int? id,
    required int roomId,
    required String roomCode,
    required String traceId,
    required String agentName,
    required String status,
    required int durationMs,
    int? totalTokens,
    required DateTime startTime,
    DateTime? endTime,
    bool? isSample,
  }) : super._(
         id: id,
         roomId: roomId,
         roomCode: roomCode,
         traceId: traceId,
         agentName: agentName,
         status: status,
         durationMs: durationMs,
         totalTokens: totalTokens,
         startTime: startTime,
         endTime: endTime,
         isSample: isSample,
       );

  /// Returns a shallow copy of this [RoomTrace]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomTrace copyWith({
    Object? id = _Undefined,
    int? roomId,
    String? roomCode,
    String? traceId,
    String? agentName,
    String? status,
    int? durationMs,
    int? totalTokens,
    DateTime? startTime,
    DateTime? endTime = const _isc.$UndefinedDateTime(),
    bool? isSample,
  }) {
    return RoomTrace(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      traceId: traceId ?? this.traceId,
      agentName: agentName ?? this.agentName,
      status: status ?? this.status,
      durationMs: durationMs ?? this.durationMs,
      totalTokens: totalTokens ?? this.totalTokens,
      startTime: startTime ?? this.startTime,
      endTime: endTime is _isc.UndefinedSentinel ? this.endTime : endTime,
      isSample: isSample ?? this.isSample,
    );
  }
}
