import 'review_state.dart';

/// Authoritative outcome container returned by the ReconciliationService.
class ReconciliationResult {
  final int totalRequested;
  final int deletedConfirmedCount;
  final int alreadyMissingCount;
  final int unresolvedRetainedCount;
  final int unresolvedInaccessibleCount;
  final int unresolvedInconclusiveCount;
  final Map<String, ReviewState> perAssetOutcomes;

  const ReconciliationResult({
    required this.totalRequested,
    required this.deletedConfirmedCount,
    required this.alreadyMissingCount,
    required this.unresolvedRetainedCount,
    required this.unresolvedInaccessibleCount,
    required this.unresolvedInconclusiveCount,
    required this.perAssetOutcomes,
  });

  int get totalUnresolved =>
      unresolvedRetainedCount +
      unresolvedInaccessibleCount +
      unresolvedInconclusiveCount;

  bool get hasUnresolved => totalUnresolved > 0;
  bool get allSucceeded => deletedConfirmedCount + alreadyMissingCount == totalRequested;

  factory ReconciliationResult.empty() {
    return const ReconciliationResult(
      totalRequested: 0,
      deletedConfirmedCount: 0,
      alreadyMissingCount: 0,
      unresolvedRetainedCount: 0,
      unresolvedInaccessibleCount: 0,
      unresolvedInconclusiveCount: 0,
      perAssetOutcomes: {},
    );
  }
}
