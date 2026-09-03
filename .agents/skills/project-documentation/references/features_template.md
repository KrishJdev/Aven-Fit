# FEATURES.md Template & Authoring Guide

> **Purpose:** Blueprint for authoring `FEATURES.md` — the complete product feature specification and absolute source of truth for what to build, screen-by-screen UX intent, and roadmap priorities.  
> **Audience:** Product designers, architects, and AI agents.

---

## 1. Structure of `FEATURES.md`

Every `FEATURES.md` document must follow this exact section layout:

```markdown
# <Project Name> — Comprehensive Feature Specification

> **Purpose:** The complete product feature specification — every feature, screen, and sub-page across the full product vision (MVP → V2).
> **Source of Truth:** Repository root. Applies to all engineering agents.
> **Rule:** Replicate behavior and UX intent, not legacy code.
> **Last updated:** <YYYY-MM-DD>

---

## 1. Product Overview & Quality Bar
- Mission statement & unique value proposition.
- Target persona, regional/market context, and target hardware constraints.
- Non-negotiable quality bar table (App size, cold start, logging latency, offline reliability, battery).

## 2. Product Laws & Competitive Positioning
- Product Laws (L1–LN): Non-negotiable design laws learned from competitor pain.
- "Why We Win" Table: Documented competitor failures vs our specific product answers.

## 3. Phase Legend & Promotion Rule
- Roadmap phase tags:
  - [P0]: MVP Core — Must ship
  - [P1]: MVP Polish / Secondary features
  - [V1.1]: Post-launch Delight
  - [V2]: Advanced / Network / AI features
  - [PROPOSED]: Feature idea awaiting user approval
- Promotion Rule: How [PROPOSED] items are promoted (user approval -> strip tag -> update phase).

## 4. Complete Screen Map
- Text-based tree diagram of every screen, modal, sub-sheet, and route in the application.
- Each entry tagged with its phase (e.g. `├─ Active Workout [P0]`).

## 5 to N. Detailed Feature & Screen Specifications
- Grouped by feature domain (e.g., Onboarding, Core Workflow, Catalog, Nutrition, History, Settings).
- Detailed screen breakdown:
  - Screen Name & Target Route
  - Phase Tag ([P0], [P1], etc.)
  - Layout & Visual Hierarchy
  - User Interactions & Tap Flows
  - Data Prefill & Ghost Values
  - Persistence & SQLite Schema Binding
  - Edge Cases, Empty States, and Error Fallbacks (Law L6)

## N+1. Proposals Ledger
- Table of proposed features awaiting user sign-off (Proposal ID, Screen, Description, Target Phase, Impact).
```

---

## 2. Best Practices for Authoring Screen Specs

### 2.1 Screen Specification Template
When describing a specific screen in `FEATURES.md`, use this standardized schema:

```markdown
### §X.Y Screen Name `[P0]`
- **Route:** `/path/to/screen` (or modal / bottom sheet)
- **Purpose:** 1–2 sentences explaining what the user accomplishes.
- **Entry Points:** How the user reaches this screen.
- **Visual Layout (Top to Bottom):**
  - Header: Title, actions, progress indicators.
  - Body: Cards, lists, steppers, tabular figures.
  - Sticky Bottom Bar: Primary CTA, summary badges.
- **Data & Invariants:**
  - Local source of truth: Table name, reactive stream.
  - Write-through rule: When and how mutations persist to SQLite.
  - Speed requirement: Maximum allowed interaction latency (e.g., <3s, <100ms).
- **Designed States (Law L6):**
  - Loading: Glass skeleton placeholder.
  - Empty: Custom copy, icon, and primary action CTA.
  - Error: Error description and retry action.
```

### 2.2 Specifying "Why We Win"
Always anchor product features against competitor pain points:
1. Identify competitor weak points (e.g., paywalled routines, calorie shaming, poor offline support, generic food data).
2. Directly define how the feature turns that weakness into your application's primary moat.

### 2.3 Phase Discipline
- Never leave features ambiguous in timing. Every bullet or screen heading must carry a phase tag: `[P0]`, `[P1]`, `[V1.1]`, or `[PROPOSED]`.
- Agents must only build features in the active sprint phase (defaulting to `[P0]`).
