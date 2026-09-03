# Stack Laws, Rules & Protocol Reference — Aven Fit

> **Scope:** The 10 Product/Stack Laws, Multi-Agent Collaboration Protocol, Archive Quarantine, and Quality Matrix.  
> **Source of Truth:** Corresponds to root `AGENTS.md` and `FEATURES.md` §2.

---

## 1. The 10 Stack Laws (Non-Negotiable)

These are architectural and product laws learned from competitor failures. Violating any law is a build/review rejection.

| # | Law | Engineering Implementation | Forbidden Anti-Patterns |
|:---|:---|:---|:---|
| **L1** | **Logging must be faster than lifting (<3s)** | Optimistic UI updates; local SQLite write-through before async calls; 1-tap set completion with ghost prefill; single-tap start from Home; warm-up volume strictly excluded. | Network requests in set logging path; multi-step modal dialogs; spinners blocking input; counting warm-ups in working volume. |
| **L2** | **Never require internet or an account (Offline Primacy)** | 100% core flow functional offline; guest mode first; bundled offline assets (55 exercises, 948+ Indian foods); local SQLite is primary source of truth. | Login walls on install; requiring cloud sync for history/routines; failing when offline. |
| **L3** | **No paywall on core utility** | Unlimited routines forever; full history access; no artificial feature caps. | Paywalls on routine slots (Strong 3-routine cap mistake); locking basic analytics. |
| **L4** | **Never shame (Adherence-Neutral UI)** | Flat cyan/grey progress bars; missing weekly goal shows neutral "0 weeks" (never angry streak-break warnings); missing goals card hides calories-remaining card; over-target days show factual grey delta (never red alarms). | Red blinking alarms; streak lost banners; moral judgment copy ("You failed", "Cheat day"). |
| **L5** | **No interruptions in the logging flow** | Haptic pulse + one-shot volt-green badge for PRs; zero full-screen popups; zero video/ads inside Active Workout. | Confetti animations; interstitial dialogs; sound effects during live sets; ads. |
| **L6** | **Every screen has designed empty, loading, and error states** | Skeleton glass loader for async data; clear empty states with actionable CTAs; error banners with actionable `RETRY` button (`ref.invalidate(...)`). | Blank black screens; infinite spinners; unhandled exceptions; dead-end error pages without retry. |
| **L7** | **Destructive actions need confirmation; sessions survive crashes** | Dialog confirmation for discarding workouts, deleting routines, or deleting completed sets; write-through persistence per set; self-healing PR recompute parity on edit/delete; active session restore via epoch math. | Silent set deletions on swipe; uncompleted sets leaving phantom PRs; losing session on app kill. |
| **L8** | **Respect the battery and the OS** | Zero CPU polling; timers derived from monotonic epoch timestamps (`DateTime.now().millisecondsSinceEpoch`); native foreground service only during active sessions; WorkManager constraints. | `Timer.periodic` polling in background; persistent wake-locks; battery-draining CPU loops. |
| **L9** | **Users own their data** | Local CSV export/import; open schema contracts; zero vendor lock-in mechanics. | Obfuscated local storage; paywalled data export. |
| **L10** | **India is not a localization — it's the product** | Curated Indian food catalog; regional household serving units (`katori`, `roti`, `scoop`, `bowl`); Satvik fasting filter (§11.10); Vrat Mode. | Generic Western database; forcing gram conversions for traditional dishes. |

---

## 2. Multi-Agent Operating Rules

### 2.1 Baseline Pre-Task Checks
Before writing any code or modifying configurations, every agent MUST execute:
```bash
1. Read AGENTS.md           # Review protocol updates & stack laws
2. Read HANDOFF.md          # Understand active milestone, sprint state & next tasks
3. Read FEATURES.md         # Absolute source of truth for product specs & phase priorities
4. Check git status         # Check for uncommitted work
5. Inspect current code     # Verify existing implementations before proposing changes
```

### 2.2 Archive Quarantine Rule
> [!IMPORTANT]
> Files in `docs/archive/` and `archive/` are strictly historical archives. Agents must **NEVER read, reference, cite, or base any implementation on files in `docs/archive/` or `archive/`** unless explicitly requested by the user. Active development relies solely on `FEATURES.md`, `ARCHITECTURE.md`, `AGENTS.md`, `HANDOFF.md`, and `README.md`.

### 2.3 No Redundant Implementation Plans Rule
Implementation plans and work units are already formally scheduled in `EXECUTION_PLAN.md`, `FEATURES.md`, and `ARCHITECTURE.md`. Agents must **NOT create separate implementation plans or pause for plan approval** when tasked with an established work unit or slice. Start immediately with code implementation, testing, and verification.

### 2.4 Handoff Protocol (`HANDOFF.md`)
- `HANDOFF.md` is the single persistent memory file across agent sessions.
- At the end of every session, update `HANDOFF.md` in place with:
  - Session notes (session number, date, work completed, bugs resolved, test counts).
  - Updated Milestone Table status.
  - Exact next recommended steps for the subsequent agent.

### 2.5 Git Safety Rules
**NEVER run destructive commands without explicit user authorization:**
- `git reset --hard`
- `git clean -fd`
- `git restore .`
- `git checkout .`
- `git push --force`

Commit messages must strictly follow **Conventional Commits**:
`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.

---

## 3. E2E Quality Matrix & User Journeys

Automated E2E journeys represent executable definitions of done across vertical slices.

| Journey | Name | Phase | Laws Verified | Gate Target |
|:---|:---|:---:|:---|:---|
| **J1** | **Core Offline Workout** | `[P0]` | L1, L2, L7, L8 | Live set logging <3s, ghost prefill, epoch restore after kill, summary totals match SQLite, warm-up volume exclusion. |
| **J2** | **Routine Creation & Schedule** | `[P0]` | L2, L3, L7 | PPL builder, instant session start (<1s), source routine unmutated, target prefill hints. |
| **J3** | **Offline Indian Nutrition** | `[P0]` | L2, L4, L10 | Local search "dal" <300ms, "1 katori" household unit scaling, macro calculation <100ms, adherence-neutral UI. |
| **J4** | **Trojan Horse Migration** | `[P1]` | L2, L7, L9 | On-device Hevy/Strong CSV import, fuzzy exercise matching, all-or-nothing transaction, PR recomputation. |
| **J5** | **Cultural & Metabolic** | `[V1.1]` | L2, L4, L10 | Vrat mode, Satvik filter restricted search, streak freeze on fast days, offline EMA TDEE recalibration. |
| **J6** | **Multi-Device Sync Pipeline** | `[V1.1]` | L2, L7, L8 | SQLite commit first, WorkManager sync queue draining, Spring Boot ingestion, Last-Writer-Wins conflict resolution. |

---

## 4. Test Craft & Code Quality Rules

### 4.1 In-Memory SQLite Testing
Drift DAO and Repository tests must execute against in-memory SQLite:
```dart
final db = AppDatabase.forTesting(NativeDatabase.memory());
```
Always verify foreign key enforcement:
```dart
await db.customStatement('PRAGMA foreign_keys = ON;');
```

### 4.2 Stream Drain Pattern (Preventing Test Hangs)
When testing screens or controllers that subscribe to Drift reactive streams (`watch*()`), closing the DB before unmounting triggers infinite hangs waiting on internal stream timers.
**Required teardown pattern:**
```dart
addTearDown(() async {
  await tester.pumpWidget(const SizedBox.shrink()); // 1. Unmount widget tree
  container.dispose();                              // 2. Dispose Riverpod container
  await tester.pump(const Duration(milliseconds: 100)); // 3. Drain pending stream timers
  await db.close();                                 // 4. Safely close database
});
```
