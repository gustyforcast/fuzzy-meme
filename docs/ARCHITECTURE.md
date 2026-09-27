# Architecture

Companion reference to SPEC.md § Architecture Principles / Technical Stack. This document goes one level deeper: module boundaries, data flow, and the shape of the codebase, so implementation can start without re-deriving structure from the spec each time.

## 1. High-Level Shape

One SwiftUI app target (or a thin per-platform app shell over shared Swift Package targets — see § 4), built around four core services that are entirely platform-agnostic, plus platform-specific UI layers.

```
                        ┌─────────────────────────────┐
                        │        SwiftUI Views        │
                        │  (Mac grid)   (iOS/iPadOS    │
                        │               swipe deck)    │
                        └───────────────┬──────────────┘
                                        │  observes / dispatches
                        ┌───────────────▼──────────────┐
                        │        AppState / ViewModels │
                        └───┬───────┬───────┬──────────┘
                            │       │       │
            ┌───────────────▼─┐  ┌──▼────┐ ┌──▼────────────┐
            │  ImportService   │  │DedupSvc│ │ MetadataStore │
            │ (PhotoKit write, │  │(Vision)│ │ (CloudKit +   │
            │  volume/folder   │  │        │ │  PhotoKit     │
            │  enumeration)    │  │        │ │  read/write)  │
            └───────┬──────────┘  └───┬────┘ └───────┬───────┘
                    │                 │              │
                    └────────┬────────┴──────┬───────┘
                             │                │
                     ┌───────▼────────┐  ┌────▼─────┐
                     │   PhotoKit      │  │ CloudKit │
                     │ (Apple Photos)  │  │ (private │
                     │                 │  │ database)│
                     └─────────────────┘  └──────────┘
```

## 2. Core Services

### 2.1 ImportService
Owns ingest end-to-end: enumerating a source volume/folder, reading embedded EXIF without copying, running the exact-match check against the library before any copy, staging new files, and — once the user commits a keep decision — writing the asset into Photos via `PHAssetCreationRequest`, applying any ratings/keywords/flags decided during triage in the same transaction.

Inputs: a `MediaSource` (card/volume, folder, or camera-direct connection).
Outputs: a stream of `TriageItem`s for the UI layer, and, on commit, new `PHAsset`s plus corresponding `MetadataStore` records.

### 2.2 DedupService
Wraps the four-stage pipeline from SPEC.md § Duplicate Detection:
1. Exact match — content hash (e.g., SHA-256 of image data) compared against a persisted index of already-imported hashes.
2. Near-duplicate — `VNGenerateImageFeaturePrintRequest` distance scoring.
3. Burst/time clustering — timestamp + GPS proximity grouping.
4. Quality-assist — blur/eyes-open scoring within a cluster, surfaced as a suggestion only.

Pure, testable, and has zero dependency on PhotoKit or CloudKit — it operates on image data and metadata it's handed, and returns cluster/suggestion data structures. This separation is deliberate: it lets the dedup accuracy work (see TEST_PLAN.md) run against a fixture image corpus with no simulator/device dependency.

### 2.3 MetadataStore
The single point of truth for all per-asset metadata, native and custom alike. Responsibilities:
- Reads/writes native fields (star rating, keywords) via `PHAssetChangeRequest`.
- Reads/writes custom fields (colour flag, pick/reject, film metadata, near-dup groupings) via a CloudKit private-database record keyed to `PHAsset.localIdentifier` (see DATA_MODEL.md).
- Presents both as one unified `AssetMetadata` value to the rest of the app — callers don't need to know which backing store a given field lives in.
- Owns conflict resolution for the CloudKit-backed fields (see DATA_MODEL.md § Conflict Resolution).

### 2.4 SyncCoordinator
Thin layer over `CKSyncEngine`/`NSPersistentCloudKitContainer` (implementation choice, see § 5) that reacts to remote change notifications and pushes local writes, backing `MetadataStore`. No custom sync protocol is written — this is the architectural principle from SPEC.md § Architecture Principles #2, and it's worth stating explicitly here: there is no queue, retry, or merge logic in this codebase that reimplements what CloudKit already does.

## 3. Platform-Specific UI Layer

- **Mac:** a contact-sheet grid (`NSCollectionView`-backed or a SwiftUI `LazyVGrid` with a performance pass at scale — see NFR.md for the target library size), keyboard shortcut handling via `.onKeyPress`/`NSEvent` monitors, full-screen loupe view.
- **iPhone/iPad:** a full-screen swipe-deck view, vertical swipe for pick/reject, secondary interaction for rating/colour flag (interaction model not yet locked — see UX_FLOWS.md and RISK_REGISTER.md).
- Both sit over the same `ViewModel` layer; no business logic lives in either platform's view code.

## 4. Codebase Structure (proposed)

```
Verso.xcodeproj (or Package.swift-based app)
├── App/                      # Per-platform app entry points, minimal
│   ├── VersoMac/
│   └── VersoiOS/
├── Sources/
│   ├── VersoCore/            # Pure Swift: models, dedup algorithms, cluster logic
│   ├── VersoPhotoKit/        # PhotoKit wrapper: ImportService, native field read/write
│   ├── VersoCloudSync/       # MetadataStore's CloudKit-backed half, SyncCoordinator
│   ├── VersoUIShared/        # Shared SwiftUI components, view models
│   ├── VersoUIMac/           # Mac-only views
│   └── VersoUIiOS/           # iPhone/iPad-only views
└── Tests/
    ├── VersoCoreTests/
    ├── VersoPhotoKitTests/
    └── VersoCloudSyncTests/
```

Rationale for a Swift Package–based split rather than one flat app target: `VersoCore`'s dedup logic needs to be unit-testable without a simulator (see TEST_PLAN.md), and the PhotoKit/CloudKit boundaries map cleanly onto the two things Phase 0 has to validate independently.

## 5. Open Implementation Choices

- **CloudKit access layer:** raw `CKDatabase`/`CKRecord` vs. `NSPersistentCloudKitContainer` (Core Data) vs. `SwiftData` with CloudKit sync. Recommendation: prototype with `SwiftData` + CloudKit first (least boilerplate, and current as of iOS 27), fall back to raw CloudKit if SwiftData's sync semantics don't give the conflict-resolution control DATA_MODEL.md requires. This is a Phase 0 spike (see ROADMAP.md).
- **Contact-sheet grid performance:** needs a real spike against a multi-thousand-asset library before committing to `LazyVGrid` vs. `NSCollectionView`/`UICollectionView` bridging.

## 6. What This Architecture Deliberately Avoids

Direct callbacks to SPEC.md § Architecture Principles, stated here as constraints on implementation, not just intent:
- No custom network layer, no custom sync/queueing engine.
- No third-party ML models or SDKs for dedup — Vision framework only.
- No server component of any kind.
- No direct image-file storage owned by the app outside of what PhotoKit itself manages (the app does not maintain a parallel copy of image bytes once an asset is committed to Photos).
