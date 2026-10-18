// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReviewedScreenshotsTable extends ReviewedScreenshots
    with TableInfo<$ReviewedScreenshotsTable, ReviewedScreenshotRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewedScreenshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _reviewStateMeta =
      const VerificationMeta('reviewState');
  @override
  late final GeneratedColumn<String> reviewState = GeneratedColumn<String>(
      'review_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<int> reviewedAt = GeneratedColumn<int>(
      'reviewed_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, assetId, reviewState, reviewedAt, sessionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reviewed_screenshots';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReviewedScreenshotRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('review_state')) {
      context.handle(
          _reviewStateMeta,
          reviewState.isAcceptableOrUnknown(
              data['review_state']!, _reviewStateMeta));
    } else if (isInserting) {
      context.missing(_reviewStateMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {assetId},
      ];
  @override
  ReviewedScreenshotRecord map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewedScreenshotRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      reviewState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}review_state'])!,
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reviewed_at'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
    );
  }

  @override
  $ReviewedScreenshotsTable createAlias(String alias) {
    return $ReviewedScreenshotsTable(attachedDatabase, alias);
  }
}

class ReviewedScreenshotRecord extends DataClass
    implements Insertable<ReviewedScreenshotRecord> {
  final int id;
  final String assetId;
  final String reviewState;
  final int reviewedAt;
  final String sessionId;
  const ReviewedScreenshotRecord(
      {required this.id,
      required this.assetId,
      required this.reviewState,
      required this.reviewedAt,
      required this.sessionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['review_state'] = Variable<String>(reviewState);
    map['reviewed_at'] = Variable<int>(reviewedAt);
    map['session_id'] = Variable<String>(sessionId);
    return map;
  }

  ReviewedScreenshotsCompanion toCompanion(bool nullToAbsent) {
    return ReviewedScreenshotsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      reviewState: Value(reviewState),
      reviewedAt: Value(reviewedAt),
      sessionId: Value(sessionId),
    );
  }

  factory ReviewedScreenshotRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewedScreenshotRecord(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      reviewState: serializer.fromJson<String>(json['reviewState']),
      reviewedAt: serializer.fromJson<int>(json['reviewedAt']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<String>(assetId),
      'reviewState': serializer.toJson<String>(reviewState),
      'reviewedAt': serializer.toJson<int>(reviewedAt),
      'sessionId': serializer.toJson<String>(sessionId),
    };
  }

  ReviewedScreenshotRecord copyWith(
          {int? id,
          String? assetId,
          String? reviewState,
          int? reviewedAt,
          String? sessionId}) =>
      ReviewedScreenshotRecord(
        id: id ?? this.id,
        assetId: assetId ?? this.assetId,
        reviewState: reviewState ?? this.reviewState,
        reviewedAt: reviewedAt ?? this.reviewedAt,
        sessionId: sessionId ?? this.sessionId,
      );
  ReviewedScreenshotRecord copyWithCompanion(
      ReviewedScreenshotsCompanion data) {
    return ReviewedScreenshotRecord(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      reviewState:
          data.reviewState.present ? data.reviewState.value : this.reviewState,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewedScreenshotRecord(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('reviewState: $reviewState, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, assetId, reviewState, reviewedAt, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewedScreenshotRecord &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.reviewState == this.reviewState &&
          other.reviewedAt == this.reviewedAt &&
          other.sessionId == this.sessionId);
}

class ReviewedScreenshotsCompanion
    extends UpdateCompanion<ReviewedScreenshotRecord> {
  final Value<int> id;
  final Value<String> assetId;
  final Value<String> reviewState;
  final Value<int> reviewedAt;
  final Value<String> sessionId;
  const ReviewedScreenshotsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.reviewState = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
  });
  ReviewedScreenshotsCompanion.insert({
    this.id = const Value.absent(),
    required String assetId,
    required String reviewState,
    required int reviewedAt,
    required String sessionId,
  })  : assetId = Value(assetId),
        reviewState = Value(reviewState),
        reviewedAt = Value(reviewedAt),
        sessionId = Value(sessionId);
  static Insertable<ReviewedScreenshotRecord> custom({
    Expression<int>? id,
    Expression<String>? assetId,
    Expression<String>? reviewState,
    Expression<int>? reviewedAt,
    Expression<String>? sessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (reviewState != null) 'review_state': reviewState,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (sessionId != null) 'session_id': sessionId,
    });
  }

  ReviewedScreenshotsCompanion copyWith(
      {Value<int>? id,
      Value<String>? assetId,
      Value<String>? reviewState,
      Value<int>? reviewedAt,
      Value<String>? sessionId}) {
    return ReviewedScreenshotsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      reviewState: reviewState ?? this.reviewState,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (reviewState.present) {
      map['review_state'] = Variable<String>(reviewState.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<int>(reviewedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewedScreenshotsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('reviewState: $reviewState, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }
}

class $ReviewHistoryTable extends ReviewHistory
    with TableInfo<$ReviewHistoryTable, ReviewHistoryRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previousStateMeta =
      const VerificationMeta('previousState');
  @override
  late final GeneratedColumn<String> previousState = GeneratedColumn<String>(
      'previous_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _newStateMeta =
      const VerificationMeta('newState');
  @override
  late final GeneratedColumn<String> newState = GeneratedColumn<String>(
      'new_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionTimestampMeta =
      const VerificationMeta('actionTimestamp');
  @override
  late final GeneratedColumn<int> actionTimestamp = GeneratedColumn<int>(
      'action_timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, assetId, previousState, newState, sessionId, actionTimestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_history';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReviewHistoryRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('previous_state')) {
      context.handle(
          _previousStateMeta,
          previousState.isAcceptableOrUnknown(
              data['previous_state']!, _previousStateMeta));
    } else if (isInserting) {
      context.missing(_previousStateMeta);
    }
    if (data.containsKey('new_state')) {
      context.handle(_newStateMeta,
          newState.isAcceptableOrUnknown(data['new_state']!, _newStateMeta));
    } else if (isInserting) {
      context.missing(_newStateMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('action_timestamp')) {
      context.handle(
          _actionTimestampMeta,
          actionTimestamp.isAcceptableOrUnknown(
              data['action_timestamp']!, _actionTimestampMeta));
    } else if (isInserting) {
      context.missing(_actionTimestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewHistoryRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewHistoryRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      previousState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}previous_state'])!,
      newState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_state'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      actionTimestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}action_timestamp'])!,
    );
  }

  @override
  $ReviewHistoryTable createAlias(String alias) {
    return $ReviewHistoryTable(attachedDatabase, alias);
  }
}

class ReviewHistoryRecord extends DataClass
    implements Insertable<ReviewHistoryRecord> {
  final int id;
  final String assetId;
  final String previousState;
  final String newState;
  final String sessionId;
  final int actionTimestamp;
  const ReviewHistoryRecord(
      {required this.id,
      required this.assetId,
      required this.previousState,
      required this.newState,
      required this.sessionId,
      required this.actionTimestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['previous_state'] = Variable<String>(previousState);
    map['new_state'] = Variable<String>(newState);
    map['session_id'] = Variable<String>(sessionId);
    map['action_timestamp'] = Variable<int>(actionTimestamp);
    return map;
  }

  ReviewHistoryCompanion toCompanion(bool nullToAbsent) {
    return ReviewHistoryCompanion(
      id: Value(id),
      assetId: Value(assetId),
      previousState: Value(previousState),
      newState: Value(newState),
      sessionId: Value(sessionId),
      actionTimestamp: Value(actionTimestamp),
    );
  }

  factory ReviewHistoryRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewHistoryRecord(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      previousState: serializer.fromJson<String>(json['previousState']),
      newState: serializer.fromJson<String>(json['newState']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      actionTimestamp: serializer.fromJson<int>(json['actionTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<String>(assetId),
      'previousState': serializer.toJson<String>(previousState),
      'newState': serializer.toJson<String>(newState),
      'sessionId': serializer.toJson<String>(sessionId),
      'actionTimestamp': serializer.toJson<int>(actionTimestamp),
    };
  }

  ReviewHistoryRecord copyWith(
          {int? id,
          String? assetId,
          String? previousState,
          String? newState,
          String? sessionId,
          int? actionTimestamp}) =>
      ReviewHistoryRecord(
        id: id ?? this.id,
        assetId: assetId ?? this.assetId,
        previousState: previousState ?? this.previousState,
        newState: newState ?? this.newState,
        sessionId: sessionId ?? this.sessionId,
        actionTimestamp: actionTimestamp ?? this.actionTimestamp,
      );
  ReviewHistoryRecord copyWithCompanion(ReviewHistoryCompanion data) {
    return ReviewHistoryRecord(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      previousState: data.previousState.present
          ? data.previousState.value
          : this.previousState,
      newState: data.newState.present ? data.newState.value : this.newState,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      actionTimestamp: data.actionTimestamp.present
          ? data.actionTimestamp.value
          : this.actionTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewHistoryRecord(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('previousState: $previousState, ')
          ..write('newState: $newState, ')
          ..write('sessionId: $sessionId, ')
          ..write('actionTimestamp: $actionTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, assetId, previousState, newState, sessionId, actionTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewHistoryRecord &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.previousState == this.previousState &&
          other.newState == this.newState &&
          other.sessionId == this.sessionId &&
          other.actionTimestamp == this.actionTimestamp);
}

class ReviewHistoryCompanion extends UpdateCompanion<ReviewHistoryRecord> {
  final Value<int> id;
  final Value<String> assetId;
  final Value<String> previousState;
  final Value<String> newState;
  final Value<String> sessionId;
  final Value<int> actionTimestamp;
  const ReviewHistoryCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.previousState = const Value.absent(),
    this.newState = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.actionTimestamp = const Value.absent(),
  });
  ReviewHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String assetId,
    required String previousState,
    required String newState,
    required String sessionId,
    required int actionTimestamp,
  })  : assetId = Value(assetId),
        previousState = Value(previousState),
        newState = Value(newState),
        sessionId = Value(sessionId),
        actionTimestamp = Value(actionTimestamp);
  static Insertable<ReviewHistoryRecord> custom({
    Expression<int>? id,
    Expression<String>? assetId,
    Expression<String>? previousState,
    Expression<String>? newState,
    Expression<String>? sessionId,
    Expression<int>? actionTimestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (previousState != null) 'previous_state': previousState,
      if (newState != null) 'new_state': newState,
      if (sessionId != null) 'session_id': sessionId,
      if (actionTimestamp != null) 'action_timestamp': actionTimestamp,
    });
  }

  ReviewHistoryCompanion copyWith(
      {Value<int>? id,
      Value<String>? assetId,
      Value<String>? previousState,
      Value<String>? newState,
      Value<String>? sessionId,
      Value<int>? actionTimestamp}) {
    return ReviewHistoryCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      previousState: previousState ?? this.previousState,
      newState: newState ?? this.newState,
      sessionId: sessionId ?? this.sessionId,
      actionTimestamp: actionTimestamp ?? this.actionTimestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (previousState.present) {
      map['previous_state'] = Variable<String>(previousState.value);
    }
    if (newState.present) {
      map['new_state'] = Variable<String>(newState.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (actionTimestamp.present) {
      map['action_timestamp'] = Variable<int>(actionTimestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewHistoryCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('previousState: $previousState, ')
          ..write('newState: $newState, ')
          ..write('sessionId: $sessionId, ')
          ..write('actionTimestamp: $actionTimestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReviewedScreenshotsTable reviewedScreenshots =
      $ReviewedScreenshotsTable(this);
  late final $ReviewHistoryTable reviewHistory = $ReviewHistoryTable(this);
  late final ReviewDao reviewDao = ReviewDao(this as AppDatabase);
  late final HistoryDao historyDao = HistoryDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [reviewedScreenshots, reviewHistory];
}

typedef $$ReviewedScreenshotsTableCreateCompanionBuilder
    = ReviewedScreenshotsCompanion Function({
  Value<int> id,
  required String assetId,
  required String reviewState,
  required int reviewedAt,
  required String sessionId,
});
typedef $$ReviewedScreenshotsTableUpdateCompanionBuilder
    = ReviewedScreenshotsCompanion Function({
  Value<int> id,
  Value<String> assetId,
  Value<String> reviewState,
  Value<int> reviewedAt,
  Value<String> sessionId,
});

class $$ReviewedScreenshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewedScreenshotsTable> {
  $$ReviewedScreenshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewState => $composableBuilder(
      column: $table.reviewState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));
}

class $$ReviewedScreenshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewedScreenshotsTable> {
  $$ReviewedScreenshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewState => $composableBuilder(
      column: $table.reviewState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));
}

class $$ReviewedScreenshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewedScreenshotsTable> {
  $$ReviewedScreenshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get reviewState => $composableBuilder(
      column: $table.reviewState, builder: (column) => column);

  GeneratedColumn<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);
}

class $$ReviewedScreenshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewedScreenshotsTable,
    ReviewedScreenshotRecord,
    $$ReviewedScreenshotsTableFilterComposer,
    $$ReviewedScreenshotsTableOrderingComposer,
    $$ReviewedScreenshotsTableAnnotationComposer,
    $$ReviewedScreenshotsTableCreateCompanionBuilder,
    $$ReviewedScreenshotsTableUpdateCompanionBuilder,
    (
      ReviewedScreenshotRecord,
      BaseReferences<_$AppDatabase, $ReviewedScreenshotsTable,
          ReviewedScreenshotRecord>
    ),
    ReviewedScreenshotRecord,
    PrefetchHooks Function()> {
  $$ReviewedScreenshotsTableTableManager(
      _$AppDatabase db, $ReviewedScreenshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewedScreenshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewedScreenshotsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewedScreenshotsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<String> reviewState = const Value.absent(),
            Value<int> reviewedAt = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
          }) =>
              ReviewedScreenshotsCompanion(
            id: id,
            assetId: assetId,
            reviewState: reviewState,
            reviewedAt: reviewedAt,
            sessionId: sessionId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String assetId,
            required String reviewState,
            required int reviewedAt,
            required String sessionId,
          }) =>
              ReviewedScreenshotsCompanion.insert(
            id: id,
            assetId: assetId,
            reviewState: reviewState,
            reviewedAt: reviewedAt,
            sessionId: sessionId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReviewedScreenshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewedScreenshotsTable,
    ReviewedScreenshotRecord,
    $$ReviewedScreenshotsTableFilterComposer,
    $$ReviewedScreenshotsTableOrderingComposer,
    $$ReviewedScreenshotsTableAnnotationComposer,
    $$ReviewedScreenshotsTableCreateCompanionBuilder,
    $$ReviewedScreenshotsTableUpdateCompanionBuilder,
    (
      ReviewedScreenshotRecord,
      BaseReferences<_$AppDatabase, $ReviewedScreenshotsTable,
          ReviewedScreenshotRecord>
    ),
    ReviewedScreenshotRecord,
    PrefetchHooks Function()>;
typedef $$ReviewHistoryTableCreateCompanionBuilder = ReviewHistoryCompanion
    Function({
  Value<int> id,
  required String assetId,
  required String previousState,
  required String newState,
  required String sessionId,
  required int actionTimestamp,
});
typedef $$ReviewHistoryTableUpdateCompanionBuilder = ReviewHistoryCompanion
    Function({
  Value<int> id,
  Value<String> assetId,
  Value<String> previousState,
  Value<String> newState,
  Value<String> sessionId,
  Value<int> actionTimestamp,
});

class $$ReviewHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewHistoryTable> {
  $$ReviewHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousState => $composableBuilder(
      column: $table.previousState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get newState => $composableBuilder(
      column: $table.newState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actionTimestamp => $composableBuilder(
      column: $table.actionTimestamp,
      builder: (column) => ColumnFilters(column));
}

class $$ReviewHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewHistoryTable> {
  $$ReviewHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousState => $composableBuilder(
      column: $table.previousState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get newState => $composableBuilder(
      column: $table.newState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actionTimestamp => $composableBuilder(
      column: $table.actionTimestamp,
      builder: (column) => ColumnOrderings(column));
}

class $$ReviewHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewHistoryTable> {
  $$ReviewHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get previousState => $composableBuilder(
      column: $table.previousState, builder: (column) => column);

  GeneratedColumn<String> get newState =>
      $composableBuilder(column: $table.newState, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get actionTimestamp => $composableBuilder(
      column: $table.actionTimestamp, builder: (column) => column);
}

class $$ReviewHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewHistoryTable,
    ReviewHistoryRecord,
    $$ReviewHistoryTableFilterComposer,
    $$ReviewHistoryTableOrderingComposer,
    $$ReviewHistoryTableAnnotationComposer,
    $$ReviewHistoryTableCreateCompanionBuilder,
    $$ReviewHistoryTableUpdateCompanionBuilder,
    (
      ReviewHistoryRecord,
      BaseReferences<_$AppDatabase, $ReviewHistoryTable, ReviewHistoryRecord>
    ),
    ReviewHistoryRecord,
    PrefetchHooks Function()> {
  $$ReviewHistoryTableTableManager(_$AppDatabase db, $ReviewHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<String> previousState = const Value.absent(),
            Value<String> newState = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<int> actionTimestamp = const Value.absent(),
          }) =>
              ReviewHistoryCompanion(
            id: id,
            assetId: assetId,
            previousState: previousState,
            newState: newState,
            sessionId: sessionId,
            actionTimestamp: actionTimestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String assetId,
            required String previousState,
            required String newState,
            required String sessionId,
            required int actionTimestamp,
          }) =>
              ReviewHistoryCompanion.insert(
            id: id,
            assetId: assetId,
            previousState: previousState,
            newState: newState,
            sessionId: sessionId,
            actionTimestamp: actionTimestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReviewHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewHistoryTable,
    ReviewHistoryRecord,
    $$ReviewHistoryTableFilterComposer,
    $$ReviewHistoryTableOrderingComposer,
    $$ReviewHistoryTableAnnotationComposer,
    $$ReviewHistoryTableCreateCompanionBuilder,
    $$ReviewHistoryTableUpdateCompanionBuilder,
    (
      ReviewHistoryRecord,
      BaseReferences<_$AppDatabase, $ReviewHistoryTable, ReviewHistoryRecord>
    ),
    ReviewHistoryRecord,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReviewedScreenshotsTableTableManager get reviewedScreenshots =>
      $$ReviewedScreenshotsTableTableManager(_db, _db.reviewedScreenshots);
  $$ReviewHistoryTableTableManager get reviewHistory =>
      $$ReviewHistoryTableTableManager(_db, _db.reviewHistory);
}
