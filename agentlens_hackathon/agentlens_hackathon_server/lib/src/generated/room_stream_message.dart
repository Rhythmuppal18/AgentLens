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
import 'package:agentlens_hackathon_server/src/generated/protocol.dart'
    as _iymk3q9p;
import 'package:serverpod/serverpod.dart' as _is;
import 'investigation_note.dart' as _i0yfkpqw;
import 'room_finding.dart' as _iozwtlrj;
import 'room_participant.dart' as _iw8zamkd;
import 'room_span.dart' as _iho1msd8;
import 'room_trace.dart' as _i4pvbzt3;

abstract class RoomStreamMessage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RoomStreamMessage._({
    required this.sequenceNumber,
    required this.eventType,
    required this.roomCode,
    required this.timestamp,
    this.participant,
    this.trace,
    this.span,
    this.finding,
    this.note,
  });

  factory RoomStreamMessage({
    required int sequenceNumber,
    required String eventType,
    required String roomCode,
    required DateTime timestamp,
    _iw8zamkd.RoomParticipant? participant,
    _i4pvbzt3.RoomTrace? trace,
    _iho1msd8.RoomSpan? span,
    _iozwtlrj.RoomFinding? finding,
    _i0yfkpqw.InvestigationNote? note,
  }) = _RoomStreamMessageImpl;

  factory RoomStreamMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomStreamMessage(
      sequenceNumber: jsonSerialization['sequenceNumber'] as int,
      eventType: jsonSerialization['eventType'] as String,
      roomCode: jsonSerialization['roomCode'] as String,
      timestamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      participant: jsonSerialization['participant'] == null
          ? null
          : _iymk3q9p.Protocol().deserialize<_iw8zamkd.RoomParticipant>(
              jsonSerialization['participant'],
            ),
      trace: jsonSerialization['trace'] == null
          ? null
          : _iymk3q9p.Protocol().deserialize<_i4pvbzt3.RoomTrace>(
              jsonSerialization['trace'],
            ),
      span: jsonSerialization['span'] == null
          ? null
          : _iymk3q9p.Protocol().deserialize<_iho1msd8.RoomSpan>(
              jsonSerialization['span'],
            ),
      finding: jsonSerialization['finding'] == null
          ? null
          : _iymk3q9p.Protocol().deserialize<_iozwtlrj.RoomFinding>(
              jsonSerialization['finding'],
            ),
      note: jsonSerialization['note'] == null
          ? null
          : _iymk3q9p.Protocol().deserialize<_i0yfkpqw.InvestigationNote>(
              jsonSerialization['note'],
            ),
    );
  }

  int sequenceNumber;

  String eventType;

  String roomCode;

  DateTime timestamp;

  _iw8zamkd.RoomParticipant? participant;

  _i4pvbzt3.RoomTrace? trace;

  _iho1msd8.RoomSpan? span;

  _iozwtlrj.RoomFinding? finding;

  _i0yfkpqw.InvestigationNote? note;

  /// Returns a shallow copy of this [RoomStreamMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RoomStreamMessage copyWith({
    int? sequenceNumber,
    String? eventType,
    String? roomCode,
    DateTime? timestamp,
    _iw8zamkd.RoomParticipant? participant =
        const _UndefinedRoomStreamMessage$participant(),
    _i4pvbzt3.RoomTrace? trace = const _UndefinedRoomStreamMessage$trace(),
    _iho1msd8.RoomSpan? span = const _UndefinedRoomStreamMessage$span(),
    _iozwtlrj.RoomFinding? finding =
        const _UndefinedRoomStreamMessage$finding(),
    _i0yfkpqw.InvestigationNote? note =
        const _UndefinedRoomStreamMessage$note(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomStreamMessage',
      'sequenceNumber': sequenceNumber,
      'eventType': eventType,
      'roomCode': roomCode,
      'timestamp': timestamp.toJson(),
      if (participant != null) 'participant': participant?.toJson(),
      if (trace != null) 'trace': trace?.toJson(),
      if (span != null) 'span': span?.toJson(),
      if (finding != null) 'finding': finding?.toJson(),
      if (note != null) 'note': note?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomStreamMessage',
      'sequenceNumber': sequenceNumber,
      'eventType': eventType,
      'roomCode': roomCode,
      'timestamp': timestamp.toJson(),
      if (participant != null) 'participant': participant?.toJsonForProtocol(),
      if (trace != null) 'trace': trace?.toJsonForProtocol(),
      if (span != null) 'span': span?.toJsonForProtocol(),
      if (finding != null) 'finding': finding?.toJsonForProtocol(),
      if (note != null) 'note': note?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _UndefinedRoomStreamMessage$participant extends _is.UndefinedSentinel
    implements _iw8zamkd.RoomParticipant {
  const _UndefinedRoomStreamMessage$participant();
}

class _UndefinedRoomStreamMessage$trace extends _is.UndefinedSentinel
    implements _i4pvbzt3.RoomTrace {
  const _UndefinedRoomStreamMessage$trace();
}

class _UndefinedRoomStreamMessage$span extends _is.UndefinedSentinel
    implements _iho1msd8.RoomSpan {
  const _UndefinedRoomStreamMessage$span();
}

class _UndefinedRoomStreamMessage$finding extends _is.UndefinedSentinel
    implements _iozwtlrj.RoomFinding {
  const _UndefinedRoomStreamMessage$finding();
}

class _UndefinedRoomStreamMessage$note extends _is.UndefinedSentinel
    implements _i0yfkpqw.InvestigationNote {
  const _UndefinedRoomStreamMessage$note();
}

class _RoomStreamMessageImpl extends RoomStreamMessage {
  _RoomStreamMessageImpl({
    required int sequenceNumber,
    required String eventType,
    required String roomCode,
    required DateTime timestamp,
    _iw8zamkd.RoomParticipant? participant,
    _i4pvbzt3.RoomTrace? trace,
    _iho1msd8.RoomSpan? span,
    _iozwtlrj.RoomFinding? finding,
    _i0yfkpqw.InvestigationNote? note,
  }) : super._(
         sequenceNumber: sequenceNumber,
         eventType: eventType,
         roomCode: roomCode,
         timestamp: timestamp,
         participant: participant,
         trace: trace,
         span: span,
         finding: finding,
         note: note,
       );

  /// Returns a shallow copy of this [RoomStreamMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RoomStreamMessage copyWith({
    int? sequenceNumber,
    String? eventType,
    String? roomCode,
    DateTime? timestamp,
    _iw8zamkd.RoomParticipant? participant =
        const _UndefinedRoomStreamMessage$participant(),
    _i4pvbzt3.RoomTrace? trace = const _UndefinedRoomStreamMessage$trace(),
    _iho1msd8.RoomSpan? span = const _UndefinedRoomStreamMessage$span(),
    _iozwtlrj.RoomFinding? finding =
        const _UndefinedRoomStreamMessage$finding(),
    _i0yfkpqw.InvestigationNote? note =
        const _UndefinedRoomStreamMessage$note(),
  }) {
    return RoomStreamMessage(
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      eventType: eventType ?? this.eventType,
      roomCode: roomCode ?? this.roomCode,
      timestamp: timestamp ?? this.timestamp,
      participant: participant is _is.UndefinedSentinel
          ? this.participant?.copyWith()
          : participant,
      trace: trace is _is.UndefinedSentinel ? this.trace?.copyWith() : trace,
      span: span is _is.UndefinedSentinel ? this.span?.copyWith() : span,
      finding: finding is _is.UndefinedSentinel
          ? this.finding?.copyWith()
          : finding,
      note: note is _is.UndefinedSentinel ? this.note?.copyWith() : note,
    );
  }
}
