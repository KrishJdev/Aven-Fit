// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pr_local_source.dart';

// ignore_for_file: type=lint
mixin _$PrDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $RoutinesTable get routines => attachedDatabase.routines;
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  $SessionExercisesTable get sessionExercises =>
      attachedDatabase.sessionExercises;
  $WorkoutSetsTable get workoutSets => attachedDatabase.workoutSets;
  $PersonalRecordsTable get personalRecords => attachedDatabase.personalRecords;
  PrDaoManager get managers => PrDaoManager(this);
}

class PrDaoManager {
  final _$PrDaoMixin _db;
  PrDaoManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db.attachedDatabase, _db.routines);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
        _db.attachedDatabase,
        _db.workoutSessions,
      );
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(
        _db.attachedDatabase,
        _db.sessionExercises,
      );
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db.attachedDatabase, _db.workoutSets);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(
        _db.attachedDatabase,
        _db.personalRecords,
      );
}
