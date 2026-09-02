import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/notifications/notification_service.dart';
import 'package:aven_fit/core/services/workout_foreground_service.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_session.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_controller.dart';
import 'package:aven_fit/features/workout/presentation/home_screen.dart';
import 'package:aven_fit/features/workout/presentation/widgets/session_conflict_dialog.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'fake_notification_service.dart';

/// Test double for the Android foreground service.
class _TestForegroundService extends WorkoutForegroundService {
  int stopCalls = 0;

  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

/// Real [WorkoutRepository] for every read; the finish write-through is
/// scriptable so the §8.1 save-error path can be forced deterministically.
class _FailingFinishRepository extends Mock implements WorkoutRepository {}

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = WorkoutRepositoryImpl(db.workoutDao);
  });

  tearDown(() async {
    await db.close();
  });

  /// Seeds an exercise, an active session, one exercise block, and two sets
  /// (1 completed + 1 planned) — the mid-workout force-kill snapshot.
  Future<WorkoutSession> seedActiveSnapshot({
    Duration startedAgo = const Duration(minutes: 10),
  }) async {
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: drift.Value('ex_bench'),
            name: drift.Value('Barbell Bench Press'),
          ),
        );
    final session = await repo.startWorkout(name: 'Crash Test');
    final se = await repo.addExerciseToSession(
      sessionId: session.id,
      exerciseId: 'ex_bench',
    );
    await repo.logSet(WorkoutSet(
      id: 'set_1',
      sessionId: session.id,
      sessionExerciseId: se.id,
      exerciseId: 'ex_bench',
      setNumber: 1,
      weightKg: 80,
      reps: 8,
      isCompleted: true,
      completedAt: DateTime.now(),
    ));
    await repo.logSet(WorkoutSet(
      id: 'set_2',
      sessionId: session.id,
      sessionExerciseId: se.id,
      exerciseId: 'ex_bench',
      setNumber: 2,
      weightKg: 82.5,
      reps: 6,
    ));

    // Backdate the session start so epoch math is observable.
    await (db.update(db.workoutSessions)
          ..where((t) => t.id.equals(session.id)))
        .write(WorkoutSessionsCompanion(
      startedAt: drift.Value(DateTime.now().subtract(startedAgo)),
    ));

    return (await repo.getActiveSession())!;
  }

  group('WorkoutSession epoch elapsed math (L8)', () {
    final start = DateTime(2026, 8, 31, 10, 0, 0);
    final at30min = start.add(const Duration(minutes: 30));

    test('running session: now − startedAt − pausedDuration', () {
      final session = WorkoutSession(id: 's', startedAt: start);
      expect(session.elapsedSecondsNow(at30min), 1800);
    });

    test('paused session: frozen at the lastResumedAt tick', () {
      final session = WorkoutSession(
        id: 's',
        startedAt: start,
        isPaused: true,
        lastResumedAt: start.add(const Duration(minutes: 12)),
      );
      // "now" moves on but the frozen value must not.
      expect(session.elapsedSecondsNow(at30min), 720);
      expect(
        session.elapsedSecondsNow(start.add(const Duration(hours: 5))),
        720,
      );
    });

    test('resumed session: accumulated pause span is excluded', () {
      final session = WorkoutSession(
        id: 's',
        startedAt: start,
        pausedDurationSeconds: 300, // paused 5 min total
      );
      expect(session.elapsedSecondsNow(at30min), 1500);
    });

    test('completed session prefers the stored durationSeconds', () {
      final session = WorkoutSession(
        id: 's',
        startedAt: start,
        status: WorkoutStatus.completed,
        completedAt: at30min,
        durationSeconds: 3600,
      );
      // Stored value wins over the epoch fallback even far in the future.
      expect(
        session.elapsedSecondsNow(start.add(const Duration(days: 2))),
        3600,
      );
    });

    test('completed without stored duration falls back to epoch math minus pauses',
        () {
      final session = WorkoutSession(
        id: 's',
        startedAt: start,
        status: WorkoutStatus.completed,
        completedAt: start.add(const Duration(minutes: 45)),
        pausedDurationSeconds: 300,
      );
      expect(session.elapsedSecondsNow(), 2400);
    });

    test('discarded session freezes so stale sessions never keep counting', () {
      final session = WorkoutSession(
        id: 's',
        startedAt: start,
        status: WorkoutStatus.discarded,
        lastResumedAt: start.add(const Duration(minutes: 3)),
      );
      expect(
        session.elapsedSecondsNow(start.add(const Duration(days: 7))),
        180,
      );
    });

    test('never negative', () {
      final session = WorkoutSession(
        id: 's',
        startedAt: start.add(const Duration(hours: 1)),
        pausedDurationSeconds: 10,
      );
      expect(session.elapsedSecondsNow(start), 0);
    });
  });

  group('Session pause / resume write-through (L7)', () {
    test('pause stamps the freeze point, resume folds the paused span',
        () async {
      final session = await repo.startWorkout(name: 'Pause Test');
      final pauseMoment = DateTime.now();

      // Freeze exactly 60s "ago" for a deterministic paused span.
      await db.workoutDao.pauseSession(
        session.id,
        pauseMoment.subtract(const Duration(seconds: 60)),
      );
      final pausedRow = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(session.id)))
          .getSingle();
      expect(pausedRow.isPaused, isTrue);
      expect(pausedRow.lastResumedAt, isNotNull);

      // While paused the domain elapsed time is frozen at the freeze point.
      final pausedSession = await repo.getActiveSession();
      expect(pausedSession!.isPaused, isTrue);
      final frozen = pausedSession.elapsedSecondsNow();
      expect(
        pausedSession
            .elapsedSecondsNow(DateTime.now().add(const Duration(hours: 1))),
        frozen,
      );

      await db.workoutDao.resumeSession(session.id, DateTime.now());
      final resumedRow = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(session.id)))
          .getSingle();
      expect(resumedRow.isPaused, isFalse);
      expect(resumedRow.lastResumedAt, isNull);
      expect(resumedRow.pausedDurationSeconds, inExclusiveRange(55, 70));
    });
  });

  group('Launch-time session restore (WU-3.8)', () {
    late FakeNotificationService notifications;
    late ProviderContainer container;

    setUp(() {
      notifications = FakeNotificationService();
      container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
      ]);
    });

    tearDown(() => container.dispose());

    test('build() restores the exact exercises, sets, and epoch elapsed time',
        () async {
      final session = await seedActiveSnapshot();
      final expectedElapsed = session.elapsedSecondsNow();

      // Keep the autoDispose controller alive across assertions.
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final state = await container.read(activeWorkoutControllerProvider.future);

      expect(state.wasRestored, isTrue);
      expect(state.session!.id, session.id);
      expect(state.exercises, hasLength(1));
      expect(state.exercises.first.exerciseName, 'Barbell Bench Press');
      expect(state.sets, hasLength(2));
      expect(state.completedSetsCount, 1);
      // Only the completed 80×8 counts toward working volume (set_2 is still
      // planned) — L1 working-volume semantics survive the restore.
      expect(state.totalVolumeKg, 640.0);
      expect(
        state.elapsedSeconds,
        inExclusiveRange(expectedElapsed - 2, expectedElapsed + 2),
      );
      sub.close();
    });

    test('build() with no active session yields a clean empty state', () async {
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final state = await container.read(activeWorkoutControllerProvider.future);

      expect(state.wasRestored, isFalse);
      expect(state.hasActiveSession, isFalse);
      expect(state.elapsedSeconds, 0);
      sub.close();
    });

    test('set confirmation persists to SQLite before the UI locks (L7)',
        () async {
      await seedActiveSnapshot();
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final controller =
          container.read(activeWorkoutControllerProvider.notifier);
      await container.read(activeWorkoutControllerProvider.future);

      await controller.toggleSetCompleted('set_2');

      // Direct SQLite read — the durable source of truth (L7).
      final row = await (db.select(db.workoutSets)
            ..where((t) => t.id.equals('set_2')))
          .getSingle();
      expect(row.isCompleted, isTrue);
      expect(row.completedAt, isNotNull);

      final state = container.read(activeWorkoutControllerProvider).value!;
      expect(state.completedSetsCount, 2);
      expect(state.sets.firstWhere((s) => s.id == 'set_2').isCompleted, isTrue);
      sub.close();
    });

    test('un-completing a set clears the PR flag and persists the revert',
        () async {
      await seedActiveSnapshot();
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final controller =
          container.read(activeWorkoutControllerProvider.notifier);
      await container.read(activeWorkoutControllerProvider.future);

      await controller.toggleSetCompleted('set_2'); // complete
      await controller.toggleSetCompleted('set_2'); // un-complete

      final row = await (db.select(db.workoutSets)
            ..where((t) => t.id.equals('set_2')))
          .getSingle();
      expect(row.isCompleted, isFalse);
      expect(row.isPr, isFalse);

      final state = container.read(activeWorkoutControllerProvider).value!;
      expect(state.completedSetsCount, 1);
      sub.close();
    });

    test('pause/resume through the controller write through to SQLite',
        () async {
      await seedActiveSnapshot();
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final controller =
          container.read(activeWorkoutControllerProvider.notifier);
      await container.read(activeWorkoutControllerProvider.future);

      await controller.pauseWorkout();
      var state = container.read(activeWorkoutControllerProvider).value!;
      expect(state.session!.isPaused, isTrue);
      var row = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(state.session!.id)))
          .getSingle();
      expect(row.isPaused, isTrue);

      await controller.resumeWorkout();
      state = container.read(activeWorkoutControllerProvider).value!;
      expect(state.session!.isPaused, isFalse);
      row = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(state.session!.id)))
          .getSingle();
      expect(row.isPaused, isFalse);
      sub.close();
    });

    test('finishWorkout stores the epoch-math duration including pauses',
        () async {
      await seedActiveSnapshot(startedAgo: const Duration(minutes: 5));
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final controller =
          container.read(activeWorkoutControllerProvider.notifier);
      await container.read(activeWorkoutControllerProvider.future);

      final session = await repo.getActiveSession();
      final finishedId = await controller.finishWorkout();
      expect(finishedId, session!.id);

      final row = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(session.id)))
          .getSingle();
      expect(row.status, 'completed');
      expect(row.durationSeconds, isNotNull);
      // ~5 minutes elapsed (±3s of test-execution drift).
      expect(row.durationSeconds!, inExclusiveRange(297, 303));
      sub.close();
    });
  });

  group('Finish save-error path (§8.1, L6/L7)', () {
    late FakeNotificationService notifications;
    late ProviderContainer container;
    late _FailingFinishRepository failingRepo;

    setUp(() {
      notifications = FakeNotificationService();
      failingRepo = _FailingFinishRepository();
      container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        workoutRepositoryProvider.overrideWithValue(failingRepo),
        notificationServiceProvider.overrideWithValue(notifications),
      ]);
    });

    tearDown(() => container.dispose());

    test('a failed finish keeps the session, sets, and error in state — '
        'retry completes the workout', () async {
      final session = await seedActiveSnapshot(
          startedAgo: const Duration(minutes: 23, seconds: 41));

      // Reads delegate to the real repository so the launch-time restore
      // sees the true snapshot; only the finish write-through fails.
      when(() => failingRepo.getActiveSession())
          .thenAnswer((_) => repo.getActiveSession());
      when(() => failingRepo.getSessionExercises(session.id))
          .thenAnswer((_) => repo.getSessionExercises(session.id));
      when(() => failingRepo.finishWorkout(
            session.id,
            durationSeconds: any(named: 'durationSeconds'),
          )).thenThrow(Exception('disk full'));

      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final restored =
          await container.read(activeWorkoutControllerProvider.future);
      expect(restored.sets, hasLength(2));

      final finishedId = await container
          .read(activeWorkoutControllerProvider.notifier)
          .finishWorkout();

      // The save reported failure — but nothing was lost: the state keeps
      // the session and every set, the row is still active in SQLite, and
      // the error is surfaced for the designed RETRY (L6/L7).
      expect(finishedId, isNull);
      final state = container.read(activeWorkoutControllerProvider).value!;
      expect(state.hasActiveSession, isTrue);
      expect(state.session!.id, session.id);
      expect(state.sets, hasLength(2));
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, isNotNull);
      final stillActive = await repo.getActiveSession();
      expect(stillActive, isNotNull);
      expect(stillActive!.id, session.id);

      // RETRY with the write-through healthy completes the workout — the
      // stub forwards to the real repository so SQLite is truth (L7).
      when(() => failingRepo.finishWorkout(
            session.id,
            durationSeconds: any(named: 'durationSeconds'),
          )).thenAnswer((inv) => repo.finishWorkout(
            session.id,
            durationSeconds: inv.namedArguments[#durationSeconds] as int?,
          ));
      final retriedId = await container
          .read(activeWorkoutControllerProvider.notifier)
          .finishWorkout();
      expect(retriedId, session.id);
      expect(await repo.getActiveSession(), isNull);
      sub.close();
    });
  });

  group('One-session conflict rule (§8.1)', () {
    late FakeNotificationService notifications;
    late _TestForegroundService foreground;

    Future<void> pumpHarness(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const _ConflictHarness(),
          ),
          GoRoute(
            path: '/workout/active',
            builder: (_, _) =>
                const Text('ACTIVE SCREEN', key: ValueKey('active_stub')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationServiceProvider.overrideWithValue(notifications),
            workoutForegroundServiceProvider.overrideWithValue(foreground),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      notifications = FakeNotificationService();
      foreground = _TestForegroundService();
    });

    testWidgets('proceeds immediately when no session is active', (tester) async {
      await pumpHarness(tester);
      await tester.tap(find.byKey(const ValueKey('conflict_trigger')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('conflict_result_true')), findsOneWidget);
      expect(find.text('SESSION IN PROGRESS'), findsNothing);
    });

    testWidgets('SAVE AS COMPLETED finishes the active session, stops foreground service, and proceeds',
        (tester) async {
      final session = await seedActiveSnapshot();
      await pumpHarness(tester);

      await tester.tap(find.byKey(const ValueKey('conflict_trigger')));
      await tester.pumpAndSettle();
      expect(find.text('SESSION IN PROGRESS'), findsOneWidget);

      await tester
          .tap(find.byKey(const ValueKey('conflict_save_completed')));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('conflict_result_true')), findsOneWidget);
      expect(foreground.stopCalls, 1);
      final row = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(session.id)))
          .getSingle();
      expect(row.status, 'completed');
      expect(row.durationSeconds, isNotNull);
    });

    testWidgets('DISCARD requires a destructive confirm (L7), stops foreground service, then discards',
        (tester) async {
      final session = await seedActiveSnapshot();
      await pumpHarness(tester);

      await tester.tap(find.byKey(const ValueKey('conflict_trigger')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('conflict_discard')));
      await tester.pumpAndSettle();

      // KEEP (cancel) → the rule blocks the new session start.
      await tester.tap(find.text('KEEP'));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('conflict_result_false')), findsOneWidget);
      expect(foreground.stopCalls, 0);

      // Retry and confirm the discard this time.
      await tester.tap(find.byKey(const ValueKey('conflict_trigger')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('conflict_discard')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DISCARD'));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('conflict_result_true')), findsOneWidget);
      expect(foreground.stopCalls, 1);
      final row = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(session.id)))
          .getSingle();
      expect(row.status, 'discarded');
    });

    testWidgets('RESUME navigates to the active workout and blocks the start',
        (tester) async {
      await seedActiveSnapshot();
      await pumpHarness(tester);

      await tester.tap(find.byKey(const ValueKey('conflict_trigger')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('conflict_resume')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('active_stub')), findsOneWidget);
    });
  });

  group('Home resume banner (§7.1)', () {
    late FakeNotificationService notifications;

    setUp(() {
      notifications = FakeNotificationService();
    });

    Future<void> pumpHome(WidgetTester tester) async {
      // UncontrolledProviderScope with a container that is intentionally NOT
      // disposed inside the fake-async test body (project pattern): drift's
      // stream-close cleanup timer must not stay pending at unmount.
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
      ]);
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomePage()),
          GoRoute(
            path: '/workout/active',
            builder: (_, _) =>
                const Text('ACTIVE SCREEN', key: ValueKey('active_stub')),
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

      // WU-X.1: Home now watches the same stream mix as the nutrition
      // dashboard, so the group's db.close() needs this drain (WU-4.5
      // recipe): unmount → dispose → pump lets drift's stream-close
      // cleanup timers fire while the fake-async zone is still alive.
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump(const Duration(milliseconds: 100));
      });
    }

    testWidgets('shows the banner with name, elapsed time, and set progress',
        (tester) async {
      await seedActiveSnapshot(
          startedAgo: const Duration(minutes: 23, seconds: 41));
      await pumpHome(tester);

      expect(find.byKey(const ValueKey('home_resume_banner')), findsOneWidget);
      expect(find.text('WORKOUT IN PROGRESS'), findsOneWidget);
      expect(find.textContaining('Crash Test'), findsOneWidget);
      expect(find.textContaining('23:4'), findsOneWidget);
      expect(find.textContaining('1/2 sets'), findsOneWidget);
    });

    testWidgets('tapping the banner returns to the active workout',
        (tester) async {
      await seedActiveSnapshot();
      await pumpHome(tester);

      await tester.tap(find.byKey(const ValueKey('home_resume_banner')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('active_stub')), findsOneWidget);
    });

    testWidgets('no banner and instant start when no session is active',
        (tester) async {
      await pumpHome(tester);

      expect(find.byKey(const ValueKey('home_resume_banner')), findsNothing);
      // Fresh DB → the §5.1 first-run CTA label.
      expect(find.text('START FIRST WORKOUT'), findsOneWidget);

      // One-session rule passes straight through → navigates.
      await tester.tap(find.text('START FIRST WORKOUT'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('active_stub')), findsOneWidget);
    });
  });
}

/// Harness that runs [resolveOneSessionRule] from a real build context with a
/// real router, surfacing the boolean outcome as keyed text for assertions.
class _ConflictHarness extends ConsumerStatefulWidget {
  const _ConflictHarness();

  @override
  ConsumerState<_ConflictHarness> createState() => _ConflictHarnessState();
}

class _ConflictHarnessState extends ConsumerState<_ConflictHarness> {
  bool? _mayStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              key: const ValueKey('conflict_trigger'),
              onPressed: () async {
                final mayStart = await resolveOneSessionRule(context, ref);
                if (mounted) setState(() => _mayStart = mayStart);
              },
              child: const Text('RESOLVE'),
            ),
            if (_mayStart != null)
              _mayStart!
                  ? const SizedBox.shrink(key: ValueKey('conflict_result_true'))
                  : const SizedBox.shrink(
                      key: ValueKey('conflict_result_false')),
          ],
        ),
      ),
    );
  }
}
