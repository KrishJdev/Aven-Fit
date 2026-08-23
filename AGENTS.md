# AGENTS.md — Multi-Agent Coordination Protocol

> **Project:** Aven Fit (Gym Tracker)
> **Repository:** Source of truth. Neither agent owns it.
> **Last updated:** 2026-08-24

---

## Agents

| Agent | Platform | Model | Primary Role |
|:---|:---|:---|:---|
| **Antigravity** | Gemini IDE Agent | Claude Opus (current) | Product, Architecture, Frontend, Code Review |
| **OpenCode** | CLI Agent | Ox Alpha | Implementation, Backend, Infrastructure |

Both agents are collaborators with equal access. Neither has override authority.

---

## Responsibilities

### Antigravity

| Area | Scope |
|:---|:---|
| **Product** | Feature interpretation, requirements, prioritization, UX decisions, MVP scope |
| **Architecture** | System architecture, domain modelling, API design, database design, sync strategy, security |
| **Frontend** | React Native architecture, TypeScript, UI/UX, navigation, screens, state management, Android UX |
| **Review** | Review OpenCode's work for correctness, architecture, security, performance, maintainability |

### OpenCode / Ox Alpha

| Area | Scope |
|:---|:---|
| **Backend** | Spring Boot implementation, JPA entities, repositories, services, controllers |
| **Database** | PostgreSQL schema implementation, migrations, seed data |
| **Infrastructure** | Build configuration, CI/CD, environment setup |
| **Implementation** | Feature implementation assigned or coordinated with Antigravity |

> [!NOTE]
> These are primary responsibilities, not exclusive territories. Either agent may work in any area when appropriate. Coordination is expected when working in the other agent's primary area.

---

## Before Every Task

Every agent MUST perform these checks before starting significant work:

```
1. Read AGENTS.md           (this file — check for protocol updates)
2. Read DEVELOPMENT_LOG.md  (understand recent changes and current state)
3. Read PRODUCT_ROADMAP.md  (understand current priorities)
4. Run: git status           (check for uncommitted work)
5. Run: git log --oneline -5 (understand recent commits)
6. Inspect current code      (do not assume prior understanding is current)
```

**Never assume your previous context is still accurate.**

---

## Git Workflow

### Branches

| Branch | Purpose |
|:---|:---|
| `main` | Stable, reviewed code only |
| `dev` | Active development integration branch |
| `feature/*` | Feature branches (branch from `dev`, merge back to `dev`) |
| `fix/*` | Bug fix branches |

### Commit Convention

Use conventional commits:

```
feat: add workout logging screen
fix: resolve rest timer not persisting across app restart
docs: update DEVELOPMENT_LOG with backend setup notes
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

---

## Conflict Resolution

When your work overlaps with the other agent's recent changes:

```
1. STOP — Do not silently overwrite
2. INSPECT — Read the other agent's implementation
3. UNDERSTAND — Determine the intent behind their changes
4. EVALUATE — Can both implementations coexist or be integrated?
5. DECIDE:
   a. If clearly compatible → integrate and note it in DEVELOPMENT_LOG.md
   b. If unclear → ask the user for direction
   c. If the other agent's work has a bug → fix minimally and document
```

**Default posture:** Preserve existing working code. Improve, don't replace.

---

## Communication Protocol

Agents communicate through the repository:

| Channel | Purpose |
|:---|:---|
| `DEVELOPMENT_LOG.md` | Handoff notes, status updates, decisions, known issues |
| `AGENTS.md` | Protocol updates (this file) |
| `PRODUCT_ROADMAP.md` | Priority and scope alignment |
| Git commit messages | Change documentation |
| Code comments | Implementation context |

### Handoff Format

When finishing a work session, leave a handoff entry in DEVELOPMENT_LOG.md:

```markdown
### [Date] — [Agent Name]

**Task:** What was being worked on
**Changes:** Files added/modified
**Status:** Complete / In Progress / Blocked
**Tests:** What was tested and results
**Known Issues:** Any problems discovered
**Next Steps:** Recommended next action
**Notes for Other Agent:** Anything the other agent should know
```

---

## Technology Stack (Locked)

The following stack decisions are **locked** and must not be changed without explicit user approval:

| Layer | Technology | Status |
|:---|:---|:---|
| Platform | Android-first | **Locked** |
| Mobile Framework | React Native + TypeScript | **Locked** |
| Local Database | SQLite | **Locked** |
| Backend | Spring Boot + Java | **Locked** |
| Server Database | PostgreSQL | **Locked** |
| API Style | REST | **Locked** |
| Auth | Spring Security | **Locked** |

### Explicitly Rejected

Do **NOT** introduce as primary stack:

- Flutter / Dart
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
