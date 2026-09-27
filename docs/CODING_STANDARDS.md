# Coding Standards & Repo Conventions

Lightweight, solo-developer-appropriate conventions — enough consistency to make the codebase maintainable across the gaps between part-time work sessions (see NFR.md § 6), not process for its own sake.

## 1. Repo Structure

Mirrors ARCHITECTURE.md § 4:

```
Verso.xcodeproj (or Package.swift-based app)
├── App/
├── Sources/
│   ├── VersoCore/
│   ├── VersoPhotoKit/
│   ├── VersoCloudSync/
│   ├── VersoUIShared/
│   ├── VersoUIMac/
│   └── VersoUIiOS/
├── Tests/
├── docs/                 # this documentation set
├── SPEC.md               # product spec & production plan (source of truth for product intent)
└── README.md
```

Module boundaries (`VersoCore` has zero PhotoKit/CloudKit imports, etc.) are enforced by the Swift Package structure itself, not just convention — a dependency the wrong direction won't compile.

## 2. Swift Style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) as the baseline; no house style beyond that is needed for a solo project.
- Prefer `struct`/value types for models (`AssetMetadata`, `TriageItem`, etc.); reserve classes for things with genuine identity/lifecycle (services, view models).
- Async work via `async`/`await` throughout — no completion-handler-based APIs written fresh in this codebase (PhotoKit and CloudKit's older completion-handler APIs get wrapped once at the boundary, not threaded through the rest of the app).
- No force-unwraps (`!`) or force-tries (`try!`) outside of test code — this matters more than usual here given PhotoKit/CloudKit's many nullable/throwing edges (see DATA_MODEL.md's nullable field list).

## 3. Testing Conventions

- Every `VersoCore` function with a non-trivial branch (especially dedup thresholding logic) gets a unit test — this module is the one place 100%-ish coverage is a reasonable bar, since it's pure and cheap to test (ARCHITECTURE.md § 2.2).
- Integration tests (`VersoPhotoKitTests`, `VersoCloudSyncTests`) are allowed to be slower and fewer, but every item in TEST_PLAN.md § 3–4 needs at least one corresponding test, not just manual verification.
- Test corpus images (TEST_PLAN.md § 2) live outside the main repo (or in Git LFS / a separate assets repo) to avoid bloating clone size with binary image fixtures.

## 4. Git Conventions

- `main` is always shippable; feature work happens on short-lived branches.
- Commit messages: imperative mood, one logical change per commit, body explains *why* when it's not obvious from the diff alone (matches the standard this project's own history already follows).
- Every commit authored with Claude Code assistance carries the attribution footer already established for this repo:
  ```
  Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_01HuUCs19T284naci6XD6yae
  ```
- Issues/Milestones seeded from ROADMAP.md — each roadmap bullet becomes one Issue, each `##` phase becomes one Milestone, so GitHub's own issue tracker stays the single live view of remaining work rather than this document drifting out of sync with it.

## 5. Documentation Upkeep

- `docs/` is living documentation, not a one-time deliverable — in particular, RISK_REGISTER.md's status column and ROADMAP.md's checkboxes should be updated as part of the work they describe, not retroactively.
- Any architectural decision that deviates from ARCHITECTURE.md or DATA_MODEL.md as written should update those documents in the same change, so they stay trustworthy as the reference rather than becoming historical artifacts.

## 6. What's Deliberately Not Specified Here

No CI/CD pipeline, linting tool, or code-formatting tool is mandated yet — for a solo project, adding one (e.g., SwiftLint/SwiftFormat, GitHub Actions for test runs) is a cheap, low-risk addition worth doing early in Phase 0/1, but the specific choice is left to whoever sets it up rather than pre-decided here.
