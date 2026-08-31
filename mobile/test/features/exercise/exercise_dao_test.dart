import 'dart:io';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/exercise/data/exercise_local_source.dart';
import 'package:aven_fit/features/exercise/data/exercise_repository.dart';
import 'package:aven_fit/features/exercise/data/exercise_seed_loader.dart';
import 'package:aven_fit/features/exercise/domain/muscle_group.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseDao & ExerciseRepository with In-Memory Drift SQLite', () {
    late AppDatabase db;
    late ExerciseDao dao;
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
      dao = db.exerciseDao;
      repository = ExerciseRepositoryImpl(dao);

      // Seed in-memory SQLite with bundled 55 exercises and 14 muscle groups
      await ExerciseSeedLoader.seedFromJsonStrings(
        dao,
        muscleGroupsJson: muscleGroupsJson,
        exercisesJson: exercisesJson,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Seed loader populates 14 muscle groups and 55 exercises', () async {
      final mgCount = await dao.countMuscleGroups();
      final exCount = await dao.countExercises();

      expect(mgCount, 14);
      expect(exCount, 55);

      final muscles = await repository.getMuscleGroups();
      expect(muscles.length, 14);
      expect(muscles.first.name, 'Chest');
      expect(muscles.last.name, 'Lower Back');
    });

    test('Search exercises by query runs under 100ms and returns accurate results', () async {
      final stopwatch = Stopwatch()..start();
      final results = await repository.searchExercises(query: 'bench');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(results.length, 7);

      final names = results.map((e) => e.name).toList();
      expect(
        names,
        containsAll([
          'Barbell Bench Press',
          'Incline Barbell Bench Press',
          'Dumbbell Bench Press',
          'Incline Dumbbell Bench Press',
          'Close-Grip Bench Press',
        ]),
      );
    });

    test('Filter exercises by equipment and category', () async {
      final barbellExercises = await repository.searchExercises(
        category: ExerciseCategory.barbell,
      );
      for (final ex in barbellExercises) {
        expect(ex.category, ExerciseCategory.barbell);
      }
      expect(barbellExercises.isNotEmpty, isTrue);

      final dumbbellExercises = await repository.searchExercises(
        equipment: Equipment.dumbbell,
      );
      for (final ex in dumbbellExercises) {
        expect(ex.equipment, Equipment.dumbbell);
      }
      expect(dumbbellExercises.isNotEmpty, isTrue);
    });

    test('Filter exercises by muscle group', () async {
      // Chest ID: 550e8400-e29b-41d4-a716-446655440001
      const chestId = '550e8400-e29b-41d4-a716-446655440001';
      final chestExercises = await repository.searchExercises(
        muscleGroupId: chestId,
      );

      expect(chestExercises.isNotEmpty, isTrue);
      for (final ex in chestExercises) {
        final matchesChest = ex.primaryMuscle == 'Chest' ||
            ex.secondaryMuscles.contains('Chest');
        expect(matchesChest, isTrue);
      }
    });

    test('Toggle favourite updates status and streams reactively', () async {
      const benchId = 'a1b2c3d4-0000-4000-8000-000000000001';

      final initial = await repository.getExerciseById(benchId);
      expect(initial, isNotNull);
      expect(initial!.isFavourite, isFalse);

      // Toggle to true
      final newStatus = await repository.toggleFavourite(benchId);
      expect(newStatus, isTrue);

      final updated = await repository.getExerciseById(benchId);
      expect(updated!.isFavourite, isTrue);

      // Query favourites only
      final favourites =
          await repository.searchExercises(favouritesOnly: true);
      expect(favourites.length, 1);
      expect(favourites.first.id, benchId);

      // Toggle back to false
      final revertStatus = await repository.toggleFavourite(benchId);
      expect(revertStatus, isFalse);

      final emptyFavourites =
          await repository.searchExercises(favouritesOnly: true);
      expect(emptyFavourites.isEmpty, isTrue);
    });

    test('Create and delete custom exercise with muscle group associations', () async {
      // Create custom exercise
      final custom = await repository.createCustomExercise(
        name: 'Landmine Press',
        description: 'Single-arm rotational press using landmine attachment.',
        category: ExerciseCategory.barbell,
        equipment: Equipment.barbell,
        primaryMuscleGroupId: '550e8400-e29b-41d4-a716-446655440003', // Shoulders
        secondaryMuscleGroupIds: const [
          '550e8400-e29b-41d4-a716-446655440005', // Triceps
          '550e8400-e29b-41d4-a716-446655440011', // Abs
        ],
      );

      expect(custom.name, 'Landmine Press');
      expect(custom.isCustom, isTrue);
      expect(custom.primaryMuscle, 'Shoulders');
      expect(custom.secondaryMuscles, containsAll(['Triceps', 'Abs']));

      // Verify custom exercise appears in search
      final searchResults =
          await repository.searchExercises(query: 'Landmine');
      expect(searchResults.length, 1);
      expect(searchResults.first.id, custom.id);

      // Delete custom exercise
      final deleted = await repository.deleteCustomExercise(custom.id);
      expect(deleted, isTrue);

      final searchAfterDelete =
          await repository.searchExercises(query: 'Landmine');
      expect(searchAfterDelete.isEmpty, isTrue);

      // Verify built-in exercise cannot be deleted
      final deletedBuiltIn = await repository.deleteCustomExercise(
        'a1b2c3d4-0000-4000-8000-000000000001',
      );
      expect(deletedBuiltIn, isFalse);
    });
  });
}
