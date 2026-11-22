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
import 'package:agentlens_hackathon_client/src/protocol/protocol.dart'
    as _iygzkvmn;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'telemetry_span_dto.dart' as _iajwa7li;

abstract class TelemetryTraceDto
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TelemetryTraceDto._({
    required this.roomCode,
    required this.ingestToken,
    required this.traceId,
    required this.agentName,
    required this.status,
    required this.durationMs,
    int? totalTokens,
    required this.startTime,
    this.endTime,
    bool? isSample,
    required this.spans,
  }) : totalTokens = totalTokens ?? 0,
       isSample = isSample ?? false;

  factory TelemetryTraceDto({
    required String roomCode,
    required String ingestToken,
    required String traceId,
    required String agentName,
    required String status,
    required int durationMs,
    int? totalTokens,
    required DateTime startTime,
    DateTime? endTime,
    bool? isSample,
    required List<_iajwa7li.TelemetrySpanDto> spans,
  }) = _TelemetryTraceDtoImpl;

  factory TelemetryTraceDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return TelemetryTraceDto(
      roomCode: jsonSerialization['roomCode'] as String,
      ingestToken: jsonSerialization['ingestToken'] as String,
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
      spans: _iygzkvmn.Protocol().deserialize<List<_iajwa7li.TelemetrySpanDto>>(
        jsonSerialization['spans'],
      ),
    );
  }

  String roomCode;

  String ingestToken;

  String traceId;

  String agentName;

  String status;

  int durationMs;

  int totalTokens;

  DateTime startTime;

  DateTime? endTime;

  bool isSample;

  List<_iajwa7li.TelemetrySpanDto> spans;

  /// Returns a shallow copy of this [TelemetryTraceDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TelemetryTraceDto copyWith({
    String? roomCode,
    String? ingestToken,
    String? traceId,
    String? agentName,
    String? status,
    int? durationMs,
    int? totalTokens,
    DateTime? startTime,
    DateTime? endTime = const _isc.$UndefinedDateTime(),
    bool? isSample,
    List<_iajwa7li.TelemetrySpanDto>? spans,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TelemetryTraceDto',
      'roomCode': roomCode,
      'ingestToken': ingestToken,
      'traceId': traceId,
      'agentName': agentName,
      'status': status,
      'durationMs': durationMs,
      'totalTokens': totalTokens,
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
      'isSample': isSample,
      'spans': spans.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TelemetryTraceDto',
      'roomCode': roomCode,
      'ingestToken': ingestToken,
      'traceId': traceId,
      'agentName': agentName,
      'status': status,
      'durationMs': durationMs,
      'totalTokens': totalTokens,
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
      'isSample': isSample,
      'spans': spans.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TelemetryTraceDtoImpl extends TelemetryTraceDto {
  _TelemetryTraceDtoImpl({
    required String roomCode,
    required String ingestToken,
    required String traceId,
    required String agentName,
    required String status,
    required int durationMs,
    int? totalTokens,
    required DateTime startTime,
    DateTime? endTime,
    bool? isSample,
    required List<_iajwa7li.TelemetrySpanDto> spans,
  }) : super._(
         roomCode: roomCode,
         ingestToken: ingestToken,
         traceId: traceId,
         agentName: agentName,
         status: status,
         durationMs: durationMs,
         totalTokens: totalTokens,
         startTime: startTime,
         endTime: endTime,
         isSample: isSample,
         spans: spans,
       );

  /// Returns a shallow copy of this [TelemetryTraceDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TelemetryTraceDto copyWith({
    String? roomCode,
    String? ingestToken,
    String? traceId,
    String? agentName,
    String? status,
    int? durationMs,
    int? totalTokens,
    DateTime? startTime,
    DateTime? endTime = const _isc.$UndefinedDateTime(),
    bool? isSample,
    List<_iajwa7li.TelemetrySpanDto>? spans,
  }) {
    return TelemetryTraceDto(
      roomCode: roomCode ?? this.roomCode,
      ingestToken: ingestToken ?? this.ingestToken,
      traceId: traceId ?? this.traceId,
      agentName: agentName ?? this.agentName,
      status: status ?? this.status,
      durationMs: durationMs ?? this.durationMs,
      totalTokens: totalTokens ?? this.totalTokens,
      startTime: startTime ?? this.startTime,
      endTime: endTime is _isc.UndefinedSentinel ? this.endTime : endTime,
      isSample: isSample ?? this.isSample,
      spans: spans ?? this.spans.map((e0) => e0.copyWith()).toList(),
    );
  }
}
