# Non-Functional Requirements

## 1. Privacy & Security

Directly enforcing SPEC.md § Architecture Principles #3 ("On-device, algorithmic only"):
- No network calls of any kind for image processing, duplicate detection, or metadata analysis. This is a testable constraint, not just a stated intent — verifiable by monitoring network activity during those operations in QA (see TEST_PLAN.md).
- No third-party SDKs, analytics, or crash reporters that transmit image data or derived image features off-device. If crash/analytics tooling is added at all, it must be limited to non-image, non-identifying operational data, and disclosed in the App Store privacy nutrition label (see RELEASE_CHECKLIST.md).
- CloudKit private database only — never a public or shared database — since there is no social/sharing feature in scope (SPEC.md explicitly excludes this).
- No account system beyond the user's own Apple ID/iCloud identity already used for Photos.

## 2. Performance

- **Library size target:** the app must remain responsive against a library in the 20,000–50,000 asset range (a realistic ceiling for a serious hybrid film/digital shooter over years of use), not just a demo-sized library of a few hundred.
- **Contact-sheet grid scroll:** target 60fps scroll on Mac at the above library size; degraded-but-usable is acceptable below that only as a documented, tracked limitation, not silently shipped.
- **Import triage responsiveness:** a single import session of several hundred files should present the first triage item within a few seconds of scan start, with clustering continuing in the background rather than blocking the UI.
- **CloudKit metadata sync latency:** a metadata change should propagate to a second device within CloudKit's normal push-notification latency (typically seconds, not minutes) under normal conditions; this is bounded by Apple's infrastructure, not something the app controls directly, but should be measured (see TEST_PLAN.md § 4) so a regression is visible.

## 3. Accessibility

- All custom UI (contact-sheet grid, swipe deck, loupe view) must support Dynamic Type and VoiceOver at a baseline level — this is a from-day-one requirement, not a post-launch addition, given Apple's own App Store review expectations and the general principle that a culling tool used for long sessions should not fatigue or exclude users.
- Colour flags (SPEC.md § Rating, Tagging & Flagging) must never be colour-only as the sole indicator of state in a list/grid context — pair with a shape/icon or label for colourblind users, consistent with the loupe/grid selection-highlight decision already made in UX_FLOWS.md § 2.
- Keyboard-only operation on Mac (UX_FLOWS.md § 2) doubles as an accessibility requirement, not just a power-user convenience.

## 4. Reliability

- **No data loss on conflict** (see DATA_MODEL.md § 4) — the single hardest reliability requirement in the whole app, since colour flags and pick/reject state have no native-Photos backup copy if the app's own metadata layer loses them.
- **Source media is never modified or deleted** by the import pipeline (SPEC.md § Import & Ingest, PRD.md US-1 AC4) — treated as an invariant, tested explicitly (TEST_PLAN.md § 5), not just assumed from code review.
- **Partial-import safety:** if an import session is interrupted (app killed, device sleeps), previously committed assets must remain fully valid in Photos with correct metadata; only the in-flight, uncommitted item may be lost.

## 5. Compatibility

- **Minimum OS: iOS 27 / iPadOS 27 / macOS 27.** A hard dependency (SPEC.md § Technical Stack), not a target to relax later without revisiting the native-field architecture decision (see RISK_REGISTER.md — this needs confirming against the target user's actual hardware/OS currency before being locked further).
- Apple Silicon Mac only is acceptable (no stated requirement for Intel Mac support, given the OS-version floor already excludes most Intel-era hardware from realistic day-one support).

## 6. Maintainability (solo-developer context)

- Given this is built and maintained by one person alongside full-time employment (SPEC.md § Production Plan), architecture choices favor low ongoing maintenance burden over maximal flexibility: this is the stated rationale for leaning on native PhotoKit fields and CloudKit's own sync rather than any custom equivalent (SPEC.md § Architecture Principles), and it should continue to guide any future scope decisions, including v2.
- Automated regression tests (TEST_PLAN.md § 10) substitute for a dedicated QA function and should be treated as load-bearing, not optional polish.

## 7. Explicit Non-Requirements

- No requirement for offline-first multi-user collaboration (single-user, single-iCloud-account scope only).
- No requirement for localisation beyond English in v1 (not addressed in SPEC.md; flagged here as an assumption to confirm, not a decision).
