// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dao.dart';

// ignore_for_file: type=lint
mixin _$ReviewDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReviewedScreenshotsTable get reviewedScreenshots =>
      attachedDatabase.reviewedScreenshots;
  ReviewDaoManager get managers => ReviewDaoManager(this);
}

class ReviewDaoManager {
  final _$ReviewDaoMixin _db;
  ReviewDaoManager(this._db);
  $$ReviewedScreenshotsTableTableManager get reviewedScreenshots =>
      $$ReviewedScreenshotsTableTableManager(
          _db.attachedDatabase, _db.reviewedScreenshots);
}
