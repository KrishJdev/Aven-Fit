import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/routine/domain/routine.dart';
import 'package:aven_fit/features/routine/domain/routine_exercise.dart';
import 'package:aven_fit/features/routine/domain/routine_set.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Routine Domain Entity Tests', () {
    test('RoutineSet defaults, immutability, and JSON serialization', () {
      const set = RoutineSet(
        id: 'set-1',
        routineExerciseId: 're-1',
        targetReps: 10,
        targetWeightKg: 80.0,
        targetRpe: 8.5,
      );

      expect(set.position, 1);
      expect(set.setType, SetType.normal);
      expect(set.targetReps, 10);
      expect(set.targetWeightKg, 80.0);
      expect(set.targetRpe, 8.5);

      final json = set.toJson();
      expect(json['id'], 'set-1');
      expect(json['position'], 1);
      expect(json['setType'], 'normal');

      final reconstructed = RoutineSet.fromJson(json);
      expect(reconstructed, equals(set));
    });

    test('RoutineExercise helpers, target summary, and JSON serialization', () {
      const exercise = RoutineExercise(
        id: 're-1',
        routineId: 'r-1',
        exerciseId: 'ex-bench',
        exerciseName: 'Barbell Bench Press',
        orderIndex: 0,
        restSeconds: 120,
        targetSetsCount: 4,
        targetReps: 8,
        targetWeightKg: 82.5,
        targetRpe: 9.0,
        sets: [
          RoutineSet(
            id: 'set-1',
            routineExerciseId: 're-1',
            position: 1,
            targetReps: 8,
            targetWeightKg: 82.5,
          ),
          RoutineSet(
            id: 'set-2',
            routineExerciseId: 're-1',
            position: 2,
            targetReps: 8,
            targetWeightKg: 82.5,
          ),
        ],
      );

      expect(exercise.position, 0);
      expect(exercise.setsCount, 2); // Derived from sets list
      expect(exercise.targetSummary, '2 × 8 reps @ 82.5 kg');

      final json = exercise.toJson();
      expect(json['id'], 're-1');
      expect(json['restSeconds'], 120);
      expect((json['sets'] as List).length, 2);

      final reconstructed = RoutineExercise.fromJson(json);
      expect(reconstructed.id, exercise.id);
      expect(reconstructed.sets.length, 2);
    });

    test('Routine duration calculations and aggregate getters', () {
      const routine = Routine(
        id: 'routine-push',
        name: 'Push Day A',
        description: 'Chest, Shoulders & Triceps focus',
        exercises: [
          RoutineExercise(
            id: 're-1',
            routineId: 'routine-push',
            exerciseId: 'ex-bench',
            orderIndex: 0,
            restSeconds: 90,
            targetSetsCount: 3, // 3 sets: 3 * 45s work = 135s, 2 rests * 90s = 180s -> 315s
          ),
          RoutineExercise(
            id: 're-2',
            routineId: 'routine-push',
            exerciseId: 'ex-ohp',
            orderIndex: 1,
            restSeconds: 60,
            targetSetsCount: 3, // 3 sets: 3 * 45s work = 135s, 2 rests * 60s = 120s -> 255s
          ),
        ],
      );

      expect(routine.exerciseCount, 2);
      expect(routine.totalSets, 6);
      // Total duration: 315s + 255s = 570 seconds = 9.5 minutes -> ceil = 10 minutes
      expect(routine.estimatedDurationSeconds, 570);
      expect(routine.estimatedDurationMinutes, 10);

      final json = routine.toJson();
      expect(json['id'], 'routine-push');
      expect(json['name'], 'Push Day A');
      expect((json['exercises'] as List).length, 2);

      final reconstructed = Routine.fromJson(json);
      expect(reconstructed.id, routine.id);
      expect(reconstructed.exercises.length, 2);
    });
  });

  group('Drift SQLite Routine Tables Integration', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('CRUD routines, exercises, sets with foreign key cascade deletion',
        () async {
      // 1. Seed prerequisite muscle group & exercise
      await db.into(db.muscleGroups).insert(
            const MuscleGroupsCompanion(
              id: Value('mg-chest'),
              name: Value('Chest'),
            ),
          );

      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: Value('ex-bench'),
              name: Value('Barbell Bench Press'),
              category: Value('CHEST'),
              equipment: Value('BARBELL'),
            ),
          );

      // 2. Insert Routine
      await db.into(db.routines).insert(
            const RoutinesCompanion(
              id: Value('r-1'),
              name: Value('Push Workout'),
              description: Value('Standard push routine'),
            ),
          );

      final fetchedRoutines = await db.select(db.routines).get();
      expect(fetchedRoutines.length, 1);
      expect(fetchedRoutines.first.name, 'Push Workout');

      // 3. Insert RoutineExercise
      await db.into(db.routineExercises).insert(
            const RoutineExercisesCompanion(
              id: Value('re-1'),
              routineId: Value('r-1'),
              exerciseId: Value('ex-bench'),
              orderIndex: Value(0),
              restSeconds: Value(90),
              targetSetsCount: Value(3),
              targetWeightKg: Value(80.0),
              targetReps: Value(8),
            ),
          );

      final fetchedExercises = await db.select(db.routineExercises).get();
      expect(fetchedExercises.length, 1);
      expect(fetchedExercises.first.routineId, 'r-1');
      expect(fetchedExercises.first.targetWeightKg, 80.0);

      // 4. Insert RoutineSets
      await db.into(db.routineSets).insert(
            const RoutineSetsCompanion(
              id: Value('rs-1'),
              routineExerciseId: Value('re-1'),
              position: Value(1),
              setType: Value('normal'),
              targetReps: Value(8),
              targetWeightKg: Value(80.0),
            ),
          );

      await db.into(db.routineSets).insert(
            const RoutineSetsCompanion(
              id: Value('rs-2'),
              routineExerciseId: Value('re-1'),
              position: Value(2),
              setType: Value('normal'),
              targetReps: Value(8),
              targetWeightKg: Value(80.0),
            ),
          );

      final fetchedSets = await db.select(db.routineSets).get();
      expect(fetchedSets.length, 2);

      // 5. Verify Cascade Deletion (Law L7)
      // Deleting the routine must cascade and delete routine exercises and routine sets
      await (db.delete(db.routines)..where((t) => t.id.equals('r-1'))).go();

      final remainingRoutines = await db.select(db.routines).get();
      final remainingExercises = await db.select(db.routineExercises).get();
      final remainingSets = await db.select(db.routineSets).get();

      expect(remainingRoutines, isEmpty);
      expect(remainingExercises, isEmpty);
      expect(remainingSets, isEmpty);
    });
  });
}
