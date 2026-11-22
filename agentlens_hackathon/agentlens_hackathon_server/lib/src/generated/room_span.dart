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
import 'dart:async' as _ida;
import 'package:serverpod/serverpod.dart' as _is;

abstract class RoomSpan
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      startTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
    );
  }

  static final t = RoomSpanTable();

  static const db = RoomSpanRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RoomSpan]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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
    DateTime? endTime = const _is.$UndefinedDateTime(),
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

  static RoomSpanInclude include() {
    return RoomSpanInclude._();
  }

  static RoomSpanIncludeList includeList({
    _is.WhereExpressionBuilder<RoomSpanTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomSpanTable>? orderBy,
    _is.OrderByListBuilder<RoomSpanTable>? orderByList,
    RoomSpanInclude? include,
  }) {
    return RoomSpanIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomSpan.t),
      orderByList: orderByList?.call(RoomSpan.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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
    DateTime? endTime = const _is.$UndefinedDateTime(),
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
      endTime: endTime is _is.UndefinedSentinel ? this.endTime : endTime,
    );
  }
}

class RoomSpanUpdateTable extends _is.UpdateTable<RoomSpanTable> {
  RoomSpanUpdateTable(super.table);

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<String, String> roomCode(String value) => _is.ColumnValue(
    table.roomCode,
    value,
  );

  _is.ColumnValue<String, String> traceId(String value) => _is.ColumnValue(
    table.traceId,
    value,
  );

  _is.ColumnValue<String, String> spanId(String value) => _is.ColumnValue(
    table.spanId,
    value,
  );

  _is.ColumnValue<String, String> parentSpanId(String? value) =>
      _is.ColumnValue(
        table.parentSpanId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> spanType(String value) => _is.ColumnValue(
    table.spanType,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> durationMs(int value) => _is.ColumnValue(
    table.durationMs,
    value,
  );

  _is.ColumnValue<String, String> inputPayloadJson(String? value) =>
      _is.ColumnValue(
        table.inputPayloadJson,
        value,
      );

  _is.ColumnValue<String, String> outputPayloadJson(String? value) =>
      _is.ColumnValue(
        table.outputPayloadJson,
        value,
      );

  _is.ColumnValue<String, String> errorMessage(String? value) =>
      _is.ColumnValue(
        table.errorMessage,
        value,
      );

  _is.ColumnValue<String, String> errorType(String? value) => _is.ColumnValue(
    table.errorType,
    value,
  );

  _is.ColumnValue<String, String> errorStack(String? value) => _is.ColumnValue(
    table.errorStack,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> startTime(DateTime value) =>
      _is.ColumnValue(
        table.startTime,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> endTime(DateTime? value) =>
      _is.ColumnValue(
        table.endTime,
        value,
      );
}

class RoomSpanTable extends _is.Table<int?> {
  RoomSpanTable({super.tableRelation}) : super(tableName: 'room_span') {
    updateTable = RoomSpanUpdateTable(this);
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    roomCode = _is.ColumnString(
      'roomCode',
      this,
    );
    traceId = _is.ColumnString(
      'traceId',
      this,
    );
    spanId = _is.ColumnString(
      'spanId',
      this,
    );
    parentSpanId = _is.ColumnString(
      'parentSpanId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    spanType = _is.ColumnString(
      'spanType',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    durationMs = _is.ColumnInt(
      'durationMs',
      this,
    );
    inputPayloadJson = _is.ColumnString(
      'inputPayloadJson',
      this,
    );
    outputPayloadJson = _is.ColumnString(
      'outputPayloadJson',
      this,
    );
    errorMessage = _is.ColumnString(
      'errorMessage',
      this,
    );
    errorType = _is.ColumnString(
      'errorType',
      this,
    );
    errorStack = _is.ColumnString(
      'errorStack',
      this,
    );
    startTime = _is.ColumnDateTime(
      'startTime',
      this,
    );
    endTime = _is.ColumnDateTime(
      'endTime',
      this,
    );
  }

  late final RoomSpanUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnString roomCode;

  late final _is.ColumnString traceId;

  late final _is.ColumnString spanId;

  late final _is.ColumnString parentSpanId;

  late final _is.ColumnString name;

  late final _is.ColumnString spanType;

  late final _is.ColumnString status;

  late final _is.ColumnInt durationMs;

  late final _is.ColumnString inputPayloadJson;

  late final _is.ColumnString outputPayloadJson;

  late final _is.ColumnString errorMessage;

  late final _is.ColumnString errorType;

  late final _is.ColumnString errorStack;

  late final _is.ColumnDateTime startTime;

  late final _is.ColumnDateTime endTime;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    roomCode,
    traceId,
    spanId,
    parentSpanId,
    name,
    spanType,
    status,
    durationMs,
    inputPayloadJson,
    outputPayloadJson,
    errorMessage,
    errorType,
    errorStack,
    startTime,
    endTime,
  ];
}

class RoomSpanInclude extends _is.IncludeObject {
  RoomSpanInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RoomSpan.t;
}

class RoomSpanIncludeList extends _is.IncludeList {
  RoomSpanIncludeList._({
    _is.WhereExpressionBuilder<RoomSpanTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RoomSpan.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RoomSpan.t;
}

class RoomSpanRepository {
  const RoomSpanRepository._();

  /// Returns a list of [RoomSpan]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<RoomSpan>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomSpanTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomSpanTable>? orderBy,
    _is.OrderByListBuilder<RoomSpanTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RoomSpan>(
      where: where?.call(RoomSpan.t),
      orderBy: orderBy?.call(RoomSpan.t),
      orderByList: orderByList?.call(RoomSpan.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [RoomSpan]s matching the given query parameters every time the
  /// source tables are modified.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `RoomSpan.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<RoomSpan>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomSpanTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomSpanTable>? orderBy,
    _is.OrderByListBuilder<RoomSpanTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<RoomSpan>(
      where: where?.call(RoomSpan.t),
      orderBy: orderBy?.call(RoomSpan.t),
      orderByList: orderByList?.call(RoomSpan.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [RoomSpan] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<RoomSpan?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomSpanTable>? where,
    int? offset,
    _is.OrderByBuilder<RoomSpanTable>? orderBy,
    _is.OrderByListBuilder<RoomSpanTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RoomSpan>(
      where: where?.call(RoomSpan.t),
      orderBy: orderBy?.call(RoomSpan.t),
      orderByList: orderByList?.call(RoomSpan.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RoomSpan] by its [id] or null if no such row exists.
  Future<RoomSpan?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RoomSpan>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RoomSpan]s in the list and returns the inserted rows.
  ///
  /// The returned [RoomSpan]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomSpan>> insert(
    _is.DatabaseSession session,
    List<RoomSpan> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RoomSpan>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RoomSpan] and returns the inserted row.
  ///
  /// The returned [RoomSpan] will have its `id` field set.
  Future<RoomSpan> insertRow(
    _is.DatabaseSession session,
    RoomSpan row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RoomSpan>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RoomSpan]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [RoomSpan]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomSpan>> upsert(
    _is.DatabaseSession session,
    List<RoomSpan> rows, {
    required _is.ColumnSelections<RoomSpanTable> conflictColumns,
    _is.ColumnSelections<RoomSpanTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomSpanTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RoomSpan>(
      rows,
      conflictColumns: conflictColumns(RoomSpan.t),
      updateColumns: updateColumns?.call(RoomSpan.t),
      updateWhere: updateWhere?.call(RoomSpan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RoomSpan] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [RoomSpan] will have its `id` field set.
  Future<RoomSpan?> upsertRow(
    _is.DatabaseSession session,
    RoomSpan row, {
    required _is.ColumnSelections<RoomSpanTable> conflictColumns,
    _is.ColumnSelections<RoomSpanTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomSpanTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RoomSpan>(
      row,
      conflictColumns: conflictColumns(RoomSpan.t),
      updateColumns: updateColumns?.call(RoomSpan.t),
      updateWhere: updateWhere?.call(RoomSpan.t),
      transaction: transaction,
    );
  }

  /// Updates all [RoomSpan]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomSpan>> update(
    _is.DatabaseSession session,
    List<RoomSpan> rows, {
    _is.ColumnSelections<RoomSpanTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RoomSpan>(
      rows,
      columns: columns?.call(RoomSpan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RoomSpan]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RoomSpan> updateRow(
    _is.DatabaseSession session,
    RoomSpan row, {
    _is.ColumnSelections<RoomSpanTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RoomSpan>(
      row,
      columns: columns?.call(RoomSpan.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoomSpan] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RoomSpan?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RoomSpanUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RoomSpan>(
      id,
      columnValues: columnValues(RoomSpan.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RoomSpan]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomSpan>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RoomSpanUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RoomSpanTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomSpanTable>? orderBy,
    _is.OrderByListBuilder<RoomSpanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RoomSpan>(
      columnValues: columnValues(RoomSpan.t.updateTable),
      where: where(RoomSpan.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomSpan.t),
      orderByList: orderByList?.call(RoomSpan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RoomSpan]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomSpan>> delete(
    _is.DatabaseSession session,
    List<RoomSpan> rows, {
    _is.OrderByBuilder<RoomSpanTable>? orderBy,
    _is.OrderByListBuilder<RoomSpanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RoomSpan>(
      rows,
      orderBy: orderBy?.call(RoomSpan.t),
      orderByList: orderByList?.call(RoomSpan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RoomSpan].
  Future<RoomSpan> deleteRow(
    _is.DatabaseSession session,
    RoomSpan row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RoomSpan>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomSpan>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomSpanTable> where,
    _is.OrderByBuilder<RoomSpanTable>? orderBy,
    _is.OrderByListBuilder<RoomSpanTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RoomSpan>(
      where: where(RoomSpan.t),
      orderBy: orderBy?.call(RoomSpan.t),
      orderByList: orderByList?.call(RoomSpan.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomSpanTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RoomSpan>(
      where: where?.call(RoomSpan.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RoomSpan] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomSpanTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RoomSpan>(
      where: where(RoomSpan.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
