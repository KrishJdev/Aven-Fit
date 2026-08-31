import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/exercise/domain/exercise.dart';
import 'package:aven_fit/features/exercise/domain/muscle_group.dart';
import 'package:aven_fit/features/routine/data/routine_local_source.dart';
import 'package:aven_fit/features/routine/data/routine_repository.dart';
import 'package:aven_fit/features/routine/domain/routine_exercise.dart';
import 'package:aven_fit/features/routine/domain/routine_set.dart';
import 'package:aven_fit/features/routine/presentation/routine_editor_controller.dart';
import 'package:aven_fit/features/routine/presentation/routine_editor_screen.dart';
import 'package:aven_fit/features/routine/presentation/routine_exercise_editor_sheet.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RoutineDao routineDao;
  late RoutineRepository routineRepo;

  final testBenchExercise = const Exercise(
    id: 'ex-bench',
    name: 'Barbell Bench Press',
    category: ExerciseCategory.barbell,
    equipment: Equipment.barbell,
  );

  final testSquatExercise = const Exercise(
    id: 'ex-squat',
    name: 'Barbell Back Squat',
    category: ExerciseCategory.barbell,
    equipment: Equipment.barbell,
  );

  final testRowExercise = const Exercise(
    id: 'ex-row',
    name: 'Barbell Bent Over Row',
    category: ExerciseCategory.barbell,
    equipment: Equipment.barbell,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    routineDao = db.routineDao;
    routineRepo = RoutineRepositoryImpl(routineDao);

    // Seed test exercises
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: Value('ex-bench'),
            name: Value('Barbell Bench Press'),
          ),
        );
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: Value('ex-squat'),
            name: Value('Barbell Back Squat'),
          ),
        );
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: Value('ex-row'),
            name: Value('Barbell Bent Over Row'),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('RoutineEditorController Unit Tests', () {
    test('Initializes with empty state for new routine', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
        ],
      );

      final state =
          await container.read(routineEditorControllerProvider(null).future);
      expect(state.isNew, isTrue);
      expect(state.name, isEmpty);
      expect(state.exercises, isEmpty);
      expect(state.totalSets, 0);
      expect(state.estimatedDurationMinutes, 0);
    });

    test('Loads existing routine and allows mutation & save', () async {
      final created = await routineRepo.createRoutine(
        name: 'Full Body A',
        description: 'Compound movements',
        exercises: [
          RoutineExercise(
            id: 're-1',
            routineId: '',
            exerciseId: 'ex-bench',
            exercise: testBenchExercise,
            orderIndex: 0,
            restSeconds: 90,
            targetSetsCount: 3,
            targetWeightKg: 80.0,
            targetReps: 8,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
        ],
      );

      final controller =
          container.read(routineEditorControllerProvider(created.id).notifier);
      final initialState =
          await container.read(routineEditorControllerProvider(created.id).future);

      expect(initialState.isNew, isFalse);
      expect(initialState.name, 'Full Body A');
      expect(initialState.exercises.length, 1);

      // Add second exercise
      controller.addExercise(testSquatExercise);
      var state = container.read(routineEditorControllerProvider(created.id)).value!;
      expect(state.exercises.length, 2);
      expect(state.exercises[1].exerciseId, 'ex-squat');

      // Update name
      controller.updateName('Full Body Hypertrophy');
      state = container.read(routineEditorControllerProvider(created.id)).value!;
      expect(state.name, 'Full Body Hypertrophy');

      // Save changes
      final saved = await controller.saveRoutine();
      expect(saved, isTrue);

      final updatedInDb = await routineRepo.getRoutineById(created.id);
      expect(updatedInDb!.name, 'Full Body Hypertrophy');
      expect(updatedInDb.exercises.length, 2);
    });

    test('addExercise, updateExercise, reorderExercises, and removeExercise',
        () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
        ],
      );

      final controller =
          container.read(routineEditorControllerProvider(null).notifier);
      await container.read(routineEditorControllerProvider(null).future);

      // Add exercises
      controller.addExercise(testBenchExercise);
      controller.addExercise(testSquatExercise);
      controller.addExercise(testRowExercise);

      var state = container.read(routineEditorControllerProvider(null)).value!;
      expect(state.exercises.length, 3);
      expect(state.exercises[0].exerciseId, 'ex-bench');
      expect(state.exercises[1].exerciseId, 'ex-squat');
      expect(state.exercises[2].exerciseId, 'ex-row');

      // Reorder exercise 0 (bench) to index 2
      controller.reorderExercises(0, 3);
      state = container.read(routineEditorControllerProvider(null)).value!;
      expect(state.exercises[0].exerciseId, 'ex-squat');
      expect(state.exercises[1].exerciseId, 'ex-row');
      expect(state.exercises[2].exerciseId, 'ex-bench');

      // Update targets of first exercise
      final updatedSquat = state.exercises[0].copyWith(
        targetWeightKg: 100.0,
        targetReps: 5,
        restSeconds: 120,
      );
      controller.updateExercise(0, updatedSquat);
      state = container.read(routineEditorControllerProvider(null)).value!;
      expect(state.exercises[0].targetWeightKg, 100.0);
      expect(state.exercises[0].restSeconds, 120);

      // Remove row (index 1)
      controller.removeExercise(1);
      state = container.read(routineEditorControllerProvider(null)).value!;
      expect(state.exercises.length, 2);
      expect(state.exercises[0].exerciseId, 'ex-squat');
      expect(state.exercises[1].exerciseId, 'ex-bench');
    });

    test('saveRoutine validates non-empty name', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
        ],
      );

      final controller =
          container.read(routineEditorControllerProvider(null).notifier);
      await container.read(routineEditorControllerProvider(null).future);

      final result = await controller.saveRoutine();
      expect(result, isFalse);

      final state = container.read(routineEditorControllerProvider(null)).value!;
      expect(state.errorMessage, contains('Routine name cannot be empty'));
    });
  });

  group('RoutineExerciseEditorSheet & RoutineEditorScreen Widget Tests', () {
    testWidgets('RoutineExerciseEditorSheet edits planned sets, rest, and weights',
        (tester) async {
      RoutineExercise? savedResult;

      final initialExercise = RoutineExercise(
        id: 're-test',
        routineId: 'r-1',
        exerciseId: 'ex-bench',
        exercise: testBenchExercise,
        orderIndex: 0,
        restSeconds: 90,
        targetSetsCount: 3,
        targetWeightKg: 60.0,
        targetReps: 10,
        sets: const [
          RoutineSet(
            id: 'rs-1',
            routineExerciseId: 're-test',
            position: 1,
            targetWeightKg: 60.0,
            targetReps: 10,
          ),
          RoutineSet(
            id: 'rs-2',
            routineExerciseId: 're-test',
            position: 2,
            targetWeightKg: 60.0,
            targetReps: 10,
          ),
          RoutineSet(
            id: 'rs-3',
            routineExerciseId: 're-test',
            position: 3,
            targetWeightKg: 60.0,
            targetReps: 10,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoutineExerciseEditorSheet(
              exercise: initialExercise,
              onSave: (updated) {
                savedResult = updated;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('3 SETS'), findsOneWidget);

      // Select 120s rest
      await tester.tap(find.text('120s'));
      await tester.pumpAndSettle();

      // Tap Confirm Targets
      await tester.ensureVisible(find.text('CONFIRM TARGETS'));
      await tester.tap(find.text('CONFIRM TARGETS'));
      await tester.pumpAndSettle();

      expect(savedResult, isNotNull);
      expect(savedResult!.restSeconds, 120);
    });

    testWidgets('RoutineEditorScreen renders form fields and validates name',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: RoutineEditorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('NEW ROUTINE'), findsOneWidget);
      expect(find.text('ROUTINE DETAILS'), findsOneWidget);
      expect(find.text('EXERCISES'), findsNWidgets(2));
      expect(find.text('No exercises added yet'), findsOneWidget);
      expect(find.text('ADD EXERCISE'), findsOneWidget);

      // Tap SAVE without name -> trigger error banner
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('Routine name cannot be empty'), findsOneWidget);

      // Enter name
      await tester.enterText(
        find.widgetWithText(TextField, 'Routine Name *'),
        'PPL Push A',
      );
      await tester.pumpAndSettle();

      expect(find.text('PPL Push A'), findsOneWidget);
    });
  });
}
