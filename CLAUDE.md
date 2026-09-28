# Verso (fuzzy-meme) — Claude Code notes

Platform: iOS / iPadOS / macOS. Built following
[app-launch-kit](https://github.com/gustyforcast/app-launch-kit)'s
pipeline — but this repo's planning docs predate and exceed
app-launch-kit's `spec.md`/`plan.md`/`tasks.md` templates, so they stay
as they are rather than being renamed to match. The mapping:

| app-launch-kit stage | This repo's equivalent |
|---|---|
| `spec.md` (the *what and why*) | `SPEC.md` + `docs/PRD.md` |
| `plan.md` (the *how*) | `docs/ARCHITECTURE.md` + `docs/DATA_MODEL.md` |
| `tasks.md` (checklist) | `docs/ROADMAP.md` (phase-by-phase; check items off in the same commit that finishes them, same rule as the template) |
| Open questions / risk tracking | `docs/RISK_REGISTER.md` — check this before assuming anything is settled |

## Read before working

- `docs/RISK_REGISTER.md` first, always — it's the live list of what's
  actually unresolved, including which design decisions are
  deliberately deferred (see row 7).
- `SPEC.md` §Production Plan and `docs/ROADMAP.md` for what phase we're
  in and its exit criterion — don't start Phase N+1 work before Phase
  N's exit criterion is met.
- `docs/UX_FLOWS.md` for screen-by-screen behavior before writing any
  screen.

## Design system

- Shared conventions are already decided in app-launch-kit's
  `docs/09-visual-direction.md`: glass surface (TimDeaconKit's
  `GlassCard`), monospace/tabular numerals for data readouts only
  (`Font.dataReadout` — EXIF fields, frame counts, ratings-as-numbers),
  one accent color per app. Apply these from day one; they don't wait
  for the Phase 3 visual-identity pass.
- This app's own visual identity (the light-table/contact-sheet/loupe
  direction, its accent color) is deliberately scheduled for Phase 3
  per `docs/RISK_REGISTER.md` #7 — don't front-run that decision in
  earlier phases beyond the shared conventions above.
- Check `TimDeaconKit`'s Explorer/catalog (once it has one) before
  writing new UI — see app-launch-kit `docs/02-design-system-guide.md`.
  Phase 0/1 work here is mostly PHAsset/CloudKit/Vision plumbing, not
  UI, so TimDeaconKit likely won't see real use in this app until the
  Phase 1 contact-sheet grid UI or later.

## Working rules

- This may run as a cloud (no Xcode) session or an on-device session —
  check which tools you actually have before assuming you can build.
  Cloud sessions: write code, tests, docs. On-device or CI: build, run
  on simulator, sign, release.
- Phase 0 is explicitly spikes with written findings, not production
  code — see `docs/ROADMAP.md` Phase 0's exit criterion. Don't scaffold
  a full app-launch-kit project (`scripts/new-project.sh`) until Phase 0
  is either done or a spike genuinely needs a runnable project shell to
  test against.
- Don't guess at `xcodebuild` invocations by hand if XcodeBuildMCP is
  available — use it.
- A task isn't done until CI is green once CI exists (see
  `docs/CODING_STANDARDS.md` and, once scaffolded,
  `.github/workflows/`).
- If you're about to write a UI component that feels like it belongs in
  every app, not just this one, say so — it probably belongs in
  `TimDeaconKit`, not here.
- Keep this file short. Point at the docs above, don't duplicate them.
