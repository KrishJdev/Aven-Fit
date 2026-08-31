import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/exercise/domain/exercise.dart';
import 'package:aven_fit/features/exercise/domain/muscle_group.dart';
import 'package:aven_fit/features/routine/data/routine_local_source.dart';
import 'package:aven_fit/features/routine/data/routine_repository.dart';
import 'package:aven_fit/features/routine/domain/routine_exercise.dart';
import 'package:aven_fit/features/routine/domain/routine_set.dart';
import 'package:aven_fit/features/routine/presentation/routine_detail_controller.dart';
import 'package:aven_fit/features/routine/presentation/routine_detail_screen.dart';
import 'package:aven_fit/features/workout/data/workout_local_source.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late RoutineDao routineDao;
  late RoutineRepository routineRepo;
  late WorkoutDao workoutDao;
  late WorkoutRepository workoutRepo;

  final testBenchExercise = const Exercise(
    id: 'ex-bench',
    name: 'Barbell Bench Press',
    category: ExerciseCategory.barbell,
    equipment: Equipment.barbell,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    routineDao = db.routineDao;
    routineRepo = RoutineRepositoryImpl(routineDao);
    workoutDao = db.workoutDao;
    workoutRepo = WorkoutRepositoryImpl(workoutDao);

    // Seed test exercises
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: Value('ex-bench'),
            name: Value('Barbell Bench Press'),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('RoutineDetailController Unit Tests', () {
    test('startWorkout creates live session and leaves routine unmutated (Law L7)',
        () async {
      final created = await routineRepo.createRoutine(
        name: 'Heavy Push',
        description: 'Focus on 5x5 bench press',
        exercises: [
          RoutineExercise(
            id: 're-push-1',
            routineId: '',
            exerciseId: 'ex-bench',
            exercise: testBenchExercise,
            orderIndex: 0,
            restSeconds: 180,
            targetSetsCount: 3,
            targetWeightKg: 90.0,
            targetReps: 5,
            sets: const [
              RoutineSet(
                id: 'rs-p1',
                routineExerciseId: 're-push-1',
                position: 1,
                targetWeightKg: 90.0,
                targetReps: 5,
                targetRpe: 8.5,
              ),
              RoutineSet(
                id: 'rs-p2',
                routineExerciseId: 're-push-1',
                position: 2,
                targetWeightKg: 90.0,
                targetReps: 5,
                targetRpe: 9.0,
              ),
            ],
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

      final controller =
          container.read(routineDetailControllerProvider(created.id).notifier);
      final session = await controller.startWorkout();

      expect(session, isNotNull);
      expect(session!.name, 'Heavy Push');
      expect(session.status.name, 'active');

      // Verify sets logged into SQLite for this workout session
      final sessionSets = await workoutRepo.watchSessionSets(session.id).first;
      expect(sessionSets.length, 2);
      expect(sessionSets[0].weightKg, 90.0);
      expect(sessionSets[0].reps, 5);
      expect(sessionSets[0].rpe, 8.5);
      expect(sessionSets[1].rpe, 9.0);

      // Verify routine in SQLite is 100% UNMUTATED (Law L7)
      final routineAfter = await routineRepo.getRoutineById(created.id);
      expect(routineAfter!.name, 'Heavy Push');
      expect(routineAfter.exercises.length, 1);
      expect(routineAfter.exercises[0].sets.length, 2);
    });

    test('duplicateRoutine and deleteRoutine operations', () async {
      final created = await routineRepo.createRoutine(
        name: 'Arm Day',
        description: 'Biceps & Triceps',
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(routineRepo),
          workoutRepositoryProvider.overrideWithValue(workoutRepo),
        ],
      );

      final controller =
          container.read(routineDetailControllerProvider(created.id).notifier);

      final cloned = await controller.duplicateRoutine();
      expect(cloned.name, 'Arm Day (Copy)');

      final deleted = await controller.deleteRoutine();
      expect(deleted, isTrue);

      final routineAfter = await routineRepo.getRoutineById(created.id);
      expect(routineAfter, isNull);
    });
  });

  group('RoutineDetailScreen Widget Tests', () {
    testWidgets('Renders routine details, metrics, set tables, and notes',
        (tester) async {
      final routine = await routineRepo.createRoutine(
        name: 'Hypertrophy Upper',
        description: 'High volume push and pull work',
        exercises: [
          RoutineExercise(
            id: 're-upper-1',
            routineId: '',
            exerciseId: 'ex-bench',
            exerciseName: 'Barbell Bench Press',
            exercise: testBenchExercise,
            orderIndex: 0,
            restSeconds: 90,
            notes: 'Touch chest softly, explosive press',
            targetSetsCount: 2,
            targetWeightKg: 80.0,
            targetReps: 8,
            sets: const [
              RoutineSet(
                id: 'rs-u1',
                routineExerciseId: 're-upper-1',
                position: 1,
                targetWeightKg: 80.0,
                targetReps: 8,
                targetRpe: 8.0,
              ),
              RoutineSet(
                id: 'rs-u2',
                routineExerciseId: 're-upper-1',
                position: 2,
                targetWeightKg: 80.0,
                targetReps: 8,
                targetRpe: 8.5,
              ),
            ],
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
          child: MaterialApp(
            home: RoutineDetailScreen(routineId: routine.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ROUTINE DETAIL'), findsOneWidget);
      expect(find.text('Hypertrophy Upper'), findsOneWidget);
      expect(find.text('High volume push and pull work'), findsOneWidget);

      // Summary badges
      expect(find.text('EXERCISES'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(3)); // count badge, position badge, set 1
      expect(find.text('TOTAL SETS'), findsOneWidget);
      expect(find.text('2'), findsNWidgets(2)); // total sets badge & set 2 row

      // Exercise Card & Sets Table
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('90s rest'), findsOneWidget);
      expect(find.text('SET'), findsOneWidget);
      expect(find.text('TARGET WEIGHT'), findsOneWidget);
      expect(find.text('TARGET REPS'), findsOneWidget);
      expect(find.text('80 kg'), findsNWidgets(2));
      expect(find.text('Touch chest softly, explosive press'), findsOneWidget);

      // START WORKOUT primary action
      expect(find.text('START WORKOUT'), findsOneWidget);
    });

    testWidgets('Renders Routine Not Found for nonexistent routine ID',
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
            home: RoutineDetailScreen(routineId: 'nonexistent-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Routine Not Found'), findsOneWidget);
      expect(find.text('BACK TO ROUTINES'), findsOneWidget);
    });
  });
}
