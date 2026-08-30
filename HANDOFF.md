# HANDOFF.md

> **Canonical Handoff State** — Single persistent handoff file. Update in place at session end.
> **Last updated:** 2026-08-31

---

## Active Project & Stack

- **Project:** Aven Fit (Offline-first Gym & Nutrition Tracker for Android)
- **Mobile:** Flutter + Dart in `mobile/` (State: Riverpod 2.x, Local DB: SQLite via **Drift** — `drift_flutter` + `sqlite3_flutter_libs`, Navigation: **GoRouter**; Feature-First layout: `lib/core/` + `lib/features/<domain>/{domain,data,presentation}/`)
- **Backend:** Spring Boot 3.3 + Java 21 in `backend/` (Server DB: PostgreSQL 16)
- **Archive Policy:** `docs/archive/` and `archive/` are quarantined; never access unless explicitly instructed.

---

## Session Notes

- **2026-08-31 (session 1):** Slice 1 scaffolding started. Legacy `mobile/node_modules` (React Native era, untracked) removed. Flutter project created in `mobile/` (`--org com.avenfit`, project name `aven_fit` → package `com.avenfit.aven_fit`, Android-only). All locked dependencies configured in `pubspec.yaml` (Riverpod 2.x, GoRouter 14.8.x, Drift 2.24.x, Dio 5.8+, WorkManager 0.5.2, Freezed 2.5.x, google_fonts, lucide_icons; dev: build_runner, riverpod_generator, drift_dev, freezed, json_serializable, mocktail, patrol 3.x, flutter_lints 5). `flutter pub get` resolved cleanly (124 deps), `flutter analyze` passes with no issues. Next: Glassmorphism theme, Drift schema in `lib/core/`, GoRouter shell, Feature-First dirs.
- **2026-08-31 (session 2):** Slice 1 core foundation scaffolded — `core/theme` (Sharp Glassmorphism: OLED black, neon cyan, volt green, burnt orange, Inter + JetBrains Mono tabular numerals), `core/database` (Drift via `drift_flutter`, `shareAcrossIsolates`, `WorkoutSessions` base table, schema v1), `core/network` (Dio, baseline timeouts, interceptor hook), `core/router` (`StatefulShellRoute.indexedStack` with the 4 main tabs: Home · Workouts · Progress · Nutrition). Feature-First trees created under `lib/features/{workout,routine,nutrition,history,sync}/{data,domain,presentation}`. `main.dart` wires `ProviderScope` + `AppTheme` + `appRouter`; DB exposed via `appDatabaseProvider` (dispose-safe). Fonts bundled as SHA-256-pinned TTF assets (google_fonts never fetches at runtime — offline-first, deterministic tests). `build_runner` codegen OK (18 outputs); `flutter analyze` 0 issues; `flutter test` 1/1 passing.
  - **Forced deviation 1 (deps):** Dart 3.13/Flutter 3.47 breaks the originally locked codegen stack — `riverpod_generator` 2.x is pinned to `analyzer ^7`, which crashes on Dart 3.10+ dot-shorthand AST (`Missing implementation of visitDotShorthandPropertyAccess`). Full `pub upgrade --major-versions` applied: riverpod_generator 4.0.8, flutter_riverpod 3.4.2, riverpod_annotation 4.0.6, freezed 4.0.1 + freezed_annotation 3.1.0, go_router 18.0.0, drift/drift_dev 2.34.x, workmanager 0.10.9, google_fonts 8.2.1, patrol 4.9.0, build_runner 2.16.0, flutter_lints 6. **Requires user ratification to amend the AGENTS.md stack table (Riverpod 3.x / GoRouter 18 / WorkManager 0.10).**
  - **Forced deviation 2 (icons):** `lucide_icons` cannot compile on Flutter 3.47 — every version subclasses `IconData`, which the framework made `final`. Replaced with `lucide_icons_flutter` (maintained Lucide port, plain `IconData`, same icon names incl. `home`/`dumbbell`/`chartColumn`/`salad`). The spec's alternative `flutter_svg` was not used (heavier runtime + asset footprint).
  - **Note:** `build_runner` on the new build 4.x ignores `--delete-conflicting-outputs` (removed flag; conflicting outputs are handled automatically).
- **2026-08-31 (session 4):** Slice 1 scaffold re-verified end to end (no code changes needed — session 2 output was intact and untracked). `dart run build_runner build --delete-conflicting-outputs` → 24 outputs (flag ignored on build 4.x, as noted in session 2); `flutter analyze` → 0 issues; `flutter test` → 1/1 passing. All 4 core modules (`core/theme`, `core/database`, `core/network`, `core/router`), 5 feature trees (`workout/routine/nutrition/history/sync` × `data/domain/presentation`), and `main.dart` wiring confirmed in place.
- **2026-08-31 (session 3):** **Ratification confirmed by user** — both forced deviations above are approved: (1) the `pub upgrade --major-versions` dependency set (Riverpod 3.x, GoRouter 18, Drift 2.34+, Freezed 4, WorkManager 0.10+, Patrol 4.9) for the Dart 3.13 / Flutter 3.47 toolchain, and (2) the `lucide_icons` → `lucide_icons_flutter` swap. `AGENTS.md` Key Tooling table updated with the ratified versions plus a ratification note; `lucide_icons_flutter` added to the locked tooling list. No code changes this session. Next: continue Slice 1 remainder / Slice 2 per milestone table.
- **2026-08-31 (session 5):** Native bindings wired (Step 4 of Slice 1):
  - **Sentry:** `sentry_flutter 8.14.2` added (satisfies requested ^8.12.0). `SentryFlutter.init()` in `main.dart` with env-based DSN placeholder (`--dart-define=AVENFIT_SENTRY_DSN`, default placeholder → sending disabled), `AVENFIT_ENV` (default `development`), `tracesSampleRate 1.0`, `sendDefaultPii false`; `appRunner` wraps `runApp` so startup crashes are captured.
  - **WorkManager:** top-level `@pragma('vm:entry-point') void workmanagerDispatcher()` created in `lib/core/sync/workmanager_dispatcher.dart` with canonical task IDs (`WorkmanagerTasks.syncQueueDrain`). In 0.10.9 `executeTask` is **void** (registers handler, returns immediately — do NOT await) and the dispatcher must be registered via `await Workmanager().initialize(workmanagerDispatcher)` before task registration (Android resolves the callback handle from SharedPreferences). A network-constrained periodic task (`BackoffPolicy.exponential`, 15 min) is registered in `main()` as a no-op placeholder until Slice 5 wires the real queue drain.
  - **Patrol (Gradle):** `android/app/build.gradle.kts` (Kotlin DSL — project has NO Groovy `build.gradle`) configured per the official Patrol 4.9 example: `testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"`, `clearPackageData` runner arg, `execution = "ANDROIDX_TEST_ORCHESTRATOR"`, `androidTestImplementation("androidx.test:runner:1.5.2")` + `androidTestUtil("androidx.test:orchestrator:1.5.1")`. The bare androidx runner requested would NOT execute Patrol tests — `PatrolJUnitRunner` is required (it binds the Dart test registry).
  - **Mocktail smoke test:** `test/smoke_test.dart` (3 tests: stub/act/verify, argument predicates, harness sanity). All pass.
  - **Verification status:** `flutter pub get` clean; `flutter analyze` 0 issues; `flutter test` 4/4 passing; Gradle configure OK (`gradlew help`/`:app:tasks` exit 0, androidTest tasks present). **`gradlew :app:compileDebugAndroidTestSources` FAILED — unresolved.** Failure is a Kotlin daemon incremental-cache corruption on Windows (`Could not close incremental caches ... kotlin/cacheable/caches-jvm`), reproduced twice; one retry after `--stop` + deleting `mobile/build` also failed. Not yet proven to be a code/config error — the last attempt was interrupted mid-run. Likely a Windows file-lock/daemon issue (the `:app:compileFlutterBuildDebug` and config steps all passed).
  - **Environment notes:** piping Gradle output into `Select-String` deadlocks on stream buffering — redirect to a log file instead (`> "$env:TEMP\opencode\x.log" 2>&1`). KGP warning (`patrol`, `sentry_flutter`, `workmanager_android` apply Kotlin Gradle Plugin) is informational only.
  - **NEXT STEP (exact):** Step 5 — Feature Slice Architecture Blueprint. Before anything else, resume the failed check: `cd mobile/android; .\gradlew.bat --stop`, delete `mobile\build` and `mobile\android\.gradle`, then run `.\gradlew.bat :app:compileDebugAndroidTestSources --console=plain > log 2>&1` with output redirected to a file (NO PowerShell pipes). If it still fails, re-run with `--no-daemon` and inspect the log for real compile errors vs. cache corruption. Only then proceed to the Slice Architecture Blueprint.

---

## Sources of Truth

- **Product Features & Build Order:** `FEATURES.md` (repo root — all phases P0/P1/V1.1/V2, per-screen specs)
- **Architecture, Rules & Stack Laws (L1–L10):** `AGENTS.md`
- **Developer Setup & Run:** `README.md`
- **Sprint / Session Memory:** `HANDOFF.md` (this file)

---

## Development Strategy & Milestones (Vertical Slices)

| Slice | Focus | Status | Scope | Test Verification Targets |
|:---|:---|:---:|:---|:---|
| **Slice 1** | Scaffolding & Foundation | 🔵 Active | Flutter setup in `mobile/`, Glassmorphism theme, Drift SQLite schema (Drift `database` in `lib/core/`), GoRouter shell, Feature-First dirs (`lib/core/` + `lib/features/`), Backend health | Flutter smoke test + Spring Boot health check |
| **Slice 2** | Exercises & Routines | ⬜ Queued | Local SQLite exercise cache + Flutter UI + `/api/v1/exercises` & `/routines` | Local SQLite query benchmarks (<100ms) + Routine builder unit tests |
| **Slice 3** | Active Workout Engine | ⬜ Queued | Live session UI, rest timer math, SQLite write-through + `/api/v1/workouts` | E2E live-session test with SQLite write-through & lock-screen service test |
| **Slice 4** | Indian Nutrition Engine | ⬜ Queued | Local 5,000 foods search, household units + `/api/v1/nutrition` | 5,000 foods local search test + macro math unit tests |
| **Slice 5** | Auth & Cloud Sync | ⬜ Queued | Phone OTP/Google login, Spring Security + `/api/v1/sync` queue | Spring Security OTP integration test + sync push/pull integration tests (`./gradlew test`) |
| **Post-MVP** | P1/V1.1/V2 slices | ⬜ Queued | CSV importer, EMA TDEE engine, Vrat Mode, sync hardening, AI surfaces | CSV importer integrity test, EMA TDEE math test, Trainer QR payload test |

---

## Branching & Workflow

- **Active Development Branch:** `dev` (Flutter codebase & active Spring Boot backend)
- **Archive Branch:** `archive/react-native` (legacy React Native code preserved for reference)
- **Stable Branch:** `main` | **Feature Branches:** `feature/*` (branched from `dev`, merged back to `dev`)
- **Rules:** Never use destructive git commands; follow conventional commits.

