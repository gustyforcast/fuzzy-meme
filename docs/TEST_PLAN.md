# Test Plan / QA Strategy

## 1. Test Levels

| Level | Target | Tooling |
| --- | --- | --- |
| Unit | `VersoCore` (dedup algorithms, clustering, field/enum logic) | XCTest, pure Swift — no simulator required |
| Integration | `VersoPhotoKit` (PhotoKit read/write round-trip), `VersoCloudSync` (CloudKit record CRUD, conflict resolution) | XCTest against a real/simulator Photos library and a CloudKit development environment |
| UI | Both platform UI layers | XCUITest for scripted flows; manual for gesture-feel/UX judgment calls that don't reduce well to assertions |
| Manual / exploratory | Whole app, real photo libraries | Primary user (Tim) as first tester, then TestFlight cohort |

## 2. Duplicate Detection Accuracy (the highest-risk area — ties directly to SPEC.md's core differentiation claim)

This is the one area where "it compiles and runs" is not sufficient — the feature's whole value proposition is *accuracy*, so it needs a measured, repeatable evaluation:

- **Test corpus:** build a fixture set (not shipped with the app) covering:
  - True exact duplicates (byte-identical).
  - True near-duplicates: same frame re-exported at different quality/size, minor crop, minor colour edit, HDR vs. non-HDR version of the same capture.
  - True bursts: 5–15 frame sequences from a single subject/moment.
  - Visually similar but **distinct** captures (same subject, different moment — e.g., two frames of a static scene shot a minute apart) — these must NOT be flagged, and are the main false-positive risk.
  - Film-scan-specific cases: same frame scanned twice at different settings (a real scenario for this user).
- **Metrics tracked and reported before v1 ships:**
  - Exact-match recall (must be effectively 100% — this is just hashing).
  - Near-dup recall and false-positive rate on the corpus above, at the chosen `VNGenerateImageFeaturePrintRequest` distance threshold.
  - Burst-clustering correctness (are true bursts grouped as one cluster, not split or over-merged).
- **Gate:** near-dup false-positive rate above an agreed threshold (proposed: <2% on the corpus) blocks v1 launch — a false "these are duplicates" claim actively damages trust in exactly the way SPEC.md positions this app against Apple Photos' weaker dedup.

## 3. PhotoKit Round-Trip Tests (Phase 0 spike, formalized as tests)

- Write a star rating via `PHAssetChangeRequest.rating`, read it back via a fresh `PHAsset` fetch, confirm it matches.
- Same for keywords (add, remove, read back).
- Confirm behavior when the same asset is rated on two devices while offline, then both come back online (informs DATA_MODEL.md § 4's real-world behavior, not just theoretical design).
- Confirm rating/keyword writes do **not** silently fail or get dropped for assets that only exist in iCloud (not yet downloaded locally) — a known edge case worth an explicit test.

## 4. CloudKit Sync Tests

- Two-device (or two-simulator-account) round trip: write a colour flag on device A, confirm it arrives on device B within the latency budget (see NFR.md).
- Conflict scenario: both devices edit different fields on the same `AssetMetadata` record while offline, reconnect, confirm both edits survive (per DATA_MODEL.md § 4's field-level merge goal) — or, if the chosen persistence layer can't do field-level merge, confirm the fallback whole-record behavior is at minimum non-silent.
- CloudKit quota/rate-limit behavior under a large batch import (thousands of records created in one import session).

## 5. Import Correctness

- Re-importing an already-fully-imported card surfaces zero new items (PRD.md US-1 AC1).
- Partial re-import (some new, some already-imported files on one card) surfaces only the new subset.
- Source volume/card is verified byte-for-byte unchanged after an import session (no accidental writes/deletes).
- Folder import handles files with missing/malformed EXIF without crashing (common for scanner output).

## 6. Platform UI

- **Mac:** full keyboard-only pass — every action in UX_FLOWS.md § 2 achievable with zero mouse/trackpad input, verified via XCUITest keyboard event injection plus a manual pass.
- **iOS/iPadOS:** swipe-deck gesture recognition doesn't misfire against system gestures (edge-swipe-back, control center, etc.) — needs real-device testing, simulator gesture handling is not representative.

## 7. Device / OS Matrix

Given the hard minimum-OS dependency (see RISK_REGISTER.md), the matrix is narrower than a typical app:
- macOS 27 on at least one Apple Silicon Mac.
- iOS 27 on at least one recent iPhone (physical device required for gesture/haptic testing).
- iPadOS 27 on at least one iPad (physical device required for USB-C card-reader ingest testing — simulators cannot exercise real card hardware).

## 8. Performance

- Contact-sheet grid scroll performance at library sizes of 5,000 / 20,000 / 50,000+ assets (see NFR.md for target numbers) — this is a dedicated perf test, not just "feels fine" during dev on a small test library.
- Import triage responsiveness with a large single-session import (e.g., a 500-shot SD card).

## 9. Beta / TestFlight

- Minimum: the primary user (Tim) running the app against his real, existing Photos library (highest-value test — real data, real film/digital mix) before any external tester.
- External cohort: a small number of real film-shooting testers (per SPEC.md § Production Plan Phase 3), specifically recruited for the hybrid film/digital use case rather than general iOS testers, since that's the one thing generic beta testers can't validate.
- Explicit test script for external testers: import a real card, import a real folder of scans, complete a full rate/flag/pick-reject pass on at least 100 images, report anything confusing without prompting (unprompted friction is the useful signal).

## 10. Regression Safety Net

Given this is a solo-developer project without a dedicated QA function, CI-run unit + integration tests (§ 1) are the primary regression safety net and should run on every commit, not just before releases — the dedup accuracy corpus (§ 2) in particular should be re-run automatically whenever `VersoCore`'s dedup code changes, so an accuracy regression is caught immediately rather than at the next manual test pass.
