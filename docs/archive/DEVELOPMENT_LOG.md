# DEVELOPMENT_LOG.md

### 2026-08-27 - Antigravity (Massive UI Pivot & Database Wiring)

**Task:** Complete UI Rewrite to Sharp Glassmorphism & SQLite DB Wiring
**Status:** Complete (Phase 1-2 UI, DB Core Wired)

**Changes:**
- **PIVOT:** The user completely rejected the previous Brutalist UI. Implemented a brand new "Sharp Glassmorphism" UI system (	heme/colors.ts, GlassCard.tsx, GlassButton.tsx, updated Typography). Accent color is now Neon Cyan (#00F0FF) with translucent black/grey surfaces.
- **UI Rewrite:** Rewrote HomeScreen, WorkoutListScreen, ActiveWorkoutScreen, ProgressScreen, NutritionScreen, ExerciseDirectory, and workout components (SetRow, ExerciseBlock) to fit the new glassy aesthetic.
- **Global SafeArea Fix:** Ripped out the buggy React Native SafeAreaView across all ~15 screens and migrated perfectly to eact-native-safe-area-context using useSafeAreaInsets to fix Notch/Camera overlap issues globally.
- **Database Architecture:** Implemented raw SQLite schemas (schema.ts) and built Zustand state stores (workoutStore.ts, outineStore.ts, exerciseStore.ts) to manage state and write to SQLite instantly.
- **Active Workout Engine Wired:** 
  - startWorkout now dynamically names workouts based on time of day (e.g., "Early Bird Session", "Midnight Lift").
  - Included a live Javascript Timer inside ActiveWorkoutScreen backed by Zustand durationCounter, complete with Pause/Play functionality.
  - Set Logging now natively features "Ghost Placeholders" (history carry-over) where tapping "Add Set" automatically fetches the previous weight/reps from history and pre-fills them as subtle translucent placeholders. Tapping the checkmark without typing locks them in.
  - Finishing a workout prompts a translucent Modal allowing the user to rename the workout before finalizing and dropping it into the SQLite completed table.
- **Home Screen Aggregates:** The Dashboard is wired to loadRecentWorkouts, automatically computing and aggregating olume, sets, and exercisesStr via SQLite joins.

**Next Steps (Tomorrow):**
- **Nutrition Engine Wiring:** Now that the workout database is successfully wired to the UI, wire up the Nutrition side (SQLite tables for daily meals, caching food items, and macros aggregation).
- **Progress Analytics:** Wire the Progress Dashboard to calculate 1RM trends and Vault metrics from the workout_sets history.
- **Routine Builder:** Wire up the Routine Builder screens to properly let users construct templated workout plans.

### 2026-08-30 - Antigravity (Stack Migration Decision)

**Task:** Switch Mobile Framework from React Native to Flutter
**Status:** In Progress
**Changes:**
- **Stack Update:** The user explicitly requested to switch the mobile framework from React Native to Flutter. The sunk cost is considered low.
- Updated `AGENTS.md` to lock Flutter + Dart as the primary mobile stack and move React Native to the explicitly rejected list.
- Updated `README.md` to reflect Flutter, Dart, Riverpod, and sqflite in the tech stack, repository structure, and setup instructions.
**Next Steps:**
- Discard/delete the current React Native `mobile/` directory.
- Initialize a new Flutter project in the `mobile/` directory.
- Re-implement the Sharp Glassmorphism UI and SQLite wiring using Flutter and Riverpod.