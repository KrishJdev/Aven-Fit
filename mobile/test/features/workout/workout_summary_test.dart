import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_session.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/features/workout/presentation/workout_summary_controller.dart';
import 'package:aven_fit/features/workout/presentation/workout_summary_screen.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('WorkoutSummaryController WU-3.7 Logic', () {
    late AppDatabase db;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      workoutRepo = WorkoutRepositoryImpl(db.workoutDao);

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

    /// Seeds a completed session with 1 warm-up + 2 working sets via the
    /// production repository, mirroring the real set-confirmation flow.
    Future<WorkoutSession> seedCompletedWorkout({
      String name = 'Chest Day',
      bool withPr = false,
    }) async {
      final session = await workoutRepo.startWorkout(name: name);
      final se = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_bench',
      );

      await workoutRepo.logSet(WorkoutSet(
        id: 'warm_${session.id}',
        sessionId: session.id,
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        setNumber: 1,
        weightKg: 20.0,
        reps: 10,
        isCompleted: true,
        type: SetType.warmup,
      ));
      await workoutRepo.logSet(WorkoutSet(
        id: 'w1_${session.id}',
        sessionId: session.id,
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        setNumber: 2,
        weightKg: 80.0,
        reps: 8,
        isCompleted: true,
      ));
      await workoutRepo.logSet(WorkoutSet(
        id: 'w2_${session.id}',
        sessionId: session.id,
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        setNumber: 3,
        weightKg: 82.5,
        reps: 8,
        isCompleted: true,
        isPr: withPr,
      ));

      await workoutRepo.finishWorkout(session.id);
      return session;
    }

    /// Seeds a bare completed session row directly through the DAO.
    Future<void> seedBareCompletedSession(
      String id,
      DateTime startedAt, {
      DateTime? completedAt,
      int? durationSeconds,
    }) async {
      await db.workoutDao.createSession(
        id: id,
        name: 'Session $id',
        startedAt: startedAt,
      );
      await db.workoutDao.completeSession(
        id,
        completedAt ?? startedAt.add(const Duration(hours: 1)),
        durationSeconds: durationSeconds,
      );
    }

    test('computes stats from persisted session; warm-ups excluded, PRs counted',
        () async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final session = await seedCompletedWorkout(withPr: true);
      final state =
          await container.read(workoutSummaryControllerProvider(session.id).future);

      expect(state.notFound, isFalse);
      expect(state.completedSetsCount, 3); // 1 warm-up + 2 working
      // Working volume excludes the 20x10 warm-up (L1): 80x8 + 82.5x8 = 1300
      expect(state.totalVolumeKg, 1300.0);
      expect(state.prCount, 1);
      expect(state.durationSeconds, greaterThanOrEqualTo(0));
      expect(state.exercises.first.exerciseName, 'Barbell Bench Press');

      container.dispose();
    });

    test('falls back to epoch math for duration when durationSeconds absent',
        () async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final started = DateTime(2026, 8, 31, 10, 0, 0);
      await seedBareCompletedSession(
        'ws_epoch',
        started,
        completedAt: started.add(const Duration(hours: 1, minutes: 5, seconds: 30)),
      );

      final state =
          await container.read(workoutSummaryControllerProvider('ws_epoch').future);
      expect(state.durationSeconds, 3930);

      container.dispose();
    });

    test('uses stored durationSeconds when present (epoch math still honors it)',
        () async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      await seedBareCompletedSession(
        'ws_stored',
        DateTime(2026, 8, 31, 10, 0, 0),
        durationSeconds: 2700,
      );

      final state =
          await container.read(workoutSummaryControllerProvider('ws_stored').future);
      expect(state.durationSeconds, 2700);

      container.dispose();
    });

    test('returns designed not-found state for a missing session (L6)', () async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final state =
          await container.read(workoutSummaryControllerProvider('missing_id').future);
      expect(state.notFound, isTrue);
      expect(state.session, isNull);

      container.dispose();
    });

    test('renameWorkout persists via write-through; blank falls back to Workout',
        () async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final session = await seedCompletedWorkout(name: 'Chest Day');
      // Keep the autoDispose provider alive across the read-mutate-read cycle.
      final sub = container.listen(
        workoutSummaryControllerProvider(session.id),
        (_, _) {},
      );
      await container.read(workoutSummaryControllerProvider(session.id).future);

      final controller = container.read(
        workoutSummaryControllerProvider(session.id).notifier,
      );

      await controller.renameWorkout('Pump Day');
      var state = await container.read(workoutSummaryControllerProvider(session.id).future);
      expect(state.session!.name, 'Pump Day');

      var persisted = await workoutRepo.getSessionById(session.id);
      expect(persisted!.name, 'Pump Day');

      // Blank submit falls back to 'Workout' (FEATURES.md §8.5)
      await controller.renameWorkout('   ');
      state = await container.read(workoutSummaryControllerProvider(session.id).future);
      expect(state.session!.name, 'Workout');

      persisted = await workoutRepo.getSessionById(session.id);
      expect(persisted!.name, 'Workout');

      sub.close();
      container.dispose();
    });

    test('weekly streak badge is met when 3+ workouts this week (incl. this one)',
        () async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final now = DateTime.now();
      await seedBareCompletedSession('ws_w1', now.subtract(const Duration(days: 1)));
      await seedBareCompletedSession('ws_w2', now.subtract(const Duration(hours: 3)));

      // One workout 8 days back — always outside the current week, never counts.
      await seedBareCompletedSession('ws_old', now.subtract(const Duration(days: 8)));

      final summarySession = await seedCompletedWorkout(name: 'Third This Week');

      final state = await container
          .read(workoutSummaryControllerProvider(summarySession.id).future);
      expect(state.weeklyWorkoutCount, 3);
      expect(state.weeklyGoalMet, isTrue);

      container.dispose();
    });

    test('weekly streak badge hidden when goal not met (adherence-neutral, L4)',
        () async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final summarySession = await seedCompletedWorkout();

      final state = await container
          .read(workoutSummaryControllerProvider(summarySession.id).future);
      expect(state.weeklyWorkoutCount, 1);
      expect(state.weeklyGoalMet, isFalse);

      container.dispose();
    });
  });

  group('WorkoutSummaryScreen Widget Tests', () {
    late AppDatabase db;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      workoutRepo = WorkoutRepositoryImpl(db.workoutDao);

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

    Future<WorkoutSession> seedWorkoutWithPR({
      String name = 'Chest Day',
    }) async {
      final session = await workoutRepo.startWorkout(name: name);
      final se = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_bench',
      );
      await workoutRepo.logSet(WorkoutSet(
        id: 'pr_${session.id}',
        sessionId: session.id,
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        setNumber: 1,
        weightKg: 100.0,
        reps: 5,
        isCompleted: true,
        isPr: true,
      ));
      await workoutRepo.finishWorkout(session.id);
      return session;
    }

    Future<void> seedExtraCompletedSession(String id, DateTime startedAt) async {
      await db.workoutDao.createSession(
        id: id,
        name: 'Session $id',
        startedAt: startedAt,
      );
      await db.workoutDao.completeSession(id, DateTime.now());
    }

    /// Monday 00:00 of the current week — same math as the controller.
    DateTime weekStart() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return today.subtract(Duration(days: today.weekday - DateTime.monday));
    }

    testWidgets('renders stats grid, exercise breakdown, PR badge, streak badge',
        (tester) async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final session = await seedWorkoutWithPR(name: 'Push Power');
      // Two extra completed workouts this week → goal (3) met.
      await seedExtraCompletedSession(
          'ws_extra1', weekStart().add(const Duration(hours: 9)));
      await seedExtraCompletedSession(
          'ws_extra2', weekStart().add(const Duration(hours: 10)));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: WorkoutSummaryScreen(sessionId: session.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Push Power'), findsOneWidget);
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('WORKING VOLUME'), findsOneWidget);
      expect(find.text('SETS'), findsOneWidget);
      expect(find.text('PRS'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      // PR chip on the set row + PR stat tile at 1
      expect(find.text('PR'), findsOneWidget);
      expect(find.textContaining('WEEKLY GOAL MET'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);

      container.dispose();
    });

    testWidgets('hides streak badge when weekly goal not met', (tester) async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final session = await seedWorkoutWithPR(name: 'Solo Session');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: WorkoutSummaryScreen(sessionId: session.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('WEEKLY GOAL MET'), findsNothing);

      container.dispose();
    });

    testWidgets('inline rename saves via dialog; blank falls back to Workout',
        (tester) async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final session = await seedWorkoutWithPR(name: 'Rename Me');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: WorkoutSummaryScreen(sessionId: session.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open rename dialog via the pencil affordance
      await tester.tap(find.text('Rename Me'));
      await tester.pumpAndSettle();
      expect(find.text('RENAME WORKOUT'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Leg Day Blast');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('Leg Day Blast'), findsOneWidget);
      final persisted = await workoutRepo.getSessionById(session.id);
      expect(persisted!.name, 'Leg Day Blast');

      // Blank submit falls back to 'Workout' (§8.5)
      await tester.tap(find.text('Leg Day Blast'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('Workout'), findsOneWidget);

      container.dispose();
    });

    testWidgets('shows designed not-found state with a way back (L6)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: WorkoutSummaryScreen(sessionId: 'nope_missing'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WORKOUT NOT FOUND'), findsOneWidget);
      expect(find.text('BACK TO HOME'), findsOneWidget);

      container.dispose();
    });

    testWidgets('DONE navigates to Home (FEATURES.md §8.5)', (tester) async {
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(workoutRepo)],
      );

      final session = await seedWorkoutWithPR(name: 'Navigation Test');

      final router = GoRouter(
        initialLocation: '/workout/summary/${session.id}',
        routes: [
          GoRoute(
            path: '/workout/summary/:id',
            builder: (context, state) =>
                WorkoutSummaryScreen(sessionId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('HOME_SCREEN')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('DONE'));
      await tester.pumpAndSettle();

      expect(find.text('HOME_SCREEN'), findsOneWidget);

      container.dispose();
    });
  });
}
