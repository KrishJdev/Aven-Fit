import 'package:drift/drift.dart';

import '../../exercise/data/exercise_tables.dart';
import '../../routine/data/routine_tables.dart';

/// Drift SQLite table for workout sessions.
///
/// Uses client-generated UUID primary keys (Law L2, L7) so the local
/// SQLite database remains the authority and sync requires no ID remapping.
@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get routineId =>
      text().nullable().references(Routines, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text().withDefault(const Constant('Workout'))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
  // Epoch of the last moment the session timer ticked — the freeze point
  // while paused (FEATURES.md §8.1 `last_resumed_at` pattern from RN, L8).
  DateTimeColumn get lastResumedAt => dateTime().nullable()();
  IntColumn get pausedDurationSeconds =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift SQLite table for exercise entries within an active/completed workout session.
///
/// Connects a workout session to an exercise in the catalog with ordering and rest timer configuration.
@DataClassName('SessionExerciseRow')
class SessionExercises extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get restSeconds => integer().withDefault(const Constant(90))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {sessionId, orderIndex},
      ];
}

/// Drift SQLite table for logged or planned workout sets.
///
/// Matches backend `workout_sets` schema and references `SessionExercises`.
@DataClassName('WorkoutSetRow')
class WorkoutSets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get sessionExerciseId =>
      text().references(SessionExercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().nullable()();
  IntColumn get setNumber => integer()();
  RealColumn get weightKg => real().withDefault(const Constant(0.0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get setType => text().withDefault(const Constant('normal'))();
  RealColumn get rpe => real().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isPr => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {sessionExerciseId, setNumber},
      ];
}
