#!/usr/bin/env python3
"""
PoC 4: Enhanced SQLite Persistence & Reconciliation State Machine Test Suite
Project: Shot - "Keep what matters."
Date: October 2026

[SIMULATION NOTICE]
This test harness executes Python SQLite simulation of the relational schema,
atomic transaction boundaries, multi-signal state transitions, and reconciliation
algorithms planned for Shot. It does NOT execute or validate compiled Dart SDK,
Flutter framework, Drift code-generation, or native Android/iOS platform channels.
Flutter/Drift runtime validation remains a separate requirement once Flutter tooling
is available.
"""

import sqlite3
import os
import sys
import uuid
import time
import tempfile
import contextlib
from typing import List, Dict, Optional, Set

# Schema matching planned Drift SQLite implementation
CREATE_REVIEWED_SCREENSHOTS_TABLE = """
CREATE TABLE IF NOT EXISTS reviewed_screenshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    asset_id TEXT NOT NULL UNIQUE,
    review_state TEXT NOT NULL,          -- 'unreviewed', 'kept', 'pending_delete', 'deleted_confirmed',
                                         -- 'unresolved_retained', 'unresolved_inaccessible',
                                         -- 'unresolved_inconclusive', 'externally_deleted'
    reviewed_at INTEGER NOT NULL,        -- Epoch milliseconds
    session_id TEXT NOT NULL
);
"""

CREATE_REVIEW_HISTORY_TABLE = """
CREATE TABLE IF NOT EXISTS review_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    asset_id TEXT NOT NULL,
    previous_state TEXT NOT NULL,
    new_state TEXT NOT NULL,
    session_id TEXT NOT NULL,
    action_timestamp INTEGER NOT NULL
);
"""

CREATE_INDEXES = """
CREATE INDEX IF NOT EXISTS idx_review_state ON reviewed_screenshots(review_state);
CREATE INDEX IF NOT EXISTS idx_asset_id ON reviewed_screenshots(asset_id);
CREATE INDEX IF NOT EXISTS idx_history_session ON review_history(session_id, action_timestamp DESC, id DESC);
"""

class MockPermissionState:
    AUTHORIZED = "authorized"
    LIMITED = "limited"
    DENIED = "denied"
    RESTRICTED = "restricted"

class MockOSMediaLibrary:
    """Simulates native MediaStore / Photos framework with permission awareness."""
    def __init__(self, initial_assets: List[str]):
        self._assets: Set[str] = set(initial_assets)
        self.permission_state: str = MockPermissionState.AUTHORIZED
        self.authorized_limited_subset: Set[str] = set(initial_assets)
        self.simulate_lookup_error_for: Set[str] = set()

    def set_permission(self, state: str):
        self.permission_state = state

    def obtain_for_id(self, asset_id: str) -> Optional[bool]:
        """
        Simulates AssetEntity.obtainForId(asset_id).
        Returns True if asset exists and is accessible.
        Returns False/None if asset is missing or inaccessible.
        Raises RuntimeError if simulated lookup error occurs.
        """
        if asset_id in self.simulate_lookup_error_for:
            raise RuntimeError(f"Simulated MediaStore query timeout/error for {asset_id}")

        if self.permission_state in (MockPermissionState.DENIED, MockPermissionState.RESTRICTED):
            # Without permissions, native framework returns null
            return None

        if self.permission_state == MockPermissionState.LIMITED:
            # Under limited permission, only authorized subset is visible
            if asset_id in self.authorized_limited_subset and asset_id in self._assets:
                return True
            return None

        # Full authorized access
        return True if asset_id in self._assets else None

    def delete_externally(self, asset_id: str):
        """Simulates file deleted in Google Photos or Apple Photos outside Shot."""
        if asset_id in self._assets:
            self._assets.remove(asset_id)

    def perform_os_deletion(self, asset_ids: List[str], user_response: str = "allow", partial_fail_ids: Optional[Set[str]] = None) -> List[str]:
        """Simulates PhotoManager.editor.deleteWithIds."""
        if self.permission_state != MockPermissionState.AUTHORIZED and self.permission_state != MockPermissionState.LIMITED:
            return []

        if user_response == "deny":
            return []

        if user_response == "crash":
            raise RuntimeError("CRASH: System process terminated during OS modal display")

        deleted_ids = []
        partial_fail_ids = partial_fail_ids or set()
        for aid in asset_ids:
            if aid in self._assets and aid not in partial_fail_ids:
                self._assets.remove(aid)
                deleted_ids.append(aid)
        return deleted_ids


class ShotPersistenceManager:
    """Manages SQLite operations corresponding to Drift DAOs."""
    def __init__(self, db_path: str):
        self.db_path = db_path
        self._init_db()

    @contextlib.contextmanager
    def _get_connection(self):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
        finally:
            conn.close()

    def _init_db(self):
        with self._get_connection() as conn:
            conn.execute(CREATE_REVIEWED_SCREENSHOTS_TABLE)
            conn.execute(CREATE_REVIEW_HISTORY_TABLE)
            conn.executescript(CREATE_INDEXES)
            conn.commit()

    def record_review(self, asset_id: str, new_state: str, session_id: str, explicit_timestamp: Optional[int] = None):
        """Records review action with Undo history atomically."""
        now_ms = explicit_timestamp if explicit_timestamp is not None else int(time.time() * 1000)
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT review_state FROM reviewed_screenshots WHERE asset_id = ?", (asset_id,))
            row = cursor.fetchone()
            prev_state = row['review_state'] if row else 'unreviewed'

            cursor.execute("""
                INSERT INTO reviewed_screenshots (asset_id, review_state, reviewed_at, session_id)
                VALUES (?, ?, ?, ?)
                ON CONFLICT(asset_id) DO UPDATE SET
                    review_state = excluded.review_state,
                    reviewed_at = excluded.reviewed_at,
                    session_id = excluded.session_id
            """, (asset_id, new_state, now_ms, session_id))

            cursor.execute("""
                INSERT INTO review_history (asset_id, previous_state, new_state, session_id, action_timestamp)
                VALUES (?, ?, ?, ?, ?)
            """, (asset_id, prev_state, new_state, session_id, now_ms))
            conn.commit()

    def record_review_with_simulated_failure(self, asset_id: str, new_state: str, session_id: str):
        """Simulates an unexpected error during transaction to verify rollback."""
        now_ms = int(time.time() * 1000)
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO reviewed_screenshots (asset_id, review_state, reviewed_at, session_id)
                VALUES (?, ?, ?, ?)
                ON CONFLICT(asset_id) DO UPDATE SET
                    review_state = excluded.review_state
            """, (asset_id, new_state, now_ms, session_id))

            # Trigger intentional failure before commit
            raise sqlite3.OperationalError("Simulated write failure mid-transaction")

    def undo_last_action(self, session_id: str) -> Optional[Dict]:
        """Pops the top undo action, using id DESC as deterministic tie-breaker for shared timestamps."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT id, asset_id, previous_state FROM review_history
                WHERE session_id = ?
                ORDER BY action_timestamp DESC, id DESC
                LIMIT 1
            """, (session_id,))
            row = cursor.fetchone()
            if not row:
                return None

            history_id = row['id']
            asset_id = row['asset_id']
            prev_state = row['previous_state']

            cursor.execute("UPDATE reviewed_screenshots SET review_state = ? WHERE asset_id = ?", (prev_state, asset_id))
            cursor.execute("DELETE FROM review_history WHERE id = ?", (history_id,))
            conn.commit()
            return {"asset_id": asset_id, "restored_state": prev_state}

    def get_review_state(self, asset_id: str) -> Optional[str]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT review_state FROM reviewed_screenshots WHERE asset_id = ?", (asset_id,))
            row = cursor.fetchone()
            return row['review_state'] if row else None

    def get_pending_deletions(self) -> List[str]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT asset_id FROM reviewed_screenshots WHERE review_state = 'pending_delete'")
            return [row['asset_id'] for row in cursor.fetchall()]

    def pre_deletion_check(self, target_ids: List[str], media_lib: MockOSMediaLibrary) -> Dict[str, List[str]]:
        """
        Pre-execution check with explicit permission verification.
        Only marks externally_deleted if permissions are confirmed active.
        """
        valid = []
        externally_deleted = []
        with self._get_connection() as conn:
            cursor = conn.cursor()
            for aid in target_ids:
                if media_lib.permission_state != MockPermissionState.AUTHORIZED:
                    # Do not mark externally deleted if we cannot read the library!
                    valid.append(aid)
                    continue

                exists = media_lib.obtain_for_id(aid)
                if exists is True:
                    valid.append(aid)
                else:
                    externally_deleted.append(aid)
                    cursor.execute("UPDATE reviewed_screenshots SET review_state = 'externally_deleted' WHERE asset_id = ?", (aid,))
            conn.commit()
        return {'valid': valid, 'externally_deleted': externally_deleted}

    def reconcile_post_deletion(self, candidate_ids: List[str], media_lib: MockOSMediaLibrary) -> Dict[str, int]:
        """
        Authoritative Multi-Signal Post-Verification Reconciliation.
        Enforces conservative fallbacks: never marks deleted on missing permissions or errors.
        """
        counts = {
            "deleted_confirmed": 0,
            "unresolved_retained": 0,
            "unresolved_inaccessible": 0,
            "unresolved_inconclusive": 0
        }

        with self._get_connection() as conn:
            cursor = conn.cursor()
            perm = media_lib.permission_state

            # Signal 1: Check active permissions
            if perm in (MockPermissionState.DENIED, MockPermissionState.RESTRICTED):
                for aid in candidate_ids:
                    cursor.execute("UPDATE reviewed_screenshots SET review_state = 'unresolved_inaccessible' WHERE asset_id = ?", (aid,))
                    counts["unresolved_inaccessible"] += 1
                conn.commit()
                return counts

            for aid in candidate_ids:
                # Signal 2: Check for lookup exceptions
                try:
                    exists = media_lib.obtain_for_id(aid)
                except Exception:
                    cursor.execute("UPDATE reviewed_screenshots SET review_state = 'unresolved_inconclusive' WHERE asset_id = ?", (aid,))
                    counts["unresolved_inconclusive"] += 1
                    continue

                # Signal 3: Evaluate asset state under active permission
                if perm == MockPermissionState.LIMITED and exists is None:
                    # Inaccessible under limited authorization (outside selection)
                    cursor.execute("UPDATE reviewed_screenshots SET review_state = 'unresolved_inaccessible' WHERE asset_id = ?", (aid,))
                    counts["unresolved_inaccessible"] += 1
                elif perm == MockPermissionState.AUTHORIZED and exists is None:
                    # Verified gone from OS library under full authorization
                    cursor.execute("UPDATE reviewed_screenshots SET review_state = 'deleted_confirmed' WHERE asset_id = ?", (aid,))
                    counts["deleted_confirmed"] += 1
                else:
                    # Still exists! (User cancelled, denied, or platform failed)
                    cursor.execute("UPDATE reviewed_screenshots SET review_state = 'unresolved_retained' WHERE asset_id = ?", (aid,))
                    counts["unresolved_retained"] += 1

            conn.commit()
        return counts


def run_comprehensive_tests():
    with tempfile.TemporaryDirectory() as temp_dir:
        db_file = os.path.join(temp_dir, "test_shot_persistence.db")

        print("======================================================================")
        print("SHOT POC 4: ENHANCED PERSISTENCE & RECONCILIATION STATE MACHINE TEST")
        print("======================================================================")
        print("[NOTICE] Running automated Python SQLite logic simulation.")
        print("         This does NOT validate compiled Flutter/Drift runtime code.\n")

        initial_assets = [f"asset_{i:03d}" for i in range(1, 31)]
        media_lib = MockOSMediaLibrary(initial_assets)
        pm = ShotPersistenceManager(db_file)
        session_id = str(uuid.uuid4())

        passed = 0
        total = 0

        # ---------------------------------------------------------------------
        total += 1
        print("[Test 1: Transaction Rollback on Failure]")
        try:
            pm.record_review_with_simulated_failure("asset_001", "pending_delete", session_id)
        except sqlite3.OperationalError:
            pass
        # Verify rollback: asset_001 must NOT exist in reviewed_screenshots
        assert pm.get_review_state("asset_001") is None
        print("  -> PASS: Atomic rollback verified. Database remained clean after failure.")
        passed += 1

        # ---------------------------------------------------------------------
        total += 1
        print("\n[Test 2: Multiple Review Actions on Single Asset]")
        # unreviewed -> kept -> pending_delete -> kept
        pm.record_review("asset_002", "kept", session_id)
        assert pm.get_review_state("asset_002") == "kept"
        pm.record_review("asset_002", "pending_delete", session_id)
        assert pm.get_review_state("asset_002") == "pending_delete"
        pm.record_review("asset_002", "kept", session_id)
        assert pm.get_review_state("asset_002") == "kept"
        # Undo once -> restores to pending_delete
        res = pm.undo_last_action(session_id)
        assert res['restored_state'] == "pending_delete"
        assert pm.get_review_state("asset_002") == "pending_delete"
        # Undo second time -> restores to kept
        res = pm.undo_last_action(session_id)
        assert res['restored_state'] == "kept"
        assert pm.get_review_state("asset_002") == "kept"
        print("  -> PASS: Multi-action sequence and sequential undo verified.")
        passed += 1

        # ---------------------------------------------------------------------
        total += 1
        print("\n[Test 3: Deterministic Undo Ordering with Identical Timestamps]")
        session_tiebreaker = str(uuid.uuid4())
        shared_timestamp = int(time.time() * 1000)
        # Rapid swiping in same millisecond
        pm.record_review("asset_003", "kept", session_tiebreaker, explicit_timestamp=shared_timestamp)
        pm.record_review("asset_004", "pending_delete", session_tiebreaker, explicit_timestamp=shared_timestamp)
        pm.record_review("asset_005", "kept", session_tiebreaker, explicit_timestamp=shared_timestamp)
        # Undo must pop asset_005 first (highest id), then asset_004, then asset_003
        u1 = pm.undo_last_action(session_tiebreaker)
        u2 = pm.undo_last_action(session_tiebreaker)
        u3 = pm.undo_last_action(session_tiebreaker)
        assert u1['asset_id'] == "asset_005", f"Expected asset_005, got {u1['asset_id']}"
        assert u2['asset_id'] == "asset_004", f"Expected asset_004, got {u2['asset_id']}"
        assert u3['asset_id'] == "asset_003", f"Expected asset_003, got {u3['asset_id']}"
        print("  -> PASS: Tie-breaking by primary key ID ensures strict LIFO order on identical timestamps.")
        passed += 1

        # ---------------------------------------------------------------------
        total += 1
        print("\n[Test 4: Reconciliation Under Permission Revocation (CRITICAL SAFETY TEST)]")
        # Setup: Mark asset_010 for deletion
        pm.record_review("asset_010", "pending_delete", session_id)
        # Simulate: User revokes photo permissions while deletion is occurring
        media_lib.set_permission(MockPermissionState.DENIED)
        # Post-reconciliation runs
        recon = pm.reconcile_post_deletion(["asset_010"], media_lib)
        # MUST NOT BE MARKED DELETED! Must be marked unresolved_inaccessible
        assert recon['deleted_confirmed'] == 0
        assert recon['unresolved_inaccessible'] == 1
        assert pm.get_review_state("asset_010") == "unresolved_inaccessible"
        print("  -> PASS: Permission loss safely prevented false-positive deletion reporting!")
        passed += 1

        # ---------------------------------------------------------------------
        total += 1
        print("\n[Test 5: Reconciliation Under iOS Limited Authorization]")
        # Restore permission to LIMITED
        media_lib.set_permission(MockPermissionState.LIMITED)
        # asset_011 is outside the user's limited selection
        media_lib.authorized_limited_subset = {"asset_012"}
        pm.record_review("asset_011", "pending_delete", session_id)
        recon = pm.reconcile_post_deletion(["asset_011"], media_lib)
        # Outside limited selection must be marked unresolved_inaccessible, NOT deleted
        assert recon['deleted_confirmed'] == 0
        assert recon['unresolved_inaccessible'] == 1
        assert pm.get_review_state("asset_011") == "unresolved_inaccessible"
        print("  -> PASS: Inaccessible limited-authorization assets safely preserved as unresolved.")
        passed += 1

        # ---------------------------------------------------------------------
        total += 1
        print("\n[Test 6: Reconciliation Under MediaStore Query Timeout / Error]")
        media_lib.set_permission(MockPermissionState.AUTHORIZED)
        pm.record_review("asset_013", "pending_delete", session_id)
        media_lib.simulate_lookup_error_for.add("asset_013")
        recon = pm.reconcile_post_deletion(["asset_013"], media_lib)
        assert recon['deleted_confirmed'] == 0
        assert recon['unresolved_inconclusive'] == 1
        assert pm.get_review_state("asset_013") == "unresolved_inconclusive"
        print("  -> PASS: Query exception safely marked unresolved_inconclusive; asset preserved.")
        passed += 1

        # ---------------------------------------------------------------------
        total += 1
        print("\n[Test 7: External Deletion Detection Prior to Batch]")
        pm.record_review("asset_014", "pending_delete", session_id)
        media_lib.delete_externally("asset_014")
        pre = pm.pre_deletion_check(["asset_014"], media_lib)
        assert "asset_014" in pre['externally_deleted']
        assert pm.get_review_state("asset_014") == "externally_deleted"
        print("  -> PASS: Pre-batch check caught external deletion and prevented OS batch error.")
        passed += 1

        # ---------------------------------------------------------------------
        total += 1
        print("\n[Test 8: Confirmed Deletion & Idempotent Retry]")
        pm.record_review("asset_015", "pending_delete", session_id)
        pm.record_review("asset_016", "pending_delete", session_id)
        # Simulate partial delete (asset_015 deleted, asset_016 fails in OS)
        media_lib.perform_os_deletion(["asset_015", "asset_016"], user_response="allow", partial_fail_ids={"asset_016"})
        recon = pm.reconcile_post_deletion(["asset_015", "asset_016"], media_lib)
        assert recon['deleted_confirmed'] == 1
        assert recon['unresolved_retained'] == 1
        assert pm.get_review_state("asset_015") == "deleted_confirmed"
        assert pm.get_review_state("asset_016") == "unresolved_retained"

        # Retry only unresolved item
        media_lib.perform_os_deletion(["asset_016"], user_response="allow")
        recon_retry = pm.reconcile_post_deletion(["asset_016"], media_lib)
        assert recon_retry['deleted_confirmed'] == 1
        assert pm.get_review_state("asset_016") == "deleted_confirmed"
        print("  -> PASS: Split outcome reconciled and retried idempotently without double-processing.")
        passed += 1

        # ---------------------------------------------------------------------
        total += 1
        print("\n[Test 9: Historical Record Preservation on Inaccessible Assets]")
        # Confirm that review_history still has all actions for asset_010 and asset_011
        with pm._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) as count FROM review_history WHERE asset_id IN ('asset_010', 'asset_011')")
            row = cursor.fetchone()
            assert row['count'] >= 2
        print("  -> PASS: Historical swipe decisions preserved in full for all unresolved assets.")
        passed += 1

        print("\n======================================================================")
        print(f"TEST RUN COMPLETE: {passed}/{total} SCENARIOS PASSED (100% SUCCESS)")
        print("STATUS: ENHANCED PERSISTENCE & RECONCILIATION SIMULATION VERIFIED")
        print("======================================================================")

if __name__ == "__main__":
    run_comprehensive_tests()
