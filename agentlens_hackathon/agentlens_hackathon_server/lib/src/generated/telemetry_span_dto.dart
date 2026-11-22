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

abstract class TelemetrySpanDto
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TelemetrySpanDto._({
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

  factory TelemetrySpanDto({
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
  }) = _TelemetrySpanDtoImpl;

  factory TelemetrySpanDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return TelemetrySpanDto(
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
      startTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
    );
  }

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

  /// Returns a shallow copy of this [TelemetrySpanDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TelemetrySpanDto copyWith({
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
    DateTime? endTime = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TelemetrySpanDto',
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
      '__className__': 'TelemetrySpanDto',
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
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TelemetrySpanDtoImpl extends TelemetrySpanDto {
  _TelemetrySpanDtoImpl({
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

  /// Returns a shallow copy of this [TelemetrySpanDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TelemetrySpanDto copyWith({
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
    DateTime? endTime = const _is.$UndefinedDateTime(),
  }) {
    return TelemetrySpanDto(
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
      endTime: endTime is _is.UndefinedSentinel ? this.endTime : endTime,
    );
  }
}
