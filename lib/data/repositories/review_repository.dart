import '../../domain/models/review_state.dart';
import '../../domain/models/screenshot_item.dart';
import '../../domain/models/reconciliation_result.dart';
import '../../domain/repositories/i_review_repository.dart';
import '../../services/media_library_service.dart';
import '../../services/reconciliation_service.dart';
import '../database/daos/review_dao.dart';
import '../database/daos/history_dao.dart';

class ReviewRepository implements IReviewRepository {
  final ReviewDao reviewDao;
  final HistoryDao historyDao;
  final IMediaLibraryService mediaLibraryService;
  final ReconciliationService reconciliationService;

  const ReviewRepository({
    required this.reviewDao,
    required this.historyDao,
    required this.mediaLibraryService,
    required this.reconciliationService,
  });

  @override
  Future<List<ScreenshotItem>> loadScreenshotsPaged({
    required int page,
    required int size,
    String? customDirectoryPath,
  }) async {
    final items = await mediaLibraryService.fetchScreenshotsPaged(
      page: page,
      size: size,
      customDirectoryPath: customDirectoryPath,
    );

    // Merge persistent review states from Drift database
    final enrichedItems = <ScreenshotItem>[];
    for (final item in items) {
      final state = await reviewDao.getReviewState(item.id);
      enrichedItems.add(item.copyWith(reviewState: state ?? ReviewState.unreviewed));
    }
    return enrichedItems;
  }

  @override
  Future<int> getTotalScreenshotCount({String? customDirectoryPath}) {
    return mediaLibraryService.getTotalScreenshotCount(
      customDirectoryPath: customDirectoryPath,
    );
  }

  @override
  Future<void> reviewScreenshot({
    required String assetId,
    required ReviewState newState,
    required String sessionId,
  }) async {
    final prevState = await reviewDao.getReviewState(assetId) ?? ReviewState.unreviewed;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // 1. Update current state
    await reviewDao.setReviewState(
      assetId: assetId,
      state: newState,
      sessionId: sessionId,
      timestampMs: nowMs,
    );

    // 2. Record in atomic undo history
    await historyDao.pushAction(
      assetId: assetId,
      previousState: prevState,
      newState: newState,
      sessionId: sessionId,
      timestampMs: nowMs,
    );
  }

  @override
  Future<ScreenshotItem?> undoLastAction(String sessionId) async {
    final poppedRecord = await historyDao.popAndRestoreLatestAction(sessionId);
    if (poppedRecord == null) return null;

    final entity = await mediaLibraryService.obtainForId(poppedRecord.assetId);
    if (entity == null) {
      // Asset missing or inaccessible
      return null;
    }

    final restoredState = ReviewState.fromString(poppedRecord.previousState);
    return ScreenshotItem.fromAssetEntity(entity, state: restoredState);
  }

  @override
  Future<List<ScreenshotItem>> getPendingDeletions() async {
    final records = await reviewDao.getRecordsByState(ReviewState.pendingDelete);
    final items = <ScreenshotItem>[];

    for (final rec in records) {
      final entity = await mediaLibraryService.obtainForId(rec.assetId);
      if (entity != null) {
        items.add(ScreenshotItem.fromAssetEntity(entity, state: ReviewState.pendingDelete));
      }
    }
    return items;
  }

  @override
  Stream<List<String>> watchPendingDeletionIds() {
    return reviewDao.watchPendingDeletions().map((records) => records.map((r) => r.assetId).toList());
  }

  @override
  Future<ReconciliationResult> executeBatchDeletion({
    required List<String> candidateIds,
    required String sessionId,
  }) {
    return reconciliationService.reconcileBatchDeletion(
      candidateIds: candidateIds,
      sessionId: sessionId,
    );
  }

  @override
  Future<int> getKeptCount() => reviewDao.countByState(ReviewState.kept);

  @override
  Future<int> getPendingDeleteCount() => reviewDao.countByState(ReviewState.pendingDelete);
}
