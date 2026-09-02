import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/history/domain/week_stats.dart';
import 'package:aven_fit/features/nutrition/data/nutrition_local_source.dart';
import 'package:aven_fit/features/nutrition/domain/nutrition_goals.dart';
import 'package:aven_fit/features/progress/domain/streak_info.dart';
import 'package:aven_fit/features/routine/data/routine_repository.dart';
import 'package:aven_fit/features/routine/domain/routine.dart';
import 'package:aven_fit/features/workout/presentation/home_controller.dart';
import 'package:aven_fit/features/workout/presentation/home_screen.dart';
import 'package:aven_fit/features/workout/presentation/home_state.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeState statics (WU-X.1, §7.1)', () {
    test('greeting covers all four time-of-day bands', () {
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 6)), 'GOOD MORNING');
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 11, 59)),
          'GOOD MORNING');
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 12)),
          'GOOD AFTERNOON');
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 16, 59)),
          'GOOD AFTERNOON');
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 17)), 'GOOD EVENING');
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 20, 59)),
          'GOOD EVENING');
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 21)), 'GOOD NIGHT');
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 4, 59)), 'GOOD NIGHT');
      expect(HomeState.greetingLabel(DateTime(2026, 9, 2, 5)), 'GOOD MORNING');
    });

    test('date label formats weekday · short month day', () {
      // 2026-09-02 is a Wednesday; 2026-12-25 a Friday.
      expect(HomeState.dateLabel(DateTime(2026, 9, 2)), 'WEDNESDAY · SEP 2');
      expect(HomeState.dateLabel(DateTime(2026, 12, 25)), 'FRIDAY · DEC 25');
    });

    test('pickSuggestedRoutine: last-used wins, then catalog fallback', () {
      const push = Routine(id: 'rt1', name: 'Push');
      const pull = Routine(id: 'rt2', name: 'Pull');
      expect(
        HomeState.pickSuggestedRoutine([push, pull], 'rt2'),
        same(pull),
      );
      // Nothing used yet → deterministic catalog order.
      expect(HomeState.pickSuggestedRoutine([push, pull], null), same(push));
      expect(HomeState.pickSuggestedRoutine([], null), isNull);
      // Stale id (deleted routine) falls back gracefully.
      expect(
        HomeState.pickSuggestedRoutine([push, pull], 'gone'),
        same(push),
      );
    });

    test('calories remaining: hidden without goals, computed with them (L4)',
        () {
      // No goals → null → the chip is hidden entirely.
      expect(const HomeState().caloriesRemaining, isNull);
      expect(const HomeState().hasCalorieGoal, isFalse);

      const state = HomeState(
        goals: NutritionGoals(id: 'default', targetCalories: 2500),
        todayTotals: DailyNutritionTotals(
          itemCount: 2,
          kcal: 1960,
          proteinG: 100,
          carbsG: 200,
          fatG: 60,
        ),
      );
      expect(state.hasCalorieGoal, isTrue);
      expect(state.caloriesRemaining, 540.0);

      // Over target stays a neutral negative fact — never red (L4).
      const over = HomeState(
        goals: NutritionGoals(id: 'default', targetCalories: 1800),
        todayTotals: DailyNutritionTotals(
          itemCount: 3,
          kcal: 2050,
          proteinG: 90,
          carbsG: 220,
          fatG: 70,
        ),
      );
      expect(over.caloriesRemaining, -250.0);
    });

    test('volume delta: no percentage without a baseline (L6)', () {
      // No glance yet → no delta.
      expect(const HomeState().volumeDeltaPercent, isNull);
      expect(const HomeState().volumeIsNewThisWeek, isFalse);

      // Both weeks empty → no fake percentage.
      const idle = HomeState(
        weeklyGlance: (
          thisWeek: WeekStats(volumeKg: 0),
          lastWeek: WeekStats(volumeKg: 0),
        ),
      );
      expect(idle.volumeDeltaPercent, isNull);
      expect(idle.volumeIsNewThisWeek, isFalse);

      // First-ever training week → neutral "▲ NEW".
      const fresh = HomeState(
        weeklyGlance: (
          thisWeek: WeekStats(volumeKg: 1100),
          lastWeek: WeekStats(volumeKg: 0),
        ),
      );
      expect(fresh.volumeDeltaPercent, isNull);
      expect(fresh.volumeIsNewThisWeek, isTrue);

      // Real baseline → ▲/▼ percentage.
      const up = HomeState(
        weeklyGlance: (
          thisWeek: WeekStats(volumeKg: 1100),
          lastWeek: WeekStats(volumeKg: 1000),
        ),
      );
      expect(up.volumeDeltaPercent, closeTo(10.0, 0.001));
      const down = HomeState(
        weeklyGlance: (
          thisWeek: WeekStats(volumeKg: 500),
          lastWeek: WeekStats(volumeKg: 1000),
        ),
      );
      expect(down.volumeDeltaPercent, closeTo(-50.0, 0.001));
    });
  });

  group('HistoryDao.watchWeeklyGlance (WU-X.1)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> seedExercise(String id, String name) async {
      await db.into(db.exercises).insert(
            ExercisesCompanion(
              id: drift.Value(id),
              name: drift.Value(name),
            ),
          );
    }

    Future<void> seedSessionWithSets(
      String id, {
      required String status,
      required DateTime startedAt,
      DateTime? completedAt,
      required List<
          ({
            double weightKg,
            int reps,
            bool completed,
            String type,
          })> sets,
    }) async {
      await db.into(db.workoutSessions).insert(
            WorkoutSessionsCompanion.insert(
              id: id,
              startedAt: startedAt,
              completedAt: drift.Value(completedAt),
              status: drift.Value(status),
              createdAt: drift.Value(startedAt),
              updatedAt: drift.Value(startedAt),
            ),
          );
      await db.into(db.sessionExercises).insert(
            SessionExercisesCompanion.insert(
              id: 'se_$id',
              sessionId: id,
              exerciseId: 'ex_1',
            ),
          );
      for (var i = 0; i < sets.length; i++) {
        final set = sets[i];
        await db.into(db.workoutSets).insert(
              WorkoutSetsCompanion.insert(
                id: 'set_${id}_$i',
                sessionId: id,
                sessionExerciseId: 'se_$id',
                setNumber: i + 1,
                weightKg: drift.Value(set.weightKg),
                reps: drift.Value(set.reps),
                isCompleted: drift.Value(set.completed),
                setType: drift.Value(set.type),
              ),
            );
      }
    }

    test('empty history buckets zeros for both weeks', () async {
      final glance = await db.historyDao.watchWeeklyGlance().first;
      expect(glance.thisWeek.workoutCount, 0);
      expect(glance.thisWeek.completedSetCount, 0);
      expect(glance.thisWeek.volumeKg, 0.0);
      expect(glance.lastWeek.workoutCount, 0);
      expect(glance.lastWeek.volumeKg, 0.0);
    });

    test('buckets by the effective completion date; warm-ups and planned '
        'sets excluded from volume', () async {
      await seedExercise('ex_1', 'Barbell Bench Press');
      final weekStart = StreakInfo.startOfWeek(DateTime.now());
      final lastWeekMid =
          weekStart.subtract(const Duration(days: 3, hours: 5));
      final tenDaysAgo = weekStart.subtract(const Duration(days: 10));

      // This week: 2 completed working sets + 1 completed warm-up + 1 planned.
      await seedSessionWithSets(
        'w_this',
        status: 'completed',
        startedAt: weekStart.add(const Duration(days: 1, hours: 8)),
        completedAt: weekStart.add(const Duration(days: 1, hours: 9)),
        sets: const [
          (weightKg: 20, reps: 10, completed: true, type: 'warmup'),
          (weightKg: 80, reps: 8, completed: true, type: 'normal'),
          (weightKg: 60, reps: 6, completed: true, type: 'normal'),
          (weightKg: 100, reps: 3, completed: false, type: 'normal'),
        ],
      );
      // Started this week but completed last week — the effective date
      // (completedAt ?? startedAt) decides the bucket.
      await seedSessionWithSets(
        'w_last',
        status: 'completed',
        startedAt: weekStart.add(const Duration(hours: 2)),
        completedAt: lastWeekMid,
        sets: const [
          (weightKg: 90, reps: 5, completed: true, type: 'normal'),
        ],
      );
      // Ten days ago: outside both buckets.
      await seedSessionWithSets(
        'w_old',
        status: 'completed',
        startedAt: tenDaysAgo,
        completedAt: tenDaysAgo.add(const Duration(hours: 1)),
        sets: const [
          (weightKg: 70, reps: 10, completed: true, type: 'normal'),
        ],
      );
      // Active session this week: never a completed workout or set.
      await seedSessionWithSets(
        'w_live',
        status: 'active',
        startedAt: weekStart.add(const Duration(days: 2, hours: 7)),
        sets: const [
          (weightKg: 120, reps: 4, completed: true, type: 'normal'),
        ],
      );

      final glance = await db.historyDao.watchWeeklyGlance().first;

      expect(glance.thisWeek.workoutCount, 1);
      // Warm-up counts as a confirmed set; planned excluded.
      expect(glance.thisWeek.completedSetCount, 3);
      // 80×8 + 60×6 = 1000 (warm-up excluded, L1).
      expect(glance.thisWeek.volumeKg, 1000.0);

      expect(glance.lastWeek.workoutCount, 1);
      expect(glance.lastWeek.completedSetCount, 1);
      expect(glance.lastWeek.volumeKg, 450.0);
    });
  });

  group('HomeController (WU-X.1)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('composes all dashboard sources from real SQLite streams',
        () async {
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(homeControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await Future<void>.delayed(const Duration(milliseconds: 80));
      final state = container.read(homeControllerProvider);
      expect(state.activeSession, isNull);
      expect(state.streak, isNotNull);
      expect(state.isFirstRun, isTrue);
      expect(state.suggestedRoutine, isNull);
      expect(state.hasCalorieGoal, isFalse);
    });

    test('startSuggestedRoutine reuses the <1s write-through start path',
        () async {
      // Seed a routine through the production repository.
      final routine =
          await RoutineRepositoryImpl(db.routineDao).createRoutine(
        name: 'Push Day',
      );
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(homeControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await Future<void>.delayed(const Duration(milliseconds: 80));
      final state = container.read(homeControllerProvider);
      expect(state.suggestedRoutine?.id, routine.id);

      final sessionId = await container
          .read(homeControllerProvider.notifier)
          .startSuggestedRoutine();
      expect(sessionId, isNotNull);

      // The session was created from the routine (name carried over,
      // routineId linked — the routine row itself unmutated, L7).
      final session = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(sessionId!)))
          .getSingle();
      expect(session.name, 'Push Day');
      expect(session.routineId, routine.id);
      expect(session.status, 'active');
    });
  });

  group('Home dashboard screen (WU-X.1)', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    /// Seeds the referenced catalog exercise (FK target for set rows).
    Future<void> seedExercise(String id, String name) async {
      await db.into(db.exercises).insert(
            ExercisesCompanion(
              id: drift.Value(id),
              name: drift.Value(name),
            ),
          );
    }

    /// Seeds one session with sets (raw rows, deterministic dates).
    Future<void> seedSessionWithSets(
      String id, {
      required String status,
      required DateTime startedAt,
      DateTime? completedAt,
      String name = 'Morning Grind',
      required List<
          ({
            double weightKg,
            int reps,
            bool completed,
            String type,
          })> sets,
    }) async {
      await db.into(db.workoutSessions).insert(
            WorkoutSessionsCompanion.insert(
              id: id,
              name: drift.Value(name),
              startedAt: startedAt,
              completedAt: drift.Value(completedAt),
              status: drift.Value(status),
              createdAt: drift.Value(startedAt),
              updatedAt: drift.Value(startedAt),
            ),
          );
      await db.into(db.sessionExercises).insert(
            SessionExercisesCompanion.insert(
              id: 'se_$id',
              sessionId: id,
              exerciseId: 'ex_1',
            ),
          );
      for (var i = 0; i < sets.length; i++) {
        final set = sets[i];
        await db.into(db.workoutSets).insert(
              WorkoutSetsCompanion.insert(
                id: 'set_${id}_$i',
                sessionId: id,
                sessionExerciseId: 'se_$id',
                setNumber: i + 1,
                weightKg: drift.Value(set.weightKg),
                reps: drift.Value(set.reps),
                isCompleted: drift.Value(set.completed),
                setType: drift.Value(set.type),
              ),
            );
      }
    }

    Future<void> pumpHome(
      WidgetTester tester, {
      Stream<NutritionGoals?>? goalsOverride,
      Stream<DailyNutritionTotals>? todayTotalsOverride,
      Stream<WeeklyGlance>? weeklyGlanceOverride,
    }) async {
      container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        if (goalsOverride != null)
          homeNutritionGoalsStreamProvider
              .overrideWith((ref) => goalsOverride),
        if (todayTotalsOverride != null)
          homeTodayTotalsStreamProvider
              .overrideWith((ref) => todayTotalsOverride),
        if (weeklyGlanceOverride != null)
          weeklyGlanceStreamProvider
              .overrideWith((ref) => weeklyGlanceOverride),
      ]);
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomePage()),
          GoRoute(
            path: '/workout/active',
            builder: (_, _) => const Scaffold(
              body: Text('ACTIVE STUB', key: ValueKey('active_stub')),
            ),
          ),
          GoRoute(
            path: '/history',
            builder: (_, _) => const Scaffold(
              body: Text('HISTORY STUB', key: ValueKey('history_stub')),
            ),
          ),
          GoRoute(
            path: '/history/:id',
            builder: (_, _) => const Scaffold(
              body: Text('DETAIL STUB', key: ValueKey('detail_stub')),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.dark,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drain before tearDown closes the DB (WU-4.5 recipe, probed
      // empirically): unmount the tree so the providers cancel their
      // drift stream subscriptions, dispose the container, and pump so
      // drift's stream-close cleanup timers fire. Without this,
      // `db.close()` in tearDown awaits a cleanup timer that can never
      // fire after the fake-async body ends and hangs the whole suite.
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump(const Duration(milliseconds: 100));
      });
    }

    // The drain above replaces the session_restore "undisposed container"
    // pattern — the rebuilt Home watches the same stream mix as the
    // nutrition dashboard (WU-4.5), whose close-hang needs this drain.
    void homeScreenTest(
      String description,
      Future<void> Function(WidgetTester tester) body,
    ) {
      testWidgets(description, body);
    }

    homeScreenTest('first run: greeting, §5.1 CTA, designed empty states',
        (tester) async {
      await pumpHome(tester);

      expect(find.byKey(const ValueKey('home_greeting')), findsOneWidget);
      expect(find.text('START FIRST WORKOUT'), findsOneWidget);
      expect(find.byKey(const ValueKey('home_recent_empty')), findsOneWidget);
      expect(find.text('No account needed. Works offline.'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('home_view_all_history')), findsNothing);
      // Fresh DB: goal progress visible, streak chip omitted (L4).
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text('0 of 3'), findsOneWidget);
      expect(find.text('STREAK'), findsNothing);
    });

    homeScreenTest('with history: recent cards, relative dates, VIEW ALL, '
        'and the regular CTA label', (tester) async {
      await seedExercise('ex_1', 'Barbell Bench Press');
      final now = DateTime.now();
      await seedSessionWithSets(
        'w1',
        name: 'Morning Grind',
        status: 'completed',
        startedAt: now.subtract(const Duration(days: 1, hours: 2)),
        completedAt: now.subtract(const Duration(days: 1)),
        sets: const [
          (weightKg: 80, reps: 8, completed: true, type: 'normal'),
        ],
      );
      await seedSessionWithSets(
        'w2',
        name: 'Evening Workout',
        status: 'completed',
        startedAt: now.subtract(const Duration(days: 3, hours: 2)),
        completedAt: now.subtract(const Duration(days: 3)),
        sets: const [
          (weightKg: 90, reps: 5, completed: true, type: 'normal'),
        ],
      );
      // An active session (no sets yet) → resume banner.
      await seedSessionWithSets(
        'live',
        name: 'Crash Test',
        status: 'active',
        startedAt: now.subtract(const Duration(minutes: 23, seconds: 41)),
        sets: const [],
      );
      await pumpHome(tester);

      expect(find.text('START NEW SESSION'), findsOneWidget);
      expect(find.byKey(const ValueKey('home_resume_banner')), findsOneWidget);
      expect(find.text('RECENT WORKOUTS'), findsOneWidget);
      expect(find.text('Morning Grind'), findsOneWidget);
      expect(find.text('Evening Workout'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.text('3d ago'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('home_view_all_history')), findsOneWidget);
    });

    homeScreenTest('tapping a recent card opens the past workout detail',
        (tester) async {
      await seedExercise('ex_1', 'Barbell Bench Press');
      final now = DateTime.now();
      await seedSessionWithSets(
        'w1',
        status: 'completed',
        startedAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(hours: 23)),
        sets: const [],
      );
      await pumpHome(tester);

      await tester.tap(find.byKey(const ValueKey('home_recent_card_w1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('detail_stub')), findsOneWidget);
    });

    homeScreenTest('VIEW ALL opens the workout history list', (tester) async {
      await seedExercise('ex_1', 'Barbell Bench Press');
      final now = DateTime.now();
      await seedSessionWithSets(
        'w1',
        status: 'completed',
        startedAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(hours: 23)),
        sets: const [],
      );
      await pumpHome(tester);

      await tester.tap(find.byKey(const ValueKey('home_view_all_history')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('history_stub')), findsOneWidget);
    });

    homeScreenTest('suggested routine card one-tap-starts the session (§7.1)',
        (tester) async {
      await db.into(db.routines).insert(
            RoutinesCompanion.insert(id: 'rt1', name: 'Push Day'),
          );
      await pumpHome(tester);

      expect(
          find.byKey(const ValueKey('home_suggested_routine')), findsOneWidget);
      expect(find.text('SUGGESTED ROUTINE'), findsOneWidget);
      expect(find.text('Push Day'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('home_suggested_routine')));
      await tester.pumpAndSettle();

      // One-session rule passed → the routine-start path ran → active.
      expect(find.byKey(const ValueKey('active_stub')), findsOneWidget);
      final sessions = await db.select(db.workoutSessions).get();
      expect(sessions.where((s) => s.routineId == 'rt1'), hasLength(1));
      expect(
        sessions.firstWhere((s) => s.routineId == 'rt1').name,
        'Push Day',
      );
    });

    homeScreenTest('calories chip hidden without goals (L4)', (tester) async {
      await pumpHome(tester);
      expect(find.text('CALORIES LEFT'), findsNothing);
    });

    homeScreenTest(
        'calories chip shows the remaining fact when goals are set',
        (tester) async {
      await pumpHome(
        tester,
        goalsOverride: Stream.value(
          const NutritionGoals(id: 'default', targetCalories: 2500),
        ),
        todayTotalsOverride: Stream.value(
          const DailyNutritionTotals(
            itemCount: 2,
            kcal: 1960,
            proteinG: 100,
            carbsG: 200,
            fatG: 60,
          ),
        ),
      );

      expect(find.text('CALORIES LEFT'), findsOneWidget);
      expect(find.text('540 kcal'), findsOneWidget);
    });

    homeScreenTest('volume glance shows the week-over-week delta badge',
        (tester) async {
      await pumpHome(
        tester,
        weeklyGlanceOverride: Stream.value((
          thisWeek: const WeekStats(
            workoutCount: 2,
            completedSetCount: 12,
            volumeKg: 1100,
          ),
          lastWeek: const WeekStats(volumeKg: 1000),
        )),
      );

      expect(find.text('1100 kg'), findsOneWidget);
      expect(find.text('▲ 10%'), findsOneWidget);
    });
  });
}
