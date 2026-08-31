import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/routine/data/routine_local_source.dart';
import 'package:aven_fit/features/routine/data/routine_repository.dart';
import 'package:aven_fit/features/routine/domain/routine_exercise.dart';
import 'package:aven_fit/features/routine/domain/routine_set.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RoutineDao dao;
  late RoutineRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.routineDao;
    repo = RoutineRepositoryImpl(dao);

    // Seed test exercises
    await db.into(db.muscleGroups).insert(
          const MuscleGroupsCompanion(
            id: Value('mg-chest'),
            name: Value('Chest'),
          ),
        );
    await db.into(db.muscleGroups).insert(
          const MuscleGroupsCompanion(
            id: Value('mg-shoulders'),
            name: Value('Shoulders'),
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
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: Value('ex-ohp'),
            name: Value('Overhead Press'),
            category: Value('SHOULDERS'),
            equipment: Value('BARBELL'),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('RoutineDao with In-Memory Drift SQLite', () {
    test('Create routine with exercises and sets, and query via getAllRoutines',
        () async {
      await dao.createRoutine(
        routine: const RoutinesCompanion(
          id: Value('r-push'),
          name: Value('Push Workout'),
          description: Value('Chest and shoulders'),
        ),
        exercisesList: const [
          RoutineExercisesCompanion(
            id: Value('re-1'),
            routineId: Value('r-push'),
            exerciseId: Value('ex-bench'),
            orderIndex: Value(0),
            restSeconds: Value(120),
            targetSetsCount: Value(3),
            targetWeightKg: Value(80.0),
            targetReps: Value(8),
          ),
          RoutineExercisesCompanion(
            id: Value('re-2'),
            routineId: Value('r-push'),
            exerciseId: Value('ex-ohp'),
            orderIndex: Value(1),
            restSeconds: Value(90),
            targetSetsCount: Value(3),
            targetWeightKg: Value(50.0),
            targetReps: Value(10),
          ),
        ],
        setsList: const [
          RoutineSetsCompanion(
            id: Value('rs-1'),
            routineExerciseId: Value('re-1'),
            position: Value(1),
            setType: Value('normal'),
            targetReps: Value(8),
            targetWeightKg: Value(80.0),
          ),
          RoutineSetsCompanion(
            id: Value('rs-2'),
            routineExerciseId: Value('re-1'),
            position: Value(2),
            setType: Value('normal'),
            targetReps: Value(8),
            targetWeightKg: Value(80.0),
          ),
        ],
      );

      final routines = await dao.getAllRoutines();
      expect(routines.length, 1);
      expect(routines.first.routine.name, 'Push Workout');
      expect(routines.first.exercises.length, 2);
      expect(routines.first.exercises[0].exercise?.name, 'Barbell Bench Press');
      expect(routines.first.exercises[0].sets.length, 2);
      expect(routines.first.exercises[1].exercise?.name, 'Overhead Press');
    });

    test('Reorder exercises updates orderIndex in SQLite', () async {
      await dao.createRoutine(
        routine: const RoutinesCompanion(
          id: Value('r-1'),
          name: Value('Push Workout'),
        ),
        exercisesList: const [
          RoutineExercisesCompanion(
            id: Value('re-bench'),
            routineId: Value('r-1'),
            exerciseId: Value('ex-bench'),
            orderIndex: Value(0),
          ),
          RoutineExercisesCompanion(
            id: Value('re-ohp'),
            routineId: Value('r-1'),
            exerciseId: Value('ex-ohp'),
            orderIndex: Value(1),
          ),
        ],
      );

      // Reorder OHP first, Bench second
      await dao.reorderExercises('r-1', ['re-ohp', 're-bench']);

      final routine = await dao.getRoutineById('r-1');
      expect(routine, isNotNull);
      expect(routine!.exercises[0].routineExercise.id, 're-ohp');
      expect(routine.exercises[0].routineExercise.orderIndex, 0);
      expect(routine.exercises[1].routineExercise.id, 're-bench');
      expect(routine.exercises[1].routineExercise.orderIndex, 1);
    });

    test('Duplicate routine creates an independent clone (Law L7)', () async {
      await dao.createRoutine(
        routine: const RoutinesCompanion(
          id: Value('r-original'),
          name: Value('Upper Body'),
        ),
        exercisesList: const [
          RoutineExercisesCompanion(
            id: Value('re-orig-1'),
            routineId: Value('r-original'),
            exerciseId: Value('ex-bench'),
            orderIndex: Value(0),
          ),
        ],
        setsList: const [
          RoutineSetsCompanion(
            id: Value('rs-orig-1'),
            routineExerciseId: Value('re-orig-1'),
            position: Value(1),
            targetReps: Value(8),
            targetWeightKg: Value(85.0),
          ),
        ],
      );

      final clonedId = await dao.duplicateRoutine(
        'r-original',
        newName: 'Upper Body (Duplicate)',
      );

      expect(clonedId, isNot('r-original'));

      final cloned = await dao.getRoutineById(clonedId);
      expect(cloned, isNotNull);
      expect(cloned!.routine.name, 'Upper Body (Duplicate)');
      expect(cloned.exercises.length, 1);
      expect(cloned.exercises.first.sets.length, 1);
      expect(cloned.exercises.first.sets.first.targetWeightKg, 85.0);

      // Mutating clone must not affect original
      await dao.deleteRoutine(clonedId);
      final originalAfterCloneDelete = await dao.getRoutineById('r-original');
      expect(originalAfterCloneDelete, isNotNull);
      expect(originalAfterCloneDelete!.exercises.length, 1);
    });
  });

  group('RoutineRepository Operations', () {
    test('createRoutine, watchAllRoutines, updateRoutine, and deleteRoutine',
        () async {
      // 1. Create Routine via Repository
      final created = await repo.createRoutine(
        name: 'PPL - Push Day',
        description: 'Heavy bench and overhead press',
        exercises: const [
          RoutineExercise(
            id: 're-p1',
            routineId: '',
            exerciseId: 'ex-bench',
            restSeconds: 120,
            targetSetsCount: 3,
            targetWeightKg: 80.0,
            targetReps: 8,
            sets: [
              RoutineSet(
                id: 'rs-p1-1',
                routineExerciseId: 're-p1',
                position: 1,
                setType: SetType.warmup,
                targetReps: 12,
                targetWeightKg: 40.0,
              ),
              RoutineSet(
                id: 'rs-p1-2',
                routineExerciseId: 're-p1',
                position: 2,
                setType: SetType.normal,
                targetReps: 8,
                targetWeightKg: 80.0,
              ),
            ],
          ),
        ],
      );

      expect(created.name, 'PPL - Push Day');
      expect(created.exercises.length, 1);
      expect(created.exercises.first.exercise?.name, 'Barbell Bench Press');
      expect(created.exercises.first.sets.length, 2);
      expect(created.exercises.first.sets[0].setType, SetType.warmup);

      // 2. Stream routines via watchAllRoutines
      final allRoutines = await repo.watchAllRoutines().first;
      expect(allRoutines.length, 1);
      expect(allRoutines.first.name, 'PPL - Push Day');

      // 3. Add second exercise
      final addedEx = await repo.addExerciseToRoutine(
        routineId: created.id,
        exerciseId: 'ex-ohp',
        restSeconds: 90,
        targetSetsCount: 3,
        targetReps: 10,
        targetWeightKg: 45.0,
      );

      expect(addedEx.exerciseId, 'ex-ohp');

      final updatedRoutine = await repo.getRoutineById(created.id);
      expect(updatedRoutine!.exercises.length, 2);
      expect(updatedRoutine.totalSets, 5); // 2 sets + 3 sets

      // 4. Update routine metadata
      final edited = updatedRoutine.copyWith(
        name: 'PPL - Heavy Push A',
        description: 'Updated description',
      );
      await repo.updateRoutine(edited);

      final fetchedEdited = await repo.getRoutineById(created.id);
      expect(fetchedEdited!.name, 'PPL - Heavy Push A');

      // 5. Delete routine
      final deleted = await repo.deleteRoutine(created.id);
      expect(deleted, isTrue);

      final emptyList = await repo.getAllRoutines();
      expect(emptyList, isEmpty);
    });
  });
}
