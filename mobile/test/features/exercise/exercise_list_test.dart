import 'dart:io';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/exercise/data/exercise_repository.dart';
import 'package:aven_fit/features/exercise/data/exercise_seed_loader.dart';
import 'package:aven_fit/features/exercise/domain/muscle_group.dart';
import 'package:aven_fit/features/exercise/presentation/exercise_list_controller.dart';
import 'package:aven_fit/features/exercise/presentation/exercise_list_screen.dart';
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

  group('ExerciseListController Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          exerciseRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial build loads muscle groups and 55 exercises', () async {
      final state = await container.read(exerciseListControllerProvider.future);

      expect(state.muscleGroups.length, 14);
      expect(state.exercises.length, 55);
      expect(state.hasActiveFilters, isFalse);
    });

    test('setSearchQuery filters exercises reactively', () async {
      final controller =
          container.read(exerciseListControllerProvider.notifier);

      await container.read(exerciseListControllerProvider.future);
      await controller.setSearchQuery('squat');

      final state = await container.read(exerciseListControllerProvider.future);
      expect(state.searchQuery, 'squat');
      expect(state.exercises.isNotEmpty, isTrue);

      for (final ex in state.exercises) {
        final matches = ex.name.toLowerCase().contains('squat') ||
            (ex.description?.toLowerCase().contains('squat') ?? false);
        expect(matches, isTrue);
      }
    });

    test('selectMuscleGroup and selectEquipment filter exercises', () async {
      final controller =
          container.read(exerciseListControllerProvider.notifier);

      await container.read(exerciseListControllerProvider.future);

      // Filter by Chest
      await controller.selectMuscleGroup('550e8400-e29b-41d4-a716-446655440001');
      var state = await container.read(exerciseListControllerProvider.future);
      expect(state.selectedMuscleGroupId, '550e8400-e29b-41d4-a716-446655440001');
      expect(state.hasActiveFilters, isTrue);

      // Filter by Barbell
      await controller.selectEquipment(Equipment.barbell);
      state = await container.read(exerciseListControllerProvider.future);
      expect(state.selectedEquipment, Equipment.barbell);

      for (final ex in state.exercises) {
        expect(ex.equipment, Equipment.barbell);
      }

      // Clear filters
      await controller.clearFilters();
      state = await container.read(exerciseListControllerProvider.future);
      expect(state.hasActiveFilters, isFalse);
      expect(state.exercises.length, 55);
    });

    test('toggleFavourite and favouritesOnly filter works correctly', () async {
      final controller =
          container.read(exerciseListControllerProvider.notifier);

      await container.read(exerciseListControllerProvider.future);

      const benchId = 'a1b2c3d4-0000-4000-8000-000000000001';
      await controller.toggleFavourite(benchId);

      var state = await container.read(exerciseListControllerProvider.future);
      final bench = state.exercises.firstWhere((e) => e.id == benchId);
      expect(bench.isFavourite, isTrue);

      // Filter favourites only
      await controller.toggleFavouritesOnly();
      state = await container.read(exerciseListControllerProvider.future);
      expect(state.favouritesOnly, isTrue);
      expect(state.exercises.length, 1);
      expect(state.exercises.first.id, benchId);
    });
  });

  group('ExerciseListScreen Widget Tests', () {
    testWidgets('Renders directory header, search bar, chips, and list tiles',
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
            home: const ExerciseListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('EXERCISE DIRECTORY'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('★ Favourites'), findsOneWidget);
      expect(find.text('Chest'), findsWidgets);
      expect(find.text('Barbell Bench Press'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'deadlift');
      await tester.pumpAndSettle();

      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsNothing);

      // Enter non-matching query to verify empty state
      await tester.enterText(find.byType(TextField), 'non_existent_exercise_xyz');
      await tester.pumpAndSettle();

      expect(find.text('No exercises match the selected filters.'), findsOneWidget);
      expect(find.text('CLEAR ALL FILTERS'), findsOneWidget);

      // Tap CLEAR ALL FILTERS
      await tester.tap(find.text('CLEAR ALL FILTERS'));
      await tester.pumpAndSettle();

      expect(find.text('Barbell Bench Press'), findsOneWidget);
    });
  });
}
