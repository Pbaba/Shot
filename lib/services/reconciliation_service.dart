import 'package:photo_manager/photo_manager.dart';

import '../domain/models/review_state.dart';
import '../domain/models/reconciliation_result.dart';
import '../data/database/daos/review_dao.dart';
import 'permission_service.dart';
import 'media_library_service.dart';

/// Conservative per-asset deletion reconciliation service.
///
/// Assets are marked deleted only after a post-deletion lookup returns null
/// under full authorization. Lookup errors and ambiguous pre-check results
/// remain unresolved rather than being treated as successful deletion.
class ReconciliationService {
  final ReviewDao reviewDao;
  final IPermissionService permissionService;
  final IMediaLibraryService mediaLibraryService;

  const ReconciliationService({
    required this.reviewDao,
    required this.permissionService,
    required this.mediaLibraryService,
  });

  Future<ReconciliationResult> reconcileBatchDeletion({
    required List<String> candidateIds,
    required String sessionId,
  }) async {
    if (candidateIds.isEmpty) {
      return ReconciliationResult.empty();
    }

    // Step 1: Pre-deletion verification.
    final initialPerm = await permissionService.getPermissionState();
    final hasActiveRead = permissionService.isAuthorized(initialPerm) ||
        permissionService.isLimited(initialPerm);

    final validBatchIds = <String>[];
    final perAssetOutcomes = <String, ReviewState>{};

    int alreadyMissingCount = 0;
    int precheckInconclusiveCount = 0;
    int precheckInaccessibleCount = 0;

    for (final id in candidateIds) {
      if (!hasActiveRead) {
        perAssetOutcomes[id] = ReviewState.unresolvedInaccessible;
        await reviewDao.setReviewState(
          assetId: id,
          state: ReviewState.unresolvedInaccessible,
          sessionId: sessionId,
        );
        precheckInaccessibleCount++;
        continue;
      }

      AssetEntity? entity;

      try {
        entity = await mediaLibraryService.obtainForId(id);
      } catch (_) {
        perAssetOutcomes[id] = ReviewState.unresolvedInconclusive;
        await reviewDao.setReviewState(
          assetId: id,
          state: ReviewState.unresolvedInconclusive,
          sessionId: sessionId,
        );
        precheckInconclusiveCount++;
        continue;
      }

      if (entity == null) {
        // The pre-check returned no entity. Under the current test/service
        // contract, classify this as already missing and exclude it from deletion.
        perAssetOutcomes[id] = ReviewState.alreadyMissing;
        await reviewDao.setReviewState(
          assetId: id,
          state: ReviewState.alreadyMissing,
          sessionId: sessionId,
        );
        alreadyMissingCount++;
  continue;
}

      validBatchIds.add(id);
    }

    if (validBatchIds.isEmpty) {
      return ReconciliationResult(
        totalRequested: candidateIds.length,
        deletedConfirmedCount: 0,
        alreadyMissingCount: alreadyMissingCount,
        unresolvedRetainedCount: 0,
        unresolvedInaccessibleCount: precheckInaccessibleCount,
        unresolvedInconclusiveCount: precheckInconclusiveCount,
        perAssetOutcomes: perAssetOutcomes,
      );
    }

    // Step 2: Request OS deletion for assets confirmed present at pre-check.
    // The returned IDs are not treated as proof of successful deletion.
    try {
      await mediaLibraryService.deleteWithIds(validBatchIds);
    } catch (_) {
      // Continue to post-check: the result may still be verifiable.
    }

    // Step 3: Re-check permission after the OS deletion interaction.
    final postPerm = await permissionService.getPermissionState();
    final isAuthorized = permissionService.isAuthorized(postPerm);
    final isLimited = permissionService.isLimited(postPerm);

    if (!isAuthorized && !isLimited) {
      for (final id in validBatchIds) {
        perAssetOutcomes[id] = ReviewState.unresolvedInaccessible;
        await reviewDao.setReviewState(
          assetId: id,
          state: ReviewState.unresolvedInaccessible,
          sessionId: sessionId,
        );
      }

      return ReconciliationResult(
        totalRequested: candidateIds.length,
        deletedConfirmedCount: 0,
        alreadyMissingCount: alreadyMissingCount,
        unresolvedRetainedCount: 0,
        unresolvedInaccessibleCount:
            precheckInaccessibleCount + validBatchIds.length,
        unresolvedInconclusiveCount: precheckInconclusiveCount,
        perAssetOutcomes: perAssetOutcomes,
      );
    }

    // Step 4: Per-asset post-deletion reconciliation.
    int deletedConfirmedCount = 0;
    int unresolvedRetainedCount = 0;
    int unresolvedInaccessibleCount = precheckInaccessibleCount;
    int unresolvedInconclusiveCount = precheckInconclusiveCount;

    for (final id in validBatchIds) {
      AssetEntity? postEntity;
      bool lookupFailed = false;

      try {
        postEntity = await mediaLibraryService.obtainForId(id);
      } catch (_) {
        lookupFailed = true;
      }

      final ReviewState finalState;

      if (lookupFailed) {
        finalState = ReviewState.unresolvedInconclusive;
        unresolvedInconclusiveCount++;
      } else if (postEntity != null) {
        // Still visible: deletion was cancelled or did not complete.
        finalState = ReviewState.unresolvedRetained;
        unresolvedRetainedCount++;
      } else if (isLimited) {
        // Limited access cannot reliably distinguish deletion from loss of
        // visibility or access to the asset.
        finalState = ReviewState.unresolvedInaccessible;
        unresolvedInaccessibleCount++;
      } else if (isAuthorized) {
        // This assumes null means the asset is no longer present in the
        // queried media library. Confirm this behavior on real devices.
        finalState = ReviewState.deletedConfirmed;
        deletedConfirmedCount++;
      } else {
        finalState = ReviewState.unresolvedInaccessible;
        unresolvedInaccessibleCount++;
      }

      perAssetOutcomes[id] = finalState;
      await reviewDao.setReviewState(
        assetId: id,
        state: finalState,
        sessionId: sessionId,
      );
    }

    return ReconciliationResult(
      totalRequested: candidateIds.length,
      deletedConfirmedCount: deletedConfirmedCount,
      alreadyMissingCount: alreadyMissingCount,
      unresolvedRetainedCount: unresolvedRetainedCount,
      unresolvedInaccessibleCount: unresolvedInaccessibleCount,
      unresolvedInconclusiveCount: unresolvedInconclusiveCount,
      perAssetOutcomes: perAssetOutcomes,
    );
  }
}
