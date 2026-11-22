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

abstract class DebugRoom
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DebugRoom._({
    this.id,
    required this.roomCode,
    required this.name,
    required this.createdBy,
    required this.ingestTokenHash,
    required this.createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  }) : currentSequenceNumber = currentSequenceNumber ?? 0,
       isActive = isActive ?? true;

  factory DebugRoom({
    int? id,
    required String roomCode,
    required String name,
    required String createdBy,
    required String ingestTokenHash,
    required DateTime createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  }) = _DebugRoomImpl;

  factory DebugRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return DebugRoom(
      id: jsonSerialization['id'] as int?,
      roomCode: jsonSerialization['roomCode'] as String,
      name: jsonSerialization['name'] as String,
      createdBy: jsonSerialization['createdBy'] as String,
      ingestTokenHash: jsonSerialization['ingestTokenHash'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      currentSequenceNumber: jsonSerialization['currentSequenceNumber'] as int?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  static final t = DebugRoomTable();

  static const db = DebugRoomRepository._();

  @override
  int? id;

  String roomCode;

  String name;

  String createdBy;

  String ingestTokenHash;

  DateTime createdAt;

  int currentSequenceNumber;

  bool isActive;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DebugRoom]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DebugRoom copyWith({
    int? id,
    String? roomCode,
    String? name,
    String? createdBy,
    String? ingestTokenHash,
    DateTime? createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DebugRoom',
      if (id != null) 'id': id,
      'roomCode': roomCode,
      'name': name,
      'createdBy': createdBy,
      'ingestTokenHash': ingestTokenHash,
      'createdAt': createdAt.toJson(),
      'currentSequenceNumber': currentSequenceNumber,
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DebugRoom',
      if (id != null) 'id': id,
      'roomCode': roomCode,
      'name': name,
      'createdBy': createdBy,
      'ingestTokenHash': ingestTokenHash,
      'createdAt': createdAt.toJson(),
      'currentSequenceNumber': currentSequenceNumber,
      'isActive': isActive,
    };
  }

  static DebugRoomInclude include() {
    return DebugRoomInclude._();
  }

  static DebugRoomIncludeList includeList({
    _is.WhereExpressionBuilder<DebugRoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebugRoomTable>? orderBy,
    _is.OrderByListBuilder<DebugRoomTable>? orderByList,
    DebugRoomInclude? include,
  }) {
    return DebugRoomIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DebugRoom.t),
      orderByList: orderByList?.call(DebugRoom.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DebugRoomImpl extends DebugRoom {
  _DebugRoomImpl({
    int? id,
    required String roomCode,
    required String name,
    required String createdBy,
    required String ingestTokenHash,
    required DateTime createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  }) : super._(
         id: id,
         roomCode: roomCode,
         name: name,
         createdBy: createdBy,
         ingestTokenHash: ingestTokenHash,
         createdAt: createdAt,
         currentSequenceNumber: currentSequenceNumber,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [DebugRoom]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DebugRoom copyWith({
    Object? id = _Undefined,
    String? roomCode,
    String? name,
    String? createdBy,
    String? ingestTokenHash,
    DateTime? createdAt,
    int? currentSequenceNumber,
    bool? isActive,
  }) {
    return DebugRoom(
      id: id is int? ? id : this.id,
      roomCode: roomCode ?? this.roomCode,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      ingestTokenHash: ingestTokenHash ?? this.ingestTokenHash,
      createdAt: createdAt ?? this.createdAt,
      currentSequenceNumber:
          currentSequenceNumber ?? this.currentSequenceNumber,
      isActive: isActive ?? this.isActive,
    );
  }
}

class DebugRoomUpdateTable extends _is.UpdateTable<DebugRoomTable> {
  DebugRoomUpdateTable(super.table);

  _is.ColumnValue<String, String> roomCode(String value) => _is.ColumnValue(
    table.roomCode,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> createdBy(String value) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<String, String> ingestTokenHash(String value) =>
      _is.ColumnValue(
        table.ingestTokenHash,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<int, int> currentSequenceNumber(int value) => _is.ColumnValue(
    table.currentSequenceNumber,
    value,
  );

  _is.ColumnValue<bool, bool> isActive(bool value) => _is.ColumnValue(
    table.isActive,
    value,
  );
}

class DebugRoomTable extends _is.Table<int?> {
  DebugRoomTable({super.tableRelation}) : super(tableName: 'debug_room') {
    updateTable = DebugRoomUpdateTable(this);
    roomCode = _is.ColumnString(
      'roomCode',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    createdBy = _is.ColumnString(
      'createdBy',
      this,
    );
    ingestTokenHash = _is.ColumnString(
      'ingestTokenHash',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    currentSequenceNumber = _is.ColumnInt(
      'currentSequenceNumber',
      this,
      hasDefault: true,
    );
    isActive = _is.ColumnBool(
      'isActive',
      this,
      hasDefault: true,
    );
  }

  late final DebugRoomUpdateTable updateTable;

  late final _is.ColumnString roomCode;

  late final _is.ColumnString name;

  late final _is.ColumnString createdBy;

  late final _is.ColumnString ingestTokenHash;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnInt currentSequenceNumber;

  late final _is.ColumnBool isActive;

  @override
  List<_is.Column> get columns => [
    id,
    roomCode,
    name,
    createdBy,
    ingestTokenHash,
    createdAt,
    currentSequenceNumber,
    isActive,
  ];
}

class DebugRoomInclude extends _is.IncludeObject {
  DebugRoomInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DebugRoom.t;
}

class DebugRoomIncludeList extends _is.IncludeList {
  DebugRoomIncludeList._({
    _is.WhereExpressionBuilder<DebugRoomTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DebugRoom.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DebugRoom.t;
}

class DebugRoomRepository {
  const DebugRoomRepository._();

  /// Returns a list of [DebugRoom]s matching the given query parameters.
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
  Future<List<DebugRoom>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebugRoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebugRoomTable>? orderBy,
    _is.OrderByListBuilder<DebugRoomTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DebugRoom>(
      where: where?.call(DebugRoom.t),
      orderBy: orderBy?.call(DebugRoom.t),
      orderByList: orderByList?.call(DebugRoom.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DebugRoom]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DebugRoom.t`.
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
  _ida.Stream<List<DebugRoom>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebugRoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebugRoomTable>? orderBy,
    _is.OrderByListBuilder<DebugRoomTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DebugRoom>(
      where: where?.call(DebugRoom.t),
      orderBy: orderBy?.call(DebugRoom.t),
      orderByList: orderByList?.call(DebugRoom.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DebugRoom] matching the given query parameters.
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
  Future<DebugRoom?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebugRoomTable>? where,
    int? offset,
    _is.OrderByBuilder<DebugRoomTable>? orderBy,
    _is.OrderByListBuilder<DebugRoomTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DebugRoom>(
      where: where?.call(DebugRoom.t),
      orderBy: orderBy?.call(DebugRoom.t),
      orderByList: orderByList?.call(DebugRoom.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DebugRoom] by its [id] or null if no such row exists.
  Future<DebugRoom?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DebugRoom>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DebugRoom]s in the list and returns the inserted rows.
  ///
  /// The returned [DebugRoom]s will have their `id` fields set.
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
  Future<List<DebugRoom>> insert(
    _is.DatabaseSession session,
    List<DebugRoom> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DebugRoom>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DebugRoom] and returns the inserted row.
  ///
  /// The returned [DebugRoom] will have its `id` field set.
  Future<DebugRoom> insertRow(
    _is.DatabaseSession session,
    DebugRoom row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DebugRoom>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DebugRoom]s in the list and returns the resulting rows.
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
  /// The returned [DebugRoom]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebugRoom>> upsert(
    _is.DatabaseSession session,
    List<DebugRoom> rows, {
    required _is.ColumnSelections<DebugRoomTable> conflictColumns,
    _is.ColumnSelections<DebugRoomTable>? updateColumns,
    _is.WhereExpressionBuilder<DebugRoomTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DebugRoom>(
      rows,
      conflictColumns: conflictColumns(DebugRoom.t),
      updateColumns: updateColumns?.call(DebugRoom.t),
      updateWhere: updateWhere?.call(DebugRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DebugRoom] and returns the resulting row.
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
  /// The returned [DebugRoom] will have its `id` field set.
  Future<DebugRoom?> upsertRow(
    _is.DatabaseSession session,
    DebugRoom row, {
    required _is.ColumnSelections<DebugRoomTable> conflictColumns,
    _is.ColumnSelections<DebugRoomTable>? updateColumns,
    _is.WhereExpressionBuilder<DebugRoomTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DebugRoom>(
      row,
      conflictColumns: conflictColumns(DebugRoom.t),
      updateColumns: updateColumns?.call(DebugRoom.t),
      updateWhere: updateWhere?.call(DebugRoom.t),
      transaction: transaction,
    );
  }

  /// Updates all [DebugRoom]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebugRoom>> update(
    _is.DatabaseSession session,
    List<DebugRoom> rows, {
    _is.ColumnSelections<DebugRoomTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DebugRoom>(
      rows,
      columns: columns?.call(DebugRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DebugRoom]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DebugRoom> updateRow(
    _is.DatabaseSession session,
    DebugRoom row, {
    _is.ColumnSelections<DebugRoomTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DebugRoom>(
      row,
      columns: columns?.call(DebugRoom.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DebugRoom] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DebugRoom?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DebugRoomUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DebugRoom>(
      id,
      columnValues: columnValues(DebugRoom.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DebugRoom]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebugRoom>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DebugRoomUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DebugRoomTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebugRoomTable>? orderBy,
    _is.OrderByListBuilder<DebugRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DebugRoom>(
      columnValues: columnValues(DebugRoom.t.updateTable),
      where: where(DebugRoom.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DebugRoom.t),
      orderByList: orderByList?.call(DebugRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DebugRoom]s in the list and returns the deleted rows.
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
  Future<List<DebugRoom>> delete(
    _is.DatabaseSession session,
    List<DebugRoom> rows, {
    _is.OrderByBuilder<DebugRoomTable>? orderBy,
    _is.OrderByListBuilder<DebugRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DebugRoom>(
      rows,
      orderBy: orderBy?.call(DebugRoom.t),
      orderByList: orderByList?.call(DebugRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DebugRoom].
  Future<DebugRoom> deleteRow(
    _is.DatabaseSession session,
    DebugRoom row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DebugRoom>(
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
  Future<List<DebugRoom>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DebugRoomTable> where,
    _is.OrderByBuilder<DebugRoomTable>? orderBy,
    _is.OrderByListBuilder<DebugRoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DebugRoom>(
      where: where(DebugRoom.t),
      orderBy: orderBy?.call(DebugRoom.t),
      orderByList: orderByList?.call(DebugRoom.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebugRoomTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DebugRoom>(
      where: where?.call(DebugRoom.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DebugRoom] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DebugRoomTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DebugRoom>(
      where: where(DebugRoom.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
