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

abstract class RoomTrace
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      startTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      isSample: jsonSerialization['isSample'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isSample']),
    );
  }

  static final t = RoomTraceTable();

  static const db = RoomTraceRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RoomTrace]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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
    DateTime? endTime = const _is.$UndefinedDateTime(),
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

  static RoomTraceInclude include() {
    return RoomTraceInclude._();
  }

  static RoomTraceIncludeList includeList({
    _is.WhereExpressionBuilder<RoomTraceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomTraceTable>? orderBy,
    _is.OrderByListBuilder<RoomTraceTable>? orderByList,
    RoomTraceInclude? include,
  }) {
    return RoomTraceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomTrace.t),
      orderByList: orderByList?.call(RoomTrace.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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
    DateTime? endTime = const _is.$UndefinedDateTime(),
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
      endTime: endTime is _is.UndefinedSentinel ? this.endTime : endTime,
      isSample: isSample ?? this.isSample,
    );
  }
}

class RoomTraceUpdateTable extends _is.UpdateTable<RoomTraceTable> {
  RoomTraceUpdateTable(super.table);

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

  _is.ColumnValue<String, String> agentName(String value) => _is.ColumnValue(
    table.agentName,
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

  _is.ColumnValue<int, int> totalTokens(int value) => _is.ColumnValue(
    table.totalTokens,
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

  _is.ColumnValue<bool, bool> isSample(bool value) => _is.ColumnValue(
    table.isSample,
    value,
  );
}

class RoomTraceTable extends _is.Table<int?> {
  RoomTraceTable({super.tableRelation}) : super(tableName: 'room_trace') {
    updateTable = RoomTraceUpdateTable(this);
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
    agentName = _is.ColumnString(
      'agentName',
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
    totalTokens = _is.ColumnInt(
      'totalTokens',
      this,
      hasDefault: true,
    );
    startTime = _is.ColumnDateTime(
      'startTime',
      this,
    );
    endTime = _is.ColumnDateTime(
      'endTime',
      this,
    );
    isSample = _is.ColumnBool(
      'isSample',
      this,
      hasDefault: true,
    );
  }

  late final RoomTraceUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnString roomCode;

  late final _is.ColumnString traceId;

  late final _is.ColumnString agentName;

  late final _is.ColumnString status;

  late final _is.ColumnInt durationMs;

  late final _is.ColumnInt totalTokens;

  late final _is.ColumnDateTime startTime;

  late final _is.ColumnDateTime endTime;

  late final _is.ColumnBool isSample;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    roomCode,
    traceId,
    agentName,
    status,
    durationMs,
    totalTokens,
    startTime,
    endTime,
    isSample,
  ];
}

class RoomTraceInclude extends _is.IncludeObject {
  RoomTraceInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RoomTrace.t;
}

class RoomTraceIncludeList extends _is.IncludeList {
  RoomTraceIncludeList._({
    _is.WhereExpressionBuilder<RoomTraceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RoomTrace.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RoomTrace.t;
}

class RoomTraceRepository {
  const RoomTraceRepository._();

  /// Returns a list of [RoomTrace]s matching the given query parameters.
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
  Future<List<RoomTrace>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomTraceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomTraceTable>? orderBy,
    _is.OrderByListBuilder<RoomTraceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RoomTrace>(
      where: where?.call(RoomTrace.t),
      orderBy: orderBy?.call(RoomTrace.t),
      orderByList: orderByList?.call(RoomTrace.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [RoomTrace]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `RoomTrace.t`.
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
  _ida.Stream<List<RoomTrace>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomTraceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomTraceTable>? orderBy,
    _is.OrderByListBuilder<RoomTraceTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<RoomTrace>(
      where: where?.call(RoomTrace.t),
      orderBy: orderBy?.call(RoomTrace.t),
      orderByList: orderByList?.call(RoomTrace.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [RoomTrace] matching the given query parameters.
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
  Future<RoomTrace?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomTraceTable>? where,
    int? offset,
    _is.OrderByBuilder<RoomTraceTable>? orderBy,
    _is.OrderByListBuilder<RoomTraceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RoomTrace>(
      where: where?.call(RoomTrace.t),
      orderBy: orderBy?.call(RoomTrace.t),
      orderByList: orderByList?.call(RoomTrace.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RoomTrace] by its [id] or null if no such row exists.
  Future<RoomTrace?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RoomTrace>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RoomTrace]s in the list and returns the inserted rows.
  ///
  /// The returned [RoomTrace]s will have their `id` fields set.
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
  Future<List<RoomTrace>> insert(
    _is.DatabaseSession session,
    List<RoomTrace> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RoomTrace>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RoomTrace] and returns the inserted row.
  ///
  /// The returned [RoomTrace] will have its `id` field set.
  Future<RoomTrace> insertRow(
    _is.DatabaseSession session,
    RoomTrace row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RoomTrace>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RoomTrace]s in the list and returns the resulting rows.
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
  /// The returned [RoomTrace]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomTrace>> upsert(
    _is.DatabaseSession session,
    List<RoomTrace> rows, {
    required _is.ColumnSelections<RoomTraceTable> conflictColumns,
    _is.ColumnSelections<RoomTraceTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomTraceTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RoomTrace>(
      rows,
      conflictColumns: conflictColumns(RoomTrace.t),
      updateColumns: updateColumns?.call(RoomTrace.t),
      updateWhere: updateWhere?.call(RoomTrace.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RoomTrace] and returns the resulting row.
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
  /// The returned [RoomTrace] will have its `id` field set.
  Future<RoomTrace?> upsertRow(
    _is.DatabaseSession session,
    RoomTrace row, {
    required _is.ColumnSelections<RoomTraceTable> conflictColumns,
    _is.ColumnSelections<RoomTraceTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomTraceTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RoomTrace>(
      row,
      conflictColumns: conflictColumns(RoomTrace.t),
      updateColumns: updateColumns?.call(RoomTrace.t),
      updateWhere: updateWhere?.call(RoomTrace.t),
      transaction: transaction,
    );
  }

  /// Updates all [RoomTrace]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomTrace>> update(
    _is.DatabaseSession session,
    List<RoomTrace> rows, {
    _is.ColumnSelections<RoomTraceTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RoomTrace>(
      rows,
      columns: columns?.call(RoomTrace.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RoomTrace]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RoomTrace> updateRow(
    _is.DatabaseSession session,
    RoomTrace row, {
    _is.ColumnSelections<RoomTraceTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RoomTrace>(
      row,
      columns: columns?.call(RoomTrace.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoomTrace] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RoomTrace?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RoomTraceUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RoomTrace>(
      id,
      columnValues: columnValues(RoomTrace.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RoomTrace]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomTrace>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RoomTraceUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RoomTraceTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomTraceTable>? orderBy,
    _is.OrderByListBuilder<RoomTraceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RoomTrace>(
      columnValues: columnValues(RoomTrace.t.updateTable),
      where: where(RoomTrace.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomTrace.t),
      orderByList: orderByList?.call(RoomTrace.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RoomTrace]s in the list and returns the deleted rows.
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
  Future<List<RoomTrace>> delete(
    _is.DatabaseSession session,
    List<RoomTrace> rows, {
    _is.OrderByBuilder<RoomTraceTable>? orderBy,
    _is.OrderByListBuilder<RoomTraceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RoomTrace>(
      rows,
      orderBy: orderBy?.call(RoomTrace.t),
      orderByList: orderByList?.call(RoomTrace.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RoomTrace].
  Future<RoomTrace> deleteRow(
    _is.DatabaseSession session,
    RoomTrace row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RoomTrace>(
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
  Future<List<RoomTrace>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomTraceTable> where,
    _is.OrderByBuilder<RoomTraceTable>? orderBy,
    _is.OrderByListBuilder<RoomTraceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RoomTrace>(
      where: where(RoomTrace.t),
      orderBy: orderBy?.call(RoomTrace.t),
      orderByList: orderByList?.call(RoomTrace.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomTraceTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RoomTrace>(
      where: where?.call(RoomTrace.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RoomTrace] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomTraceTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RoomTrace>(
      where: where(RoomTrace.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
