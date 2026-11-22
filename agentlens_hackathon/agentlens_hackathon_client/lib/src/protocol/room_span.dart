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

abstract class RoomSpan
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoomSpan._({
    this.id,
    required this.roomId,
    required this.roomCode,
    required this.traceId,
    required this.spanId,
    this.parentSpanId,
    required this.name,
    required this.spanType,
    required this.status,
    required this.durationMs,
    this.inputPayloadJson,
    this.outputPayloadJson,
    this.errorMessage,
    this.errorType,
    this.errorStack,
    required this.startTime,
    this.endTime,
  });

  factory RoomSpan({
    int? id,
    required int roomId,
    required String roomCode,
    required String traceId,
    required String spanId,
    String? parentSpanId,
    required String name,
    required String spanType,
    required String status,
    required int durationMs,
    String? inputPayloadJson,
    String? outputPayloadJson,
    String? errorMessage,
    String? errorType,
    String? errorStack,
    required DateTime startTime,
    DateTime? endTime,
  }) = _RoomSpanImpl;

  factory RoomSpan.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomSpan(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      roomCode: jsonSerialization['roomCode'] as String,
      traceId: jsonSerialization['traceId'] as String,
      spanId: jsonSerialization['spanId'] as String,
      parentSpanId: jsonSerialization['parentSpanId'] as String?,
      name: jsonSerialization['name'] as String,
      spanType: jsonSerialization['spanType'] as String,
      status: jsonSerialization['status'] as String,
      durationMs: jsonSerialization['durationMs'] as int,
      inputPayloadJson: jsonSerialization['inputPayloadJson'] as String?,
      outputPayloadJson: jsonSerialization['outputPayloadJson'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
      errorType: jsonSerialization['errorType'] as String?,
      errorStack: jsonSerialization['errorStack'] as String?,
      startTime: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  String roomCode;

  String traceId;

  String spanId;

  String? parentSpanId;

  String name;

  String spanType;

  String status;

  int durationMs;

  String? inputPayloadJson;

  String? outputPayloadJson;

  String? errorMessage;

  String? errorType;

  String? errorStack;

  DateTime startTime;

  DateTime? endTime;

  /// Returns a shallow copy of this [RoomSpan]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomSpan copyWith({
    int? id,
    int? roomId,
    String? roomCode,
    String? traceId,
    String? spanId,
    String? parentSpanId,
    String? name,
    String? spanType,
    String? status,
    int? durationMs,
    String? inputPayloadJson,
    String? outputPayloadJson,
    String? errorMessage,
    String? errorType,
    String? errorStack,
    DateTime? startTime,
    DateTime? endTime = const _isc.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomSpan',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'traceId': traceId,
      'spanId': spanId,
      if (parentSpanId != null) 'parentSpanId': parentSpanId,
      'name': name,
      'spanType': spanType,
      'status': status,
      'durationMs': durationMs,
      if (inputPayloadJson != null) 'inputPayloadJson': inputPayloadJson,
      if (outputPayloadJson != null) 'outputPayloadJson': outputPayloadJson,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (errorType != null) 'errorType': errorType,
      if (errorStack != null) 'errorStack': errorStack,
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomSpan',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'traceId': traceId,
      'spanId': spanId,
      if (parentSpanId != null) 'parentSpanId': parentSpanId,
      'name': name,
      'spanType': spanType,
      'status': status,
      'durationMs': durationMs,
      if (inputPayloadJson != null) 'inputPayloadJson': inputPayloadJson,
      if (outputPayloadJson != null) 'outputPayloadJson': outputPayloadJson,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (errorType != null) 'errorType': errorType,
      if (errorStack != null) 'errorStack': errorStack,
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomSpanImpl extends RoomSpan {
  _RoomSpanImpl({
    int? id,
    required int roomId,
    required String roomCode,
    required String traceId,
    required String spanId,
    String? parentSpanId,
    required String name,
    required String spanType,
    required String status,
    required int durationMs,
    String? inputPayloadJson,
    String? outputPayloadJson,
    String? errorMessage,
    String? errorType,
    String? errorStack,
    required DateTime startTime,
    DateTime? endTime,
  }) : super._(
         id: id,
         roomId: roomId,
         roomCode: roomCode,
         traceId: traceId,
         spanId: spanId,
         parentSpanId: parentSpanId,
         name: name,
         spanType: spanType,
         status: status,
         durationMs: durationMs,
         inputPayloadJson: inputPayloadJson,
         outputPayloadJson: outputPayloadJson,
         errorMessage: errorMessage,
         errorType: errorType,
         errorStack: errorStack,
         startTime: startTime,
         endTime: endTime,
       );

  /// Returns a shallow copy of this [RoomSpan]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomSpan copyWith({
    Object? id = _Undefined,
    int? roomId,
    String? roomCode,
    String? traceId,
    String? spanId,
    Object? parentSpanId = _Undefined,
    String? name,
    String? spanType,
    String? status,
    int? durationMs,
    Object? inputPayloadJson = _Undefined,
    Object? outputPayloadJson = _Undefined,
    Object? errorMessage = _Undefined,
    Object? errorType = _Undefined,
    Object? errorStack = _Undefined,
    DateTime? startTime,
    DateTime? endTime = const _isc.$UndefinedDateTime(),
  }) {
    return RoomSpan(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      traceId: traceId ?? this.traceId,
      spanId: spanId ?? this.spanId,
      parentSpanId: parentSpanId is String? ? parentSpanId : this.parentSpanId,
      name: name ?? this.name,
      spanType: spanType ?? this.spanType,
      status: status ?? this.status,
      durationMs: durationMs ?? this.durationMs,
      inputPayloadJson: inputPayloadJson is String?
          ? inputPayloadJson
          : this.inputPayloadJson,
      outputPayloadJson: outputPayloadJson is String?
          ? outputPayloadJson
          : this.outputPayloadJson,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      errorType: errorType is String? ? errorType : this.errorType,
      errorStack: errorStack is String? ? errorStack : this.errorStack,
      startTime: startTime ?? this.startTime,
      endTime: endTime is _isc.UndefinedSentinel ? this.endTime : endTime,
    );
  }
}
