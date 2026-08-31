// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_local_source.dart';

// ignore_for_file: type=lint
mixin _$ExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $MuscleGroupsTable get muscleGroups => attachedDatabase.muscleGroups;
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $ExerciseMuscleGroupsTable get exerciseMuscleGroups =>
      attachedDatabase.exerciseMuscleGroups;
  ExerciseDaoManager get managers => ExerciseDaoManager(this);
}

class ExerciseDaoManager {
  final _$ExerciseDaoMixin _db;
  ExerciseDaoManager(this._db);
  $$MuscleGroupsTableTableManager get muscleGroups =>
      $$MuscleGroupsTableTableManager(_db.attachedDatabase, _db.muscleGroups);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$ExerciseMuscleGroupsTableTableManager get exerciseMuscleGroups =>
      $$ExerciseMuscleGroupsTableTableManager(
        _db.attachedDatabase,
        _db.exerciseMuscleGroups,
      );
}
