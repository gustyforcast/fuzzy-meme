# Glossary

Domain and technical terms used across this document set, kept in one place so they're defined once rather than re-explained in every doc.

## Product / Domain Terms

- **Culling** — the process of reviewing a batch of photos and deciding which to keep (pick) or discard (reject), as distinct from editing.
- **Pick/Reject** — a binary triage decision per photo, independent of star rating; a "first pass" workflow state (PRD.md US-8).
- **Colour flag** — a six-colour tag (red/yellow/green/blue/purple/orange) matching the Photo Mechanic/Lightroom convention, used for workflow status rather than quality (DATA_MODEL.md § 2).
- **Star rating** — Apple Photos' native 0–5 quality/favourite rating, read/written natively via PhotoKit (not app-specific).
- **Burst** — a rapid sequence of near-identical frames shot within a short time window, typically from continuous shutter mode.
- **Near-duplicate** — two images that are not byte-identical but are perceptually very similar (a re-export, minor crop, or small edit of the same capture) — as distinct from a **true duplicate** (byte-identical) and from two **visually similar but distinct captures** (same subject, different moment), which must NOT be flagged as duplicates (TEST_PLAN.md § 2).
- **Roll** — a single roll of film, with its own metadata (stock, ISO, developer, etc.) that typically applies to every frame within it (DATA_MODEL.md § 2).
- **Frame** — one exposure within a roll; numbered sequentially.
- **Push/pull** — deliberately over- or under-developing a film roll relative to its box speed, measured in stops.
- **Triage view** — the UI screen where newly imported photos are reviewed before being committed into the permanent library (UX_FLOWS.md § 1).
- **Contact sheet** — historically, a single print showing thumbnail versions of every frame on a roll; here, the Mac grid view that serves the same purpose digitally (UX_FLOWS.md § 2).
- **Loupe** — a photographer's magnifying tool for examining film/prints closely; here, the full-screen single-image inspection view (UX_FLOWS.md § 2).

## Technical Terms

- **PhotoKit** — Apple's framework for reading and writing the user's Photos library (`PHAsset`, `PHAssetChangeRequest`, `PHAssetCreationRequest`, etc.).
- **`PHAsset`** — PhotoKit's representation of a single photo or video in the library.
- **`PHAsset.localIdentifier`** — a per-device-stable (cross-device stability not yet confirmed — see RISK_REGISTER.md #4) identifier used as this app's join key between Photos and its own metadata (DATA_MODEL.md § 1).
- **`PHAssetChangeRequest`** — the PhotoKit API for modifying an existing asset's native fields (rating, keywords, etc.).
- **`PHAssetCreationRequest`** — the PhotoKit API for importing a new asset into the library.
- **CloudKit** — Apple's cloud database framework; here used exclusively as a **private database**, syncing the app's own custom metadata across a single user's devices on one iCloud account (never a public/shared database — SPEC.md excludes any social/sharing scope).
- **`CKRecord`** — CloudKit's basic record type; see DATA_MODEL.md § 3 for this app's proposed record types.
- **Vision framework** — Apple's on-device computer vision framework; here used for `VNGenerateImageFeaturePrintRequest` (perceptual image fingerprinting for near-dup detection) and blur/face-landmark detection (quality-assist).
- **`VNGenerateImageFeaturePrintRequest`** — the specific Vision API that produces an on-device perceptual fingerprint of an image, used to score similarity between two images without any network call.
- **XMP** — a metadata standard embedded in image files (used by Lightroom, Photo Mechanic, etc.); relevant here because PhotoKit ratings may not currently round-trip into a file's XMP on export (DATA_MODEL.md § 5, RISK_REGISTER.md #5).
- **EXIF** — the standard embedded metadata format for camera-original digital images (date, camera model, exposure settings, etc.); largely absent or unreliable on scanned film, which is why film metadata needs its own custom fields (SPEC.md § Feature Spec: Film Metadata).

## Project / Process Terms

- **Working title** — the current, not-yet-finalized product name ("Verso"), pending formal trademark clearance (RISK_REGISTER.md #1).
- **Phase 0 spike** — a time-boxed technical investigation done specifically to validate a risky architectural assumption before committing further build effort to it (ROADMAP.md, RISK_REGISTER.md).
