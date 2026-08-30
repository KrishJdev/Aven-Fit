# HANDOFF.md

> **Canonical Handoff State** — Single persistent handoff file. Update in place at session end.
> **Last updated:** 2026-08-30

---

## Active Project & Stack

- **Project:** Aven Fit (Offline-first Gym & Nutrition Tracker for Android)
- **Mobile:** Flutter + Dart in `mobile/` (State: Riverpod, Local DB: `sqflite`)
- **Backend:** Spring Boot 3.3 + Java 21 in `backend/` (Server DB: PostgreSQL 16)
- **Archived RN Codebase:** `archive/react-native-frontend/` (reference UX/intent only)

---

## Sources of Truth

- **Product Features & Build Order:** `FEATURES.md` (repo root — all phases P0/P1/V1.1/V2, per-screen specs)
- **Architecture, Rules & Stack Laws (L1–L10):** `AGENTS.md`
- **Developer Setup & Run:** `README.md`
- **Sprint / Session Memory:** `HANDOFF.md` (this file)

---

## Current Milestone: MVP P0 Flutter Scaffolding & Backend DB Alignment

| Component | Status | Next Actions |
|:---|:---|:---|
| **Mobile (`mobile/`)** | ⬜ Ready to scaffold | Initialize Flutter project, establish Glassmorphism theme & SQLite schema |
| **Backend (`backend/`)** | ✅ Scaffolded | Align JPA entities and PostgreSQL migrations with `FEATURES.md` |

---

## Branching & Workflow

- **Active Branch:** `feature/flutter-migration` (branch off `dev`, merge back to `dev`)
- **Stable Branch:** `main` | **Integration Branch:** `dev`
- **Rules:** Never use destructive git commands; follow conventional commits.

