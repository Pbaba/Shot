# SHOT — Native API Contract & Deletion Mechanics Audit

**Document:** Native API Contract Audit  
**Package:** `photo_manager: 3.11.0` / `photo_manager_image_provider: 2.1.0`  
**Publisher:** FlutterCandies (Verified Publisher)  
**Date:** October 2026  
**Auditor / Architect:** Senior Mobile Systems Architect & Technical Lead  

---

## 1. Executive Summary & Purpose

This audit establishes the concrete native platform contracts governing media deletion, authorization states, and asset lookups in `photo_manager: 3.11.0` across Android and iOS. 

It eliminates speculative assumptions and provides the exact technical constraints that the Shot application foundation and reconciliation service must enforce.

---

## 2. Android Deletion Contract (`deleteWithIds`)

### Source Implementation Location
- **Repository:** [`fluttercandies/flutter_photo_manager`](https://github.com/fluttercandies/flutter_photo_manager)
- **Native Implementation Path:** `android/src/main/kotlin/com/fluttercandies/photo_manager/core/PhotoManagerPlugin.kt` and `core/Editor.kt`
- **Method Channel Signature:** `PhotoManager.editor.deleteWithIds(List<String> ids)` -> Native Method Call: `"deleteWithIds"`

### Execution Flow & Native API Mapping

```
PhotoManager.editor.deleteWithIds(ids)
                 │
                 ▼
     [Android Native Layer: Editor.kt]
                 │
  ┌──────────────┴────────────────────────┐
  ▼ (API >= 30: Android 11-15)            ▼ (API 29: Android 10)
Collect URIs from MediaStore           Attempt ContentResolver.delete()
Call MediaStore.createTrashRequest()     Catch RecoverableSecurityException
(or MediaStore.createDeleteRequest)      Launch IntentSender
Receive PendingIntent                    Receive onActivityResult
Launch via startIntentSenderForResult    │
                 │                       │
                 ▼                       ▼
      [System Confirmation Dialog Displayed to User]
                 │
  ┌──────────────┴────────────────────────┐
  ▼ (User Approves: RESULT_OK)            ▼ (User Rejects / Cancels: RESULT_CANCELED)
MediaStore moves to trash / unlinks    Zero assets modified
Native returns List<String> of IDs     Native returns empty List<String> ([])
```

### Precise Contract Interpretation: What Do Returned IDs Mean?
- **When a non-empty `List<String>` is returned:**
  It means that the Android OS dialog received `Activity.RESULT_OK` (the user approved the system dialog), and the operating system's MediaStore executed the batch intent.
- **Critical Distinction:** The return value does **not** indicate whether the asset was permanently destroyed or moved to vendor-specific trash. It only confirms that the OS accepted the operation.
- **When an empty list `[]` is returned:**
  It occurs identically under:
  1. User selected "Deny" or "Cancel".
  2. User backed out of the dialog via gesture/back button.
  3. `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` permission was revoked.
  4. The submitted IDs were invalid or no longer exist.
  5. An unhandled Android platform exception occurred.

**Contract Verdict:** An empty list `[]` is **inconclusive**. It must never be treated as proof of user cancellation without state verification.

---

## 3. Android Deletion vs. Trash Request Semantics

| Feature | `MediaStore.createDeleteRequest` | `MediaStore.createTrashRequest` | `photo_manager: 3.11.0` Reality |
| :--- | :--- | :--- | :--- |
| **API Level** | API 30+ (Android 11+) | API 30+ (Android 11+) | API 30+ |
| **System Prompt Text** | *"Allow [App] to delete [N] photos permanently?"* | *"Allow [App] to move [N] photos to trash?"* | Depends on target OEM and plugin flag |
| **Recovery Window** | **0 Days** (Immediately destroyed) | **30 Days** (Hidden in `IS_TRASHED=1`) | Unpredictable across OEM custom ROMs |
| **OEM Gallery UI** | N/A (Gone) | Google Photos exposes Trash; many AOSP/OEM galleries do NOT expose Trash UI | User may be unable to recover items if OEM lacks Trash UI |

### Architectural Invariant for Shot:
Shot **must never promise a Trash or Recently Deleted experience on Android**. The UI confirmation modal must state:
> *"Selected screenshots will be permanently deleted from this device (or moved to system trash if supported by your device)."*

---

## 4. iOS Deletion & Authorization Contract

### Source Implementation Location
- **Native Implementation Path:** `ios/Classes/core/PMEditor.m` and `core/PMManager.m`
- **Native API:** `PHPhotoLibrary.sharedPhotoLibrary performChanges:completionHandler:`

### Authorization State Representation

| iOS Native Constant (`PHAuthorizationStatus`) | `photo_manager` Dart Enum (`PermissionState`) | Capabilities & Behavior in Shot |
| :--- | :--- | :--- |
| `PHAuthorizationStatusNotDetermined` (0) | `PermissionState.notDetermined` | Initial state. Must request permission before querying. |
| `PHAuthorizationStatusRestricted` (1) | `PermissionState.restricted` | Restricted by parental controls / MDM profiles. Cannot delete. |
| `PHAuthorizationStatusDenied` (2) | `PermissionState.denied` | User denied. All asset queries return null/empty. |
| `PHAuthorizationStatusAuthorized` (3) | `PermissionState.authorized` | Full read/write access to entire photo library. |
| `PHAuthorizationStatusLimited` (4) | `PermissionState.limited` | **iOS 14+ Limited Access.** Only authorized assets are visible. System smart album `.smartAlbumScreenshots` only returns authorized screenshots. |

### Deletion Contract on iOS:
- **API Invoked:** `[PHAssetChangeRequest deleteAssets:assets]`.
- **System Guarantee:** Apple **guarantees** that assets are moved to the system "Recently Deleted" album (soft-delete for 30 days).
- **User Prompt:** Non-bypassable system alert: *"Allow 'Shot' to delete [N] photos?"*.
- **Result Contract:**
  - If user confirms: `success == YES`; returns array of deleted `localIdentifier` strings.
  - If user denies: `success == NO`; `NSError` code `3072` (`PHPhotosErrorDomain`); returns empty array `[]`.

---

## 5. Exact Semantics & Limitations of `AssetEntity.obtainForId()`

### Method Definition
```dart
static Future<AssetEntity?> obtainForId(String id);
```

### Query Semantics:
1. **Under Full Authorization (`isAuth == true`):**
   - Queries MediaStore (Android) or `PHAsset fetchAssetsWithLocalIdentifiers:` (iOS).
   - If asset exists on disk and is indexed: Returns `AssetEntity`.
   - If asset was deleted, unlinked, or moved to trash (`IS_TRASHED=1`): Returns `null`.
2. **Under Revoked or Denied Permissions:**
   - ContentResolver query fails or Photos framework returns empty fetch.
   - Returns **`null`**.
3. **Under iOS Limited Authorization (`PermissionState.limited`):**
   - If the asset was not selected by the user in the system picker: Returns **`null`**.
4. **Under Query Exceptions or SQLite Locks:**
   - Throws `PlatformException` or times out.

### Permission Race Conditions:
- **Scenario:** Shot checks permissions at $t_0$ (`isAuth == true`). At $t_1$, the OS deletion dialog completes. At $t_2$, user revoked permission in Settings or app entered background. At $t_3$, Shot calls `obtainForId(id)`.
- **Outcome:** `obtainForId` returns `null`.
- **Risk:** If Shot naively infers that `null == deleted`, it marks the asset as deleted when it was actually hidden due to permission loss.
- **Definitive Mitigation:** Shot must re-verify permissions **simultaneously** with post-deletion lookups. If permission is no longer `authorized`, the asset transitions to `unresolved_inaccessible`, **never** `deleted_confirmed`.
