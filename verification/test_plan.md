# SHOT — Proof-of-Concept Verification Test Plan

**Document:** Verification Test Plan  
**Project:** Shot — "Keep what matters."  
**Date:** October 2026  
**Auditor / Architect:** Senior Mobile Systems Architect & Technical Lead  

---

## 1. Overview and Objectives

This test plan defines the formal hypotheses, test procedures, expected results, and pass/fail criteria for the four high-risk technical proof-of-concepts identified in **Technical Addendum 1.1**.

Per strict architectural standards:
- Tests must not claim to pass based merely on compilation, documentation claims, or simulator appearances.
- If physical hardware or platform tooling is missing, the test must be marked with its exact status (**PASS**, **FAIL**, **PARTIAL**, or **BLOCKED**) and detail the exact remediation required.
- Destructive tests must use disposable test media only. Real user screenshots must never be used.

---

## 2. PoC 1: Android Deletion Request & Result Verification

### Objective
Verify the exact behavior of Android media deletion requests via `photo_manager` (`PhotoManager.editor.deleteWithIds`), distinguishing permanent deletion from trashing, and verifying post-operation media library reconciliation.

### Hypothesis
1. On Android 11+ (API 30+), `deleteWithIds` triggers an OS-level confirmation dialog (`MediaStore.createTrashRequest` or `MediaStore.createDeleteRequest`).
2. If the user approves ("Allow"), the asset is removed from normal media queries, and `AssetEntity.obtainForId(id)` returns `null`.
3. If the user denies ("Deny") or dismisses the dialog, the asset remains untouched in the media library, and `AssetEntity.obtainForId(id)` continues to return a valid entity.
4. The plugin return value alone (`[]`) is inconclusive (occurs on user denial, permission revocation, and missing IDs); authoritative outcome must be verified via a post-deletion query.

### Test Procedure
1. **Source Inspection:** Inspect `flutter_photo_manager` Android native source for `deleteWithIds`, `moveToTrash`, and `createDeleteRequest` / `createTrashRequest`.
2. **Harness Setup:** Create disposable test image asset with identifiable name `test_disposable_screenshot.png`.
3. **Execution 1 (User Approval):**
   - Call `PhotoManager.editor.deleteWithIds([testAsset.id])`.
   - Tap "Allow" on the system dialog.
   - Record returned `List<String>`.
   - Query `AssetEntity.obtainForId(testAsset.id)` to confirm physical status.
4. **Execution 2 (User Cancellation):**
   - Call `PhotoManager.editor.deleteWithIds([testAsset2.id])`.
   - Tap "Deny" or dismiss the system dialog.
   - Record returned `List<String>`.
   - Query `AssetEntity.obtainForId(testAsset2.id)` to verify asset remains accessible.
5. **Execution 3 (Stale / Invalid ID):**
   - Call `PhotoManager.editor.deleteWithIds(['invalid_non_existent_id'])`.
   - Record returned value and error behavior.

### Expected Results
- Approval: `deleteWithIds` returns `[id]`; post-query `obtainForId(id)` returns `null`.
- Denial: `deleteWithIds` returns `[]`; post-query `obtainForId(id)` returns non-null entity.
- Invalid ID: `deleteWithIds` returns `[]` without unhandled platform crashes.

### Pass/Fail Criteria
- **PASS:** Native APIs confirmed, approval vs cancellation distinguished empirically, and post-query reconciliation validated on physical device.
- **PARTIAL:** Source code and API contracts verified; physical device execution unavailable.
- **FAIL:** Operation deletes files without system dialog, or post-query fails to detect retained assets.
- **BLOCKED:** Required Android device/AVD completely unavailable.

---

## 3. PoC 2: Android Screenshot Discovery & Heuristic Precision

### Objective
Evaluate the precision and recall of the multi-tiered Android screenshot discovery strategy across varied OEM directory structures and file types.

### Controlled Test Dataset Specification
The evaluation dataset must contain at least 20 ground-truth labeled image files:
1. Standard device screenshots (taken on device via Hardware buttons) (Ground Truth: `Screenshot`).
2. Camera photographs taken with device camera (`/DCIM/Camera/IMG_...jpg`) (Ground Truth: `Not_Screenshot`).
3. Downloaded web images (`/Download/web_graphic.png`) (Ground Truth: `Not_Screenshot`).
4. Social messaging images (`/Pictures/WhatsApp/` or `/Pictures/Telegram/`) (Ground Truth: `Not_Screenshot`).
5. Regular photos renamed to `Screenshot_fake.jpg` in Camera folder (Ground Truth: `Not_Screenshot`).
6. Genuine screenshots renamed to `photo.png` in Screenshot folder (Ground Truth: `Screenshot`).
7. Screenshots in custom 3rd-party directory (`/Pictures/CustomCapture/`) (Ground Truth: `Screenshot`).

### Test Procedure
1. Query MediaStore using **Tier 1**: `RELATIVE_PATH LIKE '%Screenshots%' OR RELATIVE_PATH LIKE '%Screenshot%'`.
2. Query MediaStore using **Tier 2**: `BUCKET_DISPLAY_NAME IN ('Screenshots', 'Capturas de pantalla', ...)` or localized bucket names.
3. Query MediaStore using **Tier 3**: `DISPLAY_NAME LIKE 'Screenshot_%'`.
4. Record for each tier:
   - True Positives (TP): Correctly identified screenshots.
   - False Positives (FP): Non-screenshots incorrectly tagged as screenshots.
   - False Negatives (FN): Screenshots missed by the query.
   - True Negatives (TN): Non-screenshots correctly ignored.
5. Evaluate **Tier 4 (SAF Fallback):** Verify that if Tiers 1-3 yield 0 results, the app displays an honest empty state and allows directory picking via Storage Access Framework, rather than silently querying all photos.
6. Calculate:
   $$\text{Precision} = \frac{\text{TP}}{\text{TP} + \text{FP}}$$
   $$\text{Recall} = \frac{\text{TP}}{\text{TP} + \text{FN}}$$

### Pass/Fail Criteria
- **PASS:** Precision = 1.0 (0 camera photos or regular images included); Recall >= 0.85; Tier 4 fallback prevents silent fallbacks.
- **PARTIAL:** Heuristic queries, ground truth dataset, and SAF fallback logic validated; physical multi-OEM execution unavailable.
- **FAIL:** Camera photos or downloaded images are falsely classified as screenshots ($\text{FP} > 0$).
- **BLOCKED:** Physical Android devices unavailable.

---

## 4. PoC 3: iOS Screenshot Access & Limited-Library Permissions

### Objective
Verify that Shot correctly isolates screenshots via iOS system smart albums (`PHAssetCollectionSubtype.smartAlbumScreenshots`), handles `PHAuthorizationStatusLimited` without misidentifying unselected photos as deleted, and provides a direct in-app path to expand authorization via `PhotoManager.presentLimited()`.

### Hypothesis
1. On iOS, `PMDarwinPathFilter` targeting `.smartAlbumScreenshots` fetches screenshots deterministically without exposing camera photos.
2. Under `limited` authorization, the smart album automatically filters to only authorized screenshots.
3. Assets outside the limited authorization return `null` on fetch, but are **not** flagged as deleted in the local database.
4. Calling `PhotoManager.presentLimited()` launches the system picker (`presentLimitedLibraryPickerFromViewController`) directly without requiring the user to switch to iOS Settings.

### Test Procedure
1. **Source Inspection:** Verify `PMDarwinPathFilter`, `darwin.mediaSubtypes`, and `presentLimited` implementation in `ios/Classes` of `photo_manager`.
2. **Full Access Test:** Request permission, grant "Allow Access to All Photos". Verify screenshots detected match Apple Photos "Screenshots" smart album count.
3. **Limited Access Test:** Change permission in Settings to "Select Photos...", selecting only 2 specific screenshots.
4. **Count & State Verification:** Verify Shot reports count = 2. Verify other previously known screenshots are not marked `deleted`.
5. **Re-Prompt Test:** Tap "Select More Screenshots"; confirm native iOS sheet opens. Select 1 additional screenshot. Confirm count updates to 3 without restarting app.

### Pass/Fail Criteria
- **PASS:** Smart album query matches Photos app exactly; limited access handled without false deletion reporting; `presentLimited()` functions smoothly.
- **PARTIAL:** Source code and API contracts verified; physical iPhone unavailable.
- **FAIL:** Inaccessible photos reported as deleted; camera photos returned in screenshot collection.
- **BLOCKED:** macOS / iOS development hardware completely unavailable on host.

---

## 5. PoC 4: Drift Persistence & Interrupted-Batch Reconciliation

### Objective
Verify that Shot's review state remains transactional, idempotent, and resilient against application crashes, unexpected interruptions during deletion, external file deletions, and incomplete batches.

### Test Scenarios to Validate
1. **Normal Persistence:** Swiping Keep and Delete correctly inserts and updates rows in `reviewed_screenshots` and `review_history`.
2. **App Restart:** Restarting the database restores all reviewed states.
3. **Crash Before Deletion:** App killed while on Deletion Review screen before calling OS deletion API. Verify state remains `pending_delete` and no items are lost.
4. **Crash During / After Partial Deletion:** App killed after OS deleted 2 of 5 items. Post-verification query detects which 2 are gone and marks them `deleted`, while the remaining 3 stay `pending_delete`.
5. **External Deletion Detection:** Screenshot deleted externally by user prior to batch deletion. Pre-execution check identifies asset is missing, marks `externally_deleted`, and omits it from batch.
6. **Cancellation / Rejection Handling:** OS deletion rejected by user. Post-verification query detects all items still exist and keeps them `pending_delete` without marking them deleted.
7. **Idempotent Retry:** Re-running deletion on remaining unresolved items does not re-attempt already-deleted records.

### Pass/Fail Criteria
- **PASS:** All 7 scenarios pass automated testing; database maintains strict integrity; media library ground truth is never overridden by stale database state.
- **FAIL:** Any scenario leads to database corruption, lost review decisions, or unverified deletions.
- **BLOCKED:** Execution environment unavailable.
