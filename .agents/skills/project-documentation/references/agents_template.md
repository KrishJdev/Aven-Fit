# AGENTS.md Template & Authoring Guide

> **Purpose:** Blueprint for authoring `AGENTS.md` — the multi-agent coordination protocol, stack laws, safety rules, and E2E quality matrix.  
> **Audience:** AI coding agents (Antigravity, Claude, OpenCode, Codex) and human engineers.

---

## 1. Structure of `AGENTS.md`

Every `AGENTS.md` document must contain the following core sections:

```markdown
# AGENTS.md — Multi-Agent Coordination Protocol

> **Project:** <Project Name> (<Brief One-Liner>)
> **Repository:** Source of truth. Neither agent owns it.
> **Last updated:** <YYYY-MM-DD>

---

## 1. Agents & Responsibilities
- Table of agents, platforms, models, and scopes.
- Explicit statement of parity: agents are equal collaborators.

## 2. Development Strategy (Vertical Slices)
- Feature-First / Vertical Slice philosophy (end-to-end delivery).
- Offline-first or primary client/server contract.
- Anatomy of a slice (Domain -> Data -> Presentation -> API).
- Concrete Definition of Done per slice.

## 3. Baseline Pre-Checks (Before Every Task)
- Checklist: Read AGENTS.md -> Read HANDOFF.md -> Read FEATURES.md -> git status -> git log -> inspect code.
- Explicit Quarantine Rules (e.g. legacy/archived folders quarantined).
- "No Redundant Implementation Plans" rule (start immediately without pause if plan is established).

## 4. Git Workflow & Safety Rules
- Branching table (`main`, `dev`, `feature/*`, `fix/*`).
- Conventional Commits requirement (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).
- Strictly forbidden destructive commands (`git reset --hard`, `git clean -fd`, `git push --force`).

## 5. Conflict Resolution Protocol
- STOP -> INSPECT -> UNDERSTAND -> EVALUATE -> DECIDE.
- Posture: Preserve existing working code; improve, don't replace.

## 6. Technology Stack (Locked vs Explicitly Rejected)
- Table of Locked Stack choices (Platform, Language, Framework, State, Database, API, Auth).
- Tooling version matrix.
- Explicitly Rejected technologies (preventing architectural drift).

## 7. E2E Quality Matrix & User Journeys (J1–JN)
- Matrix of automated user journeys, phase alignment, and laws verified.
- Concrete step-by-step journey scenarios acting as merge gates.
- Device profiling and execution rules.
```

---

## 2. Authoring Guidelines

### 2.1 The Locked Stack & Explicit Rejections
- **Locked Technologies:** Pin the exact language versions, frameworks, state managers, and database engines. State why they are locked.
- **Explicitly Rejected Technologies:** List common alternatives that must **NOT** be introduced (e.g., rejecting Supabase, GraphQL, Microservices, or alternative state managers). This prevents agents from improvising dependencies.

### 2.2 Stack Laws Formulation
Formulate 5 to 10 foundational **Stack Laws** based on competitor weaknesses, device limitations, or user non-negotiables:
- Form: Short name + imperative rule + rationale + forbidden anti-pattern.
- Examples: Sub-3s performance, offline-first reliability, zero CPU polling, adherence-neutral feedback, crash resilience.

### 2.3 E2E Quality Matrix (Journeys J1–JN)
- Formulate executable user journeys that cross all stack layers (UI $\rightarrow$ Local DB $\rightarrow$ API $\rightarrow$ Cloud DB).
- Each journey must state:
  1. Trigger conditions (e.g. airplane mode, guest mode).
  2. Sequential user actions.
  3. Direct database assertions (asserting SQLite/PostgreSQL tables, not just UI widgets).
  4. Which Stack Laws it gates.
