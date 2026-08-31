# AGENTS.md — Multi-Agent Coordination Protocol

> **Project:** Aven Fit (Gym Tracker)
> **Repository:** Source of truth. Neither agent owns it.
> **Last updated:** 2026-08-31

---

## Agents

| Agent | Platform | Typical Models | Role & Scope |
|:---|:---|:---|:---|
| **Antigravity** | Gemini IDE Agent | Gemini 3.7 Flash (High), IDE Models | Full-stack, Architecture, Flutter Frontend, Code Review, Product |
| **OpenCode** | CLI Agent | Multi-model (via Command Code CLI) | Full-stack, Implementation, Backend, Refactoring, Infrastructure |

Both agents are equal collaborators across the entire project. Agent selection for any task is flexible and driven by user discretion. Neither agent has override authority.

---

## Responsibilities

Responsibilities are **flexible and collaborative across both agents** rather than rigid silos. Either agent may be tasked with:

- **Frontend (Flutter + Dart):** UI/UX, Glassmorphism design system, screens, Riverpod state management, and local SQLite persistence via **Drift** (reactive, compile-safe queries).
- **Backend (Spring Boot 3.3 + Java 21):** JPA entities, services, controllers, Flyway migrations, and PostgreSQL schemas.
- **Product & Architecture:** Feature interpretation against `FEATURES.md`, system design, sync strategy, and security.
- **Review & Quality:** Reviewing work, writing tests, refactoring, and maintaining documentation.

> [!NOTE]
> Regardless of which agent is assigned to a task, both must coordinate via `HANDOFF.md`, adhere to the stack laws, and preserve existing working code.

---

## Development Strategy: Feature-by-Feature (Vertical Slices)

To avoid schema drift and detached APIs, the project follows a strict **Vertical Slice (Feature-by-Feature)** development approach:

1. **End-to-End Delivery:** Features are built domain-by-domain across the full stack rather than building all backend APIs first or all UI screens in isolation.
2. **Offline-First Contract:**
   - **Local SQLite (`mobile/`):** Primary source of truth during live usage (Law L2). Must support instantaneous reads/writes (<3s set logging).
   - **Spring Boot API (`backend/`):** Serves as the authentication authority, cloud backup, and sync hub.
3. **Slice Anatomy (Feature-First Clean Architecture):**
   - **Flutter Client — `lib/features/<feature>/`:** each feature is self-contained in three layers:
     - `domain/`: Freezed immutable models (entities, value objects).
     - `data/`: Drift DAOs, data sources, and the Repository implementation.
     - `presentation/`: Riverpod Notifiers/Stores (unidirectional state) and `ConsumerWidget` UI.
     - Shared primitives (database, network, router, theme) live in `lib/core/` — features never reach into each other's internals.
   - **Backend Service:** Corresponding Spring Boot REST controller, DTO validation, and PostgreSQL entity/migration.
   - **Sync Contract:** Local `sync_queue` payload matches server ingestion schema.
4. **Definition of Done for a Slice:**
   - Local offline flow functions 100% without internet.
   - Associated Spring Boot endpoints pass unit/integration tests (`./gradlew test`).
   - `HANDOFF.md` updated with slice status.

---

## Before Every Task

Every agent MUST perform these checks before starting significant work:

```
1. Read AGENTS.md           (this file — check for protocol updates)
2. Read HANDOFF.md          (understand current sprint, milestone & active tasks)
3. Read FEATURES.md         (understand product specs, screen maps & phase priorities)
4. Read ARCHITECTURE.md     (understand layer anatomy, code patterns & conventions)
5. Run: git status           (check for uncommitted work)
6. Run: git log --oneline -5 (understand recent commits)
7. Inspect current code      (do not assume prior understanding is current)
```

> [!IMPORTANT]
> **Archive Quarantine Rule:**  
> Files in `docs/archive/` and `archive/` are strictly historical archives. Agents must **NEVER read, reference, cite, or base any implementation on files in `docs/archive/` or `archive/`** unless the user explicitly requests historical context. Active development relies solely on `FEATURES.md`, `ARCHITECTURE.md`, `AGENTS.md`, `HANDOFF.md`, and `README.md`.

**Never assume your previous context is still accurate.**

---

## Git Workflow

### Branches

| Branch | Purpose |
|:---|:---|
| `main` | Stable, reviewed code only |
| `dev` | Active development branch (Flutter codebase & active backend development) |
| `archive/react-native` | Archived legacy React Native branch (historical baseline & reference) |
| `feature/*` | Feature branches (branched from `dev`, merged back to `dev`) |
| `fix/*` | Bug fix branches |

### Commit Convention

Use conventional commits:

```
feat: add workout logging screen
fix: resolve rest timer not persisting across app restart
docs: update HANDOFF with backend setup notes
refactor: extract exercise repository interface
test: add unit tests for set logging service
chore: update gradle dependencies
```

### Safety Rules

**NEVER use destructive commands without explicit user authorization:**

```
git reset --hard
git clean -fd
git restore .
git checkout .
git push --force
```

**NEVER:**
- Commit unrelated changes in the same commit
- Modify files outside the scope of your current task
- Overwrite another agent's uncommitted work
- Force-push over another agent's commits
- Access or load files from `docs/archive/` or `archive/` unless explicitly requested by the user

---

## Conflict Resolution

When your work overlaps with the other agent's recent changes:

```
1. STOP — Do not silently overwrite
2. INSPECT — Read the other agent's implementation
3. UNDERSTAND — Determine the intent behind their changes
4. EVALUATE — Can both implementations coexist or be integrated?
5. DECIDE:
   a. If clearly compatible → integrate and note it in HANDOFF.md
   b. If unclear → ask the user for direction
   c. If the other agent's work has a bug → fix minimally and document
```

**Default posture:** Preserve existing working code. Improve, don't replace.

---

## Communication Protocol

Agents communicate through the repository:

| Channel | Purpose |
|:---|:---|
| `HANDOFF.md` | Session memory, status updates, decisions, known issues |
| `AGENTS.md` | Protocol updates & architecture rules (this file) |
| `ARCHITECTURE.md` | System design, layer anatomy, data flow diagrams & code patterns |
| `FEATURES.md` | Feature specifications, screen maps, and phase alignment |
| Git commit messages | Change documentation |
| Code comments | Implementation context |

### Handoff Protocol

When finishing a work session, update `HANDOFF.md` in place with the current milestone status, recent changes, and next recommended actions for the next agent/session.

---

## Technology Stack (Locked)

The following stack decisions are **locked** and must not be changed without explicit user approval:

| Layer | Technology | Status |
|:---|:---|:---|
| Platform | Android-first | **Locked** |
| Mobile Framework | Flutter + Dart | **Locked** |
| Local Database | SQLite via **Drift** (`drift_flutter` + `sqlite3_flutter_libs`) — reactive, compile-safe queries | **Locked** |
| Backend | Spring Boot + Java | **Locked** |
| Server Database | PostgreSQL | **Locked** |
| API Style | REST | **Locked** |
| Auth | Spring Security | **Locked** |

### Key Tooling (Locked)

| Tool | Role |
|:---|:---|
| Riverpod 3.x | State management — Notifiers/Stores, unidirectional state |
| GoRouter 18 | Declarative navigation (deep links, shell routes) |
| Freezed 4 + JsonSerializable | Immutable domain models & JSON codegen |
| Dio | HTTP client for Spring Boot API |
| WorkManager 0.10+ | Background sync queue draining (network-constrained, backoff) |
| Patrol 4.9+ | Native-aware E2E/integration tests (notifications, permissions) |
| Mocktail | Unit-test mocking for repositories/stores |
| lucide_icons_flutter | Icon set (Lucide); replaces `lucide_icons`, which cannot compile on Flutter 3.47 (final `IconData`) |

> [!NOTE]
> **Ratified 2026-08-31:** The version upgrades above (Riverpod 3.4.2, GoRouter 18, Drift 2.34.x, Freezed 4 / freezed_annotation 3.1, WorkManager 0.10.9, Patrol 4.9, build_runner 2.16, flutter_lints 6) and the `lucide_icons` → `lucide_icons_flutter` swap were approved by the user. The original Riverpod 2.x codegen stack is pinned to `analyzer ^7`, which cannot parse Dart 3.10+ framework sources, making the upgrade mandatory on the Dart 3.13 / Flutter 3.47 toolchain.

### Explicitly Rejected

Do **NOT** introduce as primary stack:

- React Native / TypeScript
- Supabase
- GraphQL
- Microservices
- Kafka / Redis / Elasticsearch / Kubernetes (not for MVP)

---

## Quality Standard

This project targets production quality. Both agents must optimize for:

- **Correctness** — Does it work as intended?
- **Security** — No secrets in code, proper auth, input validation
- **Maintainability** — Clear naming, clean structure, reasonable abstractions
- **Testability** — Code should be testable; write tests
- **Performance** — Budget Android phones are the target
- **User Experience** — Every interaction should feel fast and intentional

Do not optimize for:
- Speed of delivery at the cost of quality
- Number of files changed
- Artificial complexity
- "Looks finished"

---

## E2E Testing Strategy & Quality Matrix

Automated E2E journeys are the executable form of the Quality Standard. Each journey walks a real user path across Flutter UI → SQLite → (where applicable) Spring Boot → PostgreSQL, and is a pass/fail gate in the Definition of Done for slices in its phase. Steps run on an emulator with airplane-mode toggling where specified; SQLite/PostgreSQL state is asserted via direct DB queries, not UI reads alone.

### Quality Matrix

| # | Journey | Phase | Laws Verified | Gate |
|:--|:---|:---|:---|:---|
| J1 | Core Offline Workout | `[P0]` | L1, L2, L7, L8 | Merge gate: workout-engine slices |
| J2 | Routine Creation & Schedule | `[P0]` | L2, L3, L7 | Merge gate: routine slices |
| J3 | Offline Indian Nutrition | `[P0]` | L2, L4, L10 | Merge gate: nutrition slices |
| J4 | Trojan Horse Migration | `[P1]` | L2, L7, L9 | Merge gate: import engine |
| J5 | Cultural & Metabolic | `[V1.1]` | L2, L4, L10 | Merge gate: Vrat/TDEE slices |
| J6 | Multi-Device Sync Pipeline | `[V1.1]` | L2, L7, L8 | Merge gate: sync slices |

### Journey Definitions

**J1 — Core Offline Workout Journey `[P0]`**
1. Launch as guest, airplane mode ON → assert Home renders from SQLite in <2s; no account/permission wall (L2).
2. Search "bench" → assert results served from the bundled local exercise library (zero network).
3. Log set with ghost prefill → assert ghost values from last local performance; ✓ commits write-through to SQLite before UI lock, full interaction <3s (L1/L7).
4. Rest timer on lock screen → assert foreground-service notification countdown with +15s action; state changes render on event, zero polling (L8).
5. Force-kill mid-session → relaunch → assert exact restore (exercises, sets, elapsed/paused time via epoch math).
6. Finish → assert Workout Summary totals match SQLite exactly; PR badge fires for a beaten record; warm-up sets excluded.

**J2 — Routine Creation & Schedule Journey `[P0]`**
1. Build a PPL routine (3 days, ordered exercises, target sets/weight/reps) → assert write-through survives app kill.
2. START from the routine → assert pre-named session created in <1s; original routine row unmutated (L7).
3. Verify target prefills: ghost hints show routine targets ("Target: 80 × 8"), not historical values (§8.1).
4. Edit routine metadata + reorder exercises mid-flow → assert persisted order reflected on session start and restart.
5. Assert unlimited routine creation — no cap logic anywhere in the flow (L3).

**J3 — Offline Indian Nutrition Journey `[P0]`**
1. Search "dal" in airplane mode → assert results from the bundled ~5k-entry Indian food DB (L2/L10).
2. Select household unit "1 katori" → assert exact gram-equivalent macros for the entry.
3. Log to Lunch → assert write-through + macro recalculation <100ms.
4. Assert dashboard totals equal the sum of logged items; rendering is adherence-neutral — cyan/grey bars, no judgment colors (L4).
5. Assert no-goals state hides the calories-remaining card (never a nag, L4).

**J4 — Trojan Horse Migration Journey `[P1]`**
1. Import a 3-year Hevy/Strong CSV via system file picker → assert parsing is 100% on-device (network inspection: zero traffic), guest mode allowed (L2/L9).
2. Fuzzy match → assert high-confidence auto-maps, medium-confidence batch review screen, low-confidence rows become pre-filled custom-exercise offers — zero rows silently dropped (L7).
3. Cancel before commit → assert SQLite byte-identical; commit → assert single-transaction all-or-nothing ingestion.
4. Re-import the same CSV → assert source-ID duplicate detection skips every row (never double-logged).
5. Assert PRs recomputed locally (§10.2 parity) and the success state ("Imported N workouts · M sets · K PRs") lands on Progress with real data.

**J5 — Cultural & Metabolic Journey `[V1.1]`**
1. Enable Vrat Mode via explicit opt-in + region/tradition toggle → assert festival calendar loads from bundled offline asset (never assumed from date/location, L4).
2. Satvik filter check → assert food search restricted to the satvik set (sabudana, kuttu, singhara, makhana) in airplane mode (L2).
3. Assert streak freeze holds: fasting days count as active rest in the forgiving weekly streak (§17).
4. Log weight + intake over 2–3 simulated weeks → assert offline EMA TDEE recalibration fires weekly, silently, and honors user-set bulk/cut override targets (L2/L4).
5. Assert every surface in the journey is adherence-neutral — no red flags, no verdicts, no nags (L4).

**J6 — Multi-Device Sync Pipeline `[V1.1]`**
1. Sign in, go offline → log sets → assert local SQLite commits first and `sync_queue` grows (local stays source of truth, L2/L7).
2. Restore network → assert WorkManager drains the queue; inject failure → assert exponential backoff, no CPU polling (L8).
3. Push to Spring Boot `POST /api/v1/sync/push` → assert 2xx and payload matches the local `sync_queue` ingestion schema (Sync Contract, § Development Strategy).
4. Verify PostgreSQL rows by integration query — client-generated UUIDs preserved, no duplicates/lost sets after last-writer-wins conflict injection.
5. Kill sync mid-flight → assert user actions never block or roll back; Settings pending count matches queue depth (L7).

### Execution Rules

- **Tooling:** Flutter `integration_test` + Patrol for UI journeys; direct Drift/`sqlite3` assertions for DB state; `./gradlew test` + PostgreSQL integration tests for J6 backend steps (steps 3–5).
- **Device profile:** journeys run on the budget-phone emulator profile (₹9,000-class) to honor the performance quality bar above.
- **Gating:** a failing journey blocks merge to `dev` for any slice touching its domain and must be recorded in `HANDOFF.md` (known issues).
- **Extensibility:** new user journeys must extend this matrix — no parallel test-strategy documents.
