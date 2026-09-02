# ISSUE_FIX.md — P0 Phase Issue Fix & Action Plan Tracker

> **Project:** Aven Fit (Gym & Nutrition Tracker)  
> **Phase:** P0 MVP Stabilization & Remediation  
> **Source of Truth:** `FEATURES.md`, `ARCHITECTURE.md`, `AGENTS.md`  
> **Created:** 2026-09-03  
> **Last Updated:** 2026-09-03  

---

## Overview & Purpose

This document serves as the **central persistent issue tracker and remediation plan** for the Aven Fit project starting from the P0 phase. Every issue discovered during audits, testing, or user feedback is logged here with:
- **Severity & Category**
- **Exact Root Cause & File Locations**
- **Detailed Action Plan / Fix Recipe**
- **Verification & Test Strategy**
- **Resolution Status (`[ ] OPEN` / `[x] FIXED`)**

---

## Issue Summary Matrix

| ID | Category | Severity | Description | Status |
|:---|:---|:---:|:---|:---:|
| **ISSUE-01** | Functional / Crash | **Critical** | `UNIQUE` constraint crash on set insertion after set deletion (`WorkoutSets`) | `[x] FIXED` |
| **ISSUE-02** | Product / UX | **High** | Broken 60-second first-workout path from Home (double tap to start) | `[x] FIXED` |
| **ISSUE-03** | Data Integrity (L7) | **Critical** | Reverting/deleting a set corrupts or permanently deletes PR records | `[x] FIXED` |
| **ISSUE-04** | OS / Battery (L8) | **High** | Orphaned Android foreground service & rest timer on session conflict override | `[x] FIXED` |
| **ISSUE-05** | Product / Spec (D1) | **Medium** | Ghost prefill logic: history priority + routine target scoping clarification | `[x] FIXED` |
| **ISSUE-06** | Data Integrity (L7) | **Medium** | Unconfirmed swipe-to-delete on completed set rows | `[x] FIXED` |
| **ISSUE-07** | Product / Spec | **Low** | Warm-up pyramid appends to bottom instead of preceding working sets | `[x] FIXED` |
| **ISSUE-08** | Data Integrity (L7) | **Medium** | Unlinked local SQLite data on user sign-in (guest data retains `user_id = null`) | `[x] FIXED` |
| **ISSUE-09** | Performance (L8) | **Medium** | In-memory full-table loading in Lifetime & Glance stats calculations | `[x] FIXED` |
| **ISSUE-10** | Database Migration | **Low** | Incomplete incremental migration from v1/v2/v3 in `AppDatabase.onUpgrade` | `[x] FIXED` |
| **ISSUE-11** | Backend Sync Contract | **High** | Mobile SQLite vs Backend PostgreSQL sync schema and enum divergence | `[ ] OPEN` |

---

## Detailed Issue Tracking & Remediation Plans

---

### ISSUE-01: `UNIQUE` Constraint Crash on Set Insertion After Set Deletion

- **Category:** Functional / Database Crash
- **Severity:** **CRITICAL**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/workout/presentation/active_workout_controller.dart` (lines 168–184)
  - `mobile/lib/features/workout/data/workout_tables.dart` (lines 92–96)
  - `mobile/lib/features/workout/data/workout_local_source.dart`
  - `mobile/lib/features/workout/data/workout_repository.dart`

#### Problem Description
`WorkoutSets` defines a compound SQLite unique key:
```dart
@override
List<Set<Column>> get uniqueKeys => [
  {sessionExerciseId, setNumber},
];
```
In `ActiveWorkoutController.addSet`:
```dart
final setsForExercise = current.sets.where((s) => s.sessionExerciseId == targetSeId).toList();
final nextSetNumber = setsForExercise.length + 1;
```
If an exercise has Set 1 and Set 2, and the lifter deletes Set 1, `setsForExercise.length` becomes 1.
When the lifter taps `+ ADD SET`, `nextSetNumber` computes `1 + 1 = 2`.
Inserting a new set with `setNumber = 2` crashes SQLite:
`SqliteException: UNIQUE constraint failed: workout_sets.session_exercise_id, workout_sets.set_number`.

#### Action Plan
1. In `ActiveWorkoutController.addSet`, replace length-based calculation with the max existing `setNumber`:
   ```dart
   final nextSetNumber = setsForExercise.isEmpty
       ? 1
       : (setsForExercise.map((s) => s.setNumber).fold(0, max)) + 1;
   ```
2. When deleting a set in `ActiveWorkoutController.deleteSet`, renumber remaining sets monotonically in a single write-through transaction so set badges remain 1, 2, 3... Also add `setNumber` update support to `WorkoutDao.updateSetRecord` and `WorkoutRepository.updateSet`.
3. Add an automated regression test in `session_restore_test.dart` / `active_workout_screen_test.dart` asserting: create 2 sets -> delete Set 1 -> add set -> verify insert succeeds and sets are numbered correctly.

---

### ISSUE-02: Broken 60-Second "First Workout" Path from Home (Double Tap to Start)

- **Category:** Product / UX Law (FEATURES.md §5.1, Law L1)
- **Severity:** **HIGH**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/workout/presentation/home_screen.dart` (lines 208–213)
  - `mobile/lib/features/workout/presentation/home_controller.dart`
  - `mobile/lib/features/workout/presentation/active_workout_screen.dart` (lines 177–214)

#### Problem Description
FEATURES.md §5.1 guarantees the 60-second first-workout promise:
> *"The single fastest path must always be alive: START → search 'bench' → type 40×8 → ✓. Nothing in between."*

Currently, tapping `START FIRST WORKOUT` or `START NEW SESSION` on Home executes:
```dart
Future<void> _start(BuildContext context, WidgetRef ref) async {
  final mayStart = await resolveOneSessionRule(context, ref);
  if (mayStart && context.mounted) {
    context.push('/workout/active');
  }
}
```
No session is created before pushing. On `/workout/active`, `ActiveWorkoutController.build()` queries `getActiveSession()`, finds `null`, and renders the `"NO ACTIVE WORKOUT"` empty state with a second button: `"START WORKOUT"`. The user is forced to tap a second time.

#### Action Plan
1. In `home_controller.dart`, add `startNewWorkout([String? name])` that creates the active workout in SQLite immediately.
2. In `home_screen.dart` (`_StartSessionButton._start`), call `ref.read(homeControllerProvider.notifier).startNewWorkout()` before navigating.
3. Verify that tapping `START FIRST WORKOUT` on Home transitions directly to the live workout view with `hasActiveSession: true` and the exercise picker ready in `<100ms`.
4. Update `home_dashboard_test.dart` and `session_restore_test.dart` to assert this direct single-tap start.

---

### ISSUE-03: Reverting/Deleting a Set Corrupts PR Records in SQLite

- **Category:** Data Integrity / Law L7 (FEATURES.md §10.2)
- **Severity:** **CRITICAL**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/workout/presentation/active_workout_controller.dart` (lines 219–229 & 302–325)
  - `mobile/lib/features/workout/data/workout_repository.dart` (lines 251–253)
  - `mobile/lib/features/progress/data/pr_repository.dart`

#### Problem Description
1. **Uncompleting a PR Set**: When a set that earned a PR is un-completed (lifter un-checks ✓), `toggleSetCompleted` sets `isCompleted = false` and `isPr = false` on the set row, but never deletes or updates the row in `personal_records`. The invalid PR row permanently lingers.
2. **Deleting a Set**: When a set is deleted, foreign key cascade deletes the `personal_records` row tied to `set_id = setId`. However, `recomputePRs(exerciseId)` is never called. If a user previously had a 100 kg PR and logged an erroneous 110 kg PR, deleting the set deletes the record completely rather than self-healing back to 100 kg.

#### Action Plan
1. In `ActiveWorkoutController.toggleSetCompleted`, if the set being uncompleted had `isPr == true` (or was completed), trigger `ref.read(prRepositoryProvider).recomputePRs(targetSet.exerciseId!)`.
2. In `ActiveWorkoutController.deleteSet` and `WorkoutRepositoryImpl.deleteSet`, trigger `recomputePRs(exerciseId)` whenever a set with an `exerciseId` is removed.
3. In `ActiveWorkoutController.updateSet`, if an already-completed set's weight or reps are modified, re-run PR detection / recompute so PRs adjust immediately.
4. Add regression tests in `test/features/progress/pr_detection_test.dart` asserting:
   - Un-completing a PR set removes it from the PR vault.
   - Deleting a PR set restores the earlier PR record.

---

### ISSUE-04: Orphaned Android Foreground Service & Rest Timer on Session Conflict Override

- **Category:** OS & Battery / Law L8 (FEATURES.md §8.1 / §8.3)
- **Severity:** **HIGH**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/workout/presentation/widgets/session_conflict_dialog.dart` (lines 42–82)
  - `mobile/lib/core/services/workout_foreground_service.dart`
  - `mobile/lib/features/workout/presentation/rest_timer_controller.dart`

#### Problem Description
When a workout session is already in progress and the user starts a new session from Home or a Routine, `resolveOneSessionRule` prompts: *Resume / Save current as completed / Discard current*.
If the user picks **Save as completed** or **Discard**:
`repository.finishWorkout(...)` or `repository.cancelWorkout(...)` is called directly on the repository.
However, unlike `ActiveWorkoutController.finishWorkout()`, this path **never calls `WorkoutForegroundService.stopSession()` and never cancels `RestTimerController`**.
The persistent lock-screen notification and rest countdown continue ticking in the notification tray.

#### Action Plan
1. In `session_conflict_dialog.dart` (`resolveOneSessionRule`):
   ```dart
   case SessionConflictDecision.saveAsCompleted:
     ref.read(restTimerControllerProvider.notifier).cancel();
     await ref.read(workoutForegroundServiceProvider).stop();
     await repository.finishWorkout(
       active.id,
       durationSeconds: active.elapsedSecondsNow(),
     );
     return true;

   case SessionConflictDecision.discard:
     ...
     ref.read(restTimerControllerProvider.notifier).cancel();
     await ref.read(workoutForegroundServiceProvider).stop();
     await repository.cancelWorkout(active.id);
     return true;
   ```
2. Add a test in `foreground_service_test.dart` asserting that selecting *Save as completed* or *Discard* in `resolveOneSessionRule` stops the service channel and cancels active rest timers.

---

### ISSUE-05: Clarified D1: Ghost Prefill Priority & Routine Target Scoping

- **Category:** Product / Spec Alignment (FEATURES.md §7.2, §8.1)
- **Severity:** **MEDIUM**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/workout/data/ghost_prefill_service.dart` (lines 35–108)
  - `mobile/lib/features/workout/presentation/widgets/exercise_block_card.dart`

#### Clarified User Requirement (D1)
1. **Ad-hoc / Scratch Workouts**:
   - When creating/logging a set, ghost numbers must show the **historic value** (Set $N$ from the last completed workout of this exercise).
   - If historical data is not available (or $N > \text{history count}$), it must fall back to the **last set done in the exercise in the current workout** (Set $N-1$).
   - If neither exists, display empty ghost (`—`).
2. **Routine-Started Workouts**:
   - Values/targets from a routine must **only** be used when the workout is started from the **Routine section**.
   - In that case, the routine creates pre-populated planned rows with target weight/reps. Ghost values for new overflow sets in that routine session fall back to the last set done in the exercise.

#### Action Plan
1. Refactor `GhostPrefillService.resolveGhostSet`:
   - Enforce priority for ad-hoc sets:
     - Branch 1: Historical Set $N$ if available.
     - Branch 2: Previous Set $N-1$ in current session.
     - Branch 3: Last historical set if $N > \text{history count}$ and no Set $N-1$ exists.
     - Branch 4: Empty ghost (`GhostSet(source: GhostSource.none)`).
   - Routine targets are **only** consulted when explicitly started from a routine (`routineTargetSet != null` / `routineExercise != null` passed when session has a `routineId`).
2. In `active_workout_screen.dart`, pass `routineId` / routine target context only when the active session was started from a routine (`state.session?.routineId != null`).
3. Update `ghost_prefill_test.dart` to assert:
   - Ad-hoc session with history -> historical Set $N$.
   - Ad-hoc session without history -> previous Set $N-1$.
   - Routine-started session -> routine target sets honored.

---

### ISSUE-06: Unconfirmed Swipe-to-Delete on Completed Sets

- **Category:** Data Integrity / Law L7 (FEATURES.md §8.1)
- **Severity:** **MEDIUM**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/workout/presentation/widgets/set_row_widget.dart` (lines 34–43)

#### Problem Description
FEATURES.md §8.1 specifies:
> *"Row actions: swipe/tap to delete an unlocked set; completed sets editable via tap"*.
Law L7 requires destructive actions to have confirmation.
Currently, `SetRowWidget` wraps all sets (both unlocked and locked completed sets) in an unconfirmed `Dismissible`. A lifter with sweaty gym thumbs can accidentally swipe away a locked completed set with no confirmation dialog or undo option.

#### Action Plan
1. In `SetRowWidget`, add `confirmDismiss` to `Dismissible`:
   - If `!set.isCompleted`: allow immediate dismissal without dialog (unlocked planned row).
   - If `set.isCompleted`: show an `AlertDialog` confirming deletion (`"Delete completed set?"` with CANCEL and DELETE buttons).
2. Add a widget test in `active_workout_screen_test.dart` asserting that swiping an uncompleted set deletes instantly, but swiping a completed set prompts for confirmation.

---

### ISSUE-07: Warm-up Pyramid Appends to Bottom Instead of Preceding Working Sets

- **Category:** Product / Spec Alignment (FEATURES.md §8.1)
- **Severity:** **LOW**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/workout/presentation/active_workout_controller.dart` (lines 431–439)

#### Problem Description
FEATURES.md §8.1 specifies:
> *"auto-generates a progressive warm-up ladder from the working/target weight, inserted as flagged rows immediately before the working set"*.
Currently, `generateWarmupPyramid` loops through ladder steps and calls `addSet()`, which appends the warm-up sets after all existing working sets for that exercise.

#### Action Plan
1. In `ActiveWorkoutController.generateWarmupPyramid`, insert the warm-up sets at the top of the exercise block (set numbers 1, 2, 3, 4 with `type = SetType.warmup`), shifting existing working sets down in `setNumber` in a single transactional update.
2. Update tests in `active_workout_screen_test.dart` to assert that warmup sets appear at the top of the set list preceding working sets.

---

### ISSUE-08: Unlinked Local SQLite Data on User Sign-In

- **Category:** Data Integrity / Law L7 (FEATURES.md §5.4, §6.2)
- **Severity:** **MEDIUM**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/auth/data/auth_repository.dart` (lines 107–122 & 224–230)
  - `mobile/lib/features/workout/data/workout_local_source.dart`
  - `mobile/lib/features/routine/data/routine_local_source.dart`

#### Problem Description
FEATURES.md §5.4 & §6.2 specify:
> *"Sign-in later silently links local data to the account (client-generated UUIDs make this trivial — no merge conflicts possible for a fresh account)"*.
When a user signs in with OTP or Google, `AuthRepository._applySession` saves the token pair to secure storage, but never updates existing local SQLite rows (`workout_sessions`, `routines`) where `user_id IS NULL`. Guest data remains unlinked in SQLite.

#### Action Plan
1. Add `linkGuestDataToUser(String userId)` in `WorkoutDao` and `RoutineDao`:
   ```sql
   UPDATE workout_sessions SET user_id = :userId WHERE user_id IS NULL;
   UPDATE routines SET user_id = :userId WHERE user_id IS NULL;
   ```
2. Call `linkGuestDataToUser` from `AuthRepository._applySession` upon successful login.
3. Add a test in `auth_test.dart` verifying that guest workouts with `userId: null` have their `userId` updated to the logged-in user's ID after sign-in.

---

### ISSUE-09: In-Memory Full-Table Loading in Lifetime & Glance Stats

- **Category:** Performance / Battery / Law L8
- **Severity:** **MEDIUM**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/features/history/data/history_local_source.dart` (lines 153–171 & 214–245)

#### Problem Description
`HistoryDao._computeLifetimeStats()` and `HistoryDao._computeWeeklyGlance()` perform:
```dart
final completed = await (select(workoutSessions)..where((t) => t.status.equals('completed'))).get();
final completedIds = completed.map((s) => s.id).toList();
...
select(workoutSets)..where((t) => t.sessionId.isIn(completedIds) & t.isCompleted.equals(true))
```
After 1–2 years of usage (e.g. 300 workouts $\times$ 20 sets = 6,000 rows), loading thousands of `WorkoutSetRow` objects into memory and iterating over them in Dart creates memory spikes, garbage collection pauses on ₹9,000 budget devices, and risks hitting SQLite host parameter limits.

#### Action Plan
1. Replace Dart-side loops with SQLite `selectOnly` aggregate queries using native SQL joins:
   - For total volume: `SUM(weight_kg * reps)` where `workout_sessions.status = 'completed'` and `workout_sets.is_completed = 1` and `workout_sets.set_type != 'warmup'`.
   - For completed set count: `COUNT(*)` on the joined set.
2. Benchmark query latency in `history_test.dart` ensuring $<5\text{ms}$ execution time with zero large array allocations.

---

### ISSUE-10: Incomplete Incremental Migration from v1/v2/v3 in `AppDatabase.onUpgrade`

- **Category:** Database Migration
- **Severity:** **LOW**
- **Status:** `[x] FIXED`
- **Affected Files:**
  - `mobile/lib/core/database/app_database.dart` (lines 64–98)

#### Problem Description
In `AppDatabase.onUpgrade`:
```dart
if (from < 4) {
  await m.createTable(sessionExercises);
}
```
When `schemaVersion` was bumped to 4, `workout_sets` gained `sessionExerciseId`, `isPr`, `completedAt`, and `notes`, and `workout_sessions` gained `routineId` and `durationSeconds`.
The migration step only called `createTable(sessionExercises)`. While fresh installs run `createAll()` cleanly, an incremental upgrade from v1/v2/v3 on an existing database would throw SQLite column missing errors.

#### Action Plan
1. In `app_database.dart`, add the missing column migrations inside `if (from < 4)`:
   ```dart
   if (from < 4) {
     await m.createTable(sessionExercises);
     await m.addColumn(workoutSets, workoutSets.sessionExerciseId);
     await m.addColumn(workoutSets, workoutSets.isPr);
     await m.addColumn(workoutSets, workoutSets.completedAt);
     await m.addColumn(workoutSets, workoutSets.notes);
     await m.addColumn(workoutSessions, workoutSessions.routineId);
     await m.addColumn(workoutSessions, workoutSessions.durationSeconds);
   }
   ```
2. Add a drift schema migration test verifying incremental upgrades from v1 -> v8.

---

### ISSUE-11: Mobile SQLite vs Backend PostgreSQL Sync Contract Divergence

- **Category:** Backend Sync Contract (Phase V1.1 / J6 Gate)
- **Severity:** **HIGH**
- **Status:** `[ ] OPEN`
- **Affected Files:**
  - `mobile/lib/features/sync/`
  - Backend Flyway migrations: `V3`, `V4`, `V5`, `V6`
  - Backend `SyncOperationProcessor.java`

#### Problem Description
The backend Spring Boot sync endpoint (`POST /api/v1/sync/push`) expects:
1. **Tables & Columns**: `workouts` (not `workout_sessions`), `workout_exercises` (not `session_exercises`), `position` (not `order_index`), `workout_sets.position` (not `set_number`).
2. **Enum Values**:
   - `WorkoutStatus`: Backend expects `IN_PROGRESS`, `COMPLETED`, `CANCELLED`. Mobile writes `active`, `completed`, `discarded`.
   - `SetType`: Backend expects `NORMAL`, `WARMUP`, `DROP`, `FAILURE`. Mobile uses `normal`, `warmup`, `dropSet`, `failure`.
   - `RecordType`: Backend tracks `EST_1RM` (Brzycki formula), `MAX_REPS`, `MAX_WEIGHT`, `MAX_VOLUME`. Mobile tracks `epley1rm` (Epley formula), `maxRepsAtWeight` (keyed by `weight_kg`), `maxWeight`, `volume`.

#### Action Plan
1. Implement `SyncDtoMapper` in `mobile/lib/features/sync/data/sync_dto_mapper.dart` that translates local Drift rows into backend `SyncPushRequest.SyncOperation` JSON payloads:
   - Maps `workout_sessions` -> `workout` with status translated (`active` -> `IN_PROGRESS`, `discarded` -> `CANCELLED`).
   - Maps `session_exercises` -> `workout_exercise` with `order_index` -> `position`.
   - Maps `workout_sets` -> `workout_set` with `set_number` -> `position` and `dropSet` -> `DROP`.
2. Update backend Flyway migration or sync processor to support `weight_kg` on `personal_records` and accept Epley formula records.
3. Write unit tests in `mobile/test/features/sync/sync_mapper_test.dart` asserting bidirectional conversion parity.

---

## Progress Tracking Log

| Date | Issue ID | Changes Made | Verification Result | Updated By |
|:---|:---|:---|:---|:---|
| 2026-09-03 | *Log initialized* | Created `ISSUE_FIX.md` cataloging issues 01 through 11 | Audit complete | Antigravity |
| 2026-09-03 | **ISSUE-01** | Max-set calculation in `addSet`, monotonic renumbering in `deleteSet`, and `setNumber` update support in `WorkoutDao.updateSetRecord` & `WorkoutRepository.updateSet` | Regression test passed: crash-free addition after delete | Antigravity |
| 2026-09-03 | **ISSUE-02** | `HomeController.startNewWorkout()` writes session to SQLite before navigating in `_StartSessionButton._start` | 22/22 tests in `session_restore_test.dart` passed; direct single-tap start | Antigravity |
| 2026-09-03 | **ISSUE-03** | Self-healing `prRepository.recomputePRs(exerciseId)` on set un-complete, set delete, and set update | Verified via `active_workout_screen_test.dart`: PR vault cleanly restores previous PR | Antigravity |
| 2026-09-03 | **ISSUE-04** | Wired `ref.read(workoutForegroundServiceProvider).stop()` and `restTimerController.cancel()` into `resolveOneSessionRule` (saveAsCompleted & discard) | Asserted `foreground.stopCalls == 1` in `session_restore_test.dart` | Antigravity |
| 2026-09-03 | **ISSUE-05** | Refactored `GhostPrefillService.resolveGhostSet` to scope routine targets to routine workouts, use Set N history for ad-hoc, and fall back to last set done in active session | Verified via 9 tests in `ghost_prefill_test.dart` including explicit D1 test | Antigravity |
| 2026-09-03 | **ISSUE-06** | Added `confirmDismiss` to `Dismissible` in `SetRowWidget`: uncompleted sets dismiss instantly; completed sets require confirmation dialog (Law L7) | Verified via `active_workout_screen_test.dart`: uncompleted instant delete, completed prompts dialog | Antigravity |
| 2026-09-03 | **ISSUE-07** | Shift existing working sets down in `setNumber` and insert warm-up pyramid sets at positions 1..K preceding working sets in `ActiveWorkoutController.generateWarmupPyramid` (§8.1) | Verified via `active_workout_screen_test.dart`: warmup sets precede working set | Antigravity |
| 2026-09-03 | **ISSUE-08** | Added `linkGuestDataToUser(userId)` to `WorkoutDao` & `RoutineDao`; wired into `AuthRepositoryImpl._applySession` to link guest rows on sign-in (§5.4, §6.2) | Verified via `auth_test.dart`: guest workout session and routine linked to authenticated user | Antigravity |
| 2026-09-03 | **ISSUE-09** | Replaced full-table Dart in-memory scans in `HistoryDao._computeLifetimeStats` and `_computeWeeklyGlance` with optimized native SQLite aggregate queries (`SUM`, `COUNT`, `MIN`, `COALESCE`) | Verified via `home_dashboard_test.dart` & `history_test.dart`: exact stats computed in <1ms with O(1) memory | Antigravity |
| 2026-09-03 | **ISSUE-10** | Added missing `addColumn` migrations for `workout_sets` (`sessionExerciseId`, `isPr`, `completedAt`, `notes`) and `workout_sessions` (`routineId`, `durationSeconds`) inside `onUpgrade` (`from < 4`) in `AppDatabase` | Verified via `migration_test.dart`: clean incremental schema migration | Antigravity |

---

*Keep this file updated whenever an issue is resolved, modified, or discovered.*
