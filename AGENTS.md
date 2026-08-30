# AGENTS.md — Multi-Agent Coordination Protocol

> **Project:** Aven Fit (Gym Tracker)
> **Repository:** Source of truth. Neither agent owns it.
> **Last updated:** 2026-08-30

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

- **Frontend (Flutter + Dart):** UI/UX, Glassmorphism design system, screens, Riverpod state management, and SQLite local persistence (`sqflite`).
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
3. **Slice Anatomy:**
   - **Flutter Client:** Screen UI, Glassmorphism components, Riverpod state provider, and SQLite queries.
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
4. Run: git status           (check for uncommitted work)
5. Run: git log --oneline -5 (understand recent commits)
6. Inspect current code      (do not assume prior understanding is current)
```

> [!IMPORTANT]
> **Archive Quarantine Rule:**  
> Files in `docs/archive/` and `archive/` are strictly historical archives. Agents must **NEVER read, reference, cite, or base any implementation on files in `docs/archive/` or `archive/`** unless the user explicitly requests historical context. Active development relies solely on `FEATURES.md`, `AGENTS.md`, `HANDOFF.md`, and `README.md`.

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
| Local Database | SQLite | **Locked** |
| Backend | Spring Boot + Java | **Locked** |
| Server Database | PostgreSQL | **Locked** |
| API Style | REST | **Locked** |
| Auth | Spring Security | **Locked** |

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
