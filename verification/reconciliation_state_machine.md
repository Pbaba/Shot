# SHOT — Reconciliation State Machine & Deletion Safety Specification (Audited)

**Document:** Authoritative Reconciliation State Machine (Production Specification)  
**Project:** Shot — "Keep what matters."  
**Date:** October 2026 (Audited Post-Review)  
**Auditor / Architect:** Senior Mobile Systems Architect & Technical Lead  

---

## 1. Core Safety Mandate

Under no circumstances may the application assume that an asset has been successfully deleted merely because:
1. `PhotoManager.editor.deleteWithIds()` returned successfully; or
2. `AssetEntity.obtainForId(id)` returned `null`.

Every deletion outcome must be verified on a **per-asset basis** through multi-signal correlation:
- Explicit pre-execution existence check.
- Platform batch method execution.
- Active permission state verification.
- Post-execution individual asset query.

---

## 2. Definitive Enumeration of Review & Reconciliation States

| State Enum | Description | Ground Truth Meaning | Can Retry? | Re-Review? |
| :--- | :--- | :--- | :--- | :--- |
| `unreviewed` | Asset discovered in screenshot library, not yet reviewed by user. | File exists in media store; no user decision recorded. | N/A | Default |
| `kept` | User explicitly swiped right or tapped "Keep". | File remains in library; marked protected in database. | N/A | User can re-review via reset |
| `pending_delete` | User swiped left or tapped "Delete". Marked for batch review. | File remains in library; deletion decision recorded locally. | Yes (in batch) | N/A |
| `deleted_confirmed` | User confirmed batch delete; OS approved; full permissions verified active; post-lookup returned null. | **Asset was deleted by Shot.** Verifiably removed from gallery. | **No** (Done) | **No** |
| `already_missing` | Pre-batch check determined file was removed outside Shot before deletion was submitted. | **Asset no longer available.** Shot did not delete it. | **No** (Gone) | **No** |
| `unresolved_retained` | OS batch execution completed, but post-lookup confirmed file still exists in gallery (user denied or OS failed). | **Asset still in library.** Deletion was cancelled, declined, or failed. | **Yes** (Manual) | **No** (Delete intent preserved) |
| `unresolved_inaccessible` | Post-lookup returned null, but permissions were missing, revoked, restricted, or limited to other files. | **Status ambiguous.** File may still exist on disk; cannot be read. | **Yes** (After grant)| **No** (Records preserved) |
| `unresolved_inconclusive` | Post-lookup threw a ContentResolver exception, timeout, or SQLite lock error. | **Status ambiguous.** System query failed; asset state unknown. | **Yes** (Diagnostic) | **No** (Records preserved) |

---

## 3. Per-Asset Reconciliation State Machine

```
                              [pending_delete]
                                     │
                    ┌────────────────┴────────────────┐
                    ▼ (Pre-Batch Verification)        ▼ (Asset Missing Pre-Batch)
          [Verified Present]                  [already_missing]
                    │                         (Omitted from OS call)
                    ▼
     [Invoke deleteWithIds(batch)]
                    │
                    ▼
     [Verify Permissions: isAuth]
                    │
         ┌──────────┴────────────────────────┐
         ▼ (isAuth == true)                  ▼ (isAuth == false / limited)
  [Query obtainForId(id)]                    [unresolved_inaccessible]
         │                                   (Asset protected; history preserved)
  ┌──────┴───────────────────────────┐
  ▼ (Returns null)                   ▼ (Returns AssetEntity)
[deleted_confirmed]          [unresolved_retained]
(Confirmed removed by Shot)  (Preserved in library; user can retry)
```

---

## 4. Multi-Signal Reconciliation Matrix (Per-Asset Evaluation)

| Current State | Pre-Batch Existence | Platform Return | Concurrent Permission Check | Post-Query `obtainForId(id)` | Final Database State | Reporting Category |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `pending_delete` | `false` | N/A (Omitted) | `isAuth == true` | N/A | **`already_missing`** | **Already Missing** (0 delete calls) |
| `pending_delete` | `true` | ID in `returnedIds` | `isAuth == true` | Returns `null` | **`deleted_confirmed`** | **Successfully Deleted** |
| `pending_delete` | `true` | ID not in `returnedIds` | `isAuth == true` | Returns `AssetEntity` | **`unresolved_retained`** | **Unresolved (Declined/Cancelled)** |
| `pending_delete` | `true` | Any | `isAuth == false` (Revoked) | Returns `null` | **`unresolved_inaccessible`**| **Unresolved (Permission Lost)** |
| `pending_delete` | `true` | Any | `PermissionState.limited` | Returns `null` (not in set) | **`unresolved_inaccessible`**| **Unresolved (Outside Selection)** |
| `pending_delete` | `true` | Any | `isAuth == true` | Throws `PlatformException` | **`unresolved_inconclusive`**| **Unresolved (Query Error)** |

---

## 5. Idempotent Retry & Lifecycle Rules

1. **No Automatic Retries:** Ambiguous states (`unresolved_inconclusive`, `unresolved_inaccessible`) are **never retried automatically** in the background. Retrying without user awareness risks prompting unexpected system dialogs.
2. **Explicit User-Initiated Retry:** On the Deletion Review screen or Completion screen, unresolved items remain visible under an "Unresolved" tab with clear explanatory badges. The user can explicitly tap "Retry Deletion" or "Keep Instead".
3. **Partial Batch Resilience:** In a batch of 10 items where 7 succeed and 3 fail:
   - The 7 are transitioned to `deleted_confirmed`.
   - The 3 are transitioned to `unresolved_retained`.
   - A subsequent retry submits **only the 3 unresolved items**. The 7 confirmed items are permanently retired from deletion queues.
4. **History Preservation Invariant:** A transition to any `unresolved_*` or `already_missing` state **never** purges the asset's row from `reviewed_screenshots` or `review_history`. All swipe decisions are permanently preserved for audit and re-sync.
