import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_session.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_controller.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Workout Domain Entities', () {
    test('WorkoutSet immutability and copyWith', () {
      const set = WorkoutSet(
        id: 's1',
        sessionId: 'ws1',
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
    });

    test('WorkoutSession JSON serialization round-trip', () {
      final session = WorkoutSession(
        id: 'ws_test',
        name: 'Push Day',
        startedAt: DateTime.parse('2026-08-31T05:00:00Z'),
        status: WorkoutStatus.active,
        sets: const [
          WorkoutSet(
            id: 's1',
            sessionId: 'ws_test',
            exerciseId: 'bench',
            setNumber: 1,
            weightKg: 100.0,
            reps: 5,
            isCompleted: true,
          ),
        ],
      );

      final json = session.toJson();
      final deserialized = WorkoutSession.fromJson(json);

      expect(deserialized.id, session.id);
      expect(deserialized.name, 'Push Day');
      expect(deserialized.sets.length, 1);
      expect(deserialized.sets.first.weightKg, 100.0);
    });

    test('ActiveWorkoutState volume calculation excludes warmup sets', () {
      const state = ActiveWorkoutState(
        session: null,
        sets: [
          WorkoutSet(
            id: 's1',
            sessionId: 'ws1',
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

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = WorkoutRepositoryImpl(db.workoutDao);
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

      const newSet = WorkoutSet(
        id: 'set_1',
        sessionId: 'ws_placeholder',
        exerciseId: 'squat',
        setNumber: 1,
        weightKg: 100.0,
        reps: 5,
        isCompleted: false,
      );

      final setWithSession = newSet.copyWith(sessionId: session.id);
      await repository.logSet(setWithSession);

      var sets = await repository.getSetsForSession(session.id);
      expect(sets.length, 1);
      expect(sets.first.isCompleted, isFalse);

      // Toggle complete
      await repository.updateSet(setWithSession.copyWith(isCompleted: true));
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

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = WorkoutRepositoryImpl(db.workoutDao);
      container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('startWorkout and addSet update controller state immutably', () async {
      final controller = container.read(activeWorkoutControllerProvider.notifier);

      // Initially no session
      var state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.hasActiveSession, isFalse);

      // Start workout
      await controller.startWorkout(name: 'Upper Body A');
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.hasActiveSession, isTrue);
      expect(state.session!.name, 'Upper Body A');

      // Add set
      await controller.addSet(
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
      expect(state.isRestTimerRunning, isTrue);

      // Rest timer adjustments
      controller.addRestTime(15);
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.restTimerRemainingSeconds, 105);

      controller.stopRestTimer();
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.isRestTimerRunning, isFalse);

      // Finish workout
      await controller.finishWorkout();
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.hasActiveSession, isFalse);
    });
  });
}
