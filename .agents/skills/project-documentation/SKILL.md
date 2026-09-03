---
name: project-documentation
description: >-
  Operational runbook and methodology for transforming raw user requirements, product visions,
  or legacy codebases into a production-grade, multi-agent-ready project documentation suite
  (including AGENTS.md, FEATURES.md, HANDOFF.md, ARCHITECTURE.md, and EXECUTION_PLAN.md). Use when
  bootstrapping a new software project, re-architecting an existing system, onboarding autonomous
  AI coding agents, or establishing rigorous engineering protocols and specifications.
---

# Project Documentation Engineering — Operational Skill

This skill provides a systematic, repeatable framework for extracting user requirements and generating a complete, battle-tested project documentation suite optimized for multi-agent autonomous engineering.

---

## 1. The Five Pillars of Multi-Agent Documentation

A multi-agent development project requires clear separation of concerns across documentation. Never combine all instructions into a single bloated prompt or README.

```
Repository Root
├── AGENTS.md          # 1. Multi-Agent Protocol: Rules of engagement, stack laws, locked stack, git safety, quality matrix
├── FEATURES.md        # 2. Product Specification: Absolute source of truth for WHAT to build, screen maps, UX intent, phases
├── ARCHITECTURE.md    # 3. Technical Blueprint: Layer contracts, data flow diagrams, database schemas, sync contracts
├── EXECUTION_PLAN.md  # 4. Multi-Agent Plan: Work unit breakdown (sized for single sessions), DAG dependency graph
├── HANDOFF.md         # 5. Runtime Memory: Persistent session changelog, sprint state, milestones, next exact tasks
└── README.md          # 6. Developer Onboarding: High-level overview, quickstart setup, tech stack badges
```

### Document Authority Hierarchy
1. **`FEATURES.md`** has absolute override authority on **product behavior, screen layouts, and roadmap phases**.
2. **`ARCHITECTURE.md`** has absolute override authority on **layer boundaries, file structure, and technical patterns**.
3. **`AGENTS.md`** has absolute override authority on **agent behavior, stack laws, git rules, and toolchain constraints**.
4. **`EXECUTION_PLAN.md`** defines **work unit sizing and implementation sequencing**.
5. **`HANDOFF.md`** records **session-by-session state and immediate next actions**.

---

## 2. Requirement Extraction Methodology

When given raw user requirements, a product brief, or an initial codebase, systematically extract and categorize details across these 5 dimensions:

### Step 1: Persona & Hardware Constraints
- Who is the user? (e.g. gym-goers in Tier 2/3 Indian cities, enterprise accountants, offline field workers).
- What hardware/OS constraints exist? (e.g. budget ₹8,000 Android phones, OEM battery killers like MIUI, poor cellular connectivity).
- What are the non-negotiable performance budgets? (Cold start <2s, interaction <3s, zero CPU polling).

### Step 2: Competitor Pain Points ("Why We Win")
- What do existing competitors do wrong? (e.g., paywalled routines in Strong, calorie shaming in MyFitnessPal, unreliable offline mode in Hevy).
- Formulate the product's direct answer to each competitor failure.

### Step 3: Product & Stack Laws (Non-Negotiables)
- Define 5 to 10 foundational design and architectural laws (e.g. L1: Sub-3s logging, L2: 100% offline primacy, L4: Never shame, L7: Crash resilience).
- Each law must have: Rule statement + Rationale + Forbidden anti-patterns.

### Step 4: Technology Stack Selection & Rejection
- Pin the primary stack: Language, framework, state management, local database, cloud database, API style, auth.
- Explicitly declare **rejected technologies** to prevent agents from introducing architectural drift (e.g., explicitly banning Supabase, GraphQL, or Microservices).

### Step 5: Screen Map & Phase Tagging
- Enumerate every screen, modal, and sub-sheet.
- Tag every item with a strict phase: `[P0]` (MVP must-have), `[P1]` (MVP polish), `[V1.1]` (Post-launch delight), or `[PROPOSED]` (needs user review).

---

## 3. Step-by-Step Documentation Generation Workflow

Follow this sequence to author the documentation suite without gaps or circular dependencies:

```
Step 1: Draft FEATURES.md
        ├── Define Product Overview & Value Proposition
        ├── Enumerate Product Laws & "Why We Win" Matrix
        ├── Establish Phase Legend ([P0], [P1], [V1.1], [V2], [PROPOSED])
        ├── Build Complete Screen Map (hierarchical tree)
        └── Detail per-screen specifications (inputs, layouts, persistence, empty states)

Step 2: Draft AGENTS.md
        ├── Define Agent roles & equal collaboration posture
        ├── Declare Locked Tech Stack & Explicitly Rejected Technologies
        ├── Embed the Stack Laws (L1–LN) & pre-task baseline checks
        ├── Establish Git workflow (branches, Conventional Commits, forbidden destructive commands)
        ├── Formulate Conflict Resolution protocol
        └── Create E2E Quality Matrix (Journeys J1–JN across layers)

Step 3: Draft ARCHITECTURE.md
        ├── Define architectural pattern (e.g., Feature-First Clean Architecture)
        ├── Establish directory tree (`core/` vs `features/<slice>/`)
        ├── Enforce inward layer dependencies (Presentation -> Domain <- Data)
        ├── Map 5-step Unidirectional Data Flow (UI -> Controller -> Repo -> DB -> UI)
        ├── Detail database engine (tables, DAOs, migrations, isolate safety)
        └── Document API & sync contracts (DTO mappings, conflict resolution)

Step 4: Draft EXECUTION_PLAN.md
        ├── Enforce Work Unit Sizing Budget (5–12 files, 400–1,200 LOC, single agent session)
        ├── Build Mermaid Dependency Graph (DAG)
        ├── Break down vertical slices into discrete work units (WU-X.Y)
        └── Define concrete pass/fail verification commands for every work unit

Step 5: Initialize HANDOFF.md
        ├── Record Active Project & Stack baseline
        ├── Initialize Session Notes with session 1 foundation summary
        ├── List Sources of Truth
        ├── Populate Milestone Table with slice statuses (Completed, In Progress, Queued)
        └── Set the exact, unambiguous NEXT STEP for the subsequent session

Step 6: Generate README.md
        └── Summarize overview, tech stack, documentation links, and local dev setup
```

---

## 4. Key Rules for Multi-Agent Authoring

1. **Self-Contained Slices:** Specify code in vertical slices (`domain/`, `data/`, `presentation/`). Avoid horizontal slicing where one agent writes all backend APIs and another writes detached UI.
2. **No Ambiguous Verifications:** Every work unit in `EXECUTION_PLAN.md` must have an executable shell command (e.g. `./gradlew test`, `flutter test test/features/auth/auth_test.dart`) and expected pass conditions.
3. **Session Sizing Rule:** Never create work units that require more than 1,200 LOC or cross multiple architectural layers simultaneously. Decompose into `WU-X.1: Domain`, `WU-X.2: Data/DAO`, `WU-X.3: Presentation/UI`.
4. **Quarantine Historical Code:** If migrating from a legacy codebase, establish an **Archive Quarantine Rule** in `AGENTS.md` and `HANDOFF.md` forbidding agents from referencing archived code unless explicitly instructed.
5. **No Redundant Plans Rule:** Explicitly instruct agents in `AGENTS.md` not to generate repetitive implementation plans when the project plan already exists in `EXECUTION_PLAN.md`.

---

## 5. Reference Templates & Authoring Guides

For complete boilerplate templates, section-by-section schemas, and checklists, consult the files in `references/`:

- **[`references/agents_template.md`](./references/agents_template.md):** Complete guide and schema for `AGENTS.md` (stack laws, locked stack, git safety, quality matrix).
- **[`references/features_template.md`](./references/features_template.md):** Complete guide and schema for `FEATURES.md` (competitor pain, screen map, per-screen specs, phase legend).
- **[`references/handoff_template.md`](./references/handoff_template.md):** Complete guide and schema for `HANDOFF.md` (session memory, milestone table, forced deviation logs).
- **[`references/architecture_template.md`](./references/architecture_template.md):** Complete guide and schema for `ARCHITECTURE.md` (Feature-First Clean Architecture, layer contracts, data flows).
- **[`references/execution_plan_template.md`](./references/execution_plan_template.md):** Complete guide and schema for `EXECUTION_PLAN.md` (work unit sizing budgets, Mermaid DAGs, verification gates).
