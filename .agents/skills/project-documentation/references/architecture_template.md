# ARCHITECTURE.md Template & Authoring Guide

> **Purpose:** Blueprint for authoring `ARCHITECTURE.md` — the system architecture specification, layer contracts, data flow rules, and vertical slice implementation blueprint.  
> **Audience:** Software architects, lead developers, and AI agents.

---

## 1. Structure of `ARCHITECTURE.md`

Every `ARCHITECTURE.md` must follow this standardized structure:

```markdown
# ARCHITECTURE.md — System Architecture & Implementation Blueprint

> **Project:** <Project Name> (<One-Line Description>)
> **Platform:** <Platform / Stack Summary>
> **Version:** <Architecture Version & Ratified Dependencies>
> **Source of Truth:** Repository root. Applies to all engineering agents & contributors.

---

## 1. Architectural Philosophy & Core Laws
- Foundational constraints (e.g. Offline-first, performance budgets, device classes).
- Architectural laws (e.g. Sub-3s interactions, zero CPU polling, crash resilience).

## 2. Architecture Pattern (Feature-First Clean Architecture)
- Directory layout: `core/` (shared primitives) vs `features/<feature>/` (vertical slices).
- Architectural Boundary Rules:
  - Feature Encapsulation: Features never import internals from sibling features.
  - Shared Infrastructure: Features depend on `core/`, but `core/` never depends on features.
  - Dependency Flow: Presentation -> Domain <- Data.

## 3. Layer Responsibilities & Contracts
- Mermaid flowchart visualizing layer boundaries and unidirectional calls.
- 3.1 Domain Layer: Entities, value objects, domain logic, pure Dart/language (zero UI/DB imports).
- 3.2 Data Layer: Table schemas, DAOs, local sources, remote clients, repository implementations.
- 3.3 Presentation Layer: Immutable UI states, unidirectional store/controllers, declarative views.

## 4. Unidirectional Data Flow (The 5-Step Cycle)
- Sequence diagram or numbered trace:
  1. UI Event Dispatch -> 2. Controller Optimistic Update -> 3. Repository Write-Through ->
  4. Database Transaction Commit -> 5. Declarative UI Re-render.

## 5. Blueprint for New Feature Slices
- Numbered, sequential steps for adding any new slice (Step 1 Domain -> Step 2 Data -> Step 3 Presentation -> Step 4 Router -> Step 5 Verification).

## 6. Testing Strategy & Quality Matrix
- Table mapping each architectural layer to its testing tool, target, and isolation approach.

## 7. Technology Stack Reference (Ratified)
- Exact list of libraries, state management, databases, routers, and testing frameworks.
```

---

## 2. Authoring Guidelines

### 2.1 The Inward Dependency Rule
Strictly enforce layer boundaries in documentation:
- **Domain Layer:** Pure business entities and mathematical rules. Must never import UI frameworks (e.g. Flutter/React) or database libraries (e.g. Drift/Room/Prisma).
- **Data Layer:** Implements repository contracts defined in the Domain layer. Encapsulates SQL, DAOs, and API clients.
- **Presentation Layer:** Consumes Domain models and repository interfaces via dependency injection / state containers.

### 2.2 Unidirectional Flow Invariant
Explicitly ban two-way data binding, direct widget-to-database access, or mutable global singletons. The architecture must clearly document:
1. Optimistic updates for perceived speed.
2. Synchronous write-through to local persistent storage before asynchronous tasks.
3. Reactive stream emission as the single trigger for UI re-renders.
