# Photo Library Companion — Spec & Production Plan

Sep 26, 2026 · @Tim

## Vision & Positioning

## Vision & Positioning

A Photos-companion app for photographers who shoot both film and digital and currently stitch together two or three separate tools to manage the result. It handles import, culling, rating, tagging, deduplication and film-specific metadata — and stops there. Editing stays in whatever tool the photographer already uses (Photomator, Lightroom, Capture One, or a darkroom).

This mirrors the split that already works commercially for Photo Mechanic and Excire Foto: a pure library tool earns trust precisely by staying out of the editor's lane.

**Core promise:** your Apple Photos library, with the metadata rigor and culling speed that hybrid film/digital shooters have never had in one place — without leaving the Apple ecosystem, and without a subscription.

## Target User

## Target User

**The hybrid film/digital enthusiast.** Shoots on a digital body and one or more film cameras, has a backlog of negatives alongside a phone full of digital frames, and currently duct-tapes together several tools: a film logbook (Frames, Exif Notes, or a paper notebook), Apple Photos or Mylio for the digital side, and possibly Lightroom or Photo Mechanic for anything resembling real culling.

Current pain:

- Film metadata (roll, frame, stock, developer, push/pull) lives in a separate app or notebook, disconnected from the scanned image once it's imported.
- Apple Photos' duplicate detection only catches byte-identical files, so bursts and re-exports pile up uncleaned.
- No fast, keyboard- or gesture-driven way to rate and flag a large backlog of digital frames alongside film scans.
- Has already rejected Adobe's subscription model on principle, not just cost.

What they need: one place where a photo is correctly described as what it is (film roll and frame, or digital EXIF), rated and flagged quickly, properly deduplicated, and still lives inside Apple Photos rather than a walled-off replacement library.

## Market Context & Gap

## Market Context & Gap

| Tool | Strength | Gap |
| --- | --- | --- |
| Apple Photos | Free, universal, native iCloud sync | Exact-match dedup only; no film metadata; weak folder control |
| Photomator | Best-in-class AI editing | Weak library/organization; no metadata editing |
| Mylio Photos+ ($9.99–20/mo) | Genuine cross-device local sync | Exact-match dedup only; clunky Photos round-tripping |
| Photo Mechanic ($139 one-time) | Fastest keyboard-driven culling on the market | Mac/Windows only; no touch gestures; no film fields |
| Excire Foto ($199–249 one-time) | Best AI search and keywording | Desktop only; no swipe culling |
| Frames / MetaLog / Exif Notes | Rich film roll/frame logging | Standalone logbooks, disconnected from the working photo library |
| PhotoPicker (AI Photo Culling) | Closest analog: SD-card ingest + swipe culling + XMP | Niche one-developer app; no Apple Photos integration; no film metadata |

No existing product combines: SD-card ingest, true cross-device Apple-ecosystem sync, real near-duplicate detection, film-vs-digital metadata as distinct first-class fields, native Apple Photos integration, and keyboard-*and*-swipe tagging. The white space is the **film + digital unification**, built as an Apple Photos companion rather than a replacement — a niche every competitor either ignores or bolts on as an afterthought.

Financial context: this is a prosumer-niche business model (Photo Mechanic, Excire), not a mass-market consumer app — a small, sustainable side-income product in the same bracket as Tim's other Swift apps, not a full-time-replacing business.

## Architecture Principles

## Architecture Principles

1. **Photos-native first.** No custom storage, backup, or sync engine. Assets are read and written via PhotoKit against the user's existing Apple Photos library, addressed by `PHAsset.localIdentifier`. This is the single biggest risk Mylio carries (a hand-built sync mesh) that this app avoids entirely.
2. **A parallel metadata layer for everything Photos can't hold.** A CloudKit private-database record per asset, synced automatically across the user's own devices on the same Apple ID — no custom sync protocol to write or debug.
3. **On-device, algorithmic only.** No network calls, no third-party ML models, no off-device processing of any kind. Apple's own Vision framework supplies real capability here (see Duplicate Detection).
4. **All platforms from day one, one codebase.** SwiftUI + PhotoKit + CloudKit are shared APIs across macOS, iOS and iPadOS. Per-platform UI (keyboard grid on Mac, swipe deck on iPhone/iPad) sits over one shared data and business-logic layer.

**Field placement** (as of iOS/iPadOS/macOS 27, which added native PhotoKit support for ratings and keywords):

| Field | Lives in |
| --- | --- |
| Star rating (1–5) | Native Photos, via `PHAssetChangeRequest.rating` |
| Keywords/tags | Native Photos, via `PHAssetChangeRequest.addKeyword`/`removeKeyword` |
| Colour flags | App's own CloudKit metadata layer (no native equivalent) |
| Pick/Reject culling state | App's own CloudKit metadata layer (no native equivalent) |
| Film roll/frame, stock, dev notes | App's own CloudKit metadata layer |
| Near-duplicate groupings | App's own CloudKit metadata layer |

Leaning on native fields where possible removes a meaningful chunk of backend risk and ships ratings/keywords that any other Photos-aware app can also see — at the cost of a hard minimum OS requirement of version 27 (see Technical Stack).

## Feature Spec: Import & Ingest

## Feature Spec: Import & Ingest

**Sources:** SD/CF cards and card readers, external SSDs/drives, and camera-direct connections (Mac and iPad via USB-C; iPad additionally via the Files app).

**Pipeline:**

1. Enumerate media on the source volume; read embedded EXIF/metadata without copying yet.
2. Run the exact-match duplicate check against the existing Photos library and prior imports before copying anything (avoids re-importing a card that's already been ingested — the single most common Apple Photos complaint).
3. Copy new files into a staging area; run the near-duplicate and burst-clustering pass (see Duplicate Detection).
4. Present a triage view (contact-sheet grid on Mac, swipe deck on iPhone/iPad) grouped by burst/near-dupe cluster.
5. On a keep decision, write the asset into Apple Photos via `PHAssetCreationRequest`; ratings/keywords/flags applied during triage are written in the same pass.
6. Rejected frames are left out of Photos entirely (never auto-deleted from the source card) — the user clears the card themselves once satisfied.

This import-time triage is also where film-shooting workflows differ most: a batch of scanned negatives typically arrives as a folder from a lab or scanner, not a card, so folder-based import is a first-class path alongside card ingest, not an afterthought.

## Feature Spec: Duplicate Detection

## Feature Spec: Duplicate Detection

Four on-device stages, each cheap enough to run at import time:

1. **Exact match** — file hash comparison. Catches byte-identical files (the only thing Apple Photos and Mylio currently do).
2. **Perceptual near-duplicate match** — `VNGenerateImageFeaturePrintRequest` (Vision framework) computes an on-device fingerprint and distance score between images. This is the same mechanism behind Apple's own "Duplicates" album, and it catches crops, re-exports, and minor edits that exact-match misses entirely.
3. **Burst/near-time clustering** — group by timestamp proximity and GPS, so a 12-frame burst is presented as one decision unit rather than 12 separate pairwise comparisons.
4. **Optional quality-assist within a cluster** — Vision's blur and eyes-open/face-landmark detection suggests (never auto-selects or auto-deletes) the sharpest, best-composed frame in a near-duplicate group as a starting point for the user's own decision.

All four stages run locally via Apple's own frameworks — no network calls, no third-party models — and together represent a stronger dedup story than any competitor: Apple Photos and Mylio stop at stage 1; nothing on the market currently ships stages 2–4 as a consumer-facing feature.

## Feature Spec: Rating, Tagging & Flagging

## Feature Spec: Rating, Tagging & Flagging

**Star rating (1–5)** — native Photos field. Written via `PHAssetChangeRequest.rating`, visible and filterable in Apple's own Photos app immediately, syncs via iCloud with zero effort from this app.

**Keywords** — native Photos field, written via `PHAssetChangeRequest.addKeyword`. Used for general-purpose tagging (subjects, locations, projects) exactly as Apple's own iOS 27 keyword UI intends.

**Colour flags** — not natively supported by Photos, so this lives in the app's own metadata layer. A six-colour palette matching the Photo Mechanic/Lightroom convention (red, yellow, green, blue, purple, orange) so muscle memory transfers for anyone coming from those tools.

**Pick/Reject culling state** — also not native (Photos only has a boolean Favourite). A separate binary flag per asset in the metadata layer, intended for a first fast triage pass, independent of star rating (which is for quality/favourites, not culling decisions).

**Storage:** colour flags and pick/reject state live in the CloudKit metadata layer, keyed to `PHAsset.localIdentifier`, syncing across the user's own devices on the same Apple ID.

This split means a photo rated and keyworded in this app is genuinely rated and keyworded in Apple Photos itself — visible in the stock Photos app on any device, with or without this app installed — while the culling-specific workflow state (colour, pick/reject) stays app-specific, exactly where it belongs.

## Feature Spec: Film Metadata

## Feature Spec: Film Metadata

**v1 — flexible custom-field schema, no dedicated UI.** A generic key-value/tag layer on each asset's metadata record, with a starter set of film-relevant fields available but not enforced: roll ID, frame number, camera, lens, film stock, ISO/box speed, exposure compensation, developer, dilution, development time, push/pull stops, and free-text notes. This keeps the schema open for a proper film workflow later without blocking v1 on a UI decision that hasn't been made yet.

**v2 (deferred) — dedicated roll/frame logging.** A proper logging UI in the style of Frames/Exif Notes: camera, lens and film-stock libraries with autofill, a roll-to-scan linking flow so a whole roll's metadata can be applied to its scans in one pass, and import compatibility with existing film-logging apps' exports so a user's existing Frames or Exif Notes history isn't stranded.

This section is intentionally the least specified part of the document — the target user (per Tim, 2026-09-26) hasn't yet decided between an in-app logger and richer field support for importing external logs, and that decision should be made before v2 scoping starts.

## Platform-Specific UX

## Platform-Specific UX

**Mac — keyboard-driven contact-sheet grid.** Deliberately mirrors Photo Mechanic's proven shortcut scheme so muscle memory transfers for anyone coming from it: number keys 1–5 for star rating, modifier+number for colour flag, P/X for pick/reject, arrow keys to navigate. Full-screen loupe view for close inspection.

**iPhone/iPad — full-screen swipe deck.** Primary vertical swipe (up/down) for pick/reject — matches the PhotoPicker precedent and avoids clashing with the system's own horizontal photo-navigation gesture. Star rating and colour flag need a secondary interaction, since a single two-way swipe axis can't carry a binary pick/reject *and* a 5-way rating *and* a 6-way colour choice at once — proposed as a bottom action bar or long-press radial menu, to be validated by prototyping rather than locked in this document (see Open Decisions).

**Shared codebase.** One SwiftUI app target with platform-conditional views over a single data and business-logic layer (import pipeline, dedup engine, CloudKit metadata sync) — not three separate apps.

## Business Model

## Business Model

**One-time purchase, roughly $39–$59**, as a universal purchase covering Mac, iPhone and iPad from a single buy. Positioned below Photo Mechanic ($139) and Excire Foto ($199–249), reflecting a narrower v1 feature set, while staying meaningfully above impulse-buy utility pricing to signal a serious tool.

Rationale: the target user has explicitly rejected subscription fatigue (Adobe), and a companion app leaning on Apple's own iCloud/CloudKit sync carries no ongoing server costs that would justify recurring billing. A paid upgrade for the v2 film-logging module (in the spirit of Excire's $79/$99 upgrade path between major versions) is preferable to a subscription tier.

This fits the same small-but-real income bracket as Tim's other Swift apps — a third portfolio app, not a full-time-replacing business.

## Technical Stack

## Technical Stack

| Layer | Technology |
| --- | --- |
| UI | SwiftUI, one codebase, platform-conditional views |
| Photos library access | PhotoKit — `PHAsset`, `PHAssetChangeRequest` (rating, keywords, caption), `PHAssetCreationRequest` (import), `PHAssetResource` |
| Custom metadata sync | CloudKit private database, keyed to `PHAsset.localIdentifier` |
| Duplicate/quality detection | Vision framework — `VNGenerateImageFeaturePrintRequest`, blur and face-landmark detection |
| Card/drive ingest | Files app integration (iPad) and volume-level file access (Mac) |

**Minimum OS: iOS 27 / iPadOS 27 / macOS 27 ("Golden Gate").** This is a hard dependency, not a preference — native rating and keyword support in PhotoKit only exists from this version onward. For a new app this is an acceptable floor, but it does mean no support for users who haven't updated.

## Production Plan

## Production Plan

| Phase | Duration | Scope |
| --- | --- | --- |
| 0. Technical spikes | 2–4 weeks | Validate `PHAsset.rating`/keyword read-write round-trip; validate CloudKit metadata sync across devices on the same iCloud account; validate Vision feature-print accuracy on a real, messy photo set |
| 1. MVP (Mac-first) | 6–8 weeks | Folder/SD-card import → contact-sheet grid → exact + near-dup detection → native star rating/keyword read-write → custom colour flag/pick-reject in CloudKit → hand-off to external editor |
| 2. Extend to iPhone/iPad | 4–6 weeks | Swipe-deck culling UI over the same data layer; iPad card/USB-C ingest |
| 3. v1 polish & launch | 3–4 weeks | Visual identity and design pass; App Store listing and pricing; TestFlight beta with a handful of real film-shooting testers; submission |
| 4. v2 (post-launch) | Not yet scoped | Dedicated film roll/frame logging UI, camera/lens/stock libraries, improved XMP export interoperability |

**Total to v1 launch: roughly 4–5 months**, working solo and part-time alongside full-time employment — consistent with the portfolio approach of several small apps rather than one all-consuming project. Phase 0 is deliberately front-loaded: the three technical spikes are the assumptions the whole architecture rests on, and each is cheap to falsify early and expensive to discover wrong in Phase 2.

## Open Decisions & Risks

## Open Decisions & Risks

- [ ] **App name** — "Verso" is the working title; no conflicting App Store product found, but needs a proper trademark clearance search (USPTO/EU, software and photography classes) before real investment in branding.
- [ ] **Film-logging UI** — deferred to v2; flexible schema only in v1. Needs its own design session once v1 ships.
- [ ] **Swipe gesture mapping** — only one clean swipe axis is available for pick/reject; star rating, colour flag and any film-metadata entry all need a secondary interaction. Needs prototyping and real-user testing before the interaction model is locked.
- [ ] **`PHAsset.localIdentifier` stability across devices** — needs technical validation (Phase 0) that ratings/keywords/custom metadata reliably reconcile across Mac/iPhone/iPad signed into the same iCloud account, particularly for assets synced via iCloud Photos versus assets that only ever exist on one device.
- [ ] **Rating/keyword round-trip to file XMP** — early developer reports suggest Apple's own PhotoKit ratings aren't currently written to file metadata on export. Worth solving better than Apple does for interoperability with Lightroom/Photo Mechanic, but adds scope beyond v1.
- [ ] **Minimum OS = version 27** — acceptable for a new app, but confirm it matches the target user's typical hardware/OS currency before committing.
- [ ] **Visual identity** — light-table/contact-sheet aesthetic direction agreed in principle (warm neutral background, film-strip motif at rest, full-black loupe view); no actual design pass done yet.
