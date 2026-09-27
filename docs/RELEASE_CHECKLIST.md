# Release / App Store Checklist

Covers what's specific to shipping this app on the App Store, on top of the general engineering exit criteria already in ROADMAP.md Phase 3.

## 1. App Store Connect Setup

- [ ] Register app name in App Store Connect only once naming is trademark-cleared (RISK_REGISTER.md #1) — reserving the working title early is fine, but don't treat reservation as clearance.
- [ ] Universal purchase configured across macOS, iOS, iPadOS from a single SKU (SPEC.md § Business Model).
- [ ] Price tier set to land in the $39–59 range (SPEC.md § Business Model), confirmed against current App Store pricing tiers at submission time.
- [ ] App category: Photo & Video.
- [ ] Age rating questionnaire completed (expected: no special content concerns).

## 2. Privacy Nutrition Label

Directly derived from NFR.md § 1 — this should be an easy, honest label precisely because the architecture avoids data collection:
- [ ] Declare Photos library access (required, core functionality).
- [ ] Declare **no data collected** for anything image-related, given the on-device-only architecture — verify this is actually true at submission time, not just at design time (i.e., re-check if any crash/analytics tooling was added since NFR.md was written).
- [ ] If any operational (non-image) analytics or crash reporting is added, disclose precisely what's collected and confirm it contains no image data or derived image features (NFR.md § 1).
- [ ] Confirm CloudKit private-database usage doesn't require additional disclosure beyond standard iCloud sync language.

## 3. Permissions & Onboarding

- [ ] Photos library access request includes a clear `NSPhotoLibraryUsageDescription` (and additive, not full-library-by-default if Apple's permission model offers a scoped option — full access is required here since the app both reads and writes across the whole library, so this should explicitly justify full access in the description).
- [ ] First-run explanation of on-device-only processing (UX_FLOWS.md § 4) shown before or alongside the permission prompt, not buried after.
- [ ] iCloud/CloudKit account requirement communicated (metadata sync requires the user's iCloud account to be signed in and CloudKit-enabled).

## 4. Store Listing Content

- [ ] App name and subtitle finalized (post-trademark-clearance).
- [ ] Screenshots: at minimum, Mac contact-sheet grid, iPhone swipe deck, loupe view — showing the actual differentiators (dedup clustering, film metadata fields) rather than generic photo-grid shots.
- [ ] Description leads with the positioning from SPEC.md § Vision & Positioning ("Lightroom's Library module, without a subscription" register) rather than a generic feature list.
- [ ] Explicitly mention no subscription / one-time purchase in the listing — this is a stated differentiator against Adobe/Mylio and worth surfacing, not just pricing metadata.
- [ ] Keywords chosen without infringing on ruled-out/competitor names already researched (Aperture, Halide, Loupe, etc. — see naming research history).

## 5. TestFlight

- [ ] Internal testing: primary user (Tim) against his real Photos library first (TEST_PLAN.md § 9).
- [ ] External group: recruited specifically for hybrid film/digital workflow, not generic testers.
- [ ] Explicit test script distributed to external testers (TEST_PLAN.md § 9).
- [ ] Feedback loop: a lightweight way for testers to report friction (TestFlight's own feedback mechanism is sufficient for v1 — no need to build custom feedback tooling).

## 6. Pre-Submission Technical Gate

Pull from ROADMAP.md Phase 3 exit criteria and TEST_PLAN.md gates — do not submit until:
- [ ] Dedup false-positive rate is within the agreed threshold (RISK_REGISTER.md #9).
- [ ] Performance validated at 20k–50k asset library size (NFR.md § 2).
- [ ] Accessibility pass complete (NFR.md § 3).
- [ ] No known data-loss scenario in metadata sync conflict handling (DATA_MODEL.md § 4).

## 7. Post-Launch

- [ ] Monitor App Store reviews specifically for signal on the core market-gap thesis (SPEC.md § Market Context & Gap) — do reviewers mention the film+digital unification or dedup quality unprompted (PRD.md § 7 success metric).
- [ ] Keep RISK_REGISTER.md updated as post-launch issues surface (e.g., real-world dedup false positives not caught by the pre-launch corpus).
- [ ] Revisit v2 scoping (ROADMAP.md Phase 4) only after a real post-launch usage period, not immediately at launch.
