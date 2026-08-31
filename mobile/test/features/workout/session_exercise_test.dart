import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/routine/data/routine_repository.dart';
import 'package:aven_fit/features/routine/domain/routine_exercise.dart';
import 'package:aven_fit/features/routine/domain/routine_set.dart';
import 'package:aven_fit/features/routine/presentation/routine_detail_controller.dart';
import 'package:aven_fit/features/workout/data/workout_local_source.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/session_exercise.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionExercise Domain Model', () {
    test('SessionExercise immutability, volume, and setsCount calculations', () {
      const exercise = SessionExercise(
        id: 'se_1',
        sessionId: 'ws_1',
        exerciseId: 'bench_press',
        exerciseName: 'Barbell Bench Press',
        orderIndex: 0,
        restSeconds: 120,
        sets: [
          WorkoutSet(
            id: 'set_1',
            sessionId: 'ws_1',
            sessionExerciseId: 'se_1',
            exerciseId: 'bench_press',
            setNumber: 1,
            weightKg: 40.0,
            reps: 10,
            isCompleted: true,
            type: SetType.warmup,
          ),
          WorkoutSet(
            id: 'set_2',
            sessionId: 'ws_1',
            sessionExerciseId: 'se_1',
            exerciseId: 'bench_press',
            setNumber: 2,
            weightKg: 80.0,
            reps: 8,
            isCompleted: true,
            type: SetType.normal,
          ),
          WorkoutSet(
            id: 'set_3',
            sessionId: 'ws_1',
            sessionExerciseId: 'se_1',
            exerciseId: 'bench_press',
            setNumber: 3,
            weightKg: 85.0,
            reps: 6,
            isCompleted: false,
            type: SetType.normal,
          ),
        ],
      );

      expect(exercise.position, 0);
      expect(exercise.setsCount, 3);
      expect(exercise.completedSetsCount, 2);
      // Volume excludes warmup set (40 * 10 = 400 excluded; 80 * 8 = 640 counted)
      expect(exercise.totalVolumeKg, 640.0);

      final updated = exercise.copyWith(orderIndex: 2);
      expect(exercise.orderIndex, 0);
      expect(updated.orderIndex, 2);
    });

    test('SessionExercise JSON serialization round-trip', () {
      const exercise = SessionExercise(
        id: 'se_100',
        sessionId: 'ws_100',
        exerciseId: 'incline_db_press',
        exerciseName: 'Incline Dumbbell Press',
        orderIndex: 1,
        restSeconds: 90,
        notes: '30 degree incline',
        sets: [
          WorkoutSet(
            id: 'set_101',
            sessionId: 'ws_100',
            sessionExerciseId: 'se_100',
            exerciseId: 'incline_db_press',
            setNumber: 1,
            weightKg: 30.0,
            reps: 10,
            isCompleted: true,
          ),
        ],
      );

      final json = exercise.toJson();
      final fromJson = SessionExercise.fromJson(json);

      expect(fromJson.id, exercise.id);
      expect(fromJson.sessionId, exercise.sessionId);
      expect(fromJson.exerciseId, exercise.exerciseId);
      expect(fromJson.exerciseName, 'Incline Dumbbell Press');
      expect(fromJson.orderIndex, 1);
      expect(fromJson.notes, '30 degree incline');
      expect(fromJson.sets.length, 1);
      expect(fromJson.sets.first.weightKg, 30.0);
    });
  });

  group('Session-Exercise Data Layer with SQLite In-Memory', () {
    late AppDatabase db;
    late WorkoutDao workoutDao;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      workoutDao = db.workoutDao;
      workoutRepo = WorkoutRepositoryImpl(workoutDao);

      // Seed standard exercises for FK references
      await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              id: 'ex_bench',
              name: 'Barbell Bench Press',
              category: const drift.Value('CHEST'),
              equipment: const drift.Value('BARBELL'),
            ),
          );
      await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              id: 'ex_squat',
              name: 'Barbell Back Squat',
              category: const drift.Value('LEGS'),
              equipment: const drift.Value('BARBELL'),
            ),
          );
      await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              id: 'ex_overhead_press',
              name: 'Overhead Press',
              category: const drift.Value('SHOULDERS'),
              equipment: const drift.Value('BARBELL'),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('addExerciseToSession and watchSessionExercisesWithSets stream joined data', () async {
      final session = await workoutRepo.startWorkout(name: 'Push Workout');

      final se1 = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_bench',
        restSeconds: 120,
        notes: 'Focus on arch',
      );

      final se2 = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_overhead_press',
        restSeconds: 90,
      );

      expect(se1.exerciseId, 'ex_bench');
      expect(se1.exerciseName, 'Barbell Bench Press');
      expect(se1.orderIndex, 0);
      expect(se1.restSeconds, 120);

      expect(se2.exerciseId, 'ex_overhead_press');
      expect(se2.orderIndex, 1);

      // Add sets
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'set_b1',
          sessionId: session.id,
          sessionExerciseId: se1.id,
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 80.0,
          reps: 8,
          isCompleted: true,
        ),
      );

      await workoutRepo.logSet(
        WorkoutSet(
          id: 'set_b2',
          sessionId: session.id,
          sessionExerciseId: se1.id,
          exerciseId: 'ex_bench',
          setNumber: 2,
          weightKg: 85.0,
          reps: 6,
          isCompleted: false,
        ),
      );

      final exercises = await workoutRepo.getSessionExercises(session.id);
      expect(exercises.length, 2);
      expect(exercises[0].exerciseId, 'ex_bench');
      expect(exercises[0].sets.length, 2);
      expect(exercises[0].completedSetsCount, 1);
      expect(exercises[0].totalVolumeKg, 640.0);

      expect(exercises[1].exerciseId, 'ex_overhead_press');
      expect(exercises[1].sets.isEmpty, true);

      // Verify full session query with exercises
      final fullSession = await workoutRepo.getActiveSession();
      expect(fullSession, isNotNull);
      expect(fullSession!.exercises.length, 2);
      expect(fullSession.totalSetsCount, 2);
      expect(fullSession.completedSetsCount, 1);
      expect(fullSession.totalVolumeKg, 640.0);
    });

    test('reorderSessionExercises reorders exercises safely without unique constraint collision', () async {
      final session = await workoutRepo.startWorkout(name: 'Leg Day');

      final se1 = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_squat',
      );
      final se2 = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_bench',
      );
      final se3 = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_overhead_press',
      );

      var list = await workoutRepo.getSessionExercises(session.id);
      expect(list.map((e) => e.id).toList(), [se1.id, se2.id, se3.id]);

      // Reorder to: [se3, se1, se2]
      await workoutRepo.reorderSessionExercises(session.id, [se3.id, se1.id, se2.id]);

      list = await workoutRepo.getSessionExercises(session.id);
      expect(list.map((e) => e.id).toList(), [se3.id, se1.id, se2.id]);
      expect(list[0].orderIndex, 0);
      expect(list[1].orderIndex, 1);
      expect(list[2].orderIndex, 2);
    });

    test('removeExerciseFromSession cascade deletes associated workout sets in SQLite', () async {
      final session = await workoutRepo.startWorkout(name: 'Test Delete');
      final se1 = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_bench',
      );

      await workoutRepo.logSet(
        WorkoutSet(
          id: 'set_del_1',
          sessionId: session.id,
          sessionExerciseId: se1.id,
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 70.0,
          reps: 10,
        ),
      );

      var sets = await workoutRepo.getSetsForSession(session.id);
      expect(sets.length, 1);

      // Remove session exercise
      await workoutRepo.removeExerciseFromSession(se1.id);

      final exercises = await workoutRepo.getSessionExercises(session.id);
      expect(exercises.isEmpty, true);

      // Verify cascade deleted sets
      sets = await workoutRepo.getSetsForSession(session.id);
      expect(sets.isEmpty, true);
    });

    test('RoutineDetailController startWorkout preloads SessionExercises and sets', () async {
      final routineRepo = RoutineRepositoryImpl(db.routineDao);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
          routineRepositoryProvider.overrideWithValue(routineRepo),
        ],
      );

      // Create a test routine
      final routine = await routineRepo.createRoutine(
        name: 'Full Body A',
        exercises: const [
          RoutineExercise(
            id: 're_bench',
            routineId: '',
            exerciseId: 'ex_bench',
            targetSetsCount: 3,
            targetWeightKg: 80.0,
            targetReps: 8,
            sets: [
              RoutineSet(
                id: 'rs_1',
                routineExerciseId: 're_bench',
                position: 1,
                targetWeightKg: 80.0,
                targetReps: 8,
              ),
              RoutineSet(
                id: 'rs_2',
                routineExerciseId: 're_bench',
                position: 2,
                targetWeightKg: 82.5,
                targetReps: 6,
              ),
            ],
          ),
        ],
      );

      final controller =
          container.read(routineDetailControllerProvider(routine.id).notifier);
      final session = await controller.startWorkout();

      expect(session, isNotNull);
      expect(session!.name, 'Full Body A');
      expect(session.routineId, routine.id);

      final sessionExercises = await workoutRepo.getSessionExercises(session.id);
      expect(sessionExercises.length, 1);
      expect(sessionExercises.first.exerciseId, 'ex_bench');
      expect(sessionExercises.first.sets.length, 2);
      expect(sessionExercises.first.sets[0].weightKg, 80.0);
      expect(sessionExercises.first.sets[0].reps, 8);
      expect(sessionExercises.first.sets[1].weightKg, 82.5);
      expect(sessionExercises.first.sets[1].reps, 6);

      container.dispose();
    });
  });
}
