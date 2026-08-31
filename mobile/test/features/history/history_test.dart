import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/history/data/history_repository.dart';
import 'package:aven_fit/features/history/domain/workout_history_item.dart';
import 'package:aven_fit/features/history/presentation/history_list_screen.dart';
import 'package:aven_fit/features/history/presentation/workout_detail_screen.dart';
import 'package:aven_fit/features/progress/data/pr_repository.dart';
import 'package:aven_fit/features/routine/data/routine_repository.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_session.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workoutRepo;
  late HistoryRepositoryImpl historyRepo;
  late RoutineRepositoryImpl routineRepo;
  late PRRepositoryImpl prRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workoutRepo = WorkoutRepositoryImpl(db.workoutDao);
    historyRepo = HistoryRepositoryImpl(
      db.historyDao,
      workoutRepo,
      PRRepositoryImpl(db.prDao),
    );
    routineRepo = RoutineRepositoryImpl(db.routineDao);
    prRepo = PRRepositoryImpl(db.prDao);
  });

  tearDown(() async {
    await db.close();
  });

  /// Seeds one exercise and a completed workout with a warm-up, two working
  /// sets (one flagged PR), and one planned set.
  Future<String> seedExercise(String id, String name) async {
    await db.into(db.exercises).insert(
          ExercisesCompanion(
            id: drift.Value(id),
            name: drift.Value(name),
          ),
        );
    return id;
  }

  Future<String> seedCompletedWorkout({
    required String name,
    required String exerciseId,
    DateTime? completedAt,
    int durationSeconds = 1800,
  }) async {
    final session = await workoutRepo.startWorkout(name: name);
    final se = await workoutRepo.addExerciseToSession(
      sessionId: session.id,
      exerciseId: exerciseId,
    );
    await workoutRepo.logSet(WorkoutSet(
      id: '${session.id}_warm',
      sessionId: session.id,
      sessionExerciseId: se.id,
      exerciseId: exerciseId,
      setNumber: 1,
      weightKg: 20,
      reps: 10,
      isCompleted: true,
      type: SetType.warmup,
    ));
    await workoutRepo.logSet(WorkoutSet(
      id: '${session.id}_s2',
      sessionId: session.id,
      sessionExerciseId: se.id,
      exerciseId: exerciseId,
      setNumber: 2,
      weightKg: 80,
      reps: 8,
      isCompleted: true,
      isPr: true,
    ));
    await workoutRepo.logSet(WorkoutSet(
      id: '${session.id}_s3',
      sessionId: session.id,
      sessionExerciseId: se.id,
      exerciseId: exerciseId,
      setNumber: 3,
      weightKg: 82.5,
      reps: 6,
      isCompleted: true,
    ));
    await workoutRepo.logSet(WorkoutSet(
      id: '${session.id}_s4',
      sessionId: session.id,
      sessionExerciseId: se.id,
      exerciseId: exerciseId,
      setNumber: 4,
      weightKg: 75,
      reps: 5,
    ));

    await workoutRepo.finishWorkout(session.id, durationSeconds: durationSeconds);
    // Backdate the completion stamp after the finish write-through so
    // ordering across seeded workouts is deterministic.
    if (completedAt != null) {
      await (db.update(db.workoutSessions)
            ..where((t) => t.id.equals(session.id)))
          .write(WorkoutSessionsCompanion(
        completedAt: drift.Value(completedAt),
      ));
    }
    return session.id;
  }

  group('History feed (§8.6)', () {
    test('lists completed workouts newest-first with exact aggregates', () async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final older = await seedCompletedWorkout(
        name: 'Chest Day',
        exerciseId: bench,
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        durationSeconds: 1800,
      );
      final row = await seedExercise('ex_row', 'Barbell Row');
      final newer = await seedCompletedWorkout(
        name: 'Back Day',
        exerciseId: row,
        completedAt: DateTime.now(),
        durationSeconds: 3600,
      );
      // Active and discarded sessions never appear in history.
      await workoutRepo.startWorkout(name: 'Live Session');

      final items = await historyRepo.getCompletedWorkouts();

      expect(items, hasLength(2));
      expect(items[0].id, newer);
      expect(items[1].id, older);

      final chest = items.firstWhere((i) => i.id == older);
      expect(chest.name, 'Chest Day');
      expect(chest.exerciseCount, 1);
      // 3 confirmed sets (warm-up included in count, planned set excluded).
      expect(chest.totalSetsCount, 3);
      // Working volume excludes the warm-up (L1): 80×8 + 82.5×6.
      expect(chest.totalVolumeKg, 1135.0);
      expect(chest.prCount, 1);
      expect(chest.durationSeconds, 1800);
    });

    test('paginates with limit/offset', () async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      await seedCompletedWorkout(
        name: 'Older',
        exerciseId: bench,
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      await seedCompletedWorkout(
        name: 'Newer',
        exerciseId: bench,
      );

      final page1 = await historyRepo.getCompletedWorkouts(limit: 1);
      expect(page1, hasLength(1));
      expect(page1.single.name, 'Newer');

      final page2 = await historyRepo.getCompletedWorkouts(limit: 1, offset: 1);
      expect(page2, hasLength(1));
      expect(page2.single.name, 'Older');
    });

    test('watch feed re-emits when a workout completes', () async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final first = await historyRepo.watchCompletedWorkouts().first;
      expect(first, isEmpty);

      final emissions = <List<WorkoutHistoryItem>>[];
      final sub = historyRepo.watchCompletedWorkouts().listen(emissions.add);
      await Future<void>.delayed(Duration.zero);

      await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(emissions.last.map((i) => i.name), contains('Chest Day'));
      await sub.cancel();
    });
  });

  group('Past workout detail (§8.7)', () {
    test('returns the full read-only breakdown with exercise names', () async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final sessionId =
          await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);

      final detail = await historyRepo.getWorkoutDetail(sessionId);

      expect(detail, isNotNull);
      expect(detail!.name, 'Chest Day');
      expect(detail.exercises, hasLength(1));
      expect(detail.exercises.first.exerciseName, 'Barbell Bench Press');
      expect(detail.exercises.first.sets, hasLength(4));
      expect(detail.completedSetsCount, 3);
    });

    test('returns null for an unknown workout', () async {
      expect(await historyRepo.getWorkoutDetail('ws_missing'), isNull);
    });
  });

  group('Repeat workout (§8.7)', () {
    test('creates a new active session with planned copies; original untouched',
        () async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final originalId =
          await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);

      final newSessionId = await historyRepo.repeatWorkout(originalId);
      expect(newSessionId, isNot(originalId));

      final original = await historyRepo.getWorkoutDetail(originalId);
      expect(original!.status, WorkoutStatus.completed);
      expect(original.completedSetsCount, 3);

      final repeat = await historyRepo.getWorkoutDetail(newSessionId);
      expect(repeat!.status, WorkoutStatus.active);
      expect(repeat.name, 'Chest Day');
      expect(repeat.exercises, hasLength(1));
      expect(repeat.exercises.first.exerciseName, 'Barbell Bench Press');
      // Sets arrive as planned copies with identical values; PR/warm-up
      // flags preserved as types, completions cleared.
      final sets = repeat.exercises.first.sets;
      expect(sets, hasLength(4));
      expect(sets.every((s) => !s.isCompleted), isTrue);
      expect(sets.every((s) => !s.isPr), isTrue);
      expect(sets.where((s) => s.type == SetType.warmup), hasLength(1));
      final working = sets.firstWhere((s) => s.setNumber == 2);
      expect(working.weightKg, 80.0);
      expect(working.reps, 8);

      // Repeated session restores through the active-session path.
      final active = await workoutRepo.getActiveSession();
      expect(active!.id, newSessionId);
    });

    test('throws for an unknown workout', () async {
      await historyRepo.getWorkoutDetail('ws_missing');
      expect(
        () => historyRepo.repeatWorkout('ws_missing'),
        throwsStateError,
      );
    });
  });

  group('Save as routine (§8.7)', () {
    test('creates a routine with per-set targets from the workout', () async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final sessionId =
          await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);

      final routineId = await historyRepo.saveWorkoutAsRoutine(
        sessionId,
        name: 'Chest Template',
      );

      final routines = await routineRepo.getAllRoutines();
      expect(routines, hasLength(1));
      final routine = routines.first;
      expect(routine.id, routineId);
      expect(routine.name, 'Chest Template');
      expect(routine.exercises, hasLength(1));
      final re = routine.exercises.first;
      expect(re.exerciseId, 'ex_bench');
      expect(re.targetSetsCount, 4);
      expect(re.sets, hasLength(4));
      // Per-set targets mirror the performed values.
      final targetSet = re.sets.firstWhere((s) => s.position == 2);
      expect(targetSet.targetWeightKg, 80.0);
      expect(targetSet.targetReps, 8);
    });

    test('rejects a workout without exercises', () async {
      final session = await workoutRepo.startWorkout(name: 'Empty');
      await workoutRepo.finishWorkout(session.id);
      expect(
        () => historyRepo.saveWorkoutAsRoutine(session.id, name: 'X'),
        throwsStateError,
      );
    });
  });

  group('Delete workout (§8.6/§8.7, L7)', () {
    test('removes the session, cascades sets, and recomputes stale PRs',
        () async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');

      // Session A sets a 100 kg record; session B beats it with 110 kg.
      final sessionA = await workoutRepo.startWorkout(name: 'A');
      final seA = await workoutRepo.addExerciseToSession(
        sessionId: sessionA.id,
        exerciseId: bench,
      );
      final setA = WorkoutSet(
        id: 'a_set',
        sessionId: sessionA.id,
        sessionExerciseId: seA.id,
        exerciseId: bench,
        setNumber: 1,
        weightKg: 100,
        reps: 5,
        isCompleted: true,
      );
      await workoutRepo.logSet(setA);
      await prRepo.detectPRs(exerciseId: bench, set: setA);
      await workoutRepo.finishWorkout(sessionA.id);

      final sessionB = await workoutRepo.startWorkout(name: 'B');
      final seB = await workoutRepo.addExerciseToSession(
        sessionId: sessionB.id,
        exerciseId: bench,
      );
      final setB = WorkoutSet(
        id: 'b_set',
        sessionId: sessionB.id,
        sessionExerciseId: seB.id,
        exerciseId: bench,
        setNumber: 1,
        weightKg: 110,
        reps: 5,
        isCompleted: true,
      );
      await workoutRepo.logSet(setB);
      await prRepo.detectPRs(exerciseId: bench, set: setB);
      await workoutRepo.finishWorkout(sessionB.id);

      var maxWeight = (await prRepo.getRecordsForExercise(bench))
          .firstWhere((r) => r.recordType.name == 'maxWeight');
      expect(maxWeight.value, 110.0);

      await historyRepo.deleteWorkout(sessionB.id);

      // Session B and its sets are gone (cascade, L7).
      final bSets = await db.workoutDao.getSessionSets(sessionB.id);
      expect(bSets, isEmpty);
      final remaining = await historyRepo.getCompletedWorkouts();
      expect(remaining.map((i) => i.name), ['A']);

      // The PR self-heals back to the best surviving set (§10.2 parity).
      maxWeight = (await prRepo.getRecordsForExercise(bench))
          .firstWhere((r) => r.recordType.name == 'maxWeight');
      expect(maxWeight.value, 100.0);
    });
  });

  group('History list screen (§8.6 widget)', () {
    Future<void> pumpScreen(
      WidgetTester tester, {
      String initialLocation = '/history',
    }) async {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(path: '/history', builder: (_, _) => const HistoryListScreen()),
          GoRoute(
            path: '/history/:id',
            builder: (_, _) => const Text('DETAIL STUB', key: ValueKey('detail_stub')),
          ),
          GoRoute(
            path: '/workout/active',
            builder: (_, _) => const Text('ACTIVE SCREEN', key: ValueKey('active_stub')),
          ),
        ],
      );
      // UncontrolledProviderScope with a container intentionally not disposed
      // inside the fake-async test body (project pattern) — drift's
      // stream-close cleanup timer must not trip the pending-timer invariant.
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the designed empty state when history is empty (L6)',
        (tester) async {
      await pumpScreen(tester);

      expect(find.text('NO WORKOUTS YET'), findsOneWidget);
      expect(find.text('START WORKOUT'), findsOneWidget);
    });

    testWidgets('renders grouped cards with metrics and PR chip',
        (tester) async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      await seedCompletedWorkout(
        name: 'Chest Day',
        exerciseId: bench,
        completedAt: DateTime.now(),
        durationSeconds: 1800,
      );
      await pumpScreen(tester);

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('Chest Day'), findsOneWidget);
      expect(find.textContaining('3 sets'), findsOneWidget);
      expect(find.textContaining('1135 kg'), findsOneWidget);
      expect(find.textContaining('30:00'), findsOneWidget);
      expect(find.text('1 PR'), findsOneWidget);
      expect(find.textContaining('1 exercise'), findsOneWidget);
    });

    testWidgets('navigates to the workout detail on card tap', (tester) async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final sessionId =
          await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);
      await pumpScreen(tester);

      await tester.tap(find.byKey(ValueKey('history_card_$sessionId')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('detail_stub')), findsOneWidget);
    });
  });

  group('Workout detail screen (§8.7 widget)', () {
    /// Pumps the history list, then opens the workout detail by tapping its
    /// card — a real back stack, so delete's `pop()` behaves like production.
    /// [openDirect] navigates straight to the detail route instead (used for
    /// the not-found state, which needs no back stack in-test).
    Future<void> pumpDetail(
      WidgetTester tester, {
      required String sessionId,
      bool openDirect = false,
    }) async {
      final router = GoRouter(
        initialLocation: openDirect ? '/history/$sessionId' : '/history',
        routes: [
          GoRoute(path: '/history', builder: (_, _) => const HistoryListScreen()),
          GoRoute(
            path: '/history/:id',
            builder: (_, state) => WorkoutDetailScreen(
              sessionId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/workout/active',
            builder: (_, _) => const Text('ACTIVE SCREEN', key: ValueKey('active_stub')),
          ),
        ],
      );
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      if (!openDirect) {
        await tester.tap(find.byKey(ValueKey('history_card_$sessionId')));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('renders stats grid and full set breakdown', (tester) async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final sessionId =
          await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);
      await pumpDetail(tester, sessionId: sessionId);

      expect(find.text('Chest Day'), findsOneWidget);
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('30:00'), findsOneWidget);
      expect(find.text('WORKING VOLUME'), findsOneWidget);
      expect(find.text('1135 kg'), findsOneWidget);
      expect(find.text('SETS'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('PRS'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('80 kg × 8'), findsOneWidget);
      // Warm-up row carries the W badge; planned row marked not completed.
      expect(find.text('W'), findsOneWidget);
      expect(find.textContaining('(not completed)'), findsOneWidget);
    });

    testWidgets('shows the designed not-found state for unknown ids (L6)',
        (tester) async {
      await pumpDetail(tester, sessionId: 'ws_missing', openDirect: true);

      expect(find.text('WORKOUT NOT FOUND'), findsOneWidget);
      expect(find.text('BACK TO HISTORY'), findsOneWidget);
    });

    testWidgets('REPEAT WORKOUT enforces the one-session rule then navigates',
        (tester) async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final sessionId =
          await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);
      await pumpDetail(tester, sessionId: sessionId);

      await tester.tap(find.byKey(const ValueKey('repeat_workout_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('active_stub')), findsOneWidget);
      final active = await workoutRepo.getActiveSession();
      expect(active, isNotNull);
      expect(active!.id, isNot(sessionId));
      expect(active.name, 'Chest Day');
    });

    testWidgets('save-as-routine persists a routine from the workout',
        (tester) async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final sessionId =
          await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);
      await pumpDetail(tester, sessionId: sessionId);

      await tester.tap(find.byIcon(LucideIcons.ellipsisVertical));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save as routine'));
      await tester.pumpAndSettle();

      // Dialog is pre-filled with the workout name.
      expect(find.text('SAVE AS ROUTINE'), findsOneWidget);
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      final routines = await routineRepo.getAllRoutines();
      expect(routines, hasLength(1));
      expect(routines.first.name, 'Chest Day');
    });

    testWidgets('delete requires confirmation and removes the workout (L7)',
        (tester) async {
      final bench = await seedExercise('ex_bench', 'Barbell Bench Press');
      final sessionId =
          await seedCompletedWorkout(name: 'Chest Day', exerciseId: bench);
      await pumpDetail(tester, sessionId: sessionId);

      await tester.tap(find.byIcon(LucideIcons.ellipsisVertical));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete workout'));
      await tester.pumpAndSettle();

      // KEEP cancels.
      await tester.tap(find.text('KEEP'));
      await tester.pumpAndSettle();
      expect(find.text('Chest Day'), findsOneWidget);

      // Retry and confirm.
      await tester.tap(find.byIcon(LucideIcons.ellipsisVertical));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      final row = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(sessionId)))
          .getSingleOrNull();
      expect(row, isNull);
    });
  });
}
