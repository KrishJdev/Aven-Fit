import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/exercise/data/exercise_local_source.dart';
import 'package:aven_fit/features/exercise/data/exercise_repository.dart';
import 'package:aven_fit/features/exercise/domain/exercise.dart';
import 'package:aven_fit/features/exercise/domain/muscle_group.dart';
import 'package:aven_fit/features/workout/data/workout_local_source.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/features/workout/presentation/exercise_picker_controller.dart';
import 'package:aven_fit/features/workout/presentation/exercise_picker_screen.dart';
import 'package:aven_fit/features/workout/presentation/exercise_picker_state.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExercisePickerState Filtering Logic', () {
    final exercises = [
      const Exercise(
        id: 'bench',
        name: 'Barbell Bench Press',
        primaryMuscle: 'mg_chest',
        equipment: Equipment.barbell,
        isFavourite: true,
      ),
      const Exercise(
        id: 'db_incline',
        name: 'Incline Dumbbell Press',
        primaryMuscle: 'mg_chest',
        equipment: Equipment.dumbbell,
        isFavourite: false,
      ),
      const Exercise(
        id: 'squat',
        name: 'Barbell Back Squat',
        primaryMuscle: 'mg_legs',
        equipment: Equipment.barbell,
        isFavourite: false,
      ),
    ];

    test('Filters by search query', () {
      final state = ExercisePickerState(
        allExercises: exercises,
        searchQuery: 'bench',
      );
      expect(state.hasActiveFilters, isTrue);
      expect(state.filteredExercises.length, 1);
      expect(state.filteredExercises.first.name, 'Barbell Bench Press');
    });

    test('Filters by muscle group and equipment', () {
      var state = ExercisePickerState(
        allExercises: exercises,
        selectedMuscleGroupId: 'mg_chest',
      );
      expect(state.filteredExercises.length, 2);

      state = state.copyWith(selectedEquipment: Equipment.dumbbell);
      expect(state.filteredExercises.length, 1);
      expect(state.filteredExercises.first.id, 'db_incline');
    });

    test('Filters by favourites only', () {
      final state = ExercisePickerState(
        allExercises: exercises,
        favouritesOnly: true,
      );
      expect(state.filteredExercises.length, 1);
      expect(state.filteredExercises.first.id, 'bench');
    });

    test('Filters by recent only', () {
      final state = ExercisePickerState(
        allExercises: exercises,
        recentExercises: [exercises[2]], // Squat is recent
        showRecentOnly: true,
      );
      expect(state.filteredExercises.length, 1);
      expect(state.filteredExercises.first.id, 'squat');
    });
  });

  group('ExercisePickerController & SQLite History Integration', () {
    late AppDatabase db;
    late ExerciseDao exerciseDao;
    late ExerciseRepository exerciseRepo;
    late WorkoutDao workoutDao;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      exerciseDao = db.exerciseDao;
      exerciseRepo = ExerciseRepositoryImpl(exerciseDao);
      workoutDao = db.workoutDao;
      workoutRepo = WorkoutRepositoryImpl(workoutDao);

      // Seed exercises and muscle groups
      await db.into(db.muscleGroups).insert(
            const MuscleGroupsCompanion(
              id: drift.Value('mg_chest'),
              name: drift.Value('Chest'),
            ),
          );
      await db.into(db.muscleGroups).insert(
            const MuscleGroupsCompanion(
              id: drift.Value('mg_legs'),
              name: drift.Value('Legs'),
            ),
          );

      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('ex_bench'),
              name: drift.Value('Barbell Bench Press'),
              category: drift.Value('CHEST'),
              equipment: drift.Value('BARBELL'),
              isFavourite: drift.Value(true),
            ),
          );
      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('ex_squat'),
              name: drift.Value('Barbell Back Squat'),
              category: drift.Value('LEGS'),
              equipment: drift.Value('BARBELL'),
            ),
          );
      await db.into(db.exercises).insert(
            const ExercisesCompanion(
              id: drift.Value('ex_overhead_press'),
              name: drift.Value('Overhead Press'),
              category: drift.Value('SHOULDERS'),
              equipment: drift.Value('BARBELL'),
            ),
          );

      // Log a completed workout containing squat to establish history
      final session = await workoutRepo.startWorkout(name: 'Leg Day');
      final se = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_squat',
      );
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'set_sq_1',
          sessionId: session.id,
          sessionExerciseId: se.id,
          exerciseId: 'ex_squat',
          setNumber: 1,
          weightKg: 100.0,
          reps: 5,
        ),
      );
      await workoutRepo.finishWorkout(session.id);
    });

    tearDown(() async {
      await db.close();
    });

    test('Controller loads exercises, muscle groups, and recent history', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      final state =
          await container.read(exercisePickerControllerProvider.future);
      expect(state.allExercises.length, 3);
      expect(state.muscleGroups.length, 2);
      expect(state.recentExercises.length, 1);
      expect(state.recentExercises.first.id, 'ex_squat');

      final controller =
          container.read(exercisePickerControllerProvider.notifier);

      // Test Search query filter
      controller.updateSearchQuery('Bench');
      var updatedState =
          await container.read(exercisePickerControllerProvider.future);
      expect(updatedState.filteredExercises.length, 1);
      expect(updatedState.filteredExercises.first.name, 'Barbell Bench Press');

      // Test Clear filters
      controller.clearFilters();
      updatedState =
          await container.read(exercisePickerControllerProvider.future);
      expect(updatedState.hasActiveFilters, isFalse);
      expect(updatedState.filteredExercises.length, 3);

      container.dispose();
    });

    test('Controller toggles favourites optimistically and persists to SQLite', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      final controller =
          container.read(exercisePickerControllerProvider.notifier);

      await container.read(exercisePickerControllerProvider.future);
      await controller.toggleFavourite('ex_squat');
      final updatedState =
          await container.read(exercisePickerControllerProvider.future);
      final squat =
          updatedState.allExercises.firstWhere((e) => e.id == 'ex_squat');
      expect(squat.isFavourite, isTrue);

      final fromDb = await exerciseRepo.getExerciseById('ex_squat');
      expect(fromDb!.isFavourite, isTrue);

      container.dispose();
    });
  });

  group('ExercisePickerScreen Widget Tests', () {
    late AppDatabase db;
    late ExerciseDao exerciseDao;
    late ExerciseRepository exerciseRepo;
    late WorkoutDao workoutDao;
    late WorkoutRepository workoutRepo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      exerciseDao = db.exerciseDao;
      exerciseRepo = ExerciseRepositoryImpl(exerciseDao);
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

    testWidgets('Renders search bar, header, and list tiles', (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ExercisePickerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ADD EXERCISE'), findsOneWidget);
      expect(find.text('CUSTOM'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Barbell Back Squat'), findsOneWidget);
      expect(find.text('★ Favourites'), findsOneWidget);

      // Search filtering
      await tester.enterText(find.byType(TextField), 'Squat');
      await tester.pumpAndSettle();

      expect(find.text('Barbell Back Squat'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsNothing);

      // Empty state
      await tester.enterText(find.byType(TextField), 'Nonexistent Exercise');
      await tester.pumpAndSettle();

      expect(find.text('NO EXERCISE FOUND FOR "Nonexistent Exercise"'),
          findsOneWidget);
      expect(find.text('CLEAR FILTERS'), findsOneWidget);
      expect(find.text('CREATE CUSTOM'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Tapping exercise invokes onExerciseSelected callback and pops',
        (tester) async {
      Exercise? selected;
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ExercisePickerScreen(
              onExerciseSelected: (ex) {
                selected = ex;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Barbell Bench Press'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'ex_bench');
      expect(selected!.name, 'Barbell Bench Press');

      container.dispose();
    });
  });
}
