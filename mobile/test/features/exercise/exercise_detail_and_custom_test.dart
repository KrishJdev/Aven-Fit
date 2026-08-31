import 'dart:io';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/exercise/data/exercise_repository.dart';
import 'package:aven_fit/features/exercise/data/exercise_seed_loader.dart';
import 'package:aven_fit/features/exercise/domain/muscle_group.dart';
import 'package:aven_fit/features/exercise/presentation/create_custom_exercise_controller.dart';
import 'package:aven_fit/features/exercise/presentation/create_custom_exercise_screen.dart';
import 'package:aven_fit/features/exercise/presentation/exercise_detail_controller.dart';
import 'package:aven_fit/features/exercise/presentation/exercise_detail_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ExerciseRepository repository;
  late String muscleGroupsJson;
  late String exercisesJson;

  setUpAll(() async {
    muscleGroupsJson =
        await File('assets/data/muscle_groups.json').readAsString();
    exercisesJson = await File('assets/data/exercises.json').readAsString();
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = ExerciseRepositoryImpl(db.exerciseDao);

    // Seed in-memory database
    await ExerciseSeedLoader.seedFromJsonStrings(
      db.exerciseDao,
      muscleGroupsJson: muscleGroupsJson,
      exercisesJson: exercisesJson,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ExerciseDetailController & ExerciseDetailScreen Tests', () {
    test('ExerciseDetailController loads exercise and toggles favourite', () async {
      final container = ProviderContainer(
        overrides: [
          exerciseRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      const benchId = 'a1b2c3d4-0000-4000-8000-000000000001';
      final exercise =
          await container.read(exerciseDetailControllerProvider(benchId).future);

      expect(exercise, isNotNull);
      expect(exercise!.name, 'Barbell Bench Press');
      expect(exercise.primaryMuscle, 'Chest');
      expect(exercise.isFavourite, isFalse);

      // Toggle favourite
      final controller =
          container.read(exerciseDetailControllerProvider(benchId).notifier);
      await controller.toggleFavourite();

      final updated =
          await container.read(exerciseDetailControllerProvider(benchId).future);
      expect(updated!.isFavourite, isTrue);
    });

    testWidgets('ExerciseDetailScreen renders instructions, anatomy, and badges',
        (tester) async {
      const benchId = 'a1b2c3d4-0000-4000-8000-000000000001';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppTheme.oledBlack,
            ),
            home: const ExerciseDetailScreen(exerciseId: benchId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('EXERCISE DETAIL'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('INSTRUCTIONS & FORM NOTES'), findsOneWidget);
      expect(find.text('TARGET ANATOMY'), findsOneWidget);
      expect(find.text('PERFORMANCE HISTORY & PRs'), findsOneWidget);
      expect(find.text('DELETE CUSTOM EXERCISE'), findsNothing); // Built-in exercise
    });
  });

  group('CreateCustomExerciseController & CreateCustomExerciseScreen Tests', () {
    test('CreateCustomExerciseController validates empty and duplicate names',
        () async {
      final container = ProviderContainer(
        overrides: [
          exerciseRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(createCustomExerciseControllerProvider.notifier);

      // 1. Empty name should throw
      expect(
        () => controller.createExercise(
          name: '',
          primaryMuscleGroupId: '550e8400-e29b-41d4-a716-446655440001',
          equipment: Equipment.barbell,
          category: ExerciseCategory.barbell,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // 2. Duplicate name should throw (Barbell Bench Press exists)
      expect(
        () => controller.createExercise(
          name: 'Barbell Bench Press',
          primaryMuscleGroupId: '550e8400-e29b-41d4-a716-446655440001',
          equipment: Equipment.barbell,
          category: ExerciseCategory.barbell,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // 3. Unique name should succeed
      final created = await controller.createExercise(
        name: 'Z-Press',
        description: 'Seated overhead press on the floor.',
        primaryMuscleGroupId: '550e8400-e29b-41d4-a716-446655440003', // Shoulders
        secondaryMuscleGroupIds: const [
          '550e8400-e29b-41d4-a716-446655440005', // Triceps
        ],
        equipment: Equipment.barbell,
        category: ExerciseCategory.barbell,
      );

      expect(created.name, 'Z-Press');
      expect(created.isCustom, isTrue);
      expect(created.primaryMuscle, 'Shoulders');
      expect(created.secondaryMuscles, contains('Triceps'));
    });

    testWidgets('CreateCustomExerciseScreen renders form and validates inputs',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exerciseRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppTheme.oledBlack,
            ),
            home: const CreateCustomExerciseScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CREATE CUSTOM EXERCISE'), findsOneWidget);
      expect(find.text('EXERCISE NAME *'), findsOneWidget);
      expect(find.text('PRIMARY MUSCLE DRIVER *'), findsOneWidget);
      expect(find.text('SAVE CUSTOM EXERCISE'), findsOneWidget);

      // Tap SAVE without name to trigger validation
      await tester.ensureVisible(find.text('SAVE CUSTOM EXERCISE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SAVE CUSTOM EXERCISE'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an exercise name'), findsOneWidget);
    });
  });
}
