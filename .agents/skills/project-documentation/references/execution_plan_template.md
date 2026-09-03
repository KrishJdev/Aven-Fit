# EXECUTION_PLAN.md Template & Authoring Guide

> **Purpose:** Blueprint for authoring `EXECUTION_PLAN.md` — the multi-agent implementation plan that decomposes broad feature specs into discrete, parallel-safe, agent-sized work units.  
> **Audience:** Technical leads, project managers, and AI agents.

---

## 1. Structure of `EXECUTION_PLAN.md`

Every `EXECUTION_PLAN.md` must follow this structure:

```markdown
# <Project Name> — Comprehensive Multi-Agent Implementation Plan

> **Generated:** <YYYY-MM-DD> · **Branch:** `dev`
> **Goal:** Complete P0 MVP — all core flows functional, locally testable, ship-ready.

---

## 1. Current State Assessment
- Table of Completed Work Units / Slices vs Remaining Slices.
- Baseline test results and toolchain status.

## 2. Work Unit Design Philosophy
- Table defining work unit sizing budgets:
  - New files created: 5–12 files
  - Lines of code: 400–1,200 LOC
  - Scope: One layer of one feature (Domain, Data, or Presentation)
  - Duration: ~30–90 minutes of agent execution
  - Verification: Concrete pass/fail automated test command
- Agent coordination rule: Two agents never edit the same file simultaneously; concurrent agents work in separate directory trees.

## 3. Dependency Graph (Mermaid DAG)
- Visual flowchart linking Slices and Work Units from foundation to MVP complete.
- Read bottom-up or top-to-bottom with clear dependency arrows.

## 4. Slice Breakdown & Work Units (WU-X.Y)
For each Slice (e.g. Slice 1: Foundation, Slice 2: Feature A, Slice 3: Feature B):
- Slice Overview & Backend/Mobile readiness status.
- Individual Work Units (WU-1.1, WU-1.2, etc.):
  - Metadata table: Agent, Depends on, Can run parallel with, Scope.
  - Files to create / modify (with exact paths and purpose).
  - Verification checklist (exact shell commands to run, assertions, and expected test count).

## 5. Cross-Cutting Work Units (WU-X.1 to WU-X.N)
- Global concerns (Home dashboard integration, Profile/settings, Empty/loading/error state sweeps, Database migration audits).

## 6. Open Questions & Architectural Decisions
- Decision ledger (Question ID, Title, Status [Open/Resolved], Decision summary, Date).
```

---

## 2. Authoring Guidelines

### 2.1 Sizing Work Units for AI Agents
- **Avoid Oversized Units:** If a work unit requires writing the entire feature across domain, database, UI, and network all at once, the agent will run out of context or produce shallow code.
- **Enforce Single Layer per WU:**
  - `WU-X.1`: Domain models + pure unit tests.
  - `WU-X.2`: Data tables + DAOs + Repository + in-memory tests.
  - `WU-X.3`: Presentation controller + state + widget screens + UI tests.
- **State Prerequisites Explicitly:** Every WU must list its exact upstream dependencies (e.g., "Depends on WU-2.1").

### 2.2 Concrete Verification Targets
Never end a work unit with vague instructions like "verify that it works". Every WU must specify:
1. Exact command (e.g. `dart run build_runner build`, `flutter test test/features/workout/set_test.dart`).
2. Expected output (e.g., "0 analyzer issues, 4/4 passing tests").
