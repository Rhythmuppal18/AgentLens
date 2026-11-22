/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'add_note_request.dart' as _i7ryjq82;
import 'create_room_request.dart' as _idg9muf1;
import 'create_room_response.dart' as _iqoysuv7;
import 'debug_room.dart' as _inu3c563;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'investigation_note.dart' as _i0yfkpqw;
import 'join_room_request.dart' as _ij8q7nxc;
import 'join_room_response.dart' as _i2fajtwe;
import 'room_exception.dart' as _izjkwir9;
import 'room_finding.dart' as _iozwtlrj;
import 'room_participant.dart' as _iw8zamkd;
import 'room_snapshot.dart' as _idho5v64;
import 'room_span.dart' as _iho1msd8;
import 'room_stream_message.dart' as _iaev2w2b;
import 'room_trace.dart' as _i4pvbzt3;
import 'telemetry_span_dto.dart' as _iajwa7li;
import 'telemetry_trace_dto.dart' as _i4z09txt;
export 'add_note_request.dart';
export 'create_room_request.dart';
export 'create_room_response.dart';
export 'debug_room.dart';
export 'greetings/greeting.dart';
export 'investigation_note.dart';
export 'join_room_request.dart';
export 'join_room_response.dart';
export 'room_exception.dart';
export 'room_finding.dart';
export 'room_participant.dart';
export 'room_snapshot.dart';
export 'room_span.dart';
export 'room_stream_message.dart';
export 'room_trace.dart';
export 'telemetry_span_dto.dart';
export 'telemetry_trace_dto.dart';

class Protocol extends _is.DatabaseSerializationManager
    implements _is.DatabaseProtocolDeserializationProvider {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  @override
  _is.ProtocolDeserialization get deserializationMetadata =>
      _is.ProtocolDeserialization.cached(
        this,
        types: const [
          _is.getType<_i7ryjq82.AddNoteRequest>,
          _is.getType<_idg9muf1.CreateRoomRequest>,
          _is.getType<_iqoysuv7.CreateRoomResponse>,
          _is.getType<_inu3c563.DebugRoom>,
          _is.getType<_izw8z7ou.Greeting>,
          _is.getType<_i0yfkpqw.InvestigationNote>,
          _is.getType<_ij8q7nxc.JoinRoomRequest>,
          _is.getType<_i2fajtwe.JoinRoomResponse>,
          _is.getType<_izjkwir9.RoomException>,
          _is.getType<_iozwtlrj.RoomFinding>,
          _is.getType<_iw8zamkd.RoomParticipant>,
          _is.getType<_idho5v64.RoomSnapshot>,
          _is.getType<_iho1msd8.RoomSpan>,
          _is.getType<_iaev2w2b.RoomStreamMessage>,
          _is.getType<_i4pvbzt3.RoomTrace>,
          _is.getType<_iajwa7li.TelemetrySpanDto>,
          _is.getType<_i4z09txt.TelemetryTraceDto>,
          _is.getType<_i7ryjq82.AddNoteRequest?>,
          _is.getType<_idg9muf1.CreateRoomRequest?>,
          _is.getType<_iqoysuv7.CreateRoomResponse?>,
          _is.getType<_inu3c563.DebugRoom?>,
          _is.getType<_izw8z7ou.Greeting?>,
          _is.getType<_i0yfkpqw.InvestigationNote?>,
          _is.getType<_ij8q7nxc.JoinRoomRequest?>,
          _is.getType<_i2fajtwe.JoinRoomResponse?>,
          _is.getType<_izjkwir9.RoomException?>,
          _is.getType<_iozwtlrj.RoomFinding?>,
          _is.getType<_iw8zamkd.RoomParticipant?>,
          _is.getType<_idho5v64.RoomSnapshot?>,
          _is.getType<_iho1msd8.RoomSpan?>,
          _is.getType<_iaev2w2b.RoomStreamMessage?>,
          _is.getType<_i4pvbzt3.RoomTrace?>,
          _is.getType<_iajwa7li.TelemetrySpanDto?>,
          _is.getType<_i4z09txt.TelemetryTraceDto?>,
          _is.getType<List<_iw8zamkd.RoomParticipant>>,
          _is.getType<List<_i4pvbzt3.RoomTrace>>,
          _is.getType<List<_iho1msd8.RoomSpan>>,
          _is.getType<List<_iozwtlrj.RoomFinding>>,
          _is.getType<List<_i0yfkpqw.InvestigationNote>>,
          _is.getType<List<_iajwa7li.TelemetrySpanDto>>,
        ],
        modules: const [
          _iais.Protocol.new,
          _iacs.Protocol.new,
          _isp.Protocol.new,
        ],
        classNames: const [
          'AddNoteRequest',
          'CreateRoomRequest',
          'CreateRoomResponse',
          'DebugRoom',
          'Greeting',
          'InvestigationNote',
          'JoinRoomRequest',
          'JoinRoomResponse',
          'RoomException',
          'RoomFinding',
          'RoomParticipant',
          'RoomSnapshot',
          'RoomSpan',
          'RoomStreamMessage',
          'RoomTrace',
          'TelemetrySpanDto',
          'TelemetryTraceDto',
        ],
      );

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    ..._ownTableDefinitions,
    ..._iais.Protocol().getOwnTableDefinitions(),
    ..._iacs.Protocol().getOwnTableDefinitions(),
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static List<_isp.TableDefinition> get _ownTableDefinitions => [
    _isp.TableDefinition(
      name: 'debug_room',
      dartName: 'DebugRoom',
      schema: 'public',
      module: 'agentlens_hackathon',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ingestTokenHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'currentSequenceNumber',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'isActive',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'debug_room_code_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomCode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'debug_room_ingest_token_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ingestTokenHash',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'investigation_note',
      dartName: 'InvestigationNote',
      schema: 'public',
      module: 'agentlens_hackathon',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'findingId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'authorName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'investigation_note_fk_0',
          columns: ['roomId'],
          referenceTable: 'debug_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'investigation_note_room_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomCode',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'investigation_note_finding_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'findingId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'room_finding',
      dartName: 'RoomFinding',
      schema: 'public',
      module: 'agentlens_hackathon',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'traceId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'spanId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'spanName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'ruleType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'severity',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'summary',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'evidenceSummary',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'evidenceDataJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'detectedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'isSample',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'room_finding_fk_0',
          columns: ['roomId'],
          referenceTable: 'debug_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'room_finding_room_code_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomCode',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'room_finding_trace_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'traceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'room_participant',
      dartName: 'RoomParticipant',
      schema: 'public',
      module: 'agentlens_hackathon',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'participantName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'deviceId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'participantTokenHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'lastSeenAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'isOnline',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'room_participant_fk_0',
          columns: ['roomId'],
          referenceTable: 'debug_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'room_participant_room_code_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomCode',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'room_participant_token_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'participantTokenHash',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'room_span',
      dartName: 'RoomSpan',
      schema: 'public',
      module: 'agentlens_hackathon',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'traceId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'spanId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'parentSpanId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'spanType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'durationMs',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'inputPayloadJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'outputPayloadJson',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'errorMessage',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'errorType',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'errorStack',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'startTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'endTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'room_span_fk_0',
          columns: ['roomId'],
          referenceTable: 'debug_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'room_span_room_span_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'spanId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'room_span_trace_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'traceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'room_trace',
      dartName: 'RoomTrace',
      schema: 'public',
      module: 'agentlens_hackathon',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roomCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'traceId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'agentName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'durationMs',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'totalTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'startTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'endTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'isSample',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'room_trace_fk_0',
          columns: ['roomId'],
          referenceTable: 'debug_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'room_trace_room_trace_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomCode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'traceId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
  ];

  static String? getClassNameFromObjectJson(dynamic data) =>
      _is.ProtocolDeserialization.readClassName(data);

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    final rawDataClassName = _is.ProtocolDeserialization.readClassName(data);
    final dataClassName = rawDataClassName;
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i7ryjq82.AddNoteRequest) {
      return _i7ryjq82.AddNoteRequest.fromJson(data) as T;
    }
    if (t == _idg9muf1.CreateRoomRequest) {
      return _idg9muf1.CreateRoomRequest.fromJson(data) as T;
    }
    if (t == _iqoysuv7.CreateRoomResponse) {
      return _iqoysuv7.CreateRoomResponse.fromJson(data) as T;
    }
    if (t == _inu3c563.DebugRoom) {
      return _inu3c563.DebugRoom.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i0yfkpqw.InvestigationNote) {
      return _i0yfkpqw.InvestigationNote.fromJson(data) as T;
    }
    if (t == _ij8q7nxc.JoinRoomRequest) {
      return _ij8q7nxc.JoinRoomRequest.fromJson(data) as T;
    }
    if (t == _i2fajtwe.JoinRoomResponse) {
      return _i2fajtwe.JoinRoomResponse.fromJson(data) as T;
    }
    if (t == _izjkwir9.RoomException) {
      return _izjkwir9.RoomException.fromJson(data) as T;
    }
    if (t == _iozwtlrj.RoomFinding) {
      return _iozwtlrj.RoomFinding.fromJson(data) as T;
    }
    if (t == _iw8zamkd.RoomParticipant) {
      return _iw8zamkd.RoomParticipant.fromJson(data) as T;
    }
    if (t == _idho5v64.RoomSnapshot) {
      return _idho5v64.RoomSnapshot.fromJson(data) as T;
    }
    if (t == _iho1msd8.RoomSpan) {
      return _iho1msd8.RoomSpan.fromJson(data) as T;
    }
    if (t == _iaev2w2b.RoomStreamMessage) {
      return _iaev2w2b.RoomStreamMessage.fromJson(data) as T;
    }
    if (t == _i4pvbzt3.RoomTrace) {
      return _i4pvbzt3.RoomTrace.fromJson(data) as T;
    }
    if (t == _iajwa7li.TelemetrySpanDto) {
      return _iajwa7li.TelemetrySpanDto.fromJson(data) as T;
    }
    if (t == _i4z09txt.TelemetryTraceDto) {
      return _i4z09txt.TelemetryTraceDto.fromJson(data) as T;
    }
    if (t == _is.getType<_i7ryjq82.AddNoteRequest?>()) {
      return (data != null ? _i7ryjq82.AddNoteRequest.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idg9muf1.CreateRoomRequest?>()) {
      return (data != null ? _idg9muf1.CreateRoomRequest.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqoysuv7.CreateRoomResponse?>()) {
      return (data != null ? _iqoysuv7.CreateRoomResponse.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_inu3c563.DebugRoom?>()) {
      return (data != null ? _inu3c563.DebugRoom.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0yfkpqw.InvestigationNote?>()) {
      return (data != null ? _i0yfkpqw.InvestigationNote.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ij8q7nxc.JoinRoomRequest?>()) {
      return (data != null ? _ij8q7nxc.JoinRoomRequest.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2fajtwe.JoinRoomResponse?>()) {
      return (data != null ? _i2fajtwe.JoinRoomResponse.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izjkwir9.RoomException?>()) {
      return (data != null ? _izjkwir9.RoomException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iozwtlrj.RoomFinding?>()) {
      return (data != null ? _iozwtlrj.RoomFinding.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iw8zamkd.RoomParticipant?>()) {
      return (data != null ? _iw8zamkd.RoomParticipant.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idho5v64.RoomSnapshot?>()) {
      return (data != null ? _idho5v64.RoomSnapshot.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iho1msd8.RoomSpan?>()) {
      return (data != null ? _iho1msd8.RoomSpan.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iaev2w2b.RoomStreamMessage?>()) {
      return (data != null ? _iaev2w2b.RoomStreamMessage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i4pvbzt3.RoomTrace?>()) {
      return (data != null ? _i4pvbzt3.RoomTrace.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iajwa7li.TelemetrySpanDto?>()) {
      return (data != null ? _iajwa7li.TelemetrySpanDto.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i4z09txt.TelemetryTraceDto?>()) {
      return (data != null ? _i4z09txt.TelemetryTraceDto.fromJson(data) : null)
          as T;
    }
    if (t == List<_iw8zamkd.RoomParticipant>) {
      return (data as List)
              .map((e) => deserialize<_iw8zamkd.RoomParticipant>(e))
              .toList()
          as T;
    }
    if (t == List<_i4pvbzt3.RoomTrace>) {
      return (data as List)
              .map((e) => deserialize<_i4pvbzt3.RoomTrace>(e))
              .toList()
          as T;
    }
    if (t == List<_iho1msd8.RoomSpan>) {
      return (data as List)
              .map((e) => deserialize<_iho1msd8.RoomSpan>(e))
              .toList()
          as T;
    }
    if (t == List<_iozwtlrj.RoomFinding>) {
      return (data as List)
              .map((e) => deserialize<_iozwtlrj.RoomFinding>(e))
              .toList()
          as T;
    }
    if (t == List<_i0yfkpqw.InvestigationNote>) {
      return (data as List)
              .map((e) => deserialize<_i0yfkpqw.InvestigationNote>(e))
              .toList()
          as T;
    }
    if (t == List<_iajwa7li.TelemetrySpanDto>) {
      return (data as List)
              .map((e) => deserialize<_iajwa7li.TelemetrySpanDto>(e))
              .toList()
          as T;
    }
    final modules = deserializationMetadata.modulesForDeserialization(
      t,
      className: rawDataClassName,
    );
    for (final module in modules) {
      try {
        return module.deserialize<T>(data, t);
      } on _is.DeserializationTypeNotFoundException catch (_) {}
    }

    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i7ryjq82.AddNoteRequest => 'AddNoteRequest',
      _idg9muf1.CreateRoomRequest => 'CreateRoomRequest',
      _iqoysuv7.CreateRoomResponse => 'CreateRoomResponse',
      _inu3c563.DebugRoom => 'DebugRoom',
      _izw8z7ou.Greeting => 'Greeting',
      _i0yfkpqw.InvestigationNote => 'InvestigationNote',
      _ij8q7nxc.JoinRoomRequest => 'JoinRoomRequest',
      _i2fajtwe.JoinRoomResponse => 'JoinRoomResponse',
      _izjkwir9.RoomException => 'RoomException',
      _iozwtlrj.RoomFinding => 'RoomFinding',
      _iw8zamkd.RoomParticipant => 'RoomParticipant',
      _idho5v64.RoomSnapshot => 'RoomSnapshot',
      _iho1msd8.RoomSpan => 'RoomSpan',
      _iaev2w2b.RoomStreamMessage => 'RoomStreamMessage',
      _i4pvbzt3.RoomTrace => 'RoomTrace',
      _iajwa7li.TelemetrySpanDto => 'TelemetrySpanDto',
      _i4z09txt.TelemetryTraceDto => 'TelemetryTraceDto',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'agentlens_hackathon.',
        '',
      );
    }

    switch (data) {
      case _i7ryjq82.AddNoteRequest():
        return 'AddNoteRequest';
      case _idg9muf1.CreateRoomRequest():
        return 'CreateRoomRequest';
      case _iqoysuv7.CreateRoomResponse():
        return 'CreateRoomResponse';
      case _inu3c563.DebugRoom():
        return 'DebugRoom';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i0yfkpqw.InvestigationNote():
        return 'InvestigationNote';
      case _ij8q7nxc.JoinRoomRequest():
        return 'JoinRoomRequest';
      case _i2fajtwe.JoinRoomResponse():
        return 'JoinRoomResponse';
      case _izjkwir9.RoomException():
        return 'RoomException';
      case _iozwtlrj.RoomFinding():
        return 'RoomFinding';
      case _iw8zamkd.RoomParticipant():
        return 'RoomParticipant';
      case _idho5v64.RoomSnapshot():
        return 'RoomSnapshot';
      case _iho1msd8.RoomSpan():
        return 'RoomSpan';
      case _iaev2w2b.RoomStreamMessage():
        return 'RoomStreamMessage';
      case _i4pvbzt3.RoomTrace():
        return 'RoomTrace';
      case _iajwa7li.TelemetrySpanDto():
        return 'TelemetrySpanDto';
      case _i4z09txt.TelemetryTraceDto():
        return 'TelemetryTraceDto';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AddNoteRequest') {
      return deserialize<_i7ryjq82.AddNoteRequest>(data['data']);
    }
    if (dataClassName == 'CreateRoomRequest') {
      return deserialize<_idg9muf1.CreateRoomRequest>(data['data']);
    }
    if (dataClassName == 'CreateRoomResponse') {
      return deserialize<_iqoysuv7.CreateRoomResponse>(data['data']);
    }
    if (dataClassName == 'DebugRoom') {
      return deserialize<_inu3c563.DebugRoom>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'InvestigationNote') {
      return deserialize<_i0yfkpqw.InvestigationNote>(data['data']);
    }
    if (dataClassName == 'JoinRoomRequest') {
      return deserialize<_ij8q7nxc.JoinRoomRequest>(data['data']);
    }
    if (dataClassName == 'JoinRoomResponse') {
      return deserialize<_i2fajtwe.JoinRoomResponse>(data['data']);
    }
    if (dataClassName == 'RoomException') {
      return deserialize<_izjkwir9.RoomException>(data['data']);
    }
    if (dataClassName == 'RoomFinding') {
      return deserialize<_iozwtlrj.RoomFinding>(data['data']);
    }
    if (dataClassName == 'RoomParticipant') {
      return deserialize<_iw8zamkd.RoomParticipant>(data['data']);
    }
    if (dataClassName == 'RoomSnapshot') {
      return deserialize<_idho5v64.RoomSnapshot>(data['data']);
    }
    if (dataClassName == 'RoomSpan') {
      return deserialize<_iho1msd8.RoomSpan>(data['data']);
    }
    if (dataClassName == 'RoomStreamMessage') {
      return deserialize<_iaev2w2b.RoomStreamMessage>(data['data']);
    }
    if (dataClassName == 'RoomTrace') {
      return deserialize<_i4pvbzt3.RoomTrace>(data['data']);
    }
    if (dataClassName == 'TelemetrySpanDto') {
      return deserialize<_iajwa7li.TelemetrySpanDto>(data['data']);
    }
    if (dataClassName == 'TelemetryTraceDto') {
      return deserialize<_i4z09txt.TelemetryTraceDto>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      return _iais.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(19),
      });
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      return _iacs.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(20),
      });
    }
    if (dataClassName.startsWith('serverpod.')) {
      return _isp.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(10),
      });
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('agentlens_hackathon', this);
    _iacs.Protocol().registerHostProtocol('agentlens_hackathon', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _inu3c563.DebugRoom:
        return _inu3c563.DebugRoom.t;
      case _i0yfkpqw.InvestigationNote:
        return _i0yfkpqw.InvestigationNote.t;
      case _iozwtlrj.RoomFinding:
        return _iozwtlrj.RoomFinding.t;
      case _iw8zamkd.RoomParticipant:
        return _iw8zamkd.RoomParticipant.t;
      case _iho1msd8.RoomSpan:
        return _iho1msd8.RoomSpan.t;
      case _i4pvbzt3.RoomTrace:
        return _i4pvbzt3.RoomTrace.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  List<_isp.TableDefinition> getOwnTableDefinitions() => _ownTableDefinitions;

  @override
  String getModuleName() => 'agentlens_hackathon';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
