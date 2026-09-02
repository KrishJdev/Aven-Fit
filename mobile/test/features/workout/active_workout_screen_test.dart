import 'dart:math';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/notifications/notification_service.dart';
import 'package:aven_fit/features/workout/data/workout_local_source.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_controller.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_screen.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'fake_notification_service.dart';

void main() {
  group('ActiveWorkoutController WU-3.4 Logic', () {
    late AppDatabase db;
    late WorkoutDao workoutDao;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      workoutDao = db.workoutDao;
      workoutRepo = WorkoutRepositoryImpl(workoutDao);

      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('ex_bench'),
              name: drift.Value('Barbell Bench Press'),
            ),
          );
      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('ex_squat'),
              name: drift.Value('Barbell Back Squat'),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('generateDefaultWorkoutName picks one of the two band names (§8.1)',
        () {
      final morning = DateTime(2026, 8, 31, 7, 30);
      final midMorning = DateTime(2026, 8, 31, 10, 0);
      final afternoon = DateTime(2026, 8, 31, 14, 0);
      final evening = DateTime(2026, 8, 31, 18, 30);
      final night = DateTime(2026, 8, 31, 22, 0);
      final midnight = DateTime(2026, 8, 31, 2, 0);

      // One of the spec's two options per band — never the old
      // "both names joined" string.
      expect(
        ActiveWorkoutController.generateDefaultWorkoutName(morning),
        anyOf('Early Bird Workout', 'Dawn Patrol'),
      );
      expect(
        ActiveWorkoutController.generateDefaultWorkoutName(midMorning),
        anyOf('Morning Grind', 'Morning Workout'),
      );
      expect(
        ActiveWorkoutController.generateDefaultWorkoutName(afternoon),
        anyOf('Afternoon Pump', 'Midday Session'),
      );
      expect(
        ActiveWorkoutController.generateDefaultWorkoutName(evening),
        anyOf('Evening Workout', 'Sundown Session'),
      );
      expect(
        ActiveWorkoutController.generateDefaultWorkoutName(night),
        anyOf('Night Session', 'Late Lift'),
      );
      expect(
        ActiveWorkoutController.generateDefaultWorkoutName(midnight),
        anyOf('Late Night Lift', 'Midnight Session'),
      );

      // Deterministic with an injected Random: same seed → same pick,
      // always within the band.
      final seededPick = ActiveWorkoutController.generateDefaultWorkoutName(
        morning,
        Random(1),
      );
      expect(
        ActiveWorkoutController.generateDefaultWorkoutName(morning, Random(1)),
        seededPick,
      );
      expect(
        const ['Early Bird Workout', 'Dawn Patrol'],
        contains(seededPick),
      );
    });

    test('generateWarmupPyramid creates progressive warmup sets excluded from working volume', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );

      final controller =
          container.read(activeWorkoutControllerProvider.notifier);

      await controller.startWorkout(name: 'Pyramid Test');
      final sessionEx = await controller.addExercise('ex_bench');

      // Add a working set: 100 kg x 5 reps
      await controller.addSet(
        sessionExerciseId: sessionEx!.id,
        exerciseId: 'ex_bench',
        weightKg: 100.0,
        reps: 5,
      );

      // Generate warm-up pyramid for 100kg working weight
      await controller.generateWarmupPyramid(
        sessionExerciseId: sessionEx.id,
        exerciseId: 'ex_bench',
        workingWeightKg: 100.0,
      );

      final state =
          await container.read(activeWorkoutControllerProvider.future);
      expect(state.sets.length, 5); // 1 working set + 4 warm-up sets

      final warmupSets =
          state.sets.where((s) => s.type == SetType.warmup).toList();
      expect(warmupSets.length, 4);
      expect(warmupSets[0].weightKg, 20.0); // Empty bar
      expect(warmupSets[0].reps, 10);
      expect(warmupSets[1].weightKg, 50.0); // 50%
      expect(warmupSets[1].reps, 5);
      expect(warmupSets[2].weightKg, 70.0); // 70%
      expect(warmupSets[2].reps, 3);
      expect(warmupSets[3].weightKg, 85.0); // 85%
      expect(warmupSets[3].reps, 1);

      // Warm-up sets must precede the working set (FEATURES.md §8.1)
      expect(state.sets[0].type, SetType.warmup);
      expect(state.sets[3].type, SetType.warmup);
      expect(state.sets[4].type, SetType.normal);
      expect(state.sets[4].weightKg, 100.0);
      expect(state.sets[4].reps, 5);

      // Complete all sets
      for (final s in state.sets) {
        await controller.toggleSetCompleted(s.id);
      }

      final completedState =
          await container.read(activeWorkoutControllerProvider.future);
      expect(completedState.completedSetsCount, 5);
      // Working volume MUST strictly exclude the 4 warm-up sets per Law L1:
      // Only the working set: 100 kg * 5 = 500.0 kg
      expect(completedState.totalVolumeKg, 500.0);

      container.dispose();
    });

    test('updateSet and updateWorkoutName modify active session state immutably', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );

      final controller =
          container.read(activeWorkoutControllerProvider.notifier);

      await controller.startWorkout(name: 'Original Name');
      final sessionEx = await controller.addExercise('ex_bench');
      await controller.addSet(
        sessionExerciseId: sessionEx!.id,
        exerciseId: 'ex_bench',
        weightKg: 60.0,
        reps: 10,
      );

      var state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.session!.name, 'Original Name');
      expect(state.sets.first.weightKg, 60.0);

      // Rename workout
      await controller.updateWorkoutName('Renamed Chest Blast');
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.session!.name, 'Renamed Chest Blast');

      // Update set values
      final targetSet = state.sets.first;
      await controller.updateSet(targetSet.copyWith(weightKg: 80.0, reps: 8));
      state = await container.read(activeWorkoutControllerProvider.future);
      expect(state.sets.first.weightKg, 80.0);
      expect(state.sets.first.reps, 8);

      container.dispose();
    });
  });

  group('ActiveWorkoutScreen Widget Tests', () {
    late AppDatabase db;
    late WorkoutDao workoutDao;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      workoutDao = db.workoutDao;
      workoutRepo = WorkoutRepositoryImpl(workoutDao);

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

    testWidgets('Renders empty state when no active session, starts workout on tap',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ActiveWorkoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('NO ACTIVE WORKOUT'), findsOneWidget);
      expect(find.text('START EMPTY WORKOUT'), findsOneWidget);

      await tester.tap(find.text('START EMPTY WORKOUT'));
      await tester.pumpAndSettle();

      expect(find.text('ADD YOUR FIRST EXERCISE'), findsOneWidget);
      expect(find.text('WORKING VOLUME'), findsOneWidget);
      expect(find.text('ADD EXERCISE'), findsWidgets);
      expect(find.text('FINISH'), findsWidgets);

      container.dispose();
    });

    testWidgets('Renders exercise block, adjusts steppers, and completes set',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );

      final controller =
          container.read(activeWorkoutControllerProvider.notifier);

      await controller.startWorkout(name: 'Chest Routine');
      final sessionEx = await controller.addExercise('ex_bench');
      await controller.addSet(
        sessionExerciseId: sessionEx!.id,
        exerciseId: 'ex_bench',
        weightKg: 80.0,
        reps: 8,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ActiveWorkoutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Chest Routine'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('0 / 1'), findsOneWidget);

      // Tap + on weight stepper
      await tester.tap(find.text('+').first);
      await tester.pumpAndSettle();
      expect(find.text('82.5'), findsOneWidget);

      // Tap ✓ complete button
      final checkIcons = find.byIcon(LucideIcons.check);
      expect(checkIcons, findsWidgets);
      await tester.tap(checkIcons.first);
      await tester.pumpAndSettle();

      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text('REST TIMER:'), findsOneWidget);

      container.dispose();
    });

    testWidgets('block header opens the quick-info sheet with last performance (§8.1)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );

      // Seed history: a completed workout with one confirmed 80×8 set.
      final past = await workoutRepo.startWorkout(name: 'Past Session');
      final pastEx = await workoutRepo.addExerciseToSession(
        sessionId: past.id,
        exerciseId: 'ex_bench',
      );
      await workoutRepo.logSet(WorkoutSet(
        id: 'past_1',
        sessionId: past.id,
        sessionExerciseId: pastEx.id,
        exerciseId: 'ex_bench',
        setNumber: 1,
        weightKg: 80,
        reps: 8,
        isCompleted: true,
        completedAt: DateTime.now(),
      ));
      await workoutRepo.finishWorkout(past.id, durationSeconds: 1800);

      // Start the live session and add the same exercise block.
      final controller =
          container.read(activeWorkoutControllerProvider.notifier);
      await controller.startWorkout(name: 'Live Session');
      await controller.addExercise('ex_bench');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ActiveWorkoutScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the exercise name in the block header → quick-info sheet.
      await tester.tap(find.text('Barbell Bench Press'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('block_info_sheet')), findsOneWidget);
      expect(find.text('MUSCLES'), findsOneWidget);
      expect(find.text('LAST PERFORMANCE'), findsOneWidget);
      expect(find.text('Last: 1 set · best 80 kg × 8'), findsOneWidget);

      container.dispose();
    });

    testWidgets(
        'ISSUE-01 & ISSUE-03: Set deletion renumbers surviving sets, allows crash-free addSet, and recomputes PRs',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
          notificationServiceProvider
              .overrideWithValue(FakeNotificationService()),
        ],
      );

      final controller =
          container.read(activeWorkoutControllerProvider.notifier);
      await controller.startWorkout(name: 'PR & Set Test');
      final se = await controller.addExercise('ex_bench');

      // Add Set 1: 80kg x 8
      await controller.addSet(
        sessionExerciseId: se!.id,
        exerciseId: 'ex_bench',
        weightKg: 80.0,
        reps: 8,
      );

      // Add Set 2: 100kg x 5
      await controller.addSet(
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        weightKg: 100.0,
        reps: 5,
      );

      var state = container.read(activeWorkoutControllerProvider).value!;
      expect(state.sets.length, 2);
      expect(state.sets[0].setNumber, 1);
      expect(state.sets[1].setNumber, 2);

      // Complete Set 1 -> earns PR 80kg
      await controller.toggleSetCompleted(state.sets[0].id);
      // Complete Set 2 -> earns PR 100kg
      await controller.toggleSetCompleted(state.sets[1].id);

      var prRecords = await db.prDao.getRecordsForExercise('ex_bench');
      final maxWeightRecord =
          prRecords.firstWhere((r) => r.recordType == 'maxWeight');
      expect(maxWeightRecord.value, 100.0);

      // Delete Set 1: tests ISSUE-01 (deleting Set 1 leaves Set 2)
      final set1Id = state.sets[0].id;
      await controller.deleteSet(set1Id);

      state = container.read(activeWorkoutControllerProvider).value!;
      expect(state.sets.length, 1);
      // Surviving set must be renumbered to Set 1
      expect(state.sets[0].setNumber, 1);
      expect(state.sets[0].weightKg, 100.0);

      // Now tap addSet: this used to crash with UNIQUE constraint failed
      await controller.addSet(
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        weightKg: 105.0,
        reps: 3,
      );

      state = container.read(activeWorkoutControllerProvider).value!;
      expect(state.sets.length, 2);
      expect(state.sets[0].setNumber, 1);
      expect(state.sets[1].setNumber, 2);

      // Now uncomplete Set 1 (which holds the 100kg PR) -> ISSUE-03
      await controller.toggleSetCompleted(state.sets[0].id);
      prRecords = await db.prDao.getRecordsForExercise('ex_bench');
      // 100kg PR should be cleanly removed because no completed working set remains
      expect(prRecords.where((r) => r.recordType == 'maxWeight'), isEmpty);

      container.dispose();
    });

    testWidgets(
        'ISSUE-06: Swiping uncompleted set deletes immediately, completed set requires confirmation dialog (L7)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
          notificationServiceProvider
              .overrideWithValue(FakeNotificationService()),
        ],
      );

      final controller =
          container.read(activeWorkoutControllerProvider.notifier);
      await controller.startWorkout(name: 'Swipe Test');
      final se = await controller.addExercise('ex_bench');

      // Add Set 1 (uncompleted) and Set 2 (will be completed)
      await controller.addSet(
        sessionExerciseId: se!.id,
        exerciseId: 'ex_bench',
        weightKg: 60.0,
        reps: 10,
      );
      await controller.addSet(
        sessionExerciseId: se.id,
        exerciseId: 'ex_bench',
        weightKg: 70.0,
        reps: 8,
      );

      final stateBefore =
          container.read(activeWorkoutControllerProvider).value!;
      final set1Id = stateBefore.sets[0].id;
      final set2Id = stateBefore.sets[1].id;

      // Complete Set 2
      await controller.toggleSetCompleted(set2Id);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ActiveWorkoutScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Swipe uncompleted Set 1 -> dismisses immediately without dialog
      await tester.drag(
          find.byKey(Key('dismiss_$set1Id')), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('DELETE COMPLETED SET?'), findsNothing);
      expect(find.byKey(Key('dismiss_$set1Id')), findsNothing);

      // Swipe completed Set 2 -> dialog appears
      await tester.drag(
          find.byKey(Key('dismiss_$set2Id')), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('DELETE COMPLETED SET?'), findsOneWidget);

      // Tap CANCEL -> set remains
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(find.text('DELETE COMPLETED SET?'), findsNothing);
      expect(find.byKey(Key('dismiss_$set2Id')), findsOneWidget);

      // Swipe again and tap DELETE -> set is deleted
      await tester.drag(
          find.byKey(Key('dismiss_$set2Id')), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('dismiss_$set2Id')), findsNothing);

      container.dispose();
    });
  });
}
