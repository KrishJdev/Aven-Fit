---
name: aven-fit
description: >-
  Comprehensive guide and operational runbook for developing, testing, and maintaining
  the Aven Fit high-performance, offline-first gym and Indian nutrition tracker. Use when
  implementing vertical feature slices (workout, nutrition, routines, progress, auth, sync),
  working with Flutter/Riverpod/Drift or Spring Boot/PostgreSQL, enforcing the 10 Stack Laws,
  managing SQLite migrations, or executing multi-agent development protocols.
---

# Aven Fit — Engineering Runbook & Operational Skill

This skill provides step-by-step procedures, technical patterns, and hard constraints for developing across the Aven Fit codebase.

---

## 1. System Overview & Technology Stack

Aven Fit is an **offline-first gym tracker and Indian nutrition engine** for Android (budget ₹8,000–₹15,000 devices).

### Locked Technology Matrix
- **Platform:** Android-First.
- **Mobile Framework:** Flutter (Dart 3.13+).
- **State Management:** Riverpod 3.x (`flutter_riverpod: ^3.4.2`, `riverpod_annotation: ^4.0.6`).
- **Local Database:** SQLite via Drift 2.34+ (`drift_flutter: ^0.3.1`, `sqlite3_flutter_libs`).
- **Navigation:** GoRouter 18 (`go_router: ^18.0.0`).
- **Domain Models:** Freezed 4 (`freezed: ^4.0.1`, `json_serializable`).
- **Networking:** Dio 5.8+ (`dio: ^5.8.0+1`).
- **Background Dispatcher:** Android WorkManager 0.10+ (`workmanager: ^0.10.9`).
- **Icons:** `lucide_icons_flutter: ^3.1.17`.
- **Backend:** Spring Boot 3.3.x + Java 21, Flyway migrations, PostgreSQL 16.

> [!WARNING]
> **Explicitly Rejected:** React Native, Supabase, GraphQL, Microservices, and Redis/Kafka (MVP). Never introduce these technologies.

---

## 2. The 10 Stack Laws (Fast Reference)

Every pull request and slice must strictly satisfy these 10 laws:

1. **L1 (Sub-3s Logging):** Set logging takes <3s with 1 thumb. Optimistic UI update + instant SQLite write-through before async operations. Warm-up sets excluded from working volume.
2. **L2 (Offline Primacy):** Core flows (workout, routine, nutrition, history) work 100% offline. Guest mode is first-class. Local SQLite is the single source of truth.
3. **L3 (No Paywall on Core Utility):** Unlimited routines forever. No artificial restrictions on basic utility.
4. **L4 (Never Shame — Adherence-Neutral):** Cyan/grey progress bars. No red over-calorie alarms. Missing weekly streak shows neutral "0 weeks" (never angry banners). Absence of goals hides the calories-remaining card.
5. **L5 (Zero Interruption in Logging):** Haptic pulse + volt-green flash for PRs. No confetti, audio interruptions, or interstitial popups inside Active Workout.
6. **L6 (Designed States):** Every screen must implement explicit glass skeleton loading, designed empty states with action CTAs, and error states with keyed `RETRY` buttons.
7. **L7 (Crash Resilience & Data Integrity):** Destructive actions require confirmation. Sessions survive process death via epoch math. PRs self-heal via replay recomputation on set delete/edit.
8. **L8 (Battery & OS Respect):** Zero CPU polling. All timers calculate durations from monotonic epoch timestamps (`DateTime.now().millisecondsSinceEpoch`).
9. **L9 (Data Ownership):** Open schemas and local CSV import/export. No proprietary lock-in.
10. **L10 (India-First Product):** Curated Indian food database (948+ items), regional household units (`katori`, `roti`, `scoop`, `bowl`), and Satvik fasting filters (§11.10).

---

## 3. Pre-Task Operating Protocol

Before beginning any task, the agent MUST execute these steps:

```bash
# 1. Check Git status & branch (active branch is dev)
git status
git log --oneline -5

# 2. Read Session Memory
# Inspect HANDOFF.md for sprint state, active work units, and known nuances.

# 3. Read Product Specification
# Consult FEATURES.md for exact screen specifications and phase priorities ([P0] -> [P1] -> [V1.1]).
```

### Critical Rules
- **Archive Quarantine Rule:** NEVER read, reference, or cite files in `docs/archive/` or `archive/`. They are strictly historical.
- **No Redundant Implementation Plans:** Implementation plans are already formal in `EXECUTION_PLAN.md` and `FEATURES.md`. Do NOT pause for plan approval when tasked with a work unit; proceed directly to execution.
- **Session Conclusion:** At the end of every session, update `HANDOFF.md` in place with session notes, milestones, and next recommended tasks.

---

## 4. Step-by-Step Vertical Slice Development Workflow

When implementing or extending a vertical feature slice (e.g. `lib/features/<slice>/`), strictly execute in this sequential order:

```
Step 1: Domain Layer (lib/features/<slice>/domain/)
        ├── Define Freezed immutable entities (<slice>_model.dart)
        ├── Implement domain formulas & calculations (pure Dart, zero Flutter/Drift/Dio imports)
        └── Write domain unit tests (test/features/<slice>/<slice>_domain_test.dart)

Step 2: Data Layer (lib/features/<slice>/data/)
        ├── Define Drift table schema (<slice>_tables.dart) with UUIDv4 primary keys
        ├── Register table in AppDatabase (lib/core/database/app_database.dart) & bump schemaVersion
        ├── Implement isolate-safe Drift DAO (<slice>_local_source.dart) with reactive watch*() streams
        ├── Define Repository interface (<slice>_repository.dart)
        ├── Implement Repository with write-through logic (<slice>_repository_impl.dart)
        └── Write DAO & Repository integration tests with in-memory SQLite

Step 3: Presentation Layer (lib/features/<slice>/presentation/)
        ├── Define Freezed immutable UI state (<slice>_state.dart)
        ├── Implement Riverpod AsyncNotifier / Notifier (<slice>_controller.dart)
        ├── Build ConsumerWidget views & sheets (<slice>_screen.dart) with Sharp Glassmorphism tokens
        └── Enforce L6 states: LoadingStateWidget, EmptyStateWidget, ErrorStateWidget

Step 4: Router Registration (lib/core/router/app_router.dart)
        └── Wire screen to GoRouter shell tab or declarative route path

Step 5: Verification & Codegen
        ├── dart run build_runner build --delete-conflicting-outputs
        ├── flutter analyze (MUST yield 0 issues)
        └── flutter test (MUST pass 100%)
```

---

## 5. Critical Engineering Patterns & Anti-Patterns

### 5.1 SQLite Write-Through & Set Insertion Safety
- **Renumbering Rule (Prevent UNIQUE Crashes):** When inserting sets, calculate `nextSetNumber` using `(existingSets.map((s) => s.setNumber).fold(0, max)) + 1`. When deleting a set, renumber surviving sets `1..N` in a write-through transaction.
- **Write-Through Guarantee:** In `ActiveWorkoutController.toggleSetCompleted`, write to SQLite *before* locking the UI row.

### 5.2 PR Detection & Self-Healing Parity
- **Detection:** On set completion, calculate Epley e1RM: $\text{weight} \times (1 + \text{reps}/30)$ and check candidate records (`maxWeight`, `epley1rm`, `maxRepsAtWeight`, `volume`). Exclude warm-up sets.
- **Self-Healing:** If a completed set is uncompleted, modified, or deleted, ALWAYS call `prRepository.recomputePRs(exerciseId)` to replay surviving sets.

### 5.3 Monotonic Epoch Timer Math (Zero Polling)
- **Calculation:** Timers must never accumulate ticks. Store `startedAtEpochMs` and `endsAtEpochMs`. Derive remaining seconds dynamically:
  ```dart
  final remaining = (endsAtEpochMs - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
  ```
- **Active Sessions:** Track `isPaused`, `lastResumedAt`, and `pausedDurationSeconds` to ensure session elapsed time is immune to process kills or background suspension.

### 5.4 Test Teardown & Stream Drain Pattern
- **Stream Cleanup Invariant:** When testing widgets watching Drift reactive streams, `db.close()` in `tearDown` will hang if streams are active. Always drain in this exact sequence:
  ```dart
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink()); // 1. Unmount
    container.dispose();                              // 2. Dispose container
    await tester.pump(const Duration(milliseconds: 100)); // 3. Drain stream timers
    await db.close();                                 // 4. Close database
  });
  ```

### 5.5 Sharp Glassmorphism UI Conventions
- Use `AppTheme.oledBlack` (`#000000`) for surfaces, `AppTheme.glassFill` for card backgrounds, and `AppTheme.glassBorder` for borders.
- Numerical values (weights, reps, timers, macros, set numbers) MUST use `AppTheme.num` (JetBrains Mono tabular numerals) to prevent layout shifting.

---

## 6. Detailed Reference Documentation

For deep technical specifications, domain models, and system maps, refer to the files in `references/`:

- **[System Architecture & Sync Contract](./references/architecture.md):** Clean Architecture boundaries, Drift SQLite isolate setup, linear migrations, and Spring Boot REST/sync mapping.
- **[Domain Models & Formulas](./references/domain_models.md):** Complete model specifications (`WorkoutSession`, `GhostSet`, `FoodItem`, `PRRecord`, `StreakInfo`), formulas (Epley, Atwater), and prefill hierarchies.
- **[Stack Laws & Testing Matrix](./references/stack_laws_and_rules.md):** Exhaustive breakdown of L1–L10, Quality Matrix journeys (J1–J6), Git safety rules, and in-memory testing standards.
- **[Screen & Feature Navigation Map](./references/screen_and_feature_map.md):** Complete GoRouter route index, Sharp Glassmorphism design tokens, L6 widget contracts, and phase roadmap (`[P0]` through `[V2]`).
