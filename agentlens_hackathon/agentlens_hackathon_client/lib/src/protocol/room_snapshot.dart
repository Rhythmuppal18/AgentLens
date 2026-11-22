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
import 'debug_room.dart' as _inu3c563;
import 'investigation_note.dart' as _i0yfkpqw;
import 'room_finding.dart' as _iozwtlrj;
import 'room_participant.dart' as _iw8zamkd;
import 'room_span.dart' as _iho1msd8;
import 'room_trace.dart' as _i4pvbzt3;

abstract class RoomSnapshot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoomSnapshot._({
    required this.room,
    required this.lastSequenceNumber,
    required this.participants,
    required this.traces,
    required this.spans,
    required this.findings,
    required this.notes,
  });

  factory RoomSnapshot({
    required _inu3c563.DebugRoom room,
    required int lastSequenceNumber,
    required List<_iw8zamkd.RoomParticipant> participants,
    required List<_i4pvbzt3.RoomTrace> traces,
    required List<_iho1msd8.RoomSpan> spans,
    required List<_iozwtlrj.RoomFinding> findings,
    required List<_i0yfkpqw.InvestigationNote> notes,
  }) = _RoomSnapshotImpl;

  factory RoomSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomSnapshot(
      room: _iygzkvmn.Protocol().deserialize<_inu3c563.DebugRoom>(
        jsonSerialization['room'],
      ),
      lastSequenceNumber: jsonSerialization['lastSequenceNumber'] as int,
      participants: _iygzkvmn.Protocol()
          .deserialize<List<_iw8zamkd.RoomParticipant>>(
            jsonSerialization['participants'],
          ),
      traces: _iygzkvmn.Protocol().deserialize<List<_i4pvbzt3.RoomTrace>>(
        jsonSerialization['traces'],
      ),
      spans: _iygzkvmn.Protocol().deserialize<List<_iho1msd8.RoomSpan>>(
        jsonSerialization['spans'],
      ),
      findings: _iygzkvmn.Protocol().deserialize<List<_iozwtlrj.RoomFinding>>(
        jsonSerialization['findings'],
      ),
      notes: _iygzkvmn.Protocol()
          .deserialize<List<_i0yfkpqw.InvestigationNote>>(
            jsonSerialization['notes'],
          ),
    );
  }

  _inu3c563.DebugRoom room;

  int lastSequenceNumber;

  List<_iw8zamkd.RoomParticipant> participants;

  List<_i4pvbzt3.RoomTrace> traces;

  List<_iho1msd8.RoomSpan> spans;

  List<_iozwtlrj.RoomFinding> findings;

  List<_i0yfkpqw.InvestigationNote> notes;

  /// Returns a shallow copy of this [RoomSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomSnapshot copyWith({
    _inu3c563.DebugRoom? room,
    int? lastSequenceNumber,
    List<_iw8zamkd.RoomParticipant>? participants,
    List<_i4pvbzt3.RoomTrace>? traces,
    List<_iho1msd8.RoomSpan>? spans,
    List<_iozwtlrj.RoomFinding>? findings,
    List<_i0yfkpqw.InvestigationNote>? notes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomSnapshot',
      'room': room.toJson(),
      'lastSequenceNumber': lastSequenceNumber,
      'participants': participants.toJson(valueToJson: (v) => v.toJson()),
      'traces': traces.toJson(valueToJson: (v) => v.toJson()),
      'spans': spans.toJson(valueToJson: (v) => v.toJson()),
      'findings': findings.toJson(valueToJson: (v) => v.toJson()),
      'notes': notes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomSnapshot',
      'room': room.toJsonForProtocol(),
      'lastSequenceNumber': lastSequenceNumber,
      'participants': participants.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'traces': traces.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'spans': spans.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'findings': findings.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'notes': notes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _RoomSnapshotImpl extends RoomSnapshot {
  _RoomSnapshotImpl({
    required _inu3c563.DebugRoom room,
    required int lastSequenceNumber,
    required List<_iw8zamkd.RoomParticipant> participants,
    required List<_i4pvbzt3.RoomTrace> traces,
    required List<_iho1msd8.RoomSpan> spans,
    required List<_iozwtlrj.RoomFinding> findings,
    required List<_i0yfkpqw.InvestigationNote> notes,
  }) : super._(
         room: room,
         lastSequenceNumber: lastSequenceNumber,
         participants: participants,
         traces: traces,
         spans: spans,
         findings: findings,
         notes: notes,
       );

  /// Returns a shallow copy of this [RoomSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomSnapshot copyWith({
    _inu3c563.DebugRoom? room,
    int? lastSequenceNumber,
    List<_iw8zamkd.RoomParticipant>? participants,
    List<_i4pvbzt3.RoomTrace>? traces,
    List<_iho1msd8.RoomSpan>? spans,
    List<_iozwtlrj.RoomFinding>? findings,
    List<_i0yfkpqw.InvestigationNote>? notes,
  }) {
    return RoomSnapshot(
      room: room ?? this.room.copyWith(),
      lastSequenceNumber: lastSequenceNumber ?? this.lastSequenceNumber,
      participants:
          participants ?? this.participants.map((e0) => e0.copyWith()).toList(),
      traces: traces ?? this.traces.map((e0) => e0.copyWith()).toList(),
      spans: spans ?? this.spans.map((e0) => e0.copyWith()).toList(),
      findings: findings ?? this.findings.map((e0) => e0.copyWith()).toList(),
      notes: notes ?? this.notes.map((e0) => e0.copyWith()).toList(),
    );
  }
}
