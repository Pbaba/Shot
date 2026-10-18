// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_dao.dart';

// ignore_for_file: type=lint
mixin _$HistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReviewHistoryTable get reviewHistory => attachedDatabase.reviewHistory;
  $ReviewedScreenshotsTable get reviewedScreenshots =>
      attachedDatabase.reviewedScreenshots;
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final _$HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
  $$ReviewHistoryTableTableManager get reviewHistory =>
      $$ReviewHistoryTableTableManager(_db.attachedDatabase, _db.reviewHistory);
  $$ReviewedScreenshotsTableTableManager get reviewedScreenshots =>
      $$ReviewedScreenshotsTableTableManager(
          _db.attachedDatabase, _db.reviewedScreenshots);
}
