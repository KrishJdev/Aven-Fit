import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/notifications/notification_service.dart';
import 'package:aven_fit/features/progress/data/pr_repository.dart';
import 'package:aven_fit/features/progress/domain/pr_record.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_controller.dart';
import 'package:aven_fit/features/workout/presentation/widgets/set_row_widget.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../workout/fake_notification_service.dart';

void main() {
  group('Epley 1RM Formula', () {
    test('epleyE1RM matches weight × (1 + reps / 30)', () {
      // 100 kg × 5 → 100 × (1 + 5/30) = 116.66̄
      expect(PRRecord.epleyE1RM(weightKg: 100, reps: 5),
          closeTo(116.6667, 0.001));
      // 80 kg × 8 → 80 × (1 + 8/30) = 101.33̄
      expect(PRRecord.epleyE1RM(weightKg: 80, reps: 8),
          closeTo(101.3333, 0.001));
      // Single rep: 100 × (1 + 1/30) = 103.33̄
      expect(PRRecord.epleyE1RM(weightKg: 100, reps: 1),
          closeTo(103.3333, 0.001));
      // Heavy single: 150 kg × 1
      expect(PRRecord.epleyE1RM(weightKg: 150, reps: 1),
          closeTo(155.0, 0.001));
    });

    test('epleyE1RM guards empty values', () {
      expect(PRRecord.epleyE1RM(weightKg: 0, reps: 10), 0);
      expect(PRRecord.epleyE1RM(weightKg: 100, reps: 0), 0);
    });

    test('RecordType parses stored names tolerantly', () {
      expect(RecordType.fromName('epley1rm'), RecordType.epley1rm);
      expect(RecordType.fromName('EPLEY1RM'), RecordType.epley1rm);
      expect(RecordType.fromName('maxRepsAtWeight'), RecordType.maxRepsAtWeight);
      expect(RecordType.fromName('unknown-type'), RecordType.maxWeight);
    });
  });

  group('PR Detection Engine (SQLite in-memory)', () {
    late AppDatabase db;
    late PRRepository prRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      prRepo = PRRepositoryImpl(db.prDao);

      // Seed exercise + the ws_1 / se_1 / set_1 parent rows so the
      // PersonalRecords FK references (session_id, set_id) resolve.
      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('ex_bench'),
              name: drift.Value('Barbell Bench Press'),
            ),
          );
      await db.workoutDao.createSession(
        id: 'ws_1',
        name: 'PR Unit Session',
        startedAt: DateTime(2026, 8, 31, 9),
      );
      await db.workoutDao.addExerciseToSession(
        id: 'se_1',
        sessionId: 'ws_1',
        exerciseId: 'ex_bench',
        orderIndex: 0,
      );
      await db.workoutDao.insertSet(
        id: 'set_1',
        sessionId: 'ws_1',
        sessionExerciseId: 'se_1',
        exerciseId: 'ex_bench',
        setNumber: 1,
        weightKg: 0,
        reps: 0,
      );
    });

    tearDown(() async {
      await db.close();
    });

    WorkoutSet set({
      String id = 'set_1',
      required double weightKg,
      required int reps,
      bool isCompleted = true,
      SetType type = SetType.normal,
      DateTime? completedAt,
    }) {
      return WorkoutSet(
        id: id,
        sessionId: 'ws_1',
        sessionExerciseId: 'se_1',
        exerciseId: 'ex_bench',
        setNumber: 1,
        weightKg: weightKg,
        reps: reps,
        isCompleted: isCompleted,
        type: type,
        completedAt: completedAt,
      );
    }

    test('first confirmed set detects all four PR types', () async {
      final prs = await prRepo.detectPRs(
        exerciseId: 'ex_bench',
        set: set(weightKg: 100, reps: 5, completedAt: DateTime(2026, 8, 31, 10)),
      );

      expect(prs.length, 4);
      final byType = {for (final p in prs) p.recordType: p};
      expect(byType[RecordType.maxWeight]!.value, 100.0);
      expect(byType[RecordType.epley1rm]!.value, closeTo(116.6667, 0.001));
      expect(byType[RecordType.maxRepsAtWeight]!.value, 5.0);
      expect(byType[RecordType.maxRepsAtWeight]!.weightKg, 100.0);
      expect(byType[RecordType.volume]!.value, 500.0);
    });

    test('heavier set triggers max weight, e1RM, volume and reps-at-weight PRs',
        () async {
      await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 100, reps: 5));

      final prs = await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 102.5, reps: 5));

      final types = prs.map((p) => p.recordType).toSet();
      expect(types, containsAll([
        RecordType.maxWeight,
        RecordType.epley1rm,
        RecordType.volume,
        RecordType.maxRepsAtWeight,
      ]));
      final byType = {for (final p in prs) p.recordType: p};
      expect(byType[RecordType.maxWeight]!.value, 102.5);
      expect(byType[RecordType.volume]!.value, 512.5);
    });

    test('equal or lower performance on a known weight yields no new PRs',
        () async {
      await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 100, reps: 5));

      // Same weight, fewer reps → nothing improves
      final fewerReps = await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 100, reps: 4));
      expect(fewerReps, isEmpty);

      // Exactly equal set → strictly-greater rule keeps the earlier record
      final equal = await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 100, reps: 5));
      expect(equal, isEmpty);

      final records = await prRepo.getRecordsForExercise('ex_bench');
      expect(records.length, 4);
    });

    test('lighter set still beats volume when reps compensate', () async {
      await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 100, reps: 5));

      // 50 × 20 = 1000 volume > 500; 50 < 100 maxWeight; e1RM 75 < 116.7;
      // reps@50 = 20 is a new weight key.
      final prs = await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 50, reps: 20));

      final types = prs.map((p) => p.recordType).toSet();
      expect(types, {RecordType.volume, RecordType.maxRepsAtWeight});
    });

    test('warm-up sets never produce PRs (§10.2)', () async {
      await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 100, reps: 5));

      // Warm-up far above every record — still excluded.
      final prs = await prRepo.detectPRs(
        exerciseId: 'ex_bench',
        set: set(weightKg: 140, reps: 10, type: SetType.warmup),
      );
      expect(prs, isEmpty);

      final records = await prRepo.getRecordsForExercise('ex_bench');
      expect(records.length, 4);
      expect(
        records.firstWhere((r) => r.recordType == RecordType.maxWeight).value,
        100.0,
      );
    });

    test('unconfirmed sets are ignored', () async {
      final prs = await prRepo.detectPRs(
        exerciseId: 'ex_bench',
        set: set(weightKg: 100, reps: 5, isCompleted: false),
      );
      expect(prs, isEmpty);
      expect(await prRepo.getRecordsForExercise('ex_bench'), isEmpty);
    });

    test('reps-at-weight records are keyed per weight', () async {
      await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 100, reps: 5));
      await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 60, reps: 8));

      // Improve reps at 60 kg
      await prRepo.detectPRs(
          exerciseId: 'ex_bench', set: set(weightKg: 60, reps: 10));

      final records = await prRepo.getRecordsForExercise('ex_bench');
      final repsRecords = records
          .where((r) => r.recordType == RecordType.maxRepsAtWeight)
          .toList();
      expect(repsRecords.length, 2);

      final at60 = repsRecords.firstWhere((r) => r.weightKg == 60.0);
      expect(at60.value, 10.0);
      final at100 = repsRecords.firstWhere((r) => r.weightKg == 100.0);
      expect(at100.value, 5.0);
    });

    test('records carry achievement source ids when set rows exist', () async {
      // Real session + set rows so the FK references resolve.
      final workoutRepo = WorkoutRepositoryImpl(db.workoutDao);
      final session = await workoutRepo.startWorkout(name: 'Source Test');
      final se =
          await workoutRepo.addExerciseToSession(sessionId: session.id, exerciseId: 'ex_bench');
      final logged = set(id: 'set_src', weightKg: 100, reps: 5);
      await workoutRepo.logSet(logged.copyWith(
        sessionId: session.id,
        sessionExerciseId: se.id,
      ));

      final prs = await prRepo.detectPRs(
        exerciseId: 'ex_bench',
        set: logged.copyWith(
          sessionId: session.id,
          sessionExerciseId: se.id,
          completedAt: DateTime(2026, 8, 31, 9),
        ),
      );
      expect(prs, isNotEmpty);
      expect(prs.every((p) => p.sessionId == session.id), isTrue);
      expect(prs.every((p) => p.setId == logged.id), isTrue);

      final records = await prRepo.getRecordsForExercise('ex_bench');
      expect(
        records.every((r) => r.sessionId == session.id && r.setId == logged.id),
        isTrue,
      );
    });
  });

  group('Recompute Parity (detection == recompute, §10.2)', () {
    late AppDatabase db;
    late PRRepository prRepo;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      prRepo = PRRepositoryImpl(db.prDao);
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

    test('replaying history from scratch reproduces identical records',
        () async {
      final session = await workoutRepo.startWorkout(name: 'PR Session');
      final se = await workoutRepo.addExerciseToSession(
          sessionId: session.id, exerciseId: 'ex_bench');

      final history = [
        (weight: 100.0, reps: 5),
        (weight: 100.0, reps: 4),
        (weight: 60.0, reps: 8),
        (weight: 102.5, reps: 5),
        (weight: 102.5, reps: 6),
        (weight: 102.5, reps: 6), // exact repeat — no new PR
      ];

      var clock = DateTime(2026, 8, 31, 9);
      for (final (i, entry) in history.indexed) {
        final s = WorkoutSet(
          id: 'set_$i',
          sessionId: session.id,
          sessionExerciseId: se.id,
          exerciseId: 'ex_bench',
          setNumber: i + 1,
          weightKg: entry.weight,
          reps: entry.reps,
          isCompleted: true,
          completedAt: clock,
        );
        clock = clock.add(const Duration(minutes: 4));
        await workoutRepo.logSet(s);
        await prRepo.detectPRs(exerciseId: 'ex_bench', set: s);
      }

      final before = await prRepo.getAllRecords();
      final beforeByKey = {
        for (final r in before) '${r.recordType.name}|${r.weightKg}': r.value,
      };
      expect(beforeByKey['maxWeight|null'], 102.5);
      expect(beforeByKey['epley1rm|null'], closeTo(123.0, 0.001)); // 102.5 × (1 + 6/30)
      expect(beforeByKey['maxRepsAtWeight|102.5'], 6.0);
      expect(beforeByKey['volume|null'], 615.0);

      // Wipe and replay from scratch — same math, same result.
      await prRepo.recomputePRs('ex_bench');
      final after = await prRepo.getAllRecords();
      final afterByKey = {
        for (final r in after) '${r.recordType.name}|${r.weightKg}': r.value,
      };
      expect(afterByKey, beforeByKey);
    });

    test('recompute drops records whose best set was deleted (no stale rows)',
        () async {
      final session = await workoutRepo.startWorkout(name: 'Delete Test');
      final se = await workoutRepo.addExerciseToSession(
          sessionId: session.id, exerciseId: 'ex_bench');

      final s1 = WorkoutSet(
        id: 'set_1',
        sessionId: session.id,
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        setNumber: 1,
        weightKg: 100.0,
        reps: 5,
        isCompleted: true,
        completedAt: DateTime(2026, 8, 31, 9),
      );
      final s2 = s1.copyWith(id: 'set_2', setNumber: 2, weightKg: 105.0);
      await workoutRepo.logSet(s1);
      await workoutRepo.logSet(s2);
      await prRepo.detectPRs(exerciseId: 'ex_bench', set: s1);
      await prRepo.detectPRs(exerciseId: 'ex_bench', set: s2);

      expect(
        (await prRepo.getRecordsForExercise('ex_bench'))
            .firstWhere((r) => r.recordType == RecordType.maxWeight)
            .value,
        105.0,
      );

      // Deleting the PR set and re-deriving must restore the prior best.
      await workoutRepo.deleteSet('set_2');
      await prRepo.recomputePRs('ex_bench');

      final records = await prRepo.getRecordsForExercise('ex_bench');
      expect(
        records.firstWhere((r) => r.recordType == RecordType.maxWeight).value,
        100.0,
      );
      expect(
        records.firstWhere((r) => r.recordType == RecordType.volume).value,
        500.0,
      );
    });
  });

  group('ActiveWorkoutController PR Hook (WU-3.6 integration)', () {
    late AppDatabase db;
    late PRRepository prRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      prRepo = PRRepositoryImpl(db.prDao);

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

    test('confirming a PR set flags isPr on state and in SQLite; warm-ups never flag',
        () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider
              .overrideWithValue(WorkoutRepositoryImpl(db.workoutDao)),
          prRepositoryProvider.overrideWithValue(prRepo),
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(activeWorkoutControllerProvider.notifier);
      await controller.startWorkout(name: 'PR Hook Test');
      final se = await controller.addExercise('ex_bench');

      // First working set: 100 × 5 → beats all four fresh records.
      await controller.addSet(
        sessionExerciseId: se!.id,
        exerciseId: 'ex_bench',
        weightKg: 100,
        reps: 5,
      );
      final state1 = await container.read(activeWorkoutControllerProvider.future);
      final set1Id = state1.sets.last.id;
      await controller.toggleSetCompleted(set1Id);

      var state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.sets.firstWhere((s) => s.id == set1Id).isPr, isTrue);

      final persisted = await container
          .read(workoutRepositoryProvider)
          .getSetsForSession(state.session!.id);
      expect(persisted.firstWhere((s) => s.id == set1Id).isPr, isTrue);

      final records = await prRepo.getRecordsForExercise('ex_bench');
      expect(records.length, 4);

      // Warm-up set above every record — never counts, never flags.
      await controller.addSet(
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        weightKg: 120,
        reps: 10,
        type: SetType.warmup,
      );
      final state2 = await container.read(activeWorkoutControllerProvider.future);
      final warmupId = state2.sets.last.id;
      await controller.toggleSetCompleted(warmupId);

      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.sets.firstWhere((s) => s.id == warmupId).isPr, isFalse);
      expect((await prRepo.getRecordsForExercise('ex_bench')).length, 4);

      // Heavier working set fires again.
      await controller.addSet(
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        weightKg: 102.5,
        reps: 5,
      );
      final state3 = await container.read(activeWorkoutControllerProvider.future);
      final set3Id = state3.sets.last.id;
      await controller.toggleSetCompleted(set3Id);

      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.sets.firstWhere((s) => s.id == set3Id).isPr, isTrue);

      // Beating an existing record updates that row in place (same
      // identity); only the never-lifted weight key adds a new row.
      final finalRecords = await prRepo.getRecordsForExercise('ex_bench');
      expect(finalRecords.length, 5); // 4 base types + reps@102.5
      expect(
        finalRecords
            .firstWhere((r) => r.recordType == RecordType.maxWeight)
            .value,
        102.5,
      );
      expect(
        finalRecords.firstWhere((r) => r.recordType == RecordType.volume).value,
        512.5,
      );
      expect(
        finalRecords
            .firstWhere((r) =>
                r.recordType == RecordType.maxRepsAtWeight &&
                r.weightKg == 102.5)
            .value,
        5.0,
      );
    });
  });

  group('SetRowWidget PR Badge', () {
    WorkoutSet buildSet({required bool isPr}) => WorkoutSet(
          id: 'set_1',
          sessionId: 'ws_1',
          sessionExerciseId: 'se_1',
          exerciseId: 'ex_bench',
          setNumber: 2,
          weightKg: 100,
          reps: 5,
          isCompleted: true,
          isPr: isPr,
        );

    Future<void> pumpRow(
      WidgetTester tester, {
      required WorkoutSet workoutSet,
    }) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SetRowWidget(
            set: workoutSet,
            onUpdateSet: (_) {},
            onToggleComplete: () {},
            onDeleteSet: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the PR chip on a PR set', (tester) async {
      await pumpRow(tester, workoutSet: buildSet(isPr: true));
      expect(find.text('PR'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('hides the PR chip on a non-PR set', (tester) async {
      await pumpRow(tester, workoutSet: buildSet(isPr: false));
      expect(find.text('PR'), findsNothing);
    });
  });
}
