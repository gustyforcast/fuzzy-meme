# UX Flows

Screen-by-screen flows per platform. Companion to SPEC.md § Platform-Specific UX and PRD.md's user stories. This document is the reference for building actual screens; it intentionally describes flow and interaction, not visual design (see RISK_REGISTER.md — visual identity is a separate, not-yet-started pass).

## 1. Shared Flow: Import → Triage → Commit

Applies identically on Mac and iOS/iPadOS, with platform-specific presentation (§ 2, § 3):

1. **Source detected or chosen.** A card/volume is connected, or the user picks a folder (Files app on iPad, Finder-style picker on Mac).
2. **Scan.** App enumerates media, reads embedded metadata, runs the exact-match check silently. Progress shown as a simple count ("Checking 340 files…").
3. **New-only surfacing.** Only files not already in the library (per exact-match) proceed to triage. If zero new files, show a plain "Nothing new on this card" state — no empty triage screen.
4. **Near-dup/burst clustering pass.** Runs before triage is shown; clusters are pre-computed so the triage view can present them grouped from the first frame.
5. **Triage.** Platform-specific view (§ 2 / § 3). Each item or cluster gets a keep/reject decision, plus optional rating/flag/film-metadata during the same pass.
6. **Commit.** On finishing (or at any point the user chooses to commit partially), kept items are written into Photos with their decided metadata in one batch operation. A progress indicator covers this since PhotoKit writes are not instantaneous at volume.
7. **Source left untouched.** Explicit confirmation copy: "Your card hasn't been changed — clear it yourself once you're happy." No auto-delete, ever (SPEC.md § Import & Ingest is explicit on this).

## 2. Mac Flow: Contact-Sheet Grid

- **Layout:** dense grid, thumbnail-forward, current selection highlighted with a visible border (not just a colour tint, for accessibility — see NFR.md).
- **Navigation:** arrow keys move selection; a cluster is entered/expanded with Return and exited with Escape.
- **Keyboard shortcuts (mirrors Photo Mechanic, per SPEC.md § Platform-Specific UX):**
  - `1`–`5`: set star rating on current selection.
  - `0`: clear rating.
  - Modifier + number (e.g., `⌥1`–`⌥6`): set colour flag (red/yellow/green/blue/purple/orange).
  - `P`: mark pick. `X`: mark reject. `U`: clear pick/reject.
  - `Space` or `L`: open full-screen loupe view for the current selection.
  - `Delete`/`Backspace` in triage (pre-commit only): discard from import (never touches the source card).
- **Loupe view:** full-screen, single image, same shortcut set active, arrow keys advance to next item without returning to the grid.
- **Batch film-metadata entry:** a side panel, selectable across a whole cluster/roll, "Apply to all selected" action — this is the v1 mechanism for roll-level metadata without a dedicated logging UI (see PRD.md US-11, ROADMAP.md v2).

## 3. iPhone/iPad Flow: Swipe Deck

- **Layout:** one image full-screen at a time, matching the Tinder-deck mental model the user explicitly asked for.
- **Primary gesture:** vertical swipe (up = pick, down = reject), chosen specifically to avoid clashing with the system's own horizontal photo-navigation gesture (SPEC.md § Platform-Specific UX).
- **Secondary interaction (rating / colour flag) — NOT YET LOCKED.** Two candidate approaches to prototype (see RISK_REGISTER.md for tracking):
  - **Option A — bottom action bar:** a persistent thin bar with rating stars and flag colours, tappable without leaving the deck. Pro: discoverable, no hidden gestures. Con: takes vertical space on a device already tight on screen real estate.
  - **Option B — long-press radial menu:** long-press surfaces a radial picker for rating/flag, dismiss returns to the deck. Pro: zero persistent chrome. Con: hidden affordance, needs onboarding.
  - **Decision process:** build both as throwaway prototypes in Phase 2 (see ROADMAP.md), test with real users (or at minimum the primary user) doing a real 100+ photo culling pass, pick based on completion time and error rate, not aesthetic preference.
- **Cluster handling on swipe deck:** a burst/near-dup cluster is entered as a mini-deck-within-the-deck — swiping through cluster members first, with the suggested keeper (see DedupService quality-assist) shown first and visually marked.
- **Batch film-metadata entry on iOS:** deferred interaction pattern — likely a sheet presented from the action bar/radial menu rather than attempting inline entry on a small screen; not blocking v1 since folder-based film import is expected to happen from Mac more often than iPad (flagged as an assumption to validate with the actual user, not proven).

## 4. Cross-Cutting States

- **Empty states:** "No new photos" post-scan; "No duplicates found" if dedup finds nothing; both are reassuring confirmations, not dead ends.
- **Sync status (see DATA_MODEL.md § 4):** a subtle, non-blocking indicator if a metadata conflict was resolved via fallback (whole-record last-writer-wins) — never silent.
- **First-run / permissions:** a single, clear ask for full Photos library access up front, with a one-paragraph explanation of why (echoing SPEC.md's on-device-only positioning as reassurance, not just a system permission dialog).

## 5. Explicitly Deferred (v2, not designed here)

- Dedicated film roll/frame logging screens (SPEC.md § Feature Spec: Film Metadata v2).
- Any visual identity/theming pass (see RISK_REGISTER.md).
