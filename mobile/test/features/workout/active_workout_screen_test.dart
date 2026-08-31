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

    test('generateDefaultWorkoutName returns correct names for time periods', () {
      final morning = DateTime(2026, 8, 31, 7, 30);
      expect(ActiveWorkoutController.generateDefaultWorkoutName(morning),
          'Early Bird Workout · Dawn Patrol');

      final midMorning = DateTime(2026, 8, 31, 10, 0);
      expect(ActiveWorkoutController.generateDefaultWorkoutName(midMorning),
          'Morning Grind · Morning Workout');

      final afternoon = DateTime(2026, 8, 31, 14, 0);
      expect(ActiveWorkoutController.generateDefaultWorkoutName(afternoon),
          'Afternoon Pump · Midday Session');

      final evening = DateTime(2026, 8, 31, 18, 30);
      expect(ActiveWorkoutController.generateDefaultWorkoutName(evening),
          'Evening Workout · Sundown Session');

      final night = DateTime(2026, 8, 31, 22, 0);
      expect(ActiveWorkoutController.generateDefaultWorkoutName(night),
          'Night Session · Late Lift');

      final midnight = DateTime(2026, 8, 31, 2, 0);
      expect(ActiveWorkoutController.generateDefaultWorkoutName(midnight),
          'Midnight Session · Night Owl Lift');
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
  });
}
