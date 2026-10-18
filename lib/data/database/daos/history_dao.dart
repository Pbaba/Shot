import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/undo_history.dart';
import '../tables/review_records.dart';
import '../../../domain/models/review_state.dart';

part 'history_dao.g.dart';

@DriftAccessor(tables: [ReviewHistory, ReviewedScreenshots])
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.db);

  /// Pushes an action to the undo history.
  Future<void> pushAction({
    required String assetId,
    required ReviewState previousState,
    required ReviewState newState,
    required String sessionId,
    int? timestampMs,
  }) async {
    final nowMs = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
    await into(reviewHistory).insert(
      ReviewHistoryCompanion.insert(
        assetId: assetId,
        previousState: previousState.value,
        newState: newState.value,
        sessionId: sessionId,
        actionTimestamp: nowMs,
      ),
    );
  }

  /// Pops the latest action for the specified session and restores previous state in a single transaction.
  /// Uses `id DESC` as a deterministic tie-breaker for rapid swipes sharing identical timestamps.
  Future<ReviewHistoryRecord?> popAndRestoreLatestAction(String sessionId) {
    return transaction(() async {
      final query = select(reviewHistory)
        ..where((tbl) => tbl.sessionId.equals(sessionId))
        ..orderBy([
          (tbl) => OrderingTerm(expression: tbl.actionTimestamp, mode: OrderingMode.desc),
          (tbl) => OrderingTerm(expression: tbl.id, mode: OrderingMode.desc),
        ])
        ..limit(1);

      final latestRecord = await query.getSingleOrNull();
      if (latestRecord == null) return null;

      // Restore the prior state in reviewed_screenshots
      await (update(reviewedScreenshots)..where((tbl) => tbl.assetId.equals(latestRecord.assetId)))
          .write(
        ReviewedScreenshotsCompanion(
          reviewState: Value(latestRecord.previousState),
          reviewedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

      // Remove the popped entry from history
      await (delete(reviewHistory)..where((tbl) => tbl.id.equals(latestRecord.id))).go();

      return latestRecord;
    });
  }

  /// Clears undo history for a specific session.
  Future<int> clearSessionHistory(String sessionId) {
    return (delete(reviewHistory)..where((tbl) => tbl.sessionId.equals(sessionId))).go();
  }
}
