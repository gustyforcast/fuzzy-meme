# Product Requirements Document (PRD)

**Product:** Verso (working title — see [RISK_REGISTER.md](./RISK_REGISTER.md) for naming/trademark status)
**Owner:** Tim
**Status:** Draft v1 — Sep 2026
**Source of truth for vision/market/business context:** [SPEC.md](../SPEC.md). This document translates that spec into testable requirements.

## 1. Purpose

Define what must be true of the shipped v1 product for it to satisfy the target user, in terms specific enough to build against and test against. Where SPEC.md answers "why" and "what kind of product," this document answers "what exactly does it do."

## 2. Primary Persona

The hybrid film/digital enthusiast (see SPEC.md § Target User). For requirements purposes, assume:
- Owns a Mac, an iPhone, and (optionally) an iPad, all signed into the same iCloud account.
- Has an existing Apple Photos library of several thousand digital images.
- Imports film scans as folders from a lab or a home scanner (not always via SD card).
- Is comfortable with keyboard shortcuts on Mac and swipe gestures on iOS; is not a professional retoucher.

## 3. In Scope / Out of Scope

**In scope (v1):**
- Import from SD/CF cards, external drives, folders, and camera-direct connections.
- Exact- and near-duplicate detection with burst clustering.
- Star rating and keyword read/write via native PhotoKit fields.
- Colour flags and pick/reject state via the app's own metadata layer.
- Flexible film-metadata custom fields (schema only, no dedicated logging UI).
- Mac keyboard-driven culling UI; iPhone/iPad swipe-deck culling UI.
- Cross-device sync of the app's own metadata via CloudKit private database.

**Out of scope (v1, explicitly):**
- Any image editing (exposure, colour, crop, retouch) — the app hands off to the user's existing editor.
- A dedicated film roll/frame logging UI (deferred to v2 — see ROADMAP.md).
- Any server component, account system, or off-device processing of images.
- Android, Windows, or web clients.
- Social/sharing features of any kind.

## 4. User Stories & Acceptance Criteria

Each story includes acceptance criteria written to be directly testable (see TEST_PLAN.md for how each is verified).

### 4.1 Import & Ingest

**US-1 — Import from a card.**
As a user, when I connect an SD card that's been shot on my digital camera, I want to see only the new frames it contains, so I don't re-review shots I've already imported.
- AC1: Connecting a card that was already fully imported shows zero new items to triage.
- AC2: Connecting a card with a mix of previously-imported and new files shows only the new files.
- AC3: No file is copied into Photos until the user makes an explicit keep decision.
- AC4: The source card/volume is never modified or deleted from.

**US-2 — Import a folder of scans.**
As a user, when a lab returns scanned negatives as a folder of TIFF/JPEG files, I want to import that folder the same way I'd import a card, so film and digital share one workflow.
- AC1: A folder import surfaces the same triage view as a card import.
- AC2: Files without EXIF (common for scans) are still importable and don't crash or silently skip.

**US-3 — Triage before commit.**
As a user, I want to review a contact-sheet/swipe-deck of newly ingested images, grouped by burst or near-duplicate cluster, before anything lands in my permanent library.
- AC1: Frames within 2 seconds of each other (configurable) are grouped as one cluster in the triage view.
- AC2: Rating/keyword/flag decisions made during triage are applied at the moment of import, not as a separate pass.

### 4.2 Duplicate Detection

**US-4 — Catch exact duplicates.**
As a user, re-importing a card I've already processed should surface zero duplicate items.
- AC1: Byte-identical files are detected with zero false negatives in the test corpus (see TEST_PLAN.md).

**US-5 — Catch near-duplicates.**
As a user, I want re-exports, minor crops, and small edits of a photo I already have flagged as likely duplicates, so my library doesn't fill with near-identical clutter the way it does in Apple Photos today.
- AC1: A perceptual-hash distance below the configured threshold flags a pair as a near-duplicate suggestion.
- AC2: Near-duplicate suggestions are never auto-deleted or auto-merged — the user always makes the final call.
- AC3: False-positive rate on the test corpus (visually distinct images flagged as dupes) is measured and stays under an agreed threshold before v1 ships (see TEST_PLAN.md § Duplicate Detection Accuracy).

**US-6 — Quality-assist within a cluster.**
As a user, when a burst or near-dup cluster is shown, I want the sharpest/eyes-open frame highlighted as a suggested keeper, so I can triage large bursts faster.
- AC1: The suggested frame is visually marked as a suggestion, distinct from the user's own selection.
- AC2: The user can override the suggestion with zero extra taps versus accepting it.

### 4.3 Rating, Tagging, Flagging

**US-7 — Rate and tag using Photos' own fields.**
As a user, star ratings and keywords I set in this app should be visible in Apple's own Photos app, on any of my devices, with or without this app installed there.
- AC1: Setting a 1–5 star rating in-app is visible in Photos.app within one sync cycle on another device.
- AC2: Keywords set in-app appear in Photos.app's own keyword UI.

**US-8 — Colour-flag and pick/reject.**
As a user, I want a fast red/yellow/green/blue/purple/orange flag and a separate pick/reject state per photo, independent of star rating, matching the Photo Mechanic/Lightroom convention.
- AC1: Colour flag and pick/reject state sync across the user's devices via the app's own metadata layer within a defined latency budget (see NFR.md).
- AC2: Colour flag and pick/reject state survive an app reinstall (they're recovered from CloudKit, not lost).

**US-9 — Mac keyboard workflow.**
As a user on Mac, I want to rate, flag, and cull a large batch of photos using only the keyboard, at a pace comparable to Photo Mechanic.
- AC1: Number keys 1–5 set star rating without leaving the keyboard.
- AC2: A full triage pass over 200 images (rating + flag + pick/reject) is achievable without touching the trackpad/mouse.

**US-10 — iPhone/iPad swipe workflow.**
As a user on iPhone, I want a Tinder-style swipe-deck for fast pick/reject decisions, with a clear secondary interaction for rating and colour flag.
- AC1: A vertical swipe commits a pick/reject decision in one gesture.
- AC2: Rating and colour flag are reachable without leaving the full-screen deck view (exact interaction TBD — see UX_FLOWS.md and RISK_REGISTER.md).

### 4.4 Film Metadata

**US-11 — Attach film-specific fields to a scan.**
As a user, I want to record roll ID, frame number, camera, lens, film stock, ISO, developer, dilution, dev time, and push/pull on a scanned negative, so that information isn't lost the way it is in a separate paper log.
- AC1: All listed fields are present and editable on any asset, but none are required — a scan with zero film metadata is fully valid.
- AC2: A field value can be applied to a whole roll/cluster in one action rather than one photo at a time (v1: batch-apply during triage is sufficient; a dedicated roll UI is v2).

### 4.5 Cross-Device Sync

**US-12 — Metadata follows me across devices.**
As a user, if I flag and rate photos on my Mac, I expect the same flags and ratings when I open the app on my iPhone, without doing anything else.
- AC1: Metadata changes propagate across devices signed into the same iCloud account without user-initiated sync action.
- AC2: A conflicting edit made offline on two devices resolves deterministically (see DATA_MODEL.md § Conflict Resolution) without silent data loss.

## 5. Non-Goals (see NFR.md and SPEC.md for full rationale)

- No subscription, no account system beyond the user's own iCloud identity.
- No image upload to any server, ever.
- No editing surface of any kind in v1.

## 6. Dependencies

- Minimum OS: iOS/iPadOS/macOS 27 ("Golden Gate") — see ARCHITECTURE.md and RISK_REGISTER.md.
- User must grant full Photos library access and (for metadata sync) have iCloud enabled.

## 7. Success Metrics (informal, solo/indie context)

Given the business model (one-time purchase, side-income app — see SPEC.md § Business Model), success is measured qualitatively pre-launch and by simple counts post-launch:
- Phase 0 spikes all pass (see ROADMAP.md) before further investment.
- TestFlight testers (real film-shooting users) can complete a full import → triage → rate/flag cycle without external help.
- Post-launch: unprompted App Store reviews mention the film+digital unification or the dedup quality specifically (qualitative signal the gap thesis was right).
