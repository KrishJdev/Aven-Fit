import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/exercise/data/exercise_local_source.dart';
import '../../features/exercise/data/exercise_tables.dart';
import '../../features/history/data/history_local_source.dart';
import '../../features/progress/data/pr_local_source.dart';
import '../../features/progress/data/pr_tables.dart';
import '../../features/routine/data/routine_local_source.dart';
import '../../features/routine/data/routine_tables.dart';
import '../../features/workout/data/workout_local_source.dart';
import '../../features/workout/data/workout_tables.dart';

part 'app_database.g.dart';

/// Aven Fit local SQLite database — the primary source of truth during
/// live usage (Law L2).
///
/// Runs in a background isolate via `drift_flutter` so queries never
/// block the UI thread on budget devices.
@DriftDatabase(
  tables: [
    WorkoutSessions,
    SessionExercises,
    WorkoutSets,
    MuscleGroups,
    Exercises,
    ExerciseMuscleGroups,
    Routines,
    RoutineExercises,
    RoutineSets,
    PersonalRecords,
  ],
  daos: [WorkoutDao, ExerciseDao, RoutineDao, PrDao, HistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(muscleGroups);
            await m.createTable(exercises);
            await m.createTable(exerciseMuscleGroups);
          }
          if (from < 3) {
            await m.createTable(routines);
            await m.createTable(routineExercises);
            await m.createTable(routineSets);
          }
          if (from < 4) {
            await m.createTable(sessionExercises);
          }
          if (from < 5) {
            await m.createTable(personalRecords);
          }
          if (from < 6) {
            // Crash resilience & pause tracking (WU-3.8, §8.1 L7/L8).
            await m.addColumn(workoutSessions, workoutSessions.isPaused);
            await m.addColumn(workoutSessions, workoutSessions.lastResumedAt);
            await m.addColumn(
                workoutSessions, workoutSessions.pausedDurationSeconds);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'aven_fit',
    native: const DriftNativeOptions(
      // Share one database instance across isolates; prevents
      // "database is locked" when background work (sync, timers)
      // touches the DB concurrently with the UI.
      shareAcrossIsolates: true,
    ),
  );
}
