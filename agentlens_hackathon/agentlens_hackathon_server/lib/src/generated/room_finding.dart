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

abstract class RoomFinding
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      detectedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['detectedAt'],
      ),
      isSample: jsonSerialization['isSample'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isSample']),
    );
  }

  static final t = RoomFindingTable();

  static const db = RoomFindingRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RoomFinding]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static RoomFindingInclude include() {
    return RoomFindingInclude._();
  }

  static RoomFindingIncludeList includeList({
    _is.WhereExpressionBuilder<RoomFindingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomFindingTable>? orderBy,
    _is.OrderByListBuilder<RoomFindingTable>? orderByList,
    RoomFindingInclude? include,
  }) {
    return RoomFindingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomFinding.t),
      orderByList: orderByList?.call(RoomFinding.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class RoomFindingUpdateTable extends _is.UpdateTable<RoomFindingTable> {
  RoomFindingUpdateTable(super.table);

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

  _is.ColumnValue<String, String> spanId(String? value) => _is.ColumnValue(
    table.spanId,
    value,
  );

  _is.ColumnValue<String, String> spanName(String? value) => _is.ColumnValue(
    table.spanName,
    value,
  );

  _is.ColumnValue<String, String> ruleType(String value) => _is.ColumnValue(
    table.ruleType,
    value,
  );

  _is.ColumnValue<String, String> severity(String value) => _is.ColumnValue(
    table.severity,
    value,
  );

  _is.ColumnValue<String, String> summary(String value) => _is.ColumnValue(
    table.summary,
    value,
  );

  _is.ColumnValue<String, String> evidenceSummary(String value) =>
      _is.ColumnValue(
        table.evidenceSummary,
        value,
      );

  _is.ColumnValue<String, String> evidenceDataJson(String? value) =>
      _is.ColumnValue(
        table.evidenceDataJson,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> detectedAt(DateTime value) =>
      _is.ColumnValue(
        table.detectedAt,
        value,
      );

  _is.ColumnValue<bool, bool> isSample(bool value) => _is.ColumnValue(
    table.isSample,
    value,
  );
}

class RoomFindingTable extends _is.Table<int?> {
  RoomFindingTable({super.tableRelation}) : super(tableName: 'room_finding') {
    updateTable = RoomFindingUpdateTable(this);
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
    spanName = _is.ColumnString(
      'spanName',
      this,
    );
    ruleType = _is.ColumnString(
      'ruleType',
      this,
    );
    severity = _is.ColumnString(
      'severity',
      this,
    );
    summary = _is.ColumnString(
      'summary',
      this,
    );
    evidenceSummary = _is.ColumnString(
      'evidenceSummary',
      this,
    );
    evidenceDataJson = _is.ColumnString(
      'evidenceDataJson',
      this,
    );
    detectedAt = _is.ColumnDateTime(
      'detectedAt',
      this,
    );
    isSample = _is.ColumnBool(
      'isSample',
      this,
      hasDefault: true,
    );
  }

  late final RoomFindingUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnString roomCode;

  late final _is.ColumnString traceId;

  late final _is.ColumnString spanId;

  late final _is.ColumnString spanName;

  late final _is.ColumnString ruleType;

  late final _is.ColumnString severity;

  late final _is.ColumnString summary;

  late final _is.ColumnString evidenceSummary;

  late final _is.ColumnString evidenceDataJson;

  late final _is.ColumnDateTime detectedAt;

  late final _is.ColumnBool isSample;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    roomCode,
    traceId,
    spanId,
    spanName,
    ruleType,
    severity,
    summary,
    evidenceSummary,
    evidenceDataJson,
    detectedAt,
    isSample,
  ];
}

class RoomFindingInclude extends _is.IncludeObject {
  RoomFindingInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RoomFinding.t;
}

class RoomFindingIncludeList extends _is.IncludeList {
  RoomFindingIncludeList._({
    _is.WhereExpressionBuilder<RoomFindingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RoomFinding.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RoomFinding.t;
}

class RoomFindingRepository {
  const RoomFindingRepository._();

  /// Returns a list of [RoomFinding]s matching the given query parameters.
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
  Future<List<RoomFinding>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomFindingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomFindingTable>? orderBy,
    _is.OrderByListBuilder<RoomFindingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RoomFinding>(
      where: where?.call(RoomFinding.t),
      orderBy: orderBy?.call(RoomFinding.t),
      orderByList: orderByList?.call(RoomFinding.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [RoomFinding]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `RoomFinding.t`.
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
  _ida.Stream<List<RoomFinding>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomFindingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomFindingTable>? orderBy,
    _is.OrderByListBuilder<RoomFindingTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<RoomFinding>(
      where: where?.call(RoomFinding.t),
      orderBy: orderBy?.call(RoomFinding.t),
      orderByList: orderByList?.call(RoomFinding.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [RoomFinding] matching the given query parameters.
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
  Future<RoomFinding?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomFindingTable>? where,
    int? offset,
    _is.OrderByBuilder<RoomFindingTable>? orderBy,
    _is.OrderByListBuilder<RoomFindingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RoomFinding>(
      where: where?.call(RoomFinding.t),
      orderBy: orderBy?.call(RoomFinding.t),
      orderByList: orderByList?.call(RoomFinding.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RoomFinding] by its [id] or null if no such row exists.
  Future<RoomFinding?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RoomFinding>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RoomFinding]s in the list and returns the inserted rows.
  ///
  /// The returned [RoomFinding]s will have their `id` fields set.
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
  Future<List<RoomFinding>> insert(
    _is.DatabaseSession session,
    List<RoomFinding> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RoomFinding>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RoomFinding] and returns the inserted row.
  ///
  /// The returned [RoomFinding] will have its `id` field set.
  Future<RoomFinding> insertRow(
    _is.DatabaseSession session,
    RoomFinding row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RoomFinding>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RoomFinding]s in the list and returns the resulting rows.
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
  /// The returned [RoomFinding]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomFinding>> upsert(
    _is.DatabaseSession session,
    List<RoomFinding> rows, {
    required _is.ColumnSelections<RoomFindingTable> conflictColumns,
    _is.ColumnSelections<RoomFindingTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomFindingTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RoomFinding>(
      rows,
      conflictColumns: conflictColumns(RoomFinding.t),
      updateColumns: updateColumns?.call(RoomFinding.t),
      updateWhere: updateWhere?.call(RoomFinding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RoomFinding] and returns the resulting row.
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
  /// The returned [RoomFinding] will have its `id` field set.
  Future<RoomFinding?> upsertRow(
    _is.DatabaseSession session,
    RoomFinding row, {
    required _is.ColumnSelections<RoomFindingTable> conflictColumns,
    _is.ColumnSelections<RoomFindingTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomFindingTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RoomFinding>(
      row,
      conflictColumns: conflictColumns(RoomFinding.t),
      updateColumns: updateColumns?.call(RoomFinding.t),
      updateWhere: updateWhere?.call(RoomFinding.t),
      transaction: transaction,
    );
  }

  /// Updates all [RoomFinding]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomFinding>> update(
    _is.DatabaseSession session,
    List<RoomFinding> rows, {
    _is.ColumnSelections<RoomFindingTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RoomFinding>(
      rows,
      columns: columns?.call(RoomFinding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RoomFinding]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RoomFinding> updateRow(
    _is.DatabaseSession session,
    RoomFinding row, {
    _is.ColumnSelections<RoomFindingTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RoomFinding>(
      row,
      columns: columns?.call(RoomFinding.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoomFinding] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RoomFinding?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RoomFindingUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RoomFinding>(
      id,
      columnValues: columnValues(RoomFinding.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RoomFinding]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RoomFinding>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RoomFindingUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RoomFindingTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomFindingTable>? orderBy,
    _is.OrderByListBuilder<RoomFindingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RoomFinding>(
      columnValues: columnValues(RoomFinding.t.updateTable),
      where: where(RoomFinding.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomFinding.t),
      orderByList: orderByList?.call(RoomFinding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RoomFinding]s in the list and returns the deleted rows.
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
  Future<List<RoomFinding>> delete(
    _is.DatabaseSession session,
    List<RoomFinding> rows, {
    _is.OrderByBuilder<RoomFindingTable>? orderBy,
    _is.OrderByListBuilder<RoomFindingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RoomFinding>(
      rows,
      orderBy: orderBy?.call(RoomFinding.t),
      orderByList: orderByList?.call(RoomFinding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RoomFinding].
  Future<RoomFinding> deleteRow(
    _is.DatabaseSession session,
    RoomFinding row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RoomFinding>(
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
  Future<List<RoomFinding>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomFindingTable> where,
    _is.OrderByBuilder<RoomFindingTable>? orderBy,
    _is.OrderByListBuilder<RoomFindingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RoomFinding>(
      where: where(RoomFinding.t),
      orderBy: orderBy?.call(RoomFinding.t),
      orderByList: orderByList?.call(RoomFinding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomFindingTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RoomFinding>(
      where: where?.call(RoomFinding.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RoomFinding] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomFindingTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RoomFinding>(
      where: where(RoomFinding.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
