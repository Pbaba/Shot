# SHOT — Verification Audit Corrections

**Document:** Audit Corrections & Evidence Classification  
**Project:** Shot — "Keep what matters."  
**Date:** October 2026  
**Auditor / Architect:** Senior Mobile Systems Architect & Technical Lead  

---

## 1. Purpose of this Audit

This document formally audits and corrects the claims, evidence classifications, and terminology in the `verification/` documents (`results.md`, `test_plan.md`, and `environment.md`). 

The objective is to eliminate overstatements, separate empirical device measurements from simulations and specifications, and establish an unvarnished baseline of what is proven versus what remains hypothetical or blocked.

---

## 2. Evidence Classification Framework

Every statement of technical capability across the Shot verification reports is classified strictly into one of five categories:

| Category | Definition | Allowed Citations & Proof |
| :--- | :--- | :--- |
| **Category A: Verified by Actual Device Execution** | Directly observed running on physical mobile hardware or native emulator with reproducible logs/traces. | Hardware model, OS build, logcat / console logs, captured system dialogs. |
| **Category B: Verified by Source-Code Inspection** | Directly verified by reading the published package source code, native platform headers, or official platform SDK implementation. | Repository URLs, exact file paths, line numbers, API signatures. |
| **Category C: Verified by Automated Simulation** | Verified via executable unit/integration test harnesses running on developer workstation under simulated models. | Test scripts, execution logs, SQLite assertion outputs. *(Must not be conflated with production Dart/Flutter runtime).* |
| **Category D: Estimated or Hypothetical** | Reasonable engineering projections, targets, or analytical models that have not yet been empirically measured. | Analytical models, performance targets, dataset templates. |
| **Category E: Blocked or Untested** | Capabilities that cannot be executed due to missing hardware, missing SDKs, or platform constraints. | Missing tool inventory, blocked test descriptions. |

---

## 3. Specific Audit Corrections to `results.md`

### Correction 1: Removal of Speculative Android Precision/Recall Percentages
- **Original Claim in `results.md` (Section 3):**
  > *"Tier 1: Estimated Precision ~96%, Estimated Recall ~88%... Tier 2: Estimated Precision ~92%, Estimated Recall ~90%..."*
- **Correction & Status:** **REMOVED AS SPECULATIVE (Category D).**
  - No physical Android device was connected during PoC 2 (`adb devices` returned 0 attached).
  - These percentages were analytical estimates, not empirical measurements.
  - **Corrected Statement:** Precision and recall on Android cannot be quantified until physical scans across diverse OEM file systems are executed against a labeled ground-truth dataset. All heuristic detection performance remains **unmeasured and hypothetical**.

### Correction 2: Reclassification of the "20-Asset Controlled Dataset"
- **Original Claim in `results.md` (Section 3):**
  Presented a table of 20 assets (`A01` to `A10` shown) implying they were scanned assets from a test device.
- **Correction & Status:** **RECLASSIFIED AS SPECIFICATION TEMPLATE (Category D).**
  - The 20-asset table in `results.md` is a **reproducible evaluation specification and ground-truth schema**, NOT a log of physical files scanned on an Android device.
  - The actual scanning of physical test assets is **BLOCKED (Category E)** pending attachment of physical hardware.

### Correction 3: Clarification of Python Test Harness Scope (PoC 4)
- **Original Claim in `results.md` (Section 1 & 5):**
  > *"PoC 4: PASS... Invariants proven by PoC 4... SQLite schema and reconciliation handle crashes... with 100% integrity."*
- **Correction & Status:** **RECLASSIFIED AS AUTOMATED LOGICAL SIMULATION (Category C).**
  - The test harness ([poc4_reconciliation_test.py](file:///c:/Users/byaha_gv5s830/Downloads/Career/projects/Shot/verification/poc_tests/poc4_reconciliation_test.py)) is implemented in Python using SQLite 3.
  - It validates the **relational schema, state machine transitions, reconciliation algorithms, and SQL query correctness** under simulated conditions.
  - It does **NOT** validate:
    - The compiled Flutter runtime or Dart SDK behavior.
    - Drift's generated Dart code (`drift_dev` / `driftDatabase`).
    - The `photo_manager` native platform channel bindings.
  - A dedicated Flutter/Drift automated test suite remains a requirement once the Flutter SDK is installed.

### Correction 4: Clarification of Simulated Interruption vs. OS Process Termination
- **Original Claim in `results.md`:**
  Referred to "app restart" and "crash before/after deletion".
- **Correction & Status:** **RECLASSIFIED AS APPLICATION-LEVEL SIMULATION (Category C).**
  - The test closed SQLite connections and re-opened them, and raised Python runtime exceptions before database commits.
  - This simulates application-level interruption and crash boundaries, but does **NOT** constitute an OS-level `SIGKILL`, Android low-memory killer (LMK) termination, or sudden power-loss test on flash storage.

### Correction 5: Correction of Naive `AssetEntity.obtainForId() == null` Assumption
- **Original Claim in Addendum 1.1 & `results.md` (Section 2):**
  Claimed that if `AssetEntity.obtainForId(id) == null`, the asset is authoritatively confirmed deleted.
- **Correction & Status:** **REVISED FOR SAFETY (Critical Safety Defect Fixed).**
  - `obtainForId(id)` returning `null` does **not** prove deletion if permissions were revoked, if the asset is inaccessible under iOS Limited Authorization, or if a MediaStore query error occurred.
  - A multi-condition state machine is required (detailed in `reconciliation_state_machine.md`).

---

## 4. Comprehensive Audit Table of Claims

| Document & Section | Statement / Claim | Prior Classification | Audited Evidence Category | Correction Applied |
| :--- | :--- | :--- | :--- | :--- |
| **`results.md` §2** | `deleteWithIds` triggers `createTrashRequest`/`createDeleteRequest`. | Claimed as fact | **Category B (Source-Code Inspection)** | Verified by reading `PhotoManagerPlugin.kt` and `Editor.kt` in package repository. |
| **`results.md` §2** | Plugin return value `[]` is ambiguous. | Claimed as fact | **Category B (Source-Code Inspection)** | Verified by inspecting `onActivityResult` logic in native Android code. |
| **`results.md` §3** | Tier 1/2 Precision/Recall percentages (~96%/~88%). | Claimed as estimated result | **Category D (Hypothetical)** | **Removed.** Labeled as unmeasured until hardware scan occurs. |
| **`results.md` §3** | 20-asset evaluation dataset. | Implied test assets | **Category D (Specification Template)** | Clarified as synthetic ground-truth test specification. |
| **`results.md` §4** | `PMDarwinPathFilter` maps to `.smartAlbumScreenshots`. | Claimed as verified | **Category B (Source-Code Inspection)** | Verified via `ios/Classes` source in `photo_manager`. Device execution is **Category E (Blocked)**. |
| **`results.md` §5** | PoC 4 SQLite persistence and reconciliation. | Claimed as PASS | **Category C (Automated Simulation)** | Validated for relational logic. Separated from Flutter/Drift runtime validation. |
| **`environment.md`** | Absence of Flutter SDK, connected devices, and macOS. | Environment audit | **Category A (Workstation Observation)** | Verified by executing system commands (`adb devices`, `where.exe flutter`). |
