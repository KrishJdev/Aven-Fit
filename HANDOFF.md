# HANDOFF.md

> **Canonical Handoff State** — Single persistent handoff file. Update in place at session end.
> **Last updated:** 2026-08-31

---

## Active Project & Stack

- **Project:** Aven Fit (Offline-first Gym & Nutrition Tracker for Android)
- **Mobile:** Flutter + Dart in `mobile/` (State: Riverpod 3.x, Local DB: SQLite via **Drift** — `drift_flutter` + `sqlite3_flutter_libs`, Navigation: **GoRouter 18**; Feature-First layout: `lib/core/` + `lib/features/<domain>/{domain,data,presentation}/`)
- **Backend:** Spring Boot 3.3 + Java 21 in `backend/` (Server DB: PostgreSQL 16)
- **Archive Policy:** `docs/archive/` and `archive/` are quarantined; never access unless explicitly instructed.

---

## Session Notes

- **2026-08-31 (session 1):** Slice 1 scaffolding started. Legacy `mobile/node_modules` (React Native era, untracked) removed. Flutter project created in `mobile/` (`--org com.avenfit`, project name `aven_fit` → package `com.avenfit.aven_fit`, Android-only). All locked dependencies configured in `pubspec.yaml` (Riverpod 2.x, GoRouter 14.8.x, Drift 2.24.x, Dio 5.8+, WorkManager 0.5.2, Freezed 2.5.x, google_fonts, lucide_icons; dev: build_runner, riverpod_generator, drift_dev, freezed, json_serializable, mocktail, patrol 3.x, flutter_lints 5). `flutter pub get` resolved cleanly (124 deps), `flutter analyze` passes with no issues. Next: Glassmorphism theme, Drift schema in `lib/core/`, GoRouter shell, Feature-First dirs.
- **2026-08-31 (session 2):** Slice 1 core foundation scaffolded — `core/theme` (Sharp Glassmorphism: OLED black, neon cyan, volt green, burnt orange, Inter + JetBrains Mono tabular numerals), `core/database` (Drift via `drift_flutter`, `shareAcrossIsolates`, `WorkoutSessions` base table, schema v1), `core/network` (Dio, baseline timeouts, interceptor hook), `core/router` (`StatefulShellRoute.indexedStack` with the 4 main tabs: Home · Workouts · Progress · Nutrition). Feature-First trees created under `lib/features/{workout,routine,nutrition,history,sync}/{data,domain,presentation}`. `main.dart` wires `ProviderScope` + `AppTheme` + `appRouter`; DB exposed via `appDatabaseProvider` (dispose-safe). Fonts bundled as SHA-256-pinned TTF assets (google_fonts never fetches at runtime — offline-first, deterministic tests). `build_runner` codegen OK (18 outputs); `flutter analyze` 0 issues; `flutter test` 1/1 passing.
  - **Forced deviation 1 (deps):** Dart 3.13/Flutter 3.47 breaks the originally locked codegen stack — `riverpod_generator` 2.x is pinned to `analyzer ^7`, which crashes on Dart 3.10+ dot-shorthand AST (`Missing implementation of visitDotShorthandPropertyAccess`). Full `pub upgrade --major-versions` applied: riverpod_generator 4.0.8, flutter_riverpod 3.4.2, riverpod_annotation 4.0.6, freezed 4.0.1 + freezed_annotation 3.1.0, go_router 18.0.0, drift/drift_dev 2.34.x, workmanager 0.10.9, google_fonts 8.2.1, patrol 4.9.0, build_runner 2.16.0, flutter_lints 6. **Requires user ratification to amend the AGENTS.md stack table (Riverpod 3.x / GoRouter 18 / WorkManager 0.10).**
  - **Forced deviation 2 (icons):** `lucide_icons` cannot compile on Flutter 3.47 — every version subclasses `IconData`, which the framework made `final`. Replaced with `lucide_icons_flutter` (maintained Lucide port, plain `IconData`, same icon names incl. `home`/`dumbbell`/`chartColumn`/`salad`). The spec's alternative `flutter_svg` was not used (heavier runtime + asset footprint).
  - **Note:** `build_runner` on the new build 4.x ignores `--delete-conflicting-outputs` (removed flag; conflicting outputs are handled automatically).
- **2026-08-31 (session 3):** **Ratification confirmed by user** — both forced deviations above are approved: (1) the `pub upgrade --major-versions` dependency set (Riverpod 3.x, GoRouter 18, Drift 2.34+, Freezed 4, WorkManager 0.10+, Patrol 4.9) for the Dart 3.13 / Flutter 3.47 toolchain, and (2) the `lucide_icons` → `lucide_icons_flutter` swap. `AGENTS.md` Key Tooling table updated with the ratified versions plus a ratification note; `lucide_icons_flutter` added to the locked tooling list. No code changes this session. Next: continue Slice 1 remainder / Slice 2 per milestone table.
- **2026-08-31 (session 4):** Slice 1 scaffold re-verified end to end (no code changes needed — session 2 output was intact and untracked). `dart run build_runner build --delete-conflicting-outputs` → 24 outputs (flag ignored on build 4.x, as noted in session 2); `flutter analyze` → 0 issues; `flutter test` → 1/1 passing. All 4 core modules (`core/theme`, `core/database`, `core/network`, `core/router`), 5 feature trees (`workout/routine/nutrition/history/sync` × `data/domain/presentation`), and `main.dart` wiring confirmed in place.
- **2026-08-31 (session 5):** Native bindings wired (Step 4 of Slice 1):
  - **Sentry:** `sentry_flutter 8.14.2` added (satisfies requested ^8.12.0). `SentryFlutter.init()` in `main.dart` with env-based DSN placeholder (`--dart-define=AVENFIT_SENTRY_DSN`, default placeholder → sending disabled), `AVENFIT_ENV` (default `development`), `tracesSampleRate 1.0`, `sendDefaultPii false`; `appRunner` wraps `runApp` so startup crashes are captured.
  - **WorkManager:** top-level `@pragma('vm:entry-point') void workmanagerDispatcher()` created in `lib/core/sync/workmanager_dispatcher.dart` with canonical task IDs (`WorkmanagerTasks.syncQueueDrain`). In 0.10.9 `executeTask` is **void** (registers handler, returns immediately — do NOT await) and the dispatcher must be registered via `await Workmanager().initialize(workmanagerDispatcher)` before task registration (Android resolves the callback handle from SharedPreferences). A network-constrained periodic task (`BackoffPolicy.exponential`, 15 min) is registered in `main()` as a no-op placeholder until Slice 5 wires the real queue drain.
  - **Patrol (Gradle):** `android/app/build.gradle.kts` (Kotlin DSL — project has NO Groovy `build.gradle`) configured per the official Patrol 4.9 example: `testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"`, `clearPackageData` runner arg, `execution = "ANDROIDX_TEST_ORCHESTRATOR"`, `androidTestImplementation("androidx.test:runner:1.5.2")` + `androidTestUtil("androidx.test:orchestrator:1.5.1")`. The bare androidx runner requested would NOT execute Patrol tests — `PatrolJUnitRunner` is required (it binds the Dart test registry).
  - **Mocktail smoke test:** `test/smoke_test.dart` (3 tests: stub/act/verify, argument predicates, harness sanity). All pass.
- **2026-08-31 (session 6):** Gradle test compilation issue investigated and resolved:
  - **Root Cause 1 (Cross-drive incremental cache crash):** The workspace lives on `E:\Projects\Aven Fit\` while Pub cache is on `C:\Users\Krish\AppData\Local\Pub\Cache\`. Kotlin incremental compilation attempts relative path calculation (`FilesKt__UtilsKt.relativeTo`) across drive letters on Windows, triggering `IllegalArgumentException: this and base files have different roots: C:\... and E:\...`. **Resolution:** Added `kotlin.incremental=false` to `mobile/android/gradle.properties`.
  - **Root Cause 2 (Kotlin languageVersion deprecation in plugins):** `sentry_flutter`'s Android build configured `kotlinOptions { languageVersion = "1.6" }`, which Kotlin 2.x rejects (`e: Language version 1.6 is no longer supported; use version 2.0 or greater instead`). **Resolution:** Configured `tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>()` in `mobile/android/build.gradle.kts` `subprojects` block to enforce `languageVersion` and `apiVersion` to `KOTLIN_2_0`.
  - **Verification:** `.\gradlew.bat :app:compileDebugAndroidTestSources --no-daemon --console=plain` executes and succeeds cleanly (`BUILD SUCCESSFUL in 1m 45s`, all androidTest tasks compiled).
- **2026-08-31 (session 7):** Established Root Architecture Reference and Workout Reference Slice (Step 5 of Slice 1):
  - **Root Architecture Specification:** Created `ARCHITECTURE.md` establishing the Feature-First Clean Architecture blueprint, layer contracts (`domain/`, `data/`, `presentation/`), unidirectional data flow diagrams, stack laws, feature addition templates, and quality verification matrix.
  - **Workout Canonical Reference Slice (`mobile/lib/features/workout/`):**
    - **Domain Layer (`domain/`):** Implemented pure immutable Freezed domain models (`WorkoutSession`, `WorkoutSet`, `WorkoutStatus`, `SetType`).
    - **Data Layer (`data/`):** Defined Drift tables (`WorkoutSessions`, `WorkoutSets`), created `WorkoutDao` (`workout_local_source.dart`) with reactive Drift streams (`watchActiveSession()`, `watchSessionSets()`) and CRUD operations, implemented `WorkoutRepository` contract and `WorkoutRepositoryImpl` with `@riverpod` provider.
    - **Presentation Layer (`presentation/`):** Implemented `ActiveWorkoutState` immutable UI state, `ActiveWorkoutController` Riverpod 3.x `AsyncNotifier` (disallowing legacy ChangeNotifier/two-way binding; optimistic updates with SQLite write-through, rest timer management with epoch calculations), and `ActiveWorkoutScreen` declarative `ConsumerWidget` with Sharp Glassmorphism UI styling (`AppTheme.oledBlack`, `AppTheme.glassFill`, `AppTheme.glassBorder`, `AppTheme.neonCyan`, `AppTheme.voltGreen`, `AppTheme.burntOrange`, `AppTheme.num` tabular figures).
    - **Wiring & Routes:** Wired `/workout/active` route in `app_router.dart` and connected `HomePage` "START NEW SESSION" button.
    - **Build & Tests:** Configured `mobile/build.yaml` with `explicit_to_json: true`. Created `mobile/test/features/workout/workout_reference_slice_test.dart` asserting domain immutability/serialization, repository SQLite CRUD, and controller store state transitions.
    - **Verification:** `dart run build_runner build` (27 outputs), `flutter analyze` (0 issues), `flutter test` (12/12 passing).
- **2026-08-31 (session 8):** Implemented **Slice 2 WU-2.1: Exercise Domain Models & Drift Tables**:
  - **Domain Layer (`features/exercise/domain/`):**
    - `muscle_group.dart`: Freezed `MuscleGroup` entity, `ExerciseMuscleRef`, and domain enums (`MuscleRole`, `Equipment`, `ExerciseCategory`) matching the backend schema and JSON serialization mappings.
    - `exercise.dart`: Freezed `Exercise` entity with convenience getters (`instructions`, `muscleGroupPrimary`, `muscleGroupsSecondary`, `equipmentType`), default values, and full JSON serialization.
  - **Data Layer (`features/exercise/data/`):**
    - `exercise_tables.dart`: Drift tables `MuscleGroups`, `Exercises`, and `ExerciseMuscleGroups` (with foreign key references, cascade deletion, unique key constraint on `(exerciseId, muscleGroupId)`, and local-first flags `isFavourite`, `isTimeBased`, `isCardio`).
  - **Database Migration & Setup (`core/database/`):**
    - `app_database.dart`: Registered exercise tables in `@DriftDatabase`, bumped `schemaVersion` to 2 with migration step, and enabled `PRAGMA foreign_keys = ON;` in `beforeOpen` for SQLite referential integrity.
  - **Verification & Tests (`test/features/exercise/`):**
    - `exercise_domain_test.dart`: 4 test cases covering domain entity immutability, defaults, copyWith, JSON serialization round-trip, and in-memory Drift SQLite CRUD + cascade delete.
    - `dart run build_runner build` (40 outputs), `flutter analyze` (0 issues), `flutter test` (16/16 passing across the test suite).
  - **NEXT STEP (exact):** Proceed to **Slice 2 WU-2.2: Exercise DAO & Repository** (`ExerciseDao` with search/filter/favourites queries, `ExerciseRepository` interface and Riverpod implementation).
- **2026-08-31 (session 9):** Implemented **Slice 2 WU-2.2 (Exercise DAO & Repository) & WU-2.3 (Exercise Seed Data Asset)**:
  - **Seed Assets (`mobile/assets/data/`):**
    - Extracted 14 muscle groups into `muscle_groups.json` and 55 standard exercises with complete muscle group mappings into `exercises.json` from backend migrations.
    - Registered `assets/data/` in `pubspec.yaml` for bundled zero-network offline operation (Law L2).
  - **Data Layer (`features/exercise/data/`):**
    - `exercise_local_source.dart`: Drift DAO `ExerciseDao` with reactive streams (`watchExercises`, `watchMuscleGroups`, `watchExerciseById`), multi-predicate search (`query`, `category`, `equipment`, `muscleGroupId`, `favouritesOnly`), favourite toggling, transactional custom exercise creation, and batch insertion.
    - `exercise_seed_loader.dart`: Bundled asset loader that parses and seeds SQLite on first launch (guarded by count check or `force` flag).
    - `exercise_repository.dart`: Repository interface `ExerciseRepository` and implementation `ExerciseRepositoryImpl` exposed via `@riverpod` provider.
  - **Database Wiring (`core/database/`):**
    - Registered `ExerciseDao` in `AppDatabase` `daos` array.
  - **Verification & Tests (`test/features/exercise/`):**
    - Created `exercise_dao_test.dart` (6 test cases): seed loading 55 exercises + 14 muscle groups, search query benchmark (<100ms), category & equipment filters, muscle group filtering, favourite status stream reactivity, and custom exercise CRUD.
    - `dart run build_runner build` (40 outputs), `flutter analyze` (0 issues), `flutter test` (22/22 passing across the full suite).
  - **NEXT STEP (exact):** Proceed to **Slice 2 WU-2.4: Exercise List & Search Screen** (`exercise_list_controller.dart`, `exercise_list_screen.dart`, `exercise_search_delegate.dart` with Sharp Glassmorphism UI and filter chips).
- **2026-08-31 (session 10):** Implemented **Slice 2 WU-2.4: Exercise List & Search Screen**:
  - **Presentation Layer (`features/exercise/presentation/`):**
    - `exercise_list_state.dart`: Pure Freezed immutable state model `ExerciseListState` tracking query, filters, muscle groups, exercises, and active filter flags.
    - `exercise_list_controller.dart`: Riverpod `AsyncNotifier` `ExerciseListController` managing reactive debounced search, muscle group/equipment filter chips, favourite toggling, and filter resets.
    - `exercise_search_delegate.dart`: Reusable UI components (`ExerciseSearchBar`, `ExerciseFilterChipsBar`, `ExerciseListTile`) styled with Sharp Glassmorphism design tokens (`AppTheme.oledBlack`, `AppTheme.glassFill`, `AppTheme.glassBorder`, `AppTheme.neonCyan`, `AppTheme.voltGreen`).
    - `exercise_list_screen.dart`: Declarative `ConsumerWidget` with search bar, horizontal filter chips, exercise count header badge, reactive list tiles, and designed empty states (Law L6). Supports both standalone navigation and context-aware selection (`onExerciseSelected`).
  - **Routing (`core/router/app_router.dart`):** Registered `/exercises` route.
  - **Verification & Tests (`test/features/exercise/`):**
    - Created `exercise_list_test.dart` (5 unit/widget tests): verifying controller filter transitions, search debouncing, favourite toggling, screen UI rendering, empty state handling, and "CLEAR ALL FILTERS" action.
    - `dart run build_runner build` (36 outputs), `flutter analyze` (0 issues), `flutter test` (27/27 passing across the full suite).
  - **NEXT STEP (exact):** Proceed to **Slice 2 WU-2.5: Exercise Detail & Custom Exercise Screen** (`exercise_detail_screen.dart`, `create_custom_exercise_screen.dart`).
- **2026-08-31 (session 11):** Implemented **Slice 2 WU-2.5: Exercise Detail & Custom Exercise Screen**:
  - **Presentation Layer (`features/exercise/presentation/`):**
    - `exercise_detail_controller.dart`: Riverpod `AsyncNotifier` `ExerciseDetailController` managing single-exercise reactive lookup, favourite toggling, and custom exercise deletion.
    - `exercise_detail_screen.dart`: Declarative `ConsumerWidget` rendering exercise name, primary/secondary muscle badges, equipment, instructions card, target anatomy card, performance history placeholder, and confirmed custom deletion dialog (Law L7).
    - `create_custom_exercise_controller.dart`: Riverpod `AsyncNotifier` `CreateCustomExerciseController` validating exercise names (uniqueness against local catalog, Law L6) and persisting custom exercises with muscle group associations.
    - `create_custom_exercise_screen.dart`: Complete creation form with primary muscle dropdown, secondary muscle chips, equipment dropdown, category dropdown, time-based/cardio options, and inline error feedback.
  - **Routing (`core/router/app_router.dart`):** Registered `/exercises/new` and `/exercises/:id` routes; connected tile tapping and "+" FAB in `ExerciseListScreen`.
  - **Verification & Tests (`test/features/exercise/`):**
    - Created `exercise_detail_and_custom_test.dart` (4 unit/widget tests): verifying detail loading, favourite toggling, custom exercise validation (empty/duplicate errors), form inputs, and custom creation.
    - `dart run build_runner build` (44 outputs), `flutter analyze` (0 issues), `flutter test` (31/31 passing across the full suite).
  - **NEXT STEP (exact):** Proceed to **Slice 2 WU-2.6: Routine Domain Models & Drift Tables** (`Routine` and `RoutineExercise` Freezed entities, `Routines` and `RoutineExercises` Drift tables in `features/routine/`).
- **2026-08-31 (session 12):** Implemented **Slice 2 WU-2.6: Routine Domain Models & Drift Tables**:
  - **Protocol Update (`AGENTS.md`):** Added explicit "No Redundant Implementation Plans Rule" confirming implementation plans are already established in `EXECUTION_PLAN.md`, `FEATURES.md`, and `ARCHITECTURE.md`.
  - **Domain Layer (`features/routine/domain/`):**
    - `routine_set.dart`: Freezed `RoutineSet` entity representing a planned set in a routine exercise (`id`, `routineExerciseId`, `position`, `setType`, `targetReps`, `targetWeightKg`, `targetRpe`, JSON serialization).
    - `routine_exercise.dart`: Freezed `RoutineExercise` entity (`id`, `routineId`, `exerciseId`, `orderIndex`, `restSeconds`, `notes`, `targetSetsCount`, `targetWeightKg`, `targetReps`, `targetRpe`, `sets`, `exercise` embedding, convenience getters: `position`, `setsCount`, `targetSummary`, JSON serialization).
    - `routine.dart`: Freezed `Routine` entity (`id`, `name`, `description`, `userId`, `exercises`, convenience getters: `exerciseCount`, `totalSets`, `estimatedDurationSeconds`, `estimatedDurationMinutes`, JSON serialization).
  - **Data Layer & Database Schema (`features/routine/data/` & `core/database/`):**
    - `routine_tables.dart`: Drift tables `Routines` (`RoutineRow`), `RoutineExercises` (`RoutineExerciseRow` with foreign key cascade delete on routine/exercise and unique `(routineId, orderIndex)`), and `RoutineSets` (`RoutineSetRow` with foreign key cascade delete and unique `(routineExerciseId, position)`).
    - `app_database.dart`: Registered `Routines`, `RoutineExercises`, `RoutineSets` in `@DriftDatabase`, bumped `schemaVersion` to 3, and added v3 migration block.
  - **Verification & Tests (`test/features/routine/`):**
    - Created `routine_domain_test.dart` (4 unit/integration tests): verifying domain immutability, duration/set count math, JSON serialization roundtrip, in-memory Drift SQLite CRUD, and cascade deletion.
    - `dart run build_runner build` (82 outputs), `flutter analyze` (0 issues), `flutter test` (35/35 passing across the full suite).
  - **NEXT STEP (exact):** Proceed to **Slice 2 WU-2.7: Routine DAO & Repository** (`RoutineDao` with reactive streams `watchAllRoutines()`, `getRoutineWithExercises(id)`, CRUD, and `RoutineRepository` Riverpod implementation).
- **2026-08-31 (session 13):** Implemented **Slice 2 WU-2.7: Routine DAO & Repository**:
  - **Data Layer (`features/routine/data/`):**
    - `routine_local_source.dart`: Drift DAO `RoutineDao` with reactive joins (`watchAllRoutines()`, `getAllRoutines()`, `watchRoutineById()`, `getRoutineById()`), multi-table transactional mutations (`createRoutine`, `updateRoutine`, `deleteRoutine`, `addExerciseToRoutine`, `removeExerciseFromRoutine`), two-pass constraint-safe reordering (`reorderExercises`), and non-destructive duplication (`duplicateRoutine`, Law L7).
    - `routine_repository.dart`: Interface `RoutineRepository` and production implementation `RoutineRepositoryImpl` with domain mappings and `@riverpod` provider.
  - **Database Wiring (`core/database/`):**
    - Registered `RoutineDao` in `AppDatabase` `daos` array.
  - **Verification & Tests (`test/features/routine/`):**
    - Created `routine_dao_and_repo_test.dart` (4 comprehensive tests): in-memory Drift DAO creation & queries, exercise reordering with unique constraint safety, non-destructive cloning (Law L7), and repository domain mapping/CRUD/stream reactivity.
    - `dart run build_runner build` (72 outputs), `flutter analyze` (0 issues), `flutter test` (39/39 passing across the full suite).
  - **NEXT STEP (exact):** Proceed to **Slice 2 WU-2.8: Routines List Screen** (`routine_list_controller.dart`, `routine_list_screen.dart` with Sharp Glassmorphism design and designed empty state per L6).
- **2026-08-31 (session 14):** Implemented **Slice 2 WU-2.8: Routines List Screen**:
  - **Presentation Layer (`features/routine/presentation/`):**
    - `routine_list_controller.dart`: Riverpod `AsyncNotifier` `RoutineListController` streaming all routines, supporting deep-clone duplication, deletion, and fast session startup (`startWorkoutFromRoutine`, pre-populating target sets into SQLite in <1s, Law L1, L7).
    - `routine_list_screen.dart`: Declarative `ConsumerWidget` with Sharp Glassmorphism UI, search filter bar, routine preview cards with exercise count/sets/duration badges (`AppTheme.num` tabular figures), START WORKOUT action, overflow actions (edit, duplicate, delete confirmation dialog), and designed empty state (Law L6).
    - `routines_screen.dart`: Updated to delegate directly to `RoutineListScreen`.
  - **Verification & Tests (`test/features/routine/`):**
    - Created `routine_list_test.dart` (4 comprehensive unit & widget tests): verifying session startup with preloaded targets in <1s, duplication, empty state rendering, search filtering, and action triggers.
    - `dart run build_runner build` (82 outputs), `flutter analyze` (0 issues), `flutter test` (43/43 passing across the full suite).
  - **NEXT STEP (exact):** Proceed to **Slice 2 WU-2.9: Routine Builder / Editor Screen** (`routine_editor_controller.dart`, `routine_editor_screen.dart`, `routine_exercise_editor_sheet.dart`).
- **2026-08-31 (session 15):** Implemented **Slice 2 WU-2.9: Routine Builder / Editor Screen**:
  - **Presentation Layer (`features/routine/presentation/`):**
    - `routine_editor_state.dart`: Freezed UI state `RoutineEditorState` tracking routine metadata, ordered routine exercises, duration/set calculations, and validation.
    - `routine_editor_controller.dart`: AutoDispose Riverpod controller managing routine mutations: adding exercises from library, updating exercise targets, two-pass reordering, deletion with confirmation (Law L7), and synchronous SQLite write-through save.
    - `routine_exercise_editor_sheet.dart`: Sharp Glassmorphism bottom sheet for tuning sets count (steppers), target weight (kg), target reps, rest timer chips (30s, 60s, 90s, 120s, 180s), target RPE, and exercise notes.
    - `routine_editor_screen.dart`: Full-screen builder supporting both creation (`/routines/new`) and editing (`/routines/:id/edit`), with summary metrics cards, drag-and-drop `ReorderableListView`, exercise catalog picker connection, and sticky save bar.
  - **Routing (`core/router/app_router.dart`):**
    - Registered routes: `/routines/new`, `/routines/:id`, and `/routines/:id/edit`.
  - **Verification & Tests (`test/features/routine/`):**
    - Created `routine_editor_test.dart` (5 comprehensive unit & widget tests): verifying empty new routine state, existing routine loading/mutation, exercise reordering and removal, empty name validation, `RoutineExerciseEditorSheet` target configuration, and screen form interactions.
    - `dart run build_runner build` (76 outputs), `flutter analyze` (0 issues), `flutter test` (49/49 passing across the full mobile test suite).
  - **NEXT STEP (exact):** Proceed to **Slice 2 WU-2.10: Routine Detail & Start Workout** (`routine_detail_screen.dart`, `routine_detail_controller.dart`).
- **2026-08-31 (session 16):** Implemented **Slice 2 WU-2.10: Routine Detail & Start Workout** and completed **Slice 2: Exercises & Routines**:
  - **Presentation Layer (`features/routine/presentation/`):**
    - `routine_detail_controller.dart`: Riverpod `AutoDisposeFamilyAsyncNotifier` `RoutineDetailController` streaming routine changes reactively from SQLite, with instant workout creation (`startWorkout`, pre-populating planned sets and target weights/reps into SQLite in <1s while leaving the routine 100% unmutated per Law L7), non-destructive duplication, and cascade deletion.
    - `routine_detail_screen.dart`: Read-only Sharp Glassmorphism UI detail screen showing metadata header, summary cards (Exercises, Sets, Estimated Duration), full set-by-set target tables (`SET | TARGET WEIGHT | REPS | REST`), notes container, sticky "START WORKOUT" action bar, edit routing, and not-found state.
  - **Routing (`core/router/app_router.dart`):**
    - Updated `/routines/:id` route to `RoutineDetailScreen(routineId: ...)`.
  - **Verification & Tests (`test/features/routine/` & `backend/`):**
    - Created `routine_detail_test.dart` (4 comprehensive unit & widget tests): verifying start-workout session creation, immutability of source routine (Law L7), duplicate/delete operations, and UI table rendering.
  - **Slice 2 Status:** ✅ **100% COMPLETE** across full vertical stack (Exercise Catalog, Custom Exercises, Favourites, Routine Tables, DAO, Repository, Routine List, Routine Builder/Editor, and Routine Detail/Start Workout).
- **2026-08-31 (session 17):** Implemented **Slice 3 WU-3.1: Session-Exercise Data Layer**:
  - **Domain Layer (`features/workout/domain/`):**
    - `session_exercise.dart`: Freezed entity `SessionExercise` (`id`, `sessionId`, `exerciseId`, `exercise`, `exerciseName`, `orderIndex`, `restSeconds`, `notes`, `sets`, convenience getters: `position`, `setsCount`, `completedSetsCount`, `totalVolumeKg`, JSON serialization).
    - `workout_set.dart` & `workout_session.dart`: Updated to include `sessionExerciseId`, set metadata (`completedAt`, `isPr`, `notes`), and aggregate calculations (`totalSetsCount`, `completedSetsCount`, `totalVolumeKg`).
  - **Data Layer & Database Schema (`features/workout/data/` & `core/database/`):**
    - `workout_tables.dart`: Added `SessionExercises` table (`SessionExerciseRow` with foreign key cascade delete on session and exercise, and unique `(sessionId, orderIndex)`) and updated `WorkoutSessions` and `WorkoutSets` tables (`WorkoutSetRow` with foreign key on `sessionExerciseId` and unique `(sessionExerciseId, setNumber)`).
    - `app_database.dart`: Registered `SessionExercises` table in `@DriftDatabase`, bumped `schemaVersion` to 4, and added v4 migration step.
    - `workout_local_source.dart`: Updated `WorkoutDao` with joined reactive queries (`watchSessionExercisesWithSets`, `watchSessionWithExercises`), carrier models (`SessionWithExercises`, `SessionExerciseWithSets`), transactional two-pass collision-safe reordering (`reorderSessionExercises`), and cascade deletion.
    - `workout_repository.dart`: Updated `WorkoutRepository` interface and `WorkoutRepositoryImpl` with domain entity mapping and Riverpod provider.
  - **Presentation Layer Updates (`features/workout/presentation/` & `features/routine/presentation/`):**
    - `active_workout_state.dart` & `active_workout_controller.dart`: Updated state and controller with optimistic `SessionExercise` updates and write-through persistence.
    - `routine_detail_controller.dart` & `routine_list_controller.dart`: Updated `startWorkout` to create `SessionExercises` and link target sets via `sessionExerciseId`.
  - **Verification & Tests (`test/features/workout/` & `backend/`):**
    - Created `session_exercise_test.dart` (5 comprehensive unit & DAO tests): testing domain immutability/volume math, JSON serialization, in-memory Drift SQLite session exercises CRUD, two-pass reordering, cascade set deletion, and routine startup.
    - Updated `workout_reference_slice_test.dart` with `sessionExerciseId` and SQLite setup.
    - `dart run build_runner build` (181 outputs), `flutter analyze` (0 issues), `flutter test` (**59/59 tests passing across mobile**), `./gradlew test` (**BUILD SUCCESSFUL across backend**).
  - **NEXT STEP (exact):** Proceed to **Slice 3 WU-3.2: Ghost Prefill Logic** (`ghost_set.dart` Freezed value object, `ghost_prefill_service.dart` with 4-branch history/routine/set prefill resolution, unit tests).


---

## Sources of Truth

- **Product Features & Build Order:** `FEATURES.md` (repo root — all phases P0/P1/V1.1/V2, per-screen specs)
- **Architecture Blueprint & Conventions:** `ARCHITECTURE.md` (repo root — layer anatomy, contracts, diagrams)
- **Architecture, Rules & Stack Laws (L1–L10):** `AGENTS.md`
- **Developer Setup & Run:** `README.md`
- **Sprint / Session Memory:** `HANDOFF.md` (this file)

---

## Development Strategy & Milestones (Vertical Slices)

| Slice | Focus | Status | Scope | Test Verification Targets |
|:---|:---|:---:|:---|:---|
| **Slice 1** | Scaffolding & Foundation | ✅ Completed | Flutter setup in `mobile/`, Glassmorphism theme, Drift SQLite schema, GoRouter shell, Feature-First trees, Native bindings (Sentry/WorkManager/Patrol), Root `ARCHITECTURE.md`, Canonical Reference Slice (`features/workout`) | Flutter analyze (0 issues) + Flutter test (12/12 passing) + Gradle androidTest compile |
| **Slice 2** | Exercises & Routines | ✅ Completed | Local SQLite 55-exercise library + Custom Exercises + Routines CRUD + Routine Builder + Live Startup (<1s) + PostgreSQL V3/V4 migrations + `/api/v1/exercises` & `/routines` | 53/53 Flutter tests passing (query benchmarks <100ms, cascade delete, reordering, L7 immutability) + Gradle backend tests pass |
| **Slice 3** | Active Workout Engine | 🔵 Active | Live session UI, ghost prefill, rest timer math, SQLite write-through + `/api/v1/workouts` | E2E live-session test with SQLite write-through & lock-screen service test |
| **Slice 4** | Indian Nutrition Engine | ⬜ Queued | Local 5,000 foods search, household units + `/api/v1/nutrition` | 5,000 foods local search test + macro math unit tests |
| **Slice 5** | Auth & Cloud Sync | ⬜ Queued | Phone OTP/Google login, Spring Security + `/api/v1/sync` queue | Spring Security OTP integration test + sync push/pull integration tests (`./gradlew test`) |
| **Post-MVP** | P1/V1.1/V2 slices | ⬜ Queued | CSV importer, EMA TDEE engine, Vrat Mode, sync hardening, AI surfaces | CSV importer integrity test, EMA TDEE math test, Trainer QR payload test |

---

## Branching & Workflow

- **Active Development Branch:** `dev` (Flutter codebase & active Spring Boot backend)
- **Archive Branch:** `archive/react-native` (legacy React Native code preserved for reference)
- **Stable Branch:** `main` | **Feature Branches:** `feature/*` (branched from `dev`, merged back to `dev`)
- **Rules:** Never use destructive git commands; follow conventional commits.
