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

abstract class InvestigationNote
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  InvestigationNote._({
    this.id,
    required this.roomId,
    required this.roomCode,
    this.findingId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory InvestigationNote({
    int? id,
    required int roomId,
    required String roomCode,
    int? findingId,
    required String authorName,
    required String content,
    required DateTime createdAt,
  }) = _InvestigationNoteImpl;

  factory InvestigationNote.fromJson(Map<String, dynamic> jsonSerialization) {
    return InvestigationNote(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      roomCode: jsonSerialization['roomCode'] as String,
      findingId: jsonSerialization['findingId'] as int?,
      authorName: jsonSerialization['authorName'] as String,
      content: jsonSerialization['content'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = InvestigationNoteTable();

  static const db = InvestigationNoteRepository._();

  @override
  int? id;

  int roomId;

  String roomCode;

  int? findingId;

  String authorName;

  String content;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [InvestigationNote]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InvestigationNote copyWith({
    int? id,
    int? roomId,
    String? roomCode,
    int? findingId,
    String? authorName,
    String? content,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InvestigationNote',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      if (findingId != null) 'findingId': findingId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InvestigationNote',
      if (id != null) 'id': id,
      'roomId': roomId,
      'roomCode': roomCode,
      if (findingId != null) 'findingId': findingId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toJson(),
    };
  }

  static InvestigationNoteInclude include() {
    return InvestigationNoteInclude._();
  }

  static InvestigationNoteIncludeList includeList({
    _is.WhereExpressionBuilder<InvestigationNoteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InvestigationNoteTable>? orderBy,
    _is.OrderByListBuilder<InvestigationNoteTable>? orderByList,
    InvestigationNoteInclude? include,
  }) {
    return InvestigationNoteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InvestigationNote.t),
      orderByList: orderByList?.call(InvestigationNote.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InvestigationNoteImpl extends InvestigationNote {
  _InvestigationNoteImpl({
    int? id,
    required int roomId,
    required String roomCode,
    int? findingId,
    required String authorName,
    required String content,
    required DateTime createdAt,
  }) : super._(
         id: id,
         roomId: roomId,
         roomCode: roomCode,
         findingId: findingId,
         authorName: authorName,
         content: content,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [InvestigationNote]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InvestigationNote copyWith({
    Object? id = _Undefined,
    int? roomId,
    String? roomCode,
    Object? findingId = _Undefined,
    String? authorName,
    String? content,
    DateTime? createdAt,
  }) {
    return InvestigationNote(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      findingId: findingId is int? ? findingId : this.findingId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class InvestigationNoteUpdateTable
    extends _is.UpdateTable<InvestigationNoteTable> {
  InvestigationNoteUpdateTable(super.table);

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<String, String> roomCode(String value) => _is.ColumnValue(
    table.roomCode,
    value,
  );

  _is.ColumnValue<int, int> findingId(int? value) => _is.ColumnValue(
    table.findingId,
    value,
  );

  _is.ColumnValue<String, String> authorName(String value) => _is.ColumnValue(
    table.authorName,
    value,
  );

  _is.ColumnValue<String, String> content(String value) => _is.ColumnValue(
    table.content,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class InvestigationNoteTable extends _is.Table<int?> {
  InvestigationNoteTable({super.tableRelation})
    : super(tableName: 'investigation_note') {
    updateTable = InvestigationNoteUpdateTable(this);
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    roomCode = _is.ColumnString(
      'roomCode',
      this,
    );
    findingId = _is.ColumnInt(
      'findingId',
      this,
    );
    authorName = _is.ColumnString(
      'authorName',
      this,
    );
    content = _is.ColumnString(
      'content',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final InvestigationNoteUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnString roomCode;

  late final _is.ColumnInt findingId;

  late final _is.ColumnString authorName;

  late final _is.ColumnString content;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    roomCode,
    findingId,
    authorName,
    content,
    createdAt,
  ];
}

class InvestigationNoteInclude extends _is.IncludeObject {
  InvestigationNoteInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => InvestigationNote.t;
}

class InvestigationNoteIncludeList extends _is.IncludeList {
  InvestigationNoteIncludeList._({
    _is.WhereExpressionBuilder<InvestigationNoteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(InvestigationNote.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => InvestigationNote.t;
}

class InvestigationNoteRepository {
  const InvestigationNoteRepository._();

  /// Returns a list of [InvestigationNote]s matching the given query parameters.
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
  Future<List<InvestigationNote>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InvestigationNoteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InvestigationNoteTable>? orderBy,
    _is.OrderByListBuilder<InvestigationNoteTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<InvestigationNote>(
      where: where?.call(InvestigationNote.t),
      orderBy: orderBy?.call(InvestigationNote.t),
      orderByList: orderByList?.call(InvestigationNote.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [InvestigationNote]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `InvestigationNote.t`.
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
  _ida.Stream<List<InvestigationNote>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InvestigationNoteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InvestigationNoteTable>? orderBy,
    _is.OrderByListBuilder<InvestigationNoteTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<InvestigationNote>(
      where: where?.call(InvestigationNote.t),
      orderBy: orderBy?.call(InvestigationNote.t),
      orderByList: orderByList?.call(InvestigationNote.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [InvestigationNote] matching the given query parameters.
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
  Future<InvestigationNote?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InvestigationNoteTable>? where,
    int? offset,
    _is.OrderByBuilder<InvestigationNoteTable>? orderBy,
    _is.OrderByListBuilder<InvestigationNoteTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<InvestigationNote>(
      where: where?.call(InvestigationNote.t),
      orderBy: orderBy?.call(InvestigationNote.t),
      orderByList: orderByList?.call(InvestigationNote.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [InvestigationNote] by its [id] or null if no such row exists.
  Future<InvestigationNote?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<InvestigationNote>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [InvestigationNote]s in the list and returns the inserted rows.
  ///
  /// The returned [InvestigationNote]s will have their `id` fields set.
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
  Future<List<InvestigationNote>> insert(
    _is.DatabaseSession session,
    List<InvestigationNote> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<InvestigationNote>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [InvestigationNote] and returns the inserted row.
  ///
  /// The returned [InvestigationNote] will have its `id` field set.
  Future<InvestigationNote> insertRow(
    _is.DatabaseSession session,
    InvestigationNote row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<InvestigationNote>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [InvestigationNote]s in the list and returns the resulting rows.
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
  /// The returned [InvestigationNote]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InvestigationNote>> upsert(
    _is.DatabaseSession session,
    List<InvestigationNote> rows, {
    required _is.ColumnSelections<InvestigationNoteTable> conflictColumns,
    _is.ColumnSelections<InvestigationNoteTable>? updateColumns,
    _is.WhereExpressionBuilder<InvestigationNoteTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<InvestigationNote>(
      rows,
      conflictColumns: conflictColumns(InvestigationNote.t),
      updateColumns: updateColumns?.call(InvestigationNote.t),
      updateWhere: updateWhere?.call(InvestigationNote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [InvestigationNote] and returns the resulting row.
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
  /// The returned [InvestigationNote] will have its `id` field set.
  Future<InvestigationNote?> upsertRow(
    _is.DatabaseSession session,
    InvestigationNote row, {
    required _is.ColumnSelections<InvestigationNoteTable> conflictColumns,
    _is.ColumnSelections<InvestigationNoteTable>? updateColumns,
    _is.WhereExpressionBuilder<InvestigationNoteTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<InvestigationNote>(
      row,
      conflictColumns: conflictColumns(InvestigationNote.t),
      updateColumns: updateColumns?.call(InvestigationNote.t),
      updateWhere: updateWhere?.call(InvestigationNote.t),
      transaction: transaction,
    );
  }

  /// Updates all [InvestigationNote]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InvestigationNote>> update(
    _is.DatabaseSession session,
    List<InvestigationNote> rows, {
    _is.ColumnSelections<InvestigationNoteTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<InvestigationNote>(
      rows,
      columns: columns?.call(InvestigationNote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [InvestigationNote]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<InvestigationNote> updateRow(
    _is.DatabaseSession session,
    InvestigationNote row, {
    _is.ColumnSelections<InvestigationNoteTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<InvestigationNote>(
      row,
      columns: columns?.call(InvestigationNote.t),
      transaction: transaction,
    );
  }

  /// Updates a single [InvestigationNote] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<InvestigationNote?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<InvestigationNoteUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<InvestigationNote>(
      id,
      columnValues: columnValues(InvestigationNote.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [InvestigationNote]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InvestigationNote>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<InvestigationNoteUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<InvestigationNoteTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InvestigationNoteTable>? orderBy,
    _is.OrderByListBuilder<InvestigationNoteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<InvestigationNote>(
      columnValues: columnValues(InvestigationNote.t.updateTable),
      where: where(InvestigationNote.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InvestigationNote.t),
      orderByList: orderByList?.call(InvestigationNote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [InvestigationNote]s in the list and returns the deleted rows.
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
  Future<List<InvestigationNote>> delete(
    _is.DatabaseSession session,
    List<InvestigationNote> rows, {
    _is.OrderByBuilder<InvestigationNoteTable>? orderBy,
    _is.OrderByListBuilder<InvestigationNoteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<InvestigationNote>(
      rows,
      orderBy: orderBy?.call(InvestigationNote.t),
      orderByList: orderByList?.call(InvestigationNote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [InvestigationNote].
  Future<InvestigationNote> deleteRow(
    _is.DatabaseSession session,
    InvestigationNote row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<InvestigationNote>(
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
  Future<List<InvestigationNote>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InvestigationNoteTable> where,
    _is.OrderByBuilder<InvestigationNoteTable>? orderBy,
    _is.OrderByListBuilder<InvestigationNoteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<InvestigationNote>(
      where: where(InvestigationNote.t),
      orderBy: orderBy?.call(InvestigationNote.t),
      orderByList: orderByList?.call(InvestigationNote.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InvestigationNoteTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<InvestigationNote>(
      where: where?.call(InvestigationNote.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [InvestigationNote] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InvestigationNoteTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<InvestigationNote>(
      where: where(InvestigationNote.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
