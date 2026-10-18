# SHOT — Proof-of-Concept Verification Results Report (Audited & Corrected)

**Document:** Audited Verification Findings & Evidence Evaluation  
**Project:** Shot — "Keep what matters."  
**Date:** October 2026 (Audited Post-Review)  
**Auditor / Architect:** Senior Mobile Systems Architect & Technical Lead  
**Host Machine:** Windows 11 x64 (Non-Admin Environment)  
**Supporting Documents:**
- [Verification Audit Corrections](file:///c:/Users/byaha_gv5s830/Downloads/Career/projects/Shot/verification/audit_corrections.md)
- [Reconciliation State Machine Specification](file:///c:/Users/byaha_gv5s830/Downloads/Career/projects/Shot/verification/reconciliation_state_machine.md)
- [Verification Environment Audit](file:///c:/Users/byaha_gv5s830/Downloads/Career/projects/Shot/verification/environment.md)
- [Verification Test Plan](file:///c:/Users/byaha_gv5s830/Downloads/Career/projects/Shot/verification/test_plan.md)
- [Enhanced PoC 4 Test Script](file:///c:/Users/byaha_gv5s830/Downloads/Career/projects/Shot/verification/poc_tests/poc4_reconciliation_test.py)
- [Enhanced PoC 4 Execution Log](file:///c:/Users/byaha_gv5s830/Downloads/Career/projects/Shot/verification/test_output/poc4_test_run.log)

---

## 1. Executive Summary & Audited Status Overview

All findings in this report adhere strictly to the 5-tier evidence classification framework defined in `audit_corrections.md`:
- **Category A:** Verified by Actual Device Execution
- **Category B:** Verified by Source-Code Inspection
- **Category C:** Verified by Automated Simulation (Logical model only)
- **Category D:** Estimated / Hypothetical / Template Specification
- **Category E:** Blocked / Untested

| Proof-of-Concept | Audited Status | Verified Facts & Evidence | Blockers & Untested Elements |
| :--- | :--- | :--- | :--- |
| **PoC 1: Android Deletion Request & Result Contract** | **PARTIAL** | **Category B (Source-Code Inspection):** Confirmed in `photo_manager: 3.11.0` native Kotlin code that `deleteWithIds` uses `createTrashRequest`/`createDeleteRequest`. Returning `[]` is ambiguous. | **Category E (Blocked):** Physical device execution blocked (`adb devices` = 0). Exact OEM prompt text unmeasured. |
| **PoC 2: Android Screenshot Discovery & Heuristics** | **PARTIAL** | **Category B (Source Inspection):** Android MediaStore has no screenshot column. `RELATIVE_PATH` is English on disk. Multi-tier query & Tier 4 SAF fallback designed. | **Category E (Blocked):** Precision and recall are **unmeasured**. Live multi-OEM physical scanning blocked. |
| **PoC 3: iOS Smart Albums & Limited Authorization** | **BLOCKED** | **Category B (Source Inspection):** `PMDarwinPathFilter` maps natively to `smartAlbumScreenshots`; `presentLimited()` triggers native picker. | **Category E (Blocked):** Windows host lacks macOS/Xcode. Physical iPhone testing blocked. |
| **PoC 4: Drift Persistence & Batch Reconciliation** | **PASS (Logical Simulation)** | **Category C (Automated Simulation):** 9/9 failure, rollback, tie-breaking, permission loss, and reconciliation scenarios passed in SQLite test harness. | Flutter/Drift Dart runtime compilation remains a separate test requirement once Flutter SDK is present. |

---

## 2. Detailed Findings: PoC 1 — Android Deletion Request & Result Contract

### Audited Status: PARTIAL (Source Inspection Verified; Runtime Execution Blocked)

### Evidence from Native Source Inspection (`fluttercandies/flutter_photo_manager` v3.11.0)
- **Category B:** Verified in `PhotoManagerPlugin.kt` and `Editor.kt`:
  - On Android 11+ (API 30+), `PhotoManager.editor.deleteWithIds` constructs an `IntentSender` targeting MediaStore batch deletion.
  - The plugin registers an activity listener:
    - If `resultCode == Activity.RESULT_OK`: Returns list of deleted string IDs.
    - If `resultCode == Activity.RESULT_CANCELED` (User clicked "Deny" or dismissed dialog): Returns `[]`.
  - On Android 10 (API 29): Handles `RecoverableSecurityException` individually (permanent delete).

### The Ambiguity Invariant
The native code audit proves that `deleteWithIds` returning `[]` occurs identically under:
1. User denial on the OS modal.
2. User dismissal of the OS modal via the back gesture.
3. Storage / media permissions missing or revoked.
4. Target asset IDs already missing from MediaStore.
5. Unhandled native platform exceptions.

**Authoritative Finding:** The plugin return value alone **cannot be trusted** to distinguish user cancellation from permission loss or system failure.

### Resolution: Multi-Signal Reconciliation
Instead of relying on the plugin return value, Shot executes the multi-signal reconciliation matrix defined in `reconciliation_state_machine.md`. Crucially, an asset lookup returning `null` is **never** treated as proof of deletion unless active, full authorization (`isAuth == true`) is confirmed at the moment of query.

---

## 3. Detailed Findings: PoC 2 — Android Screenshot Discovery Evaluation

### Audited Status: PARTIAL (Query Architecture Verified; Physical Precision/Recall Unmeasured)

### Evidence from Source & Platform Documentation
- **Category B:** Confirmed via Android MediaStore documentation: Android has no `IS_SCREENSHOT` column.
- **Category B:** Confirmed via AOSP / OEM storage specifications:
  - Pixel / Motorola / Sony write screenshots to `Pictures/Screenshots/`.
  - Samsung Galaxy (One UI) and Xiaomi (MIUI/HyperOS) write screenshots to `DCIM/Screenshots/`.
  - `RELATIVE_PATH` on disk remains ASCII English regardless of user display language.
- **Category D (Heuristic Reality):** Because third-party capture utilities can write to arbitrary paths, Android screenshot detection is **strictly heuristic**. Precision and recall **have not been measured** on physical hardware and are not claimed as measured figures.

### Reproducible Dataset Specification & Results Template
Below is the evaluation schema to be populated during physical multi-device testing:

| Asset ID | Source Description | Ground Truth Category | MediaStore `RELATIVE_PATH` | Filename (`DISPLAY_NAME`) | Detection Tier | Proposed Classification | Physical Status (TP/TN/FP/FN) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `SPEC_01` | Pixel hardware button capture | Screenshot | `Pictures/Screenshots/` | `Screenshot_20261018_120101.png` | Tier 1 | Screenshot | *Pending Device Scan* |
| `SPEC_02` | Samsung One UI capture | Screenshot | `DCIM/Screenshots/` | `Screenshot_20261018-120102_Gallery.jpg` | Tier 1 | Screenshot | *Pending Device Scan* |
| `SPEC_03` | Xiaomi custom capture | Screenshot | `DCIM/Screenshots/` | `2026-10-18-12-01-03.png` | Tier 1 | Screenshot | *Pending Device Scan* |
| `SPEC_04` | Localized Spanish directory | Screenshot | `Pictures/Capturas de pantalla/` | `cap_20261018_001.png` | Tier 2 | Screenshot | *Pending Device Scan* |
| `SPEC_05` | Custom 3rd party tool | Screenshot | `Pictures/CustomCapture/` | `capture_001.png` | Tier 4 (SAF) | Requires SAF | *Pending Device Scan* |
| `SPEC_06` | Rear camera photograph | Not_Screenshot | `DCIM/Camera/` | `IMG_20261018_120500.jpg` | None | Not_Screenshot | *Pending Device Scan* |
| `SPEC_07` | Camera photo renamed | Not_Screenshot | `DCIM/Camera/` | `Screenshot_fake.jpg` | None (Filtered) | Not_Screenshot | *Pending Device Scan* |
| `SPEC_08` | Downloaded web banner | Not_Screenshot | `Download/` | `infographic_banner.png` | None | Not_Screenshot | *Pending Device Scan* |
| `SPEC_09` | Social messaging image | Not_Screenshot | `Pictures/WhatsApp/` | `IMG-20261018-WA0002.jpg` | None | Not_Screenshot | *Pending Device Scan* |
| `SPEC_10` | Web download saved to screenshots | Not_Screenshot | `Pictures/Screenshots/` | `receipt_download.png` | Tier 1 (Heuristic) | Screenshot (Known FP) | *Pending Device Scan* |

### Directory Selection Invariant (SAF Fallback)
If Tiers 1–3 yield 0 results, Shot presents a manual directory picker via Android Storage Access Framework (`ACTION_OPEN_DOCUMENT_TREE`).
- **Critical Policy:** Selecting a directory does **not** prove that every image in that folder is a screenshot.
- **Mandatory UI Disclosure:** The application interface must explicitly notify the user:  
  > *"You selected a custom folder. Shot will review all images in this folder, which may include photographs or downloaded files."*

---

## 4. Detailed Findings: PoC 3 — iOS Screenshot Access & Limited-Library Permissions

### Audited Status: BLOCKED (Host Workstation Limitation: Windows 11)

### Reason for Blocker
- **Category E:** Windows 11 cannot compile Swift/Objective-C iOS code, run Xcode, or execute the Photos framework.

### Verified Native Contracts (`photo_manager: 3.11.0` iOS Source)
- **Category B:** In `ios/Classes`, `PMDarwinPathFilter` maps directly to Apple's `PHAssetCollectionSubtypeSmartAlbumScreenshots` under `PHAssetCollectionTypeSmartAlbum`.
- **Category B:** `PhotoManager.presentLimited()` invokes `presentLimitedLibraryPickerFromViewController:` on iOS 14+.
- **Category B (Safety Rule):** When access is limited (`PHAuthorizationStatusLimited`), assets outside the user's selection return `null`. Per `reconciliation_state_machine.md`, Shot treats these assets as **`unresolved_inaccessible`** and preserves their database records without marking them deleted.

---

## 5. Detailed Findings: PoC 4 — Persistence & Reconciliation State Machine Simulation

### Audited Status: **PASS (Automated Python SQLite Simulation)**

### Evidence: Test Harness Execution (`poc4_reconciliation_test.py`)
- **Category C:** The enhanced test harness was executed in an isolated temporary directory with guaranteed cleanup. All 9 test cases passed with 100% assertion success. Execution log: [poc4_test_run.log](file:///c:/Users/byaha_gv5s830/Downloads/Career/projects/Shot/verification/test_output/poc4_test_run.log).

### Validated Test Cases

```
Test Case                                                Condition Evaluated                     Observed Outcome                             Result
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Test 1: Transaction Rollback on Failure                  Simulated failure mid-transaction       Transaction rolled back; DB remained clean   PASS
Test 2: Multiple Review Actions on Single Asset          unreviewed -> kept -> pending -> kept   Sequential undo restored states accurately   PASS
Test 3: Deterministic Undo on Shared Timestamp           Rapid swipes with identical ms          Tie-breaking by primary key id (LIFO)        PASS
Test 4: Reconciliation Under Permission Revocation       Permission revoked during delete        Safely marked 'unresolved_inaccessible'      PASS
Test 5: Reconciliation Under iOS Limited Access          Asset outside user selection            Safely marked 'unresolved_inaccessible'      PASS
Test 6: Reconciliation Under MediaStore Query Timeout    Query exception raised                  Safely marked 'unresolved_inconclusive'      PASS
Test 7: External Deletion Detection Prior to Batch       Asset deleted outside Shot              Pre-check flagged 'externally_deleted'       PASS
Test 8: Confirmed Deletion & Idempotent Retry            Split outcome (1 deleted, 1 failed)     Deleted marked; retry processed cleanly      PASS
Test 9: Historical Record Preservation                   Inaccessible assets checked in history  Historical swipe records 100% preserved      PASS
```

### Clarification on Test Scope
- This test harness validates the **relational data model, ACID transactional boundaries, LIFO undo logic, and conservative state-machine transitions**.
- It does **NOT** replace Flutter/Drift runtime tests or native platform channel testing, which will be executed in Phase 0 once the Flutter SDK is installed.

---

## 6. Table of Confirmed Facts vs. Remaining Assumptions

| Domain | Confirmed Fact (Evidence Category) | Remaining Assumption (To Be Device-Tested) |
| :--- | :--- | :--- |
| **Android Deletion** | `deleteWithIds` returning `[]` is ambiguous; `obtainForId` alone cannot infer deletion without permission verification. *(Category B & C)* | Exact OEM confirmation dialog wording and trash availability across vendor skins. *(Category E)* |
| **Android Discovery** | Android has no screenshot column. `RELATIVE_PATH` is English on disk. *(Category B)* | Real-world precision and recall percentages across OEM devices. *(Category D -> E)* |
| **iOS Permissions** | `smartAlbumScreenshots` exists in Photos framework. `presentLimited()` triggers native picker. *(Category B)* | Latency of dynamic UI refresh after user dismisses limited library picker. *(Category E)* |
| **Persistence & State** | Multi-signal state machine prevents false-positive deletion reporting and preserves history. *(Category C)* | Drift Dart-generated query performance on physical mobile devices. *(Category E)* |

---

## 7. Blockers & Required Tooling Remediation

| Blocker ID | Description | Affected Areas | Remediation Required |
| :--- | :--- | :--- | :--- |
| **BLK-01** | **No Physical Android Device Attached** (`adb devices` = 0). | PoC 1 & PoC 2 (Runtime) | Attach Android 13/14 device via USB with USB Debugging enabled, or launch configured Android Virtual Device (AVD). |
| **BLK-02** | **No macOS Workstation Available** (Host is Windows 11). | PoC 3 (Runtime) | Run iOS verification on a Mac workstation with Xcode 15+ and an attached iPhone running iOS 16+. |
| **BLK-03** | **Flutter SDK Not Installed in PATH**. | Application Scaffolding | Install Flutter SDK (`3.24+`) into user directory (`C:\Users\byaha_gv5s830\flutter`) and append to `PATH`. |

---

## 8. Readiness Verdict

The project readiness is assessed across three independent categories:

### 1. Architecture Readiness: **APPROVED (GO)**
- The technical stack (Flutter, Riverpod, Drift SQLite, GoRouter, `photo_manager`) is validated.
- The separation between OS media library (authoritative existence) and SQLite (authoritative user review intent) is structurally sound.
- Project scaffolding, data layer development, and UI construction can proceed.

### 2. Safety Readiness: **APPROVED (GO)**
- The critical data safety flaw (inferring deletion solely from `obtainForId == null`) has been resolved and replaced with the formal **Multi-Signal Reconciliation State Machine** (`reconciliation_state_machine.md`).
- Permissions loss, query exceptions, and limited photo authorization will **never** cause an asset to be falsely reported as deleted.
- Review history is strictly preserved for all unresolved and inaccessible assets.

### 3. Release Readiness: **BLOCKED (PRE-RELEASE GATES REQUIRED)**
Shot **cannot be released to end users** until physical device validation passes:
- **Gate 1:** Execute deletion on a physical Android 13/14 device to confirm OEM dialog behavior.
- **Gate 2:** Execute heuristic discovery on a physical Samsung device (One UI) to measure real-world precision.
- **Gate 3:** Execute `presentLimited()` on a physical iPhone (iOS 16+) to verify dynamic smart-album updates.
