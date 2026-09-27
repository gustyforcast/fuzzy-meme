# Verso (working title)

A Photos-companion app for photographers who shoot both film and digital — import, cull, rate, tag, deduplicate, and manage film-specific metadata, without leaving Apple Photos and without a subscription. Full context: [SPEC.md](./SPEC.md).

> **Naming note:** "Verso" is a working title only, pending formal trademark clearance — see [docs/RISK_REGISTER.md](./docs/RISK_REGISTER.md) #1.

## Start Here

| Document | What it covers |
| --- | --- |
| [SPEC.md](./SPEC.md) | Product vision, target user, market gap, business model, high-level architecture and production plan — the source of truth for *why* this app exists and *what kind* of product it is. |
| [docs/PRD.md](./docs/PRD.md) | Testable product requirements: user stories and acceptance criteria for every v1 feature. |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | System architecture, module boundaries, proposed codebase structure. |
| [docs/DATA_MODEL.md](./docs/DATA_MODEL.md) | Exactly which fields live in native Photos vs. this app's CloudKit metadata layer, plus sync/conflict rules. |
| [docs/UX_FLOWS.md](./docs/UX_FLOWS.md) | Screen-by-screen flows for Mac and iPhone/iPad. |
| [docs/TEST_PLAN.md](./docs/TEST_PLAN.md) | QA strategy, with a dedicated section on measuring duplicate-detection accuracy. |
| [docs/NFR.md](./docs/NFR.md) | Performance, privacy, accessibility, reliability and compatibility requirements. |
| [docs/ROADMAP.md](./docs/ROADMAP.md) | Production plan broken into phase-by-phase epics/backlog items. |
| [docs/RISK_REGISTER.md](./docs/RISK_REGISTER.md) | Every open decision and risk, tracked with status — check this before assuming something is settled. |
| [docs/RELEASE_CHECKLIST.md](./docs/RELEASE_CHECKLIST.md) | App Store Connect, privacy label, and TestFlight checklist. |
| [docs/CODING_STANDARDS.md](./docs/CODING_STANDARDS.md) | Repo structure, Swift style, git conventions. |
| [docs/GLOSSARY.md](./docs/GLOSSARY.md) | Every domain and technical term used across this document set. |

## Suggested Reading Order

1. **SPEC.md** — understand the product and why it's worth building.
2. **docs/PRD.md** and **docs/UX_FLOWS.md** — understand exactly what v1 does, screen by screen.
3. **docs/ARCHITECTURE.md** and **docs/DATA_MODEL.md** — understand how it's built.
4. **docs/ROADMAP.md** — start with Phase 0; nothing else should begin until its spikes pass.
5. **docs/RISK_REGISTER.md** — keep this open throughout; it's the live list of what's still unresolved.

## Status

Documentation-complete for a from-scratch build; no code written yet. Next step is Phase 0 (see [docs/ROADMAP.md](./docs/ROADMAP.md)).
