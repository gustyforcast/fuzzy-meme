# Roadmap / Backlog

Expands SPEC.md § Production Plan into concrete epics, sized for a solo developer working part-time. Intended to seed GitHub Issues/Milestones directly — each `###` heading below maps to one proposed Milestone, each bullet to one proposed Issue.

## Phase 0 — Technical Spikes (2–4 weeks)

Everything else depends on these three assumptions holding. Each spike should produce a written finding (a short doc or an update to RISK_REGISTER.md), not just working throwaway code.

- [ ] **Spike: PHAsset rating/keyword round-trip.** Confirm `PHAssetChangeRequest.rating`/`addKeyword` write and read back correctly, including across two devices on the same iCloud account. Formalize as the tests in TEST_PLAN.md § 3.
- [ ] **Spike: CloudKit metadata sync.** Stand up the minimal `AssetMetadata` record type (DATA_MODEL.md § 3), confirm cross-device sync latency and conflict behavior. Decide the persistence layer (raw CloudKit vs. SwiftData vs. Core Data + CloudKit — ARCHITECTURE.md § 5).
- [ ] **Spike: Vision feature-print accuracy.** Run `VNGenerateImageFeaturePrintRequest` against a first-pass version of the test corpus (TEST_PLAN.md § 2), even if the corpus isn't complete yet — early signal on threshold tuning.
- [ ] **Spike: `PHAsset.localIdentifier` stability.** Confirm or refute the identity assumption in DATA_MODEL.md § 1 across devices for iCloud-synced assets.

**Exit criterion:** all four spikes have a written finding; any spike that fails its assumption triggers a design revisit (in DATA_MODEL.md or ARCHITECTURE.md) before Phase 1 starts.

## Phase 1 — MVP, Mac-First (6–8 weeks)

- [ ] Folder import pipeline (ImportService, folder source only — card/USB deferred to this phase's later half or Phase 2 if needed).
- [ ] Exact-match duplicate detection against existing library.
- [ ] Near-duplicate detection + burst clustering (DedupService), tuned against Phase 0's spike findings.
- [ ] Mac contact-sheet grid UI (UX_FLOWS.md § 2), keyboard shortcuts complete.
- [ ] Native star rating + keyword read/write wired to the grid.
- [ ] Colour flag + pick/reject wired to CloudKit metadata layer.
- [ ] Loupe (full-screen single-image) view.
- [ ] SD/CF card import via card reader (if not done earlier in this phase).
- [ ] Manual hand-off to external editor (e.g., "Open in Photomator" or equivalent — reveal-in-Photos is likely sufficient for v1; no in-app editing integration required).

**Exit criterion:** Tim can fully replace his current Mac-side workflow (Apple Photos + manual culling) with this app for a real import session.

## Phase 2 — Extend to iPhone/iPad (4–6 weeks)

- [ ] Swipe-deck UI (UX_FLOWS.md § 3), vertical swipe pick/reject.
- [ ] Prototype both secondary-interaction candidates (bottom bar vs. radial menu) and test with real usage before locking one in (RISK_REGISTER.md item).
- [ ] iPad card/USB-C ingest.
- [ ] iPad Files-app folder import.
- [ ] Cross-device metadata sync validated end-to-end (Mac-authored flags visible on iPhone and vice versa) under real, not just simulated, conditions.

**Exit criterion:** a full triage pass (100+ photos) is completable entirely on iPhone, at a pace the primary user considers "actually faster than what I do today."

## Phase 3 — v1 Polish & Launch (3–4 weeks)

- [ ] Visual identity/design pass (RISK_REGISTER.md — currently only a directional agreement, no actual design done).
- [ ] Accessibility pass against NFR.md § 3 (Dynamic Type, VoiceOver, colour-independent flag indicators).
- [ ] Performance validation at the 20k–50k asset library size (NFR.md § 2).
- [ ] App Store Connect listing, screenshots, privacy nutrition label (RELEASE_CHECKLIST.md).
- [ ] TestFlight beta with real film-shooting testers (TEST_PLAN.md § 9).
- [ ] Naming finalized and trademark-cleared (RISK_REGISTER.md — currently "Verso" working title, unclearance pending).
- [ ] Submission.

**Exit criterion:** app is live on the App Store.

## Phase 4 — v2 (post-launch, not yet scoped in detail)

Deliberately left loose per SPEC.md § Production Plan — do not begin detailed sizing until v1 has real usage data:
- [ ] Dedicated film roll/frame logging UI (camera/lens/stock libraries with autofill, roll-to-scan linking).
- [ ] Import compatibility with existing film-logging apps' exports (Frames, Exif Notes) so existing user history isn't stranded.
- [ ] Investigate and, if feasible, close the PhotoKit rating→XMP export gap (DATA_MODEL.md § 5) for interoperability with Lightroom/Photo Mechanic.
- [ ] Paid upgrade pricing/mechanism (SPEC.md § Business Model — Excire-style paid major-version upgrade, not a subscription).

## Ongoing / Not Phase-Bound

- [ ] Keep RISK_REGISTER.md current as spikes and decisions resolve open items.
- [ ] Keep the dedup accuracy test corpus (TEST_PLAN.md § 2) growing as real-world edge cases are found post-launch.
