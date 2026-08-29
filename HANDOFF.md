# HANDOFF.md

> **Canonical handoff state.** Update this file in place at the end of every work session — do not append historical entries. Detailed history lives in `docs/archive/`.
> **Last updated:** 2026-08-30

---

## Current Focus

**Migrating the mobile app from React Native to Flutter** (`feature/flutter-migration` branch).

## Project State

| Component | Status |
|:---|:---|
| Backend (Spring Boot) | Scaffolded, not actively developed |
| Mobile (React Native) | **Superseded** — last stable state on `dev` (commit `ed9370c`) |
| Mobile (Flutter) | **Not started** — no Flutter project exists yet |

## Completed Milestones (RN era — reference for re-implementation)

- **UI system:** "Sharp Glassmorphism" — Neon Cyan (#00F0FF) accent, translucent surfaces (`theme/colors`, GlassCard, GlassButton, Typography)
- **Screens:** Home, WorkoutList, ActiveWorkout, Progress, Nutrition, ExerciseDirectory, RoutineMetadata, WorkoutSummary
- **Local SQLite schema** with workout / exercise / set tables
- **Active workout engine:** dynamic time-of-day naming, live timer with persisted pause state (`last_resumed_at`), ghost set placeholders from history
- **Dashboard aggregates:** volume/sets/exercises computed via SQLite joins

## Next Steps (Flutter)

1. Delete the React Native `mobile/` directory
2. Initialize a Flutter project in `mobile/`
3. Re-implement: Glassmorphism theme → SQLite (sqflite) → workout engine → screens, using Riverpod for state
4. Read `docs/archive/DEVELOPMENT_LOG.md` for detailed UI/DB implementation decisions worth carrying over

## Branches

| Branch | State |
|:---|:---|
| `main` | Stable |
| `dev` | Latest RN bug fixes (pause persistence, input sanitization) — kept as reference |
| `feature/flutter-migration` | **Active** — Flutter migration work happens here |

## Known Issues / Decisions

- RN `mobile/` on `dev` contains a debug script (`mobile/test-db.js`) — do not carry over
- Stack is locked per `AGENTS.md`: Flutter + Dart, Riverpod, sqflite, Spring Boot backend
- Root docs (`AGENTS.md`, `PRODUCT_ROADMAP.md`, `README.md`) are untracked in git — keep them updated in place

## Notes for Other Agent

- The RN codebase on `dev` is the spec: replicate behavior and UX intent, not code
- WorkoutSummaryScreen had robust "not found" and error-alert handling — preserve this UX quality in Flutter
