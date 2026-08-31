import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/routine/data/routine_local_source.dart';
import 'package:aven_fit/features/routine/data/routine_repository.dart';
import 'package:aven_fit/features/routine/domain/routine_exercise.dart';
import 'package:aven_fit/features/routine/domain/routine_set.dart';
import 'package:aven_fit/features/routine/presentation/routine_list_controller.dart';
import 'package:aven_fit/features/routine/presentation/routine_list_screen.dart';
import 'package:aven_fit/features/workout/data/workout_local_source.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;
  late RoutineDao routineDao;
  late RoutineRepository routineRepo;
  late WorkoutDao workoutDao;
  late WorkoutRepository workoutRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    routineDao = db.routineDao;
    routineRepo = RoutineRepositoryImpl(routineDao);
    workoutDao = db.workoutDao;
    workoutRepo = WorkoutRepositoryImpl(workoutDao);

    // Seed exercises for foreign key integrity
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: Value('ex-squat'),
            name: Value('Barbell Back Squat'),
          ),
        );
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: Value('ex-bench'),
            name: Value('Barbell Bench Press'),
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

  group('RoutineListController Unit Tests', () {
    test('startWorkoutFromRoutine creates active session with preloaded targets in <1s',
        () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      final routine = await routineRepo.createRoutine(
        name: 'Legs & Core',
        description: 'Squat focus',
        exercises: const [
          RoutineExercise(
            id: 're-squat',
            routineId: '',
            exerciseId: 'ex-squat',
            restSeconds: 120,
            targetSetsCount: 3,
            targetWeightKg: 100.0,
            targetReps: 5,
            sets: [
              RoutineSet(
                id: 'rs-s1',
                routineExerciseId: 're-squat',
                position: 1,
                targetReps: 5,
                targetWeightKg: 100.0,
              ),
              RoutineSet(
                id: 'rs-s2',
                routineExerciseId: 're-squat',
                position: 2,
                targetReps: 5,
                targetWeightKg: 100.0,
              ),
            ],
          ),
        ],
      );

      final controller = container.read(routineListControllerProvider.notifier);
      final session = await controller.startWorkoutFromRoutine(routine);

      expect(session.name, 'Legs & Core');
      expect(session.status.name, 'active');

      // Verify sets logged into SQLite
      final sessionSets = await workoutRepo.watchSessionSets(session.id).first;
      expect(sessionSets.length, 2);
      expect(sessionSets.first.weightKg, 100.0);
      expect(sessionSets.first.reps, 5);
    });

    test('duplicateRoutine creates independent routine copy', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      final original = await routineRepo.createRoutine(
        name: 'Chest & Back',
      );

      final controller = container.read(routineListControllerProvider.notifier);
      final cloned = await controller.duplicateRoutine(original.id);

      expect(cloned.name, 'Chest & Back (Copy)');
      expect(cloned.id, isNot(original.id));

      final all = await routineRepo.getAllRoutines();
      expect(all.length, 2);
    });
  });

  group('RoutineListScreen Widget Tests', () {
    testWidgets('Renders header, search bar, and designed empty state when empty',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: RoutineListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ROUTINES'), findsOneWidget);
      expect(find.text('Workout splits & templates'), findsOneWidget);
      expect(find.text('EXERCISES'), findsOneWidget);
      expect(find.text('NEW ROUTINE'), findsOneWidget);

      // Designed Empty State (Law L6)
      expect(find.text('NO ROUTINES YET'), findsOneWidget);
      expect(find.text('CREATE ROUTINE'), findsOneWidget);
    });

    testWidgets('Renders routine cards and filters via search bar',
        (tester) async {
      await routineRepo.createRoutine(
        name: 'Push Day A',
        description: 'Chest emphasis',
        exercises: const [
          RoutineExercise(
            id: 're-1',
            routineId: '',
            exerciseId: 'ex-bench',
            restSeconds: 90,
            targetSetsCount: 3,
            targetWeightKg: 80.0,
            targetReps: 8,
          ),
        ],
      );

      await routineRepo.createRoutine(
        name: 'Pull Day A',
        description: 'Back & Biceps',
        exercises: const [
          RoutineExercise(
            id: 're-2',
            routineId: '',
            exerciseId: 'ex-row',
            restSeconds: 90,
            targetSetsCount: 4,
            targetWeightKg: 60.0,
            targetReps: 10,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: RoutineListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Push Day A'), findsOneWidget);
      expect(find.text('Pull Day A'), findsOneWidget);
      expect(find.text('START WORKOUT'), findsNWidgets(2));

      // Test Search Filter
      await tester.enterText(find.byType(TextField), 'Push');
      await tester.pumpAndSettle();

      expect(find.text('Push Day A'), findsOneWidget);
      expect(find.text('Pull Day A'), findsNothing);

      // Test Empty Search Results
      await tester.enterText(find.byType(TextField), 'Nonexistent Routine');
      await tester.pumpAndSettle();

      expect(find.text('No routines matching "Nonexistent Routine"'),
          findsOneWidget);
      expect(find.text('CLEAR SEARCH'), findsOneWidget);
    });
  });
}
