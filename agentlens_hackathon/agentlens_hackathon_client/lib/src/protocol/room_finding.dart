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

abstract class RoomFinding
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoomFinding._({
    this.id,
    required this.roomId,
    required this.roomCode,
    required this.traceId,
    this.spanId,
    this.spanName,
    required this.ruleType,
    required this.severity,
    required this.summary,
    required this.evidenceSummary,
    this.evidenceDataJson,
    required this.detectedAt,
    bool? isSample,
  }) : isSample = isSample ?? false;

  factory RoomFinding({
    int? id,
    required int roomId,
    required String roomCode,
    required String traceId,
    String? spanId,
    String? spanName,
    required String ruleType,
    required String severity,
    required String summary,
    required String evidenceSummary,
    String? evidenceDataJson,
    required DateTime detectedAt,
    bool? isSample,
  }) = _RoomFindingImpl;

  factory RoomFinding.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomFinding(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      roomCode: jsonSerialization['roomCode'] as String,
      traceId: jsonSerialization['traceId'] as String,
      spanId: jsonSerialization['spanId'] as String?,
      spanName: jsonSerialization['spanName'] as String?,
      ruleType: jsonSerialization['ruleType'] as String,
      severity: jsonSerialization['severity'] as String,
      summary: jsonSerialization['summary'] as String,
      evidenceSummary: jsonSerialization['evidenceSummary'] as String,
      evidenceDataJson: jsonSerialization['evidenceDataJson'] as String?,
      detectedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['detectedAt'],
      ),
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

  String? spanId;

  String? spanName;

  String ruleType;

  String severity;

  String summary;

  String evidenceSummary;

  String? evidenceDataJson;

  DateTime detectedAt;

  bool isSample;

  /// Returns a shallow copy of this [RoomFinding]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomFinding copyWith({
    int? id,
    int? roomId,
    String? roomCode,
    String? traceId,
    String? spanId,
    String? spanName,
    String? ruleType,
    String? severity,
    String? summary,
    String? evidenceSummary,
    String? evidenceDataJson,
    DateTime? detectedAt,
    bool? isSample,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomFinding',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'traceId': traceId,
      if (spanId != null) 'spanId': spanId,
      if (spanName != null) 'spanName': spanName,
      'ruleType': ruleType,
      'severity': severity,
      'summary': summary,
      'evidenceSummary': evidenceSummary,
      if (evidenceDataJson != null) 'evidenceDataJson': evidenceDataJson,
      'detectedAt': detectedAt.toJson(),
      'isSample': isSample,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomFinding',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      'traceId': traceId,
      if (spanId != null) 'spanId': spanId,
      if (spanName != null) 'spanName': spanName,
      'ruleType': ruleType,
      'severity': severity,
      'summary': summary,
      'evidenceSummary': evidenceSummary,
      if (evidenceDataJson != null) 'evidenceDataJson': evidenceDataJson,
      'detectedAt': detectedAt.toJson(),
      'isSample': isSample,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomFindingImpl extends RoomFinding {
  _RoomFindingImpl({
    int? id,
    required int roomId,
    required String roomCode,
    required String traceId,
    String? spanId,
    String? spanName,
    required String ruleType,
    required String severity,
    required String summary,
    required String evidenceSummary,
    String? evidenceDataJson,
    required DateTime detectedAt,
    bool? isSample,
  }) : super._(
         id: id,
         roomId: roomId,
         roomCode: roomCode,
         traceId: traceId,
         spanId: spanId,
         spanName: spanName,
         ruleType: ruleType,
         severity: severity,
         summary: summary,
         evidenceSummary: evidenceSummary,
         evidenceDataJson: evidenceDataJson,
         detectedAt: detectedAt,
         isSample: isSample,
       );

  /// Returns a shallow copy of this [RoomFinding]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomFinding copyWith({
    Object? id = _Undefined,
    int? roomId,
    String? roomCode,
    String? traceId,
    Object? spanId = _Undefined,
    Object? spanName = _Undefined,
    String? ruleType,
    String? severity,
    String? summary,
    String? evidenceSummary,
    Object? evidenceDataJson = _Undefined,
    DateTime? detectedAt,
    bool? isSample,
  }) {
    return RoomFinding(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      traceId: traceId ?? this.traceId,
      spanId: spanId is String? ? spanId : this.spanId,
      spanName: spanName is String? ? spanName : this.spanName,
      ruleType: ruleType ?? this.ruleType,
      severity: severity ?? this.severity,
      summary: summary ?? this.summary,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      evidenceDataJson: evidenceDataJson is String?
          ? evidenceDataJson
          : this.evidenceDataJson,
      detectedAt: detectedAt ?? this.detectedAt,
      isSample: isSample ?? this.isSample,
    );
  }
}
