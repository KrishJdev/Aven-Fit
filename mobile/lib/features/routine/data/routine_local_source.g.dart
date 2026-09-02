// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_local_source.dart';

// ignore_for_file: type=lint
mixin _$RoutineDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoutinesTable get routines => attachedDatabase.routines;
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $RoutineExercisesTable get routineExercises =>
      attachedDatabase.routineExercises;
  $RoutineSetsTable get routineSets => attachedDatabase.routineSets;
  $MuscleGroupsTable get muscleGroups => attachedDatabase.muscleGroups;
  $ExerciseMuscleGroupsTable get exerciseMuscleGroups =>
      attachedDatabase.exerciseMuscleGroups;
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  RoutineDaoManager get managers => RoutineDaoManager(this);
}

class RoutineDaoManager {
  final _$RoutineDaoMixin _db;
  RoutineDaoManager(this._db);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db.attachedDatabase, _db.routines);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$RoutineExercisesTableTableManager get routineExercises =>
      $$RoutineExercisesTableTableManager(
        _db.attachedDatabase,
        _db.routineExercises,
      );
  $$RoutineSetsTableTableManager get routineSets =>
      $$RoutineSetsTableTableManager(_db.attachedDatabase, _db.routineSets);
  $$MuscleGroupsTableTableManager get muscleGroups =>
      $$MuscleGroupsTableTableManager(_db.attachedDatabase, _db.muscleGroups);
  $$ExerciseMuscleGroupsTableTableManager get exerciseMuscleGroups =>
      $$ExerciseMuscleGroupsTableTableManager(
        _db.attachedDatabase,
        _db.exerciseMuscleGroups,
      );
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
        _db.attachedDatabase,
        _db.workoutSessions,
      );
}
