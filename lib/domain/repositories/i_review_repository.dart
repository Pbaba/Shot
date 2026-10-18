import '../models/review_state.dart';
import '../models/screenshot_item.dart';
import '../models/reconciliation_result.dart';

abstract class IReviewRepository {
  Future<List<ScreenshotItem>> loadScreenshotsPaged({
    required int page,
    required int size,
    String? customDirectoryPath,
  });

  Future<int> getTotalScreenshotCount({String? customDirectoryPath});

  Future<void> reviewScreenshot({
    required String assetId,
    required ReviewState newState,
    required String sessionId,
  });

  Future<ScreenshotItem?> undoLastAction(String sessionId);

  Future<List<ScreenshotItem>> getPendingDeletions();

  Stream<List<String>> watchPendingDeletionIds();

  Future<ReconciliationResult> executeBatchDeletion({
    required List<String> candidateIds,
    required String sessionId,
  });

  Future<int> getKeptCount();
  Future<int> getPendingDeleteCount();
}
