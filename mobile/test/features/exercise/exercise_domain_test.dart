import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/exercise/domain/exercise.dart';
import 'package:aven_fit/features/exercise/domain/muscle_group.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exercise & MuscleGroup Domain Entities', () {
    test('MuscleGroup immutability, defaults, and copyWith', () {
      const mg = MuscleGroup(
        id: 'mg_chest',
        name: 'Chest',
        displayOrder: 1,
      );

      final updated = mg.copyWith(displayOrder: 2);

      expect(mg.displayOrder, 1);
      expect(updated.displayOrder, 2);
      expect(updated.id, 'mg_chest');
      expect(updated.name, 'Chest');
    });

    test('Exercise immutability, defaults, and aliases', () {
      const exercise = Exercise(
        id: 'ex_bench',
        name: 'Barbell Bench Press',
        description: 'Lie on flat bench, press barbell upwards.',
        category: ExerciseCategory.barbell,
        equipment: Equipment.barbell,
        primaryMuscle: 'Chest',
        secondaryMuscles: ['Triceps', 'Shoulders'],
      );

      expect(exercise.isCustom, isFalse);
      expect(exercise.isFavourite, isFalse);
      expect(exercise.isTimeBased, isFalse);
      expect(exercise.isCardio, isFalse);

      // Verify convenience aliases
      expect(exercise.instructions, 'Lie on flat bench, press barbell upwards.');
      expect(exercise.muscleGroupPrimary, 'Chest');
      expect(exercise.muscleGroupsSecondary, ['Triceps', 'Shoulders']);
      expect(exercise.equipmentType, Equipment.barbell);

      final favExercise = exercise.copyWith(isFavourite: true);
      expect(exercise.isFavourite, isFalse);
      expect(favExercise.isFavourite, isTrue);
    });

    test('JSON serialization round-trip for Exercise and enums', () {
      final now = DateTime.parse('2026-08-31T05:00:00.000Z');
      final exercise = Exercise(
        id: '550e8400-e29b-41d4-a716-446655440001',
        name: 'Incline Dumbbell Press',
        description: 'Set bench to 30 degrees incline.',
        category: ExerciseCategory.dumbbell,
        equipment: Equipment.dumbbell,
        isCustom: true,
        isFavourite: true,
        primaryMuscle: 'Chest',
        secondaryMuscles: const ['Triceps', 'Shoulders'],
        muscleRefs: const [
          ExerciseMuscleRef(
            muscleGroupId: 'mg_chest',
            name: 'Chest',
            role: MuscleRole.primary,
          ),
          ExerciseMuscleRef(
            muscleGroupId: 'mg_triceps',
            name: 'Triceps',
            role: MuscleRole.secondary,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      final json = exercise.toJson();
      expect(json['category'], 'DUMBBELL');
      expect(json['equipment'], 'DUMBBELL');
      expect(json['isCustom'], isTrue);
      expect(json['isFavourite'], isTrue);

      final deserialized = Exercise.fromJson(json);
      expect(deserialized.id, exercise.id);
      expect(deserialized.name, exercise.name);
      expect(deserialized.category, ExerciseCategory.dumbbell);
      expect(deserialized.equipment, Equipment.dumbbell);
      expect(deserialized.muscleRefs.length, 2);
      expect(deserialized.muscleRefs.first.role, MuscleRole.primary);
      expect(deserialized.muscleRefs.last.role, MuscleRole.secondary);
    });
  });

  group('Drift SQLite Exercise Tables Integration', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Insert and query MuscleGroups, Exercises, and ExerciseMuscleGroups', () async {
      // 1. Insert muscle groups
      await db.into(db.muscleGroups).insert(
            MuscleGroupsCompanion.insert(
              id: 'mg_1',
              name: 'Chest',
              displayOrder: const Value(1),
            ),
          );
      await db.into(db.muscleGroups).insert(
            MuscleGroupsCompanion.insert(
              id: 'mg_2',
              name: 'Triceps',
              displayOrder: const Value(5),
            ),
          );

      final muscles = await db.select(db.muscleGroups).get();
      expect(muscles.length, 2);

      // 2. Insert exercise
      await db.into(db.exercises).insert(
            ExercisesCompanion.insert(
              id: 'ex_1',
              name: 'Barbell Bench Press',
              description: const Value('Flat bench press'),
              category: const Value('BARBELL'),
              equipment: const Value('BARBELL'),
              isCustom: const Value(false),
              isFavourite: const Value(true),
            ),
          );

      final exerciseRows = await db.select(db.exercises).get();
      expect(exerciseRows.length, 1);
      expect(exerciseRows.first.name, 'Barbell Bench Press');
      expect(exerciseRows.first.isFavourite, isTrue);

      // 3. Link exercise to muscle groups
      await db.into(db.exerciseMuscleGroups).insert(
            ExerciseMuscleGroupsCompanion.insert(
              id: 'emg_1',
              exerciseId: 'ex_1',
              muscleGroupId: 'mg_1',
              role: const Value('PRIMARY'),
            ),
          );
      await db.into(db.exerciseMuscleGroups).insert(
            ExerciseMuscleGroupsCompanion.insert(
              id: 'emg_2',
              exerciseId: 'ex_1',
              muscleGroupId: 'mg_2',
              role: const Value('SECONDARY'),
            ),
          );

      final emgRows = await db.select(db.exerciseMuscleGroups).get();
      expect(emgRows.length, 2);

      // 4. Cascade delete: deleting exercise should cascade delete ExerciseMuscleGroups
      await (db.delete(db.exercises)..where((tbl) => tbl.id.equals('ex_1'))).go();
      final remainingEmg = await db.select(db.exerciseMuscleGroups).get();
      expect(remainingEmg.isEmpty, isTrue);
    });
  });
}
