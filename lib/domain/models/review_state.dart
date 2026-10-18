/// Enumeration of all discrete review and reconciliation states in Shot.
///
/// Follows the authoritative specification in `verification/reconciliation_state_machine.md`.
enum ReviewState {
  /// Discovered in screenshot library, not yet reviewed by user.
  unreviewed('unreviewed'),

  /// User explicitly marked this screenshot to be kept in library.
  kept('kept'),

  /// User marked this screenshot for batch deletion (swipe left).
  pendingDelete('pending_delete'),

  /// Deletion was confirmed by the OS media library under verified full authorization.
  deletedConfirmed('deleted_confirmed'),

  /// Asset was discovered missing outside Shot prior to batch deletion submission.
  alreadyMissing('already_missing'),

  /// Batch delete completed, but post-query confirmed asset still exists in library.
  unresolvedRetained('unresolved_retained'),

  /// Asset state cannot be verified because permissions are missing, revoked, or limited.
  unresolvedInaccessible('unresolved_inaccessible'),

  /// Post-query threw an unexpected MediaStore / Photos framework exception or timeout.
  unresolvedInconclusive('unresolved_inconclusive');

  final String value;
  const ReviewState(this.value);

  static ReviewState fromString(String val) {
    for (final state in ReviewState.values) {
      if (state.value == val) return state;
    }
    return ReviewState.unreviewed;
  }

  bool get isUnresolved =>
      this == ReviewState.unresolvedRetained ||
      this == ReviewState.unresolvedInaccessible ||
      this == ReviewState.unresolvedInconclusive;

  bool get isTerminal =>
      this == ReviewState.deletedConfirmed ||
      this == ReviewState.alreadyMissing;

  bool get isActionableForBatch =>
      this == ReviewState.pendingDelete ||
      this == ReviewState.unresolvedRetained;
}
