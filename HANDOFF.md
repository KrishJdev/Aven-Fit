# HANDOFF.md

> **Canonical Handoff State** — Single persistent handoff file. Update in place at session end.
> **Last updated:** 2026-08-31

---

## Active Project & Stack

- **Project:** Aven Fit (Offline-first Gym & Nutrition Tracker for Android)
- **Mobile:** Flutter + Dart in `mobile/` (State: Riverpod, Local DB: `sqflite`)
- **Backend:** Spring Boot 3.3 + Java 21 in `backend/` (Server DB: PostgreSQL 16)
- **Archive Policy:** `docs/archive/` and `archive/` are quarantined; never access unless explicitly instructed.

---

## Sources of Truth

- **Product Features & Build Order:** `FEATURES.md` (repo root — all phases P0/P1/V1.1/V2, per-screen specs)
- **Architecture, Rules & Stack Laws (L1–L10):** `AGENTS.md`
- **Developer Setup & Run:** `README.md`
- **Sprint / Session Memory:** `HANDOFF.md` (this file)

---

## Development Strategy & Milestones (Vertical Slices)

| Slice | Focus | Status | Scope | Test Verification Targets |
|:---|:---|:---:|:---|:---|
| **Slice 1** | Scaffolding & Foundation | 🔵 Active | Flutter setup in `mobile/`, Glassmorphism theme, SQLite helper, Backend health | Flutter smoke test + Spring Boot health check |
| **Slice 2** | Exercises & Routines | ⬜ Queued | Local SQLite exercise cache + Flutter UI + `/api/v1/exercises` & `/routines` | Local SQLite query benchmarks (<100ms) + Routine builder unit tests |
| **Slice 3** | Active Workout Engine | ⬜ Queued | Live session UI, rest timer math, SQLite write-through + `/api/v1/workouts` | E2E live-session test with SQLite write-through & lock-screen service test |
| **Slice 4** | Indian Nutrition Engine | ⬜ Queued | Local 5,000 foods search, household units + `/api/v1/nutrition` | 5,000 foods local search test + macro math unit tests |
| **Slice 5** | Auth & Cloud Sync | ⬜ Queued | Phone OTP/Google login, Spring Security + `/api/v1/sync` queue | Spring Security OTP integration test + sync push/pull integration tests (`./gradlew test`) |
| **Post-MVP** | P1/V1.1/V2 slices | ⬜ Queued | CSV importer, EMA TDEE engine, Vrat Mode, sync hardening, AI surfaces | CSV importer integrity test, EMA TDEE math test, Trainer QR payload test |

---

## Branching & Workflow

- **Active Development Branch:** `dev` (Flutter codebase & active Spring Boot backend)
- **Archive Branch:** `archive/react-native` (legacy React Native code preserved for reference)
- **Stable Branch:** `main` | **Feature Branches:** `feature/*` (branched from `dev`, merged back to `dev`)
- **Rules:** Never use destructive git commands; follow conventional commits.

