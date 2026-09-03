# HANDOFF.md Template & Authoring Guide

> **Purpose:** Blueprint for authoring and maintaining `HANDOFF.md` — the single persistent memory file and active sprint state across multi-agent sessions.  
> **Audience:** AI coding agents ending or resuming work sessions.

---

## 1. Structure of `HANDOFF.md`

Every `HANDOFF.md` must adhere to this exact canonical structure:

```markdown
# HANDOFF.md

> **Canonical Handoff State** — Single persistent handoff file. Update in place at session end.
> **Last updated:** <YYYY-MM-DD>

---

## Active Project & Stack

- **Project:** <Project Name> (<Platform & Core Purpose>)
- **Mobile / Frontend:** <Framework, Language, State Management, Local DB, Navigation, Architecture Pattern>
- **Backend / API:** <Framework, Language, Server DB, Auth Mechanism>
- **Archive Policy:** <List of quarantined folders or branches to never access>

---

## Session Notes

- **<YYYY-MM-DD> (session 1):** <Detailed summary of work done: files created, architectural decisions, forced deviations, test results>.
  - **NEXT STEP (exact):** <Concrete, actionable task description for the next session>.

- **<YYYY-MM-DD> (session 2):** <Summary of work unit completed, bug fixes, test counts>.
  - **NEXT STEP (exact):** <Next task>.

---

## Sources of Truth

- **Product Features & Build Order:** `FEATURES.md`
- **Architecture Blueprint & Conventions:** `ARCHITECTURE.md`
- **Multi-Agent Protocol & Stack Laws:** `AGENTS.md`
- **Implementation Work Units:** `EXECUTION_PLAN.md`
- **Developer Setup & Run:** `README.md`
- **Sprint / Session Memory:** `HANDOFF.md` (this file)

---

## Development Strategy & Milestones (Vertical Slices)

| Slice | Focus | Status | Scope | Test Verification Targets |
|:---|:---|:---:|:---|:---|
| **Slice 1** | Foundation & Scaffold | ✅ Completed | Core setup, database, router, theme | Unit tests passing, analyze 0 issues |
| **Slice 2** | <Feature A> | ✅ Completed | Domain, data, DAO, UI, API | All feature tests green |
| **Slice 3** | <Feature B> | 🔵 In Progress | Core loop, live UI, write-through | E2E journey tests |
| **Slice 4** | <Feature C> | ⬜ Queued | Integration, background sync | Integration test suite |

---

## Branching & Workflow

- **Active Development Branch:** `dev`
- **Stable Production Branch:** `main`
- **Feature Branches:** `feature/*` (branched from `dev`, merged back to `dev`)
- **Rules:** Never force-push or clean uncommitted files; use Conventional Commits.
```

---

## 2. Session Protocol & Rules of Engagement

### 2.1 Updating in Place
- **Never wipe session history:** Chronological session entries create an audit trail and prevent repeated mistakes or duplicate work.
- **Always update the Milestone Table:** Reflect accurate statuses (`✅ Completed`, `🔵 In Progress`, `⬜ Queued`).
- **Always provide an exact NEXT STEP:** The next agent starting cold should not have to guess what file or function to build next.

### 2.2 Recording Forced Deviations & Ratifications
If an unexpected toolchain break, compiler update, or API change requires deviating from the locked stack:
1. Document the exact root cause, failed command, and resolution.
2. Record whether the deviation requires user ratification.
3. Once ratified, document the date and update `AGENTS.md`.
