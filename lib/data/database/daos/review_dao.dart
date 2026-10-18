import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/review_records.dart';
import '../../../domain/models/review_state.dart';

part 'review_dao.g.dart';

@DriftAccessor(tables: [ReviewedScreenshots])
class ReviewDao extends DatabaseAccessor<AppDatabase> with _$ReviewDaoMixin {
  ReviewDao(super.db);

  /// Upserts the review state for an asset.
  Future<void> setReviewState({
    required String assetId,
    required ReviewState state,
    required String sessionId,
    int? timestampMs,
  }) async {
    final nowMs = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
    await into(reviewedScreenshots).insertOnConflictUpdate(
      ReviewedScreenshotsCompanion.insert(
        assetId: assetId,
        reviewState: state.value,
        reviewedAt: nowMs,
        sessionId: sessionId,
      ),
    );
  }

  /// Retrieves the current persistent state of an asset, or null if unreviewed.
  Future<ReviewState?> getReviewState(String assetId) async {
    final query = select(reviewedScreenshots)..where((tbl) => tbl.assetId.equals(assetId));
    final record = await query.getSingleOrNull();
    return record != null ? ReviewState.fromString(record.reviewState) : null;
  }

  /// Retrieves all records matching a specific review state.
  Future<List<ReviewedScreenshotRecord>> getRecordsByState(ReviewState state) {
    return (select(reviewedScreenshots)..where((tbl) => tbl.reviewState.equals(state.value))).get();
  }

  /// Watches all pending deletion records reactively.
  Stream<List<ReviewedScreenshotRecord>> watchPendingDeletions() {
    return (select(reviewedScreenshots)
          ..where((tbl) => tbl.reviewState.equals(ReviewState.pendingDelete.value)))
        .watch();
  }

  /// Batch updates multiple asset states in a single transaction.
  Future<void> batchUpdateState(List<String> assetIds, ReviewState newState) async {
    await batch((b) {
      for (final id in assetIds) {
        b.update(
          reviewedScreenshots,
          ReviewedScreenshotsCompanion(
            reviewState: Value(newState.value),
            reviewedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
          where: (tbl) => tbl.assetId.equals(id),
        );
      }
    });
  }

  /// Counts assets by state.
  Future<int> countByState(ReviewState state) async {
    final countExp = reviewedScreenshots.id.count();
    final query = selectOnly(reviewedScreenshots)
      ..addColumns([countExp])
      ..where(reviewedScreenshots.reviewState.equals(state.value));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
