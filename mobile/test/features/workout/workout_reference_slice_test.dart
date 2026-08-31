import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/notifications/notification_service.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/session_exercise.dart';
import 'package:aven_fit/features/workout/domain/workout_session.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_controller.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_state.dart';
import 'package:aven_fit/features/workout/presentation/rest_timer_controller.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_notification_service.dart';

void main() {
  group('Workout Domain Entities', () {
    test('WorkoutSet immutability and copyWith', () {
      const set = WorkoutSet(
        id: 's1',
        sessionId: 'ws1',
        sessionExerciseId: 'se1',
        exerciseId: 'ex1',
        setNumber: 1,
        weightKg: 80.0,
        reps: 8,
        isCompleted: false,
        type: SetType.normal,
      );

      final completedSet = set.copyWith(isCompleted: true);

      expect(set.isCompleted, isFalse);
      expect(completedSet.isCompleted, isTrue);
      expect(completedSet.weightKg, 80.0);
      expect(completedSet.sessionExerciseId, 'se1');
    });

    test('SessionExercise and WorkoutSession JSON serialization round-trip', () {
      final session = WorkoutSession(
        id: 'ws_test',
        name: 'Push Day',
        startedAt: DateTime.parse('2026-08-31T05:00:00Z'),
        status: WorkoutStatus.active,
        exercises: const [
          SessionExercise(
            id: 'se1',
            sessionId: 'ws_test',
            exerciseId: 'bench',
            orderIndex: 0,
            sets: [
              WorkoutSet(
                id: 's1',
                sessionId: 'ws_test',
                sessionExerciseId: 'se1',
                exerciseId: 'bench',
                setNumber: 1,
                weightKg: 100.0,
                reps: 5,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );

      final json = session.toJson();
      final deserialized = WorkoutSession.fromJson(json);

      expect(deserialized.id, session.id);
      expect(deserialized.name, 'Push Day');
      expect(deserialized.exercises.length, 1);
      expect(deserialized.exercises.first.sets.first.weightKg, 100.0);
      expect(deserialized.totalSetsCount, 1);
      expect(deserialized.completedSetsCount, 1);
      expect(deserialized.totalVolumeKg, 500.0);
    });

    test('ActiveWorkoutState volume calculation excludes warmup sets', () {
      const state = ActiveWorkoutState(
        session: null,
        sets: [
          WorkoutSet(
            id: 's1',
            sessionId: 'ws1',
            sessionExerciseId: 'se1',
            exerciseId: 'bench',
            setNumber: 1,
            weightKg: 40.0,
            reps: 10,
            isCompleted: true,
            type: SetType.warmup, // 400kg warmup
          ),
          WorkoutSet(
            id: 's2',
            sessionId: 'ws1',
            sessionExerciseId: 'se1',
            exerciseId: 'bench',
            setNumber: 2,
            weightKg: 80.0,
            reps: 8,
            isCompleted: true,
            type: SetType.normal, // 640kg working
          ),
          WorkoutSet(
            id: 's3',
            sessionId: 'ws1',
            sessionExerciseId: 'se1',
            exerciseId: 'bench',
            setNumber: 3,
            weightKg: 80.0,
            reps: 8,
            isCompleted: false, // uncompleted
            type: SetType.normal,
          ),
        ],
      );

      expect(state.completedSetsCount, 2);
      expect(state.totalVolumeKg, 640.0); // Warmup set excluded per Law L1
    });
  });

  group('WorkoutRepository with in-memory Drift SQLite', () {
    late AppDatabase db;
    late WorkoutRepository repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = WorkoutRepositoryImpl(db.workoutDao);
      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('squat'),
              name: drift.Value('Barbell Back Squat'),
            ),
          );
      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('ex_bench'),
              name: drift.Value('Barbell Bench Press'),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('startWorkout creates active session and watchActiveSession streams it', () async {
      final initialSession = await repository.getActiveSession();
      expect(initialSession, isNull);

      final session = await repository.startWorkout(name: 'Chest & Triceps');
      expect(session.name, 'Chest & Triceps');
      expect(session.status, WorkoutStatus.active);

      final active = await repository.getActiveSession();
      expect(active, isNotNull);
      expect(active!.id, session.id);
      expect(active.status, WorkoutStatus.active);
    });

    test('logSet, updateSet, and deleteSet modify sets reactively', () async {
      final session = await repository.startWorkout(name: 'Leg Day');
      final sessionEx = await repository.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'squat',
      );

      final newSet = WorkoutSet(
        id: 'set_1',
        sessionId: session.id,
        sessionExerciseId: sessionEx.id,
        exerciseId: 'squat',
        setNumber: 1,
        weightKg: 100.0,
        reps: 5,
        isCompleted: false,
      );

      await repository.logSet(newSet);

      var sets = await repository.getSetsForSession(session.id);
      expect(sets.length, 1);
      expect(sets.first.isCompleted, isFalse);

      // Toggle complete
      await repository.updateSet(newSet.copyWith(isCompleted: true));
      sets = await repository.getSetsForSession(session.id);
      expect(sets.first.isCompleted, isTrue);

      // Delete set
      await repository.deleteSet('set_1');
      sets = await repository.getSetsForSession(session.id);
      expect(sets.isEmpty, isTrue);
    });

    test('finishWorkout marks session completed', () async {
      final session = await repository.startWorkout(name: 'Full Body');
      await repository.finishWorkout(session.id);

      final active = await repository.getActiveSession();
      expect(active, isNull);
    });

    test('cancelWorkout discards session', () async {
      final session = await repository.startWorkout(name: 'Cancelled');
      await repository.cancelWorkout(session.id);

      final active = await repository.getActiveSession();
      expect(active, isNull);
    });
  });

  group('ActiveWorkoutController Store / Presentation', () {
    late AppDatabase db;
    late WorkoutRepository repository;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = WorkoutRepositoryImpl(db.workoutDao);
      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('ex_bench'),
              name: drift.Value('Barbell Bench Press'),
            ),
          );
      container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(repository),
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('startWorkout, addExercise, and addSet update controller state immutably', () async {
      final controller = container.read(activeWorkoutControllerProvider.notifier);

      // Initially no session
      var state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.hasActiveSession, isFalse);

      // Start workout
      await controller.startWorkout(name: 'Upper Body A');
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.hasActiveSession, isTrue);
      expect(state.session!.name, 'Upper Body A');

      // Add exercise
      final ex = await controller.addExercise('ex_bench');
      expect(ex, isNotNull);
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.exercises.length, 1);
      expect(state.exerciseCount, 1);

      // Add set
      await controller.addSet(
        sessionExerciseId: ex!.id,
        exerciseId: 'ex_bench',
        weightKg: 80.0,
        reps: 8,
      );
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.sets.length, 1);
      expect(state.sets.first.weightKg, 80.0);
      expect(state.sets.first.reps, 8);
      expect(state.sets.first.isCompleted, isFalse);

      // Toggle complete
      await controller.toggleSetCompleted(state.sets.first.id);
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.sets.first.isCompleted, isTrue);
      expect(state.completedSetsCount, 1);

      // Rest timer auto-starts on set confirmation (§8.3, default 90s)
      final restTimer = container.read(restTimerControllerProvider);
      expect(restTimer.isRunning, isTrue);
      expect(restTimer.totalSeconds, 90);

      // Rest timer adjustments
      container.read(restTimerControllerProvider.notifier).addTime(15);
      expect(container.read(restTimerControllerProvider).remainingSeconds, 105);

      container.read(restTimerControllerProvider.notifier).cancel();
      expect(container.read(restTimerControllerProvider).isRunning, isFalse);

      // Finish workout
      await controller.finishWorkout();
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.hasActiveSession, isFalse);
    });
  });
}
