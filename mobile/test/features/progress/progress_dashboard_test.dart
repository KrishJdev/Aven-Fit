import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/progress/data/pr_local_source.dart';
import 'package:aven_fit/features/progress/domain/pr_record.dart';
import 'package:aven_fit/features/progress/domain/streak_info.dart';
import 'package:aven_fit/features/progress/presentation/pr_vault_screen.dart';
import 'package:aven_fit/features/history/presentation/progress_screen.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecordType.formatValue (WU-X.3, §10.2)', () {
    test('formats all four record types with units', () {
      expect(RecordType.maxWeight.formatValue(100), '100 kg');
      expect(RecordType.epley1rm.formatValue(117.5), '117.5 kg e1RM');
      expect(
        RecordType.maxRepsAtWeight.formatValue(8, weightKg: 60),
        '8 reps @ 60 kg',
      );
      expect(RecordType.volume.formatValue(360), '360 kg');
    });

    test('trims trailing .0 and defaults the weight key', () {
      expect(RecordType.maxWeight.formatValue(102.5), '102.5 kg');
      expect(RecordType.epley1rm.formatValue(120.0), '120 kg e1RM');
      expect(
        RecordType.maxRepsAtWeight.formatValue(6),
        '6 reps @ 0 kg',
      );
    });
  });

  group('PrDao.watchVault (WU-X.3)', () {
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

    Future<void> seedRecord(
      String id, {
      required String exerciseId,
      required RecordType type,
      required double value,
      double? weightKg,
      required DateTime achievedAt,
    }) async {
      await db.into(db.personalRecords).insert(
            PersonalRecordsCompanion.insert(
              id: id,
              exerciseId: exerciseId,
              recordType: type.name,
              value: value,
              weightKg: drift.Value(weightKg),
              achievedAt: achievedAt,
              createdAt: drift.Value(achievedAt),
              updatedAt: drift.Value(achievedAt),
            ),
          );
    }

    test('empty vault streams an empty list', () async {
      expect(await db.prDao.watchVault().first, isEmpty);
    });

    test('joins exercise names, orders newest-first, keeps the weight key, '
        'and re-emits on inserts', () async {
      await seedExercise('ex_bench', 'Barbell Bench Press');
      await seedExercise('ex_squat', 'Barbell Back Squat');

      await seedRecord(
        'pr1',
        exerciseId: 'ex_bench',
        type: RecordType.maxWeight,
        value: 100,
        achievedAt: DateTime(2026, 8, 1),
      );
      await seedRecord(
        'pr2',
        exerciseId: 'ex_squat',
        type: RecordType.epley1rm,
        value: 142.5,
        achievedAt: DateTime(2026, 8, 20),
      );
      await seedRecord(
        'pr3',
        exerciseId: 'ex_bench',
        type: RecordType.maxRepsAtWeight,
        value: 8,
        weightKg: 60,
        achievedAt: DateTime(2026, 8, 10),
      );

      final vault = await db.prDao.watchVault().first;

      expect(vault, hasLength(3));
      // Newest achievement first.
      expect(vault[0].record.id, 'pr2');
      expect(vault[0].exerciseName, 'Barbell Back Squat');
      expect(vault[1].record.id, 'pr3');
      expect(vault[1].exerciseName, 'Barbell Bench Press');
      expect(vault[1].record.weightKg, 60);
      expect(vault[2].record.id, 'pr1');

      // Reactive: a new record re-emits at the top (L8).
      final emissions = <List<PRVaultEntry>>[];
      final sub = db.prDao.watchVault().listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final before = emissions.length;
      await seedRecord(
        'pr4',
        exerciseId: 'ex_squat',
        type: RecordType.volume,
        value: 900,
        achievedAt: DateTime(2026, 9, 1),
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(emissions.length, greaterThan(before));
      expect(emissions.last.first.record.id, 'pr4');
      await sub.cancel();
    });
  });

  group('Progress dashboard + PR vault screens (WU-X.3)', () {
    late AppDatabase db;
    late ProviderContainer container;

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

    Future<void> seedRecord(
      String id, {
      required String exerciseId,
      required RecordType type,
      required double value,
      double? weightKg,
      required DateTime achievedAt,
    }) async {
      await db.into(db.personalRecords).insert(
            PersonalRecordsCompanion.insert(
              id: id,
              exerciseId: exerciseId,
              recordType: type.name,
              value: value,
              weightKg: drift.Value(weightKg),
              achievedAt: achievedAt,
              createdAt: drift.Value(achievedAt),
              updatedAt: drift.Value(achievedAt),
            ),
          );
    }

    /// Seeds a completed session through the workout DAO (the streak and
    /// recent-workouts input).
    Future<void> seedCompletedSession(
      String id,
      String name,
      DateTime completedAt,
    ) async {
      await db.workoutDao.createSession(
        id: id,
        name: name,
        startedAt: completedAt.subtract(const Duration(hours: 1)),
      );
      await db.workoutDao.completeSession(id, completedAt);
    }

    Future<void> pumpScreen(
      WidgetTester tester, {
      required String initialLocation,
    }) async {
      container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/progress',
            builder: (_, _) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/progress/prs',
            builder: (_, _) => const PrVaultScreen(),
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

      // WU-4.5 drain: unmount → dispose → pump so drift's stream-close
      // cleanup timers fire before tearDown's db.close().
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump(const Duration(milliseconds: 100));
      });
    }

    testWidgets('fresh DB: neutral zero facts and designed empty states',
        (tester) async {
      await pumpScreen(tester, initialLocation: '/progress');

      expect(find.byKey(const ValueKey('progress_streak_card')),
          findsOneWidget);
      expect(find.text('0 of 3'), findsOneWidget);
      expect(find.text('0 weeks'), findsOneWidget);
      expect(find.byKey(const ValueKey('progress_pr_empty')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('progress_recent_empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('progress_body_weight')),
          findsOneWidget);
      // Nothing to view yet — no actions rendered.
      expect(find.byKey(const ValueKey('progress_pr_view_all')), findsNothing);
      expect(
          find.byKey(const ValueKey('progress_recent_view_all')), findsNothing);
    });

    testWidgets('with data: streak values, PR preview, recent card, '
        'VIEW ALL actions', (tester) async {
      await seedExercise('ex_bench', 'Barbell Bench Press');
      final weekStart = StreakInfo.startOfWeek(DateTime.now());
      // Three sessions this week → goal met → streak chain of 1 (§17).
      for (var i = 0; i < 3; i++) {
        await seedCompletedSession(
          'w$i',
          'Morning Grind $i',
          weekStart.add(Duration(days: i ~/ 2, hours: 9 + i)),
        );
      }
      await seedRecord(
        'pr1',
        exerciseId: 'ex_bench',
        type: RecordType.maxWeight,
        value: 100,
        achievedAt: weekStart.add(const Duration(days: 1, hours: 9, minutes: 30)),
      );
      await seedRecord(
        'pr2',
        exerciseId: 'ex_bench',
        type: RecordType.epley1rm,
        value: 117.5,
        achievedAt: weekStart.add(const Duration(days: 1, hours: 9, minutes: 31)),
      );
      await pumpScreen(tester, initialLocation: '/progress');

      expect(find.text('3 of 3'), findsOneWidget);
      expect(find.text('1 week'), findsOneWidget);
      expect(find.byKey(const ValueKey('progress_pr_entry_pr2')),
          findsOneWidget);
      expect(find.text('117.5 kg e1RM'), findsOneWidget);
      // Both preview rows are for the same exercise.
      expect(find.text('Barbell Bench Press'), findsNWidgets(2));
      expect(
          find.byKey(const ValueKey('progress_pr_view_all')), findsOneWidget);
      expect(find.byKey(const ValueKey('progress_recent_view_all')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('progress_recent_card_w0')),
          findsOneWidget);
      expect(find.text('Morning Grind 0'), findsOneWidget);
      // Only the top-5 PRs preview — both records fit here.
      expect(find.byKey(const ValueKey('progress_pr_entry_pr1')),
          findsOneWidget);
    });

    testWidgets('VIEW ALL opens the full vault grouped by exercise',
        (tester) async {
      await seedExercise('ex_bench', 'Barbell Bench Press');
      final weekStart = StreakInfo.startOfWeek(DateTime.now());
      await seedCompletedSession(
        'w0',
        'Morning Grind',
        weekStart.add(const Duration(hours: 9)),
      );
      await seedRecord(
        'pr1',
        exerciseId: 'ex_bench',
        type: RecordType.maxWeight,
        value: 100,
        achievedAt: weekStart.add(const Duration(hours: 9, minutes: 30)),
      );
      await pumpScreen(tester, initialLocation: '/progress');

      await tester.tap(find.byKey(const ValueKey('progress_pr_view_all')));
      await tester.pumpAndSettle();

      expect(find.text('PR VAULT'), findsOneWidget);
      expect(find.byKey(const ValueKey('pr_vault_group_Barbell Bench Press')),
          findsOneWidget);
      expect(find.text('100 kg'), findsOneWidget);
    });

    testWidgets('recent card opens the past workout detail', (tester) async {
      final weekStart = StreakInfo.startOfWeek(DateTime.now());
      await seedCompletedSession(
        'w0',
        'Morning Grind',
        weekStart.add(const Duration(hours: 9)),
      );
      await pumpScreen(tester, initialLocation: '/progress');

      await tester
          .tap(find.byKey(const ValueKey('progress_recent_card_w0')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('detail_stub')), findsOneWidget);
    });

    testWidgets('vault screen groups records by exercise with all types',
        (tester) async {
      await seedExercise('ex_bench', 'Barbell Bench Press');
      await seedExercise('ex_squat', 'Barbell Back Squat');
      await seedRecord(
        'pr1',
        exerciseId: 'ex_bench',
        type: RecordType.maxWeight,
        value: 100,
        achievedAt: DateTime(2026, 8, 1),
      );
      await seedRecord(
        'pr2',
        exerciseId: 'ex_bench',
        type: RecordType.maxRepsAtWeight,
        value: 8,
        weightKg: 60,
        achievedAt: DateTime(2026, 8, 10),
      );
      await seedRecord(
        'pr3',
        exerciseId: 'ex_squat',
        type: RecordType.volume,
        value: 900,
        achievedAt: DateTime(2026, 8, 20),
      );
      await pumpScreen(tester, initialLocation: '/progress/prs');

      expect(find.byKey(const ValueKey('pr_vault_group_Barbell Bench Press')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('pr_vault_group_Barbell Back Squat')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('pr_vault_row_pr1')), findsOneWidget);
      expect(find.byKey(const ValueKey('pr_vault_row_pr2')), findsOneWidget);
      expect(find.byKey(const ValueKey('pr_vault_row_pr3')), findsOneWidget);
      expect(find.text('100 kg'), findsOneWidget);
      expect(find.text('8 reps @ 60 kg'), findsOneWidget);
      expect(find.text('900 kg'), findsOneWidget);
      expect(find.text('MAX WEIGHT'), findsOneWidget);
      expect(find.text('REPS @ WEIGHT'), findsOneWidget);
      expect(find.text('VOLUME'), findsOneWidget);
    });

    testWidgets('vault empty state is designed (L6)', (tester) async {
      await pumpScreen(tester, initialLocation: '/progress/prs');

      expect(find.byKey(const ValueKey('pr_vault_empty')), findsOneWidget);
      expect(find.text('NO RECORDS YET'), findsOneWidget);
    });
  });
}
