import 'package:drift/drift.dart';

import '../../exercise/data/exercise_tables.dart';

/// Drift SQLite table for workout routines / templates.
///
/// Complies with Law L2 (offline-first storage), Law L3 (unlimited routines forever),
/// and Law L7 (write-through persistence).
@DataClassName('RoutineRow')
class Routines extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift SQLite table for exercise entries within a routine.
///
/// Uses cascade delete so deleting a routine cleans up its exercise entries.
@DataClassName('RoutineExerciseRow')
class RoutineExercises extends Table {
  TextColumn get id => text()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get restSeconds => integer().withDefault(const Constant(90))();
  TextColumn get notes => text().nullable()();
  IntColumn get targetSetsCount => integer().nullable()();
  RealColumn get targetWeightKg => real().nullable()();
  IntColumn get targetReps => integer().nullable()();
  RealColumn get targetRpe => real().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {routineId, orderIndex},
      ];
}

/// Drift SQLite table for individual target sets within a routine exercise.
///
/// Matches backend `routine_sets` schema for sync contract compatibility.
@DataClassName('RoutineSetRow')
class RoutineSets extends Table {
  TextColumn get id => text()();
  TextColumn get routineExerciseId =>
      text().references(RoutineExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().withDefault(const Constant(1))();
  TextColumn get setType => text().withDefault(const Constant('normal'))();
  IntColumn get targetReps => integer().nullable()();
  RealColumn get targetWeightKg => real().nullable()();
  RealColumn get targetRpe => real().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {routineExerciseId, position},
      ];
}
