import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/progress/data/streak_repository.dart';
import 'package:aven_fit/features/progress/domain/streak_info.dart';
import 'package:aven_fit/features/workout/presentation/home_screen.dart';
import 'package:aven_fit/features/workout/presentation/workout_summary_controller.dart';
import 'package:aven_fit/features/workout/presentation/workout_summary_state.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakInfo pure math (FEATURES.md §17)', () {
    // Fixed "now": Wednesday 2026-08-05 12:00. Week anchor: Mon 2026-08-03.
    final now = DateTime(2026, 8, 5, 12);
    final week0 = DateTime(2026, 8, 3);
    final week1 = week0.subtract(const Duration(days: 7));
    final week2 = week0.subtract(const Duration(days: 14));

    DateTime at(DateTime week, int dayOffsetHours) =>
        week.add(Duration(hours: dayOffsetHours));

    test('startOfWeek anchors to Monday 00:00 across boundaries', () {
      expect(StreakInfo.startOfWeek(now), week0);
      // Sunday rolls back to the same week's Monday.
      expect(StreakInfo.startOfWeek(DateTime(2026, 8, 9, 23, 59)), week0);
      // Monday itself anchors to midnight.
      expect(StreakInfo.startOfWeek(DateTime(2026, 8, 3, 18)), week0);
      // Month boundary: Wed 2026-07-01 → Mon 2026-06-29.
      expect(StreakInfo.startOfWeek(DateTime(2026, 7, 1)), DateTime(2026, 6, 29));
    });

    test('empty history yields zeros with the default goal', () {
      final info = StreakInfo.compute(
          now: now, weeklyGoalDays: kDefaultWeeklyGoal, completedWorkoutDates: const []);
      expect(info.weeklyGoalDays, 3);
      expect(info.workoutsThisWeek, 0);
      expect(info.currentStreakWeeks, 0);
      expect(info.weeklyGoalMet, isFalse);
      expect(info.weeklyProgressDisplay, '0 of 3');
      expect(info.streakDisplay, isEmpty);
    });

    test('first-ever week meeting the goal starts the streak at 1', () {
      final info = StreakInfo.compute(
        now: now,
        weeklyGoalDays: 3,
        completedWorkoutDates: [
          at(week0, 9),
          at(week0, 30),
          at(week0, 72),
        ],
      );
      expect(info.workoutsThisWeek, 3);
      expect(info.weeklyGoalMet, isTrue);
      expect(info.currentStreakWeeks, 1);
      expect(info.streakDisplay, '1 week');
    });

    test('two consecutive met weeks give streak 2 (WU-X.2 verification)', () {
      final info = StreakInfo.compute(
        now: now,
        weeklyGoalDays: 3,
        completedWorkoutDates: [
          at(week0, 9), at(week0, 30), at(week0, 72), // this week
          at(week1, 9), at(week1, 30), at(week1, 72), // last week
        ],
      );
      expect(info.currentStreakWeeks, 2);
      expect(info.streakDisplay, '2 weeks');
    });

    test('a missed week resets the streak to 0', () {
      final info = StreakInfo.compute(
        now: now,
        weeklyGoalDays: 3,
        completedWorkoutDates: [
          at(week2, 9), at(week2, 30), at(week2, 72), // week -2 met
          // week -1 missed entirely
          at(week0, 9), at(week0, 30), // this week below goal
        ],
      );
      expect(info.currentStreakWeeks, 0);
      expect(info.workoutsThisWeek, 2);
    });

    test('the in-progress current week never breaks the chain mid-week (L4)',
        () {
      final info = StreakInfo.compute(
        now: now,
        weeklyGoalDays: 3,
        completedWorkoutDates: [
          at(week1, 9), at(week1, 30), at(week1, 72), // last week met
          at(week0, 9), // today: 1 of 3 so far
        ],
      );
      expect(info.workoutsThisWeek, 1);
      expect(info.currentStreakWeeks, 1); // last week still counts
      expect(info.weeklyGoalMet, isFalse);
    });

    test('a partially-met lapsed week does not extend the streak', () {
      final info = StreakInfo.compute(
        now: now,
        weeklyGoalDays: 3,
        completedWorkoutDates: [
          at(week1, 9), // last week: 1 of 3 → missed
        ],
      );
      expect(info.currentStreakWeeks, 0);
    });

    test('a met current week starts a new chain after a miss', () {
      final info = StreakInfo.compute(
        now: now,
        weeklyGoalDays: 3,
        completedWorkoutDates: [
          at(week1, 9), // last week missed (1 of 3)
          at(week0, 9), at(week0, 30), at(week0, 72), // this week met
        ],
      );
      expect(info.currentStreakWeeks, 1);
    });

    test('sessions on the same day count individually toward the week', () {
      final info = StreakInfo.compute(
        now: now,
        weeklyGoalDays: 3,
        completedWorkoutDates: [
          at(week0, 9), at(week0, 12), at(week0, 15),
        ],
      );
      expect(info.workoutsThisWeek, 3);
      expect(info.currentStreakWeeks, 1);
    });

    test('a non-positive goal falls back to the default', () {
      final info = StreakInfo.compute(
          now: now, weeklyGoalDays: 0, completedWorkoutDates: const []);
      expect(info.weeklyGoalDays, kDefaultWeeklyGoal);
    });
  });

  group('StreakDao & StreakRepository (in-memory SQLite)', () {
    late AppDatabase db;
    late StreakRepositoryImpl repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = StreakRepositoryImpl(db.streakDao);
    });

    tearDown(() async {
      await db.close();
    });

    /// Seeds a completed session whose effective completion date is
    /// [completedAt] directly through the workout DAO.
    Future<void> seedCompletedSession(
      String id,
      DateTime startedAt,
      DateTime completedAt,
    ) async {
      await db.workoutDao.createSession(id: id, name: id, startedAt: startedAt);
      await db.workoutDao.completeSession(id, completedAt);
    }

    test('fresh database: default goal, no workouts, no streak', () async {
      final info = await repo.getStreakInfo();
      expect(info.weeklyGoalDays, kDefaultWeeklyGoal);
      expect(info.workoutsThisWeek, 0);
      expect(info.currentStreakWeeks, 0);
    });

    test('setWeeklyGoal persists on both insert and update paths', () async {
      await repo.setWeeklyGoal(5);
      var row = await db.streakDao.getSettings();
      expect(row!.weeklyGoalDays, 5);

      await repo.setWeeklyGoal(2);
      row = await db.streakDao.getSettings();
      expect(row!.weeklyGoalDays, 2);

      final info = await repo.getStreakInfo();
      expect(info.weeklyGoalDays, 2);
    });

    test('counts completed sessions by effective completion week', () async {
      final now = DateTime.now();
      final weekStart = StreakInfo.startOfWeek(now);
      await seedCompletedSession(
        'w1',
        weekStart.add(const Duration(hours: 9)),
        weekStart.add(const Duration(hours: 11)),
      );
      await seedCompletedSession(
        'w2',
        weekStart.add(const Duration(hours: 30)),
        weekStart.add(const Duration(hours: 31)),
      );
      // Last week's workout never counts toward this week.
      await seedCompletedSession(
        'old',
        weekStart.subtract(const Duration(days: 2)),
        weekStart.subtract(const Duration(days: 2)).add(const Duration(hours: 1)),
      );

      final info = await repo.getStreakInfo();
      expect(info.workoutsThisWeek, 2);
    });

    test('active and discarded sessions never count', () async {
      final now = DateTime.now();
      await seedCompletedSession('done', now, now);
      await db.workoutDao.createSession(
        id: 'active',
        name: 'active',
        startedAt: now,
      );
      await db.workoutDao.createSession(
        id: 'discarded',
        name: 'discarded',
        startedAt: now,
      );
      await db.workoutDao.discardSession('discarded');

      final info = await repo.getStreakInfo();
      expect(info.workoutsThisWeek, 1);
    });

    test('watchStreakInfo re-emits on goal change and session completion',
        () async {
      final emissions = <StreakInfo>[];
      final sub = repo.watchStreakInfo().listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final initialCount = emissions.length;
      expect(initialCount, greaterThanOrEqualTo(1));
      expect(emissions.last.weeklyGoalDays, kDefaultWeeklyGoal);

      // Settings change → re-emission with the new goal.
      await repo.setWeeklyGoal(4);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(emissions.length, greaterThan(initialCount));
      expect(emissions.last.weeklyGoalDays, 4);

      // Session completion → re-emission with updated count.
      final now = DateTime.now();
      await seedCompletedSession('live', now, now);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(emissions.length, greaterThan(initialCount + 1));
      expect(emissions.last.workoutsThisWeek, 1);

      await sub.cancel();
    });
  });

  group('Home glance stats row (§5.2, WU-X.2)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    /// Seeds a completed session at [completedAt] through the workout DAO.
    Future<void> seedCompletedSession(String id, DateTime completedAt) async {
      await db.workoutDao.createSession(
        id: id,
        name: id,
        startedAt: completedAt.subtract(const Duration(hours: 1)),
      );
      await db.workoutDao.completeSession(id, completedAt);
    }

    Future<void> pumpHome(WidgetTester tester) async {
      // Project pattern: UncontrolledProviderScope whose container is
      // intentionally NOT disposed in the fake-async test body — drift's
      // stream-close cleanup timer must not stay pending at unmount.
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pumpAndSettle();

      // WU-X.1: Home now watches the same stream mix as the nutrition
      // dashboard, so tearDown's db.close() needs this drain (WU-4.5
      // recipe): unmount → dispose → pump lets drift's stream-close
      // cleanup timers fire while the fake-async zone is still alive.
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump(const Duration(milliseconds: 100));
      });
    }

    testWidgets('renders "0 of 3" and omits the streak chip on a fresh DB',
        (tester) async {
      await pumpHome(tester);

      expect(find.byKey(const ValueKey('home_glance_stats')), findsOneWidget);
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text('0 of 3'), findsOneWidget);
      expect(find.text('STREAK'), findsNothing);
    });

    testWidgets('shows weekly progress without a streak chip below the goal',
        (tester) async {
      final weekStart = StreakInfo.startOfWeek(DateTime.now());
      await seedCompletedSession(
          'h1', weekStart.add(const Duration(hours: 9)));
      await seedCompletedSession(
          'h2', weekStart.add(const Duration(hours: 30)));
      await pumpHome(tester);

      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.text('STREAK'), findsNothing);
    });

    testWidgets('shows the streak chip when the goal is met', (tester) async {
      final weekStart = StreakInfo.startOfWeek(DateTime.now());
      await seedCompletedSession(
          'h1', weekStart.add(const Duration(hours: 9)));
      await seedCompletedSession(
          'h2', weekStart.add(const Duration(hours: 30)));
      await seedCompletedSession(
          'h3', weekStart.add(const Duration(hours: 72)));
      await pumpHome(tester);

      expect(find.text('3 of 3'), findsOneWidget);
      expect(find.text('STREAK'), findsOneWidget);
      expect(find.text('1 week'), findsOneWidget);
    });

    testWidgets('honors a custom weekly goal from settings', (tester) async {
      await db.streakDao.setWeeklyGoal(2);
      final weekStart = StreakInfo.startOfWeek(DateTime.now());
      await seedCompletedSession(
          'h1', weekStart.add(const Duration(hours: 9)));
      await seedCompletedSession(
          'h2', weekStart.add(const Duration(hours: 30)));
      await pumpHome(tester);

      expect(find.text('2 of 2'), findsOneWidget);
      expect(find.text('STREAK'), findsOneWidget);
      expect(find.text('1 week'), findsOneWidget);
    });
  });

  group('WorkoutSummary streak wiring (WU-X.2)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    /// Seeds one completed session this week and reads the summary
    /// controller state through the real streak-repository path.
    Future<WorkoutSummaryState> seedAndRead(
      String sessionId, {
      int? goal,
    }) async {
      if (goal != null) {
        await db.streakDao.setWeeklyGoal(goal);
      }
      final weekStart = StreakInfo.startOfWeek(DateTime.now());
      await db.workoutDao.createSession(
        id: sessionId,
        name: 'Session $sessionId',
        startedAt: weekStart.add(const Duration(hours: 9)),
      );
      await db.workoutDao
          .completeSession(sessionId, weekStart.add(const Duration(hours: 10)));

      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
      final state = await container
          .read(workoutSummaryControllerProvider(sessionId).future);
      container.dispose();
      return state;
    }

    test('badge uses the settings-driven goal (default 3 → unmet at 1)',
        () async {
      final state = await seedAndRead('sum_default');
      expect(state.weeklyGoal, kDefaultWeeklyGoal);
      expect(state.weeklyWorkoutCount, 1);
      expect(state.weeklyGoalMet, isFalse);
    });

    test('custom goal of 1 is met by a single workout', () async {
      final state = await seedAndRead('sum_goal1', goal: 1);
      expect(state.weeklyGoal, 1);
      expect(state.weeklyGoalMet, isTrue);
    });
  });
}
