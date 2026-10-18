import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shot/domain/models/review_state.dart';
import 'package:shot/domain/models/screenshot_item.dart';
import 'package:shot/services/reconciliation_service.dart';
import 'package:shot/services/permission_service.dart';
import 'package:shot/services/media_library_service.dart';
import 'package:shot/data/database/daos/review_dao.dart';

// ---------------------------------------------------------------------------
// Mock Implementations for Isolated Unit Testing
// ---------------------------------------------------------------------------

class MockPermissionService implements IPermissionService {
  PermissionState currentState = PermissionState.authorized;

  @override
  Future<PermissionState> getPermissionState() async => currentState;

  @override
  Future<PermissionState> requestPermissions() async => currentState;

  @override
  Future<void> presentLimitedPicker() async {}

  @override
  bool isAuthorized(PermissionState state) =>
      state.isAuth && state != PermissionState.limited;

  @override
  bool isLimited(PermissionState state) => state == PermissionState.limited;
}

class MockMediaLibraryService implements IMediaLibraryService {
  final Set<String> _existingAssets = {};
  final Set<String> _throwExceptionFor = {};
  bool simulateUserDenial = false;

  void seedAssets(List<String> ids) => _existingAssets.addAll(ids);
  void removeAsset(String id) => _existingAssets.remove(id);
  void setThrowException(String id) => _throwExceptionFor.add(id);

  @override
  Future<AssetEntity?> obtainForId(String id) async {
    if (_throwExceptionFor.contains(id)) {
      throw Exception('Simulated MediaStore query timeout/error for $id');
    }
    if (_existingAssets.contains(id)) {
      return AssetEntity(
        id: id,
        typeInt: 1, // image
        width: 1080,
        height: 2400,
      );
    }
    return null;
  }

  @override
  Future<List<String>> deleteWithIds(List<String> ids) async {
    if (simulateUserDenial) {
      // User tapped "Deny" / "Cancel": 0 assets deleted, returns []
      return [];
    }
    final deleted = <String>[];
    for (final id in ids) {
      if (_existingAssets.contains(id)) {
        _existingAssets.remove(id);
        deleted.add(id);
      }
    }
    return deleted;
  }

  @override
  Future<List<ScreenshotItem>> fetchScreenshotsPaged({
    required int page,
    required int size,
    String? customDirectoryPath,
  }) async => [];

  @override
  Future<int> getTotalScreenshotCount({String? customDirectoryPath}) async => _existingAssets.length;
}

class FakeReviewDao implements ReviewDao {
  final Map<String, ReviewState> storedStates = {};

  @override
  Future<void> setReviewState({
    required String assetId,
    required ReviewState state,
    required String sessionId,
    int? timestampMs,
  }) async {
    storedStates[assetId] = state;
  }

  @override
  Future<ReviewState?> getReviewState(String assetId) async => storedStates[assetId];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Unit Test Suite
// ---------------------------------------------------------------------------

void main() {
  group('ReconciliationService Unit Tests (Phase 2 & 3 Safety Specification)', () {
    late FakeReviewDao fakeDao;
    late MockPermissionService mockPerm;
    late MockMediaLibraryService mockMedia;
    late ReconciliationService service;

    setUp(() {
      fakeDao = FakeReviewDao();
      mockPerm = MockPermissionService();
      mockMedia = MockMediaLibraryService();
      service = ReconciliationService(
        reviewDao: fakeDao,
        permissionService: mockPerm,
        mediaLibraryService: mockMedia,
      );
    });

    test('Scenario 1: Confirmed Deletion under full authorized access', () async {
      mockMedia.seedAssets(['asset_001']);
      mockPerm.currentState = PermissionState.authorized;

      final result = await service.reconcileBatchDeletion(
        candidateIds: ['asset_001'],
        sessionId: 'session_test_1',
      );

      expect(result.deletedConfirmedCount, equals(1));
      expect(result.unresolvedRetainedCount, equals(0));
      expect(result.perAssetOutcomes['asset_001'], equals(ReviewState.deletedConfirmed));
      expect(fakeDao.storedStates['asset_001'], equals(ReviewState.deletedConfirmed));
    });

    test('Scenario 2: User denial / cancel preserves asset as unresolvedRetained', () async {
      mockMedia.seedAssets(['asset_002']);
      mockMedia.simulateUserDenial = true; // User tapped "Deny"
      mockPerm.currentState = PermissionState.authorized;

      final result = await service.reconcileBatchDeletion(
        candidateIds: ['asset_002'],
        sessionId: 'session_test_2',
      );

      expect(result.deletedConfirmedCount, equals(0));
      expect(result.unresolvedRetainedCount, equals(1));
      expect(result.perAssetOutcomes['asset_002'], equals(ReviewState.unresolvedRetained));
      expect(fakeDao.storedStates['asset_002'], equals(ReviewState.unresolvedRetained));
    });

    test('Scenario 3: Permission Revocation safely flags unresolvedInaccessible (NEVER deleted)', () async {
      mockMedia.seedAssets(['asset_003']);
      // Simulate permission loss
      mockPerm.currentState = PermissionState.denied;

      final result = await service.reconcileBatchDeletion(
        candidateIds: ['asset_003'],
        sessionId: 'session_test_3',
      );

      expect(result.deletedConfirmedCount, equals(0));
      expect(result.unresolvedInaccessibleCount, equals(1));
      expect(result.perAssetOutcomes['asset_003'], equals(ReviewState.unresolvedInaccessible));
      expect(fakeDao.storedStates['asset_003'], equals(ReviewState.unresolvedInaccessible));
    });

    test('Scenario 4: iOS Limited Authorization flags unselected assets as unresolvedInaccessible', () async {
      mockMedia.seedAssets(['asset_004']);
      mockPerm.currentState = PermissionState.limited;

      final result = await service.reconcileBatchDeletion(
        candidateIds: ['asset_004'],
        sessionId: 'session_test_4',
      );

      expect(result.deletedConfirmedCount, equals(0));
      expect(result.unresolvedInaccessibleCount, equals(1));
      expect(result.perAssetOutcomes['asset_004'], equals(ReviewState.unresolvedInaccessible));
    });

    test('Scenario 5: MediaStore lookup exception flags unresolvedInconclusive', () async {
      mockMedia.seedAssets(['asset_005']);
      mockMedia.setThrowException('asset_005');
      mockPerm.currentState = PermissionState.authorized;

      final result = await service.reconcileBatchDeletion(
        candidateIds: ['asset_005'],
        sessionId: 'session_test_5',
      );

      expect(result.deletedConfirmedCount, equals(0));
      expect(result.unresolvedInconclusiveCount, equals(1));
      expect(result.perAssetOutcomes['asset_005'], equals(ReviewState.unresolvedInconclusive));
    });

    test('Scenario 6: Pre-batch check catches already_missing file and excludes from OS call', () async {
      // Do NOT seed asset_006 in media library (already missing)
      mockPerm.currentState = PermissionState.authorized;

      final result = await service.reconcileBatchDeletion(
        candidateIds: ['asset_006'],
        sessionId: 'session_test_6',
      );

      expect(result.alreadyMissingCount, equals(1));
      expect(result.deletedConfirmedCount, equals(0));
      expect(result.perAssetOutcomes['asset_006'], equals(ReviewState.alreadyMissing));
      expect(fakeDao.storedStates['asset_006'], equals(ReviewState.alreadyMissing));
    });
  });
}
