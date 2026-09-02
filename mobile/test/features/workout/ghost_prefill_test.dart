import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/routine/domain/routine_exercise.dart';
import 'package:aven_fit/features/routine/domain/routine_set.dart';
import 'package:aven_fit/features/workout/data/ghost_prefill_service.dart';
import 'package:aven_fit/features/workout/data/workout_local_source.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/ghost_set.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GhostSet Domain Value Object', () {
    test('GhostSet immutability, formatting, and summary helpers', () {
      const ghost = GhostSet(
        weightKg: 82.5,
        reps: 8,
        rpe: 8.5,
        setType: SetType.normal,
        source: GhostSource.history,
      );

      expect(ghost.hasValue, isTrue);
      expect(ghost.weightDisplay, '82.5');
      expect(ghost.repsDisplay, '8');
      expect(ghost.prevSummary, '82.5 kg × 8');
      expect(ghost.source, GhostSource.history);

      const integerWeightGhost = GhostSet(
        weightKg: 100.0,
        reps: 5,
        source: GhostSource.routineTarget,
      );
      expect(integerWeightGhost.weightDisplay, '100');
      expect(integerWeightGhost.prevSummary, '100 kg × 5');

      const emptyGhost = GhostSet(source: GhostSource.none);
      expect(emptyGhost.hasValue, isFalse);
      expect(emptyGhost.weightDisplay, '—');
      expect(emptyGhost.repsDisplay, '—');
      expect(emptyGhost.prevSummary, '—');
    });

    test('GhostSet JSON serialization round-trip', () {
      const ghost = GhostSet(
        weightKg: 60.0,
        reps: 12,
        rpe: 7.5,
        setType: SetType.dropSet,
        source: GhostSource.routineTarget,
      );

      final json = ghost.toJson();
      final fromJson = GhostSet.fromJson(json);

      expect(fromJson.weightKg, 60.0);
      expect(fromJson.reps, 12);
      expect(fromJson.rpe, 7.5);
      expect(fromJson.setType, SetType.dropSet);
      expect(fromJson.source, GhostSource.routineTarget);
    });
  });

  group('GhostPrefillService Standard Set Population Logic (FEATURES.md §7.2)', () {
    late AppDatabase db;
    late WorkoutDao workoutDao;
    late WorkoutRepository workoutRepo;
    late GhostPrefillService service;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      workoutDao = db.workoutDao;
      workoutRepo = WorkoutRepositoryImpl(workoutDao);
      service = GhostPrefillService(workoutRepo);

      // Seed catalog exercise
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

    test('Branch 1: Prefills exact Set N values from last completed workout when N <= history count', () async {
      // 1. Create and complete a previous session
      final pastSession = await workoutRepo.startWorkout(name: 'Last Week Chest');
      final pastSessionEx = await workoutRepo.addExerciseToSession(
        sessionId: pastSession.id,
        exerciseId: 'ex_bench',
      );

      // Past sets: Set 1 = 80kg x 10, Set 2 = 85kg x 8, Set 3 = 90kg x 6
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'past_s1',
          sessionId: pastSession.id,
          sessionExerciseId: pastSessionEx.id,
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 80.0,
          reps: 10,
          isCompleted: true,
        ),
      );
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'past_s2',
          sessionId: pastSession.id,
          sessionExerciseId: pastSessionEx.id,
          exerciseId: 'ex_bench',
          setNumber: 2,
          weightKg: 85.0,
          reps: 8,
          isCompleted: true,
        ),
      );
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'past_s3',
          sessionId: pastSession.id,
          sessionExerciseId: pastSessionEx.id,
          exerciseId: 'ex_bench',
          setNumber: 3,
          weightKg: 90.0,
          reps: 6,
          isCompleted: true,
        ),
      );
      await workoutRepo.finishWorkout(pastSession.id);

      // 2. Resolve ghosts for new workout
      final ghost1 = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 1,
      );
      expect(ghost1.source, GhostSource.history);
      expect(ghost1.weightKg, 80.0);
      expect(ghost1.reps, 10);
      expect(ghost1.prevSummary, '80 kg × 10');

      final ghost2 = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 2,
      );
      expect(ghost2.source, GhostSource.history);
      expect(ghost2.weightKg, 85.0);
      expect(ghost2.reps, 8);
      expect(ghost2.prevSummary, '85 kg × 8');

      final ghost3 = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 3,
      );
      expect(ghost3.source, GhostSource.history);
      expect(ghost3.weightKg, 90.0);
      expect(ghost3.reps, 6);
      expect(ghost3.prevSummary, '90 kg × 6');
    });

    test('Branch 2: Adding overflow set (N > history count) copies from active session Set N-1', () async {
      // Past session had only 1 set
      final pastSession = await workoutRepo.startWorkout(name: 'Previous Day');
      final pastSessionEx = await workoutRepo.addExerciseToSession(
        sessionId: pastSession.id,
        exerciseId: 'ex_bench',
      );
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'past_1',
          sessionId: pastSession.id,
          sessionExerciseId: pastSessionEx.id,
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 60.0,
          reps: 12,
          isCompleted: true,
        ),
      );
      await workoutRepo.finishWorkout(pastSession.id);

      // In current active session, user already performed Set 2 with 70kg x 8
      final activeSets = [
        const WorkoutSet(
          id: 'cur_1',
          sessionId: 'cur_session',
          sessionExerciseId: 'cur_se',
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 60.0,
          reps: 12,
          isCompleted: true,
        ),
        const WorkoutSet(
          id: 'cur_2',
          sessionId: 'cur_session',
          sessionExerciseId: 'cur_se',
          exerciseId: 'ex_bench',
          setNumber: 2,
          weightKg: 70.0,
          reps: 8,
          isCompleted: true,
        ),
      ];

      // User adds Set 3 (N > history count) -> should copy from Set 2 (70kg x 8)
      final ghost3 = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 3,
        activeSessionSets: activeSets,
      );

      expect(ghost3.source, GhostSource.previousSet);
      expect(ghost3.weightKg, 70.0);
      expect(ghost3.reps, 8);
    });

    test('Branch 3: Overflow fallback when no active previous set exists falls back to last historical set', () async {
      final pastSession = await workoutRepo.startWorkout(name: 'Past Session');
      final pastSessionEx = await workoutRepo.addExerciseToSession(
        sessionId: pastSession.id,
        exerciseId: 'ex_bench',
      );
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'past_1',
          sessionId: pastSession.id,
          sessionExerciseId: pastSessionEx.id,
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 100.0,
          reps: 5,
          isCompleted: true,
        ),
      );
      await workoutRepo.finishWorkout(pastSession.id);

      // Resolving Set 4 when active session is empty falls back to last historical set (100kg x 5)
      final ghost4 = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 4,
        activeSessionSets: const [],
      );

      expect(ghost4.source, GhostSource.history);
      expect(ghost4.weightKg, 100.0);
      expect(ghost4.reps, 5);
    });

    test('Branch 4: Routine targets prefill when no workout history exists', () async {
      const routineEx = RoutineExercise(
        id: 're_1',
        routineId: 'r_push',
        exerciseId: 'ex_squat',
        targetSetsCount: 3,
        targetWeightKg: 120.0,
        targetReps: 5,
        targetRpe: 8.5,
        sets: [
          RoutineSet(
            id: 'rs_1',
            routineExerciseId: 're_1',
            position: 1,
            targetWeightKg: 120.0,
            targetReps: 5,
            targetRpe: 8.0,
          ),
          RoutineSet(
            id: 'rs_2',
            routineExerciseId: 're_1',
            position: 2,
            targetWeightKg: 125.0,
            targetReps: 5,
            targetRpe: 9.0,
          ),
        ],
      );

      // Set 1 from routine set
      final ghost1 = await service.resolveGhostSet(
        exerciseId: 'ex_squat',
        setNumber: 1,
        routineExercise: routineEx,
      );
      expect(ghost1.source, GhostSource.routineTarget);
      expect(ghost1.weightKg, 120.0);
      expect(ghost1.reps, 5);
      expect(ghost1.rpe, 8.0);

      // Set 2 from routine set
      final ghost2 = await service.resolveGhostSet(
        exerciseId: 'ex_squat',
        setNumber: 2,
        routineExercise: routineEx,
      );
      expect(ghost2.source, GhostSource.routineTarget);
      expect(ghost2.weightKg, 125.0);
      expect(ghost2.reps, 5);
      expect(ghost2.rpe, 9.0);

      // Set 3 (beyond routine sets list) falls back to routineExercise targets
      final ghost3 = await service.resolveGhostSet(
        exerciseId: 'ex_squat',
        setNumber: 3,
        routineExercise: routineEx,
      );
      expect(ghost3.source, GhostSource.routineTarget);
      expect(ghost3.weightKg, 120.0);
      expect(ghost3.reps, 5);
    });

    test('Branch 5: First-ever exercise with no history or routine targets returns empty ghost', () async {
      final ghost = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 1,
      );

      expect(ghost.source, GhostSource.none);
      expect(ghost.hasValue, isFalse);
      expect(ghost.weightKg, isNull);
      expect(ghost.reps, isNull);
      expect(ghost.prevSummary, '—');
    });

    test('resolveGhostSetsForExercise batch resolves all sets for an exercise block', () async {
      final pastSession = await workoutRepo.startWorkout(name: 'Past Workout');
      final pastEx = await workoutRepo.addExerciseToSession(
        sessionId: pastSession.id,
        exerciseId: 'ex_bench',
      );
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'ps_1',
          sessionId: pastSession.id,
          sessionExerciseId: pastEx.id,
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 50.0,
          reps: 12,
        ),
      );
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'ps_2',
          sessionId: pastSession.id,
          sessionExerciseId: pastEx.id,
          exerciseId: 'ex_bench',
          setNumber: 2,
          weightKg: 55.0,
          reps: 10,
        ),
      );
      await workoutRepo.finishWorkout(pastSession.id);

      final ghosts = await service.resolveGhostSetsForExercise(
        exerciseId: 'ex_bench',
        totalSetsCount: 3,
      );

      expect(ghosts.length, 3);
      expect(ghosts[0].weightKg, 50.0);
      expect(ghosts[0].reps, 12);
      expect(ghosts[1].weightKg, 55.0);
      expect(ghosts[1].reps, 10);
      // 3rd set falls back to last historical set
      expect(ghosts[2].weightKg, 55.0);
      expect(ghosts[2].reps, 10);
    });

    test(
        'D1 Requirement: routine targets only used when from routine, ad-hoc uses history Set N and falls back to last set done in exercise',
        () async {
      // 1. History has 1 completed set: Set 1 = 75.0kg x 8
      final pastSession = await workoutRepo.startWorkout(name: 'Past Workout');
      final pastEx = await workoutRepo.addExerciseToSession(
        sessionId: pastSession.id,
        exerciseId: 'ex_bench',
      );
      await workoutRepo.logSet(
        WorkoutSet(
          id: 'ps_bench_1',
          sessionId: pastSession.id,
          sessionExerciseId: pastEx.id,
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 75.0,
          reps: 8,
          isCompleted: true,
        ),
      );
      await workoutRepo.finishWorkout(pastSession.id);

      // A routine target exists with 90kg x 5
      const routineSet = RoutineSet(
        id: 'rs_target',
        routineExerciseId: 're_bench',
        position: 1,
        targetWeightKg: 90.0,
        targetReps: 5,
      );

      // Test Case A: Ad-hoc workout without routine context -> MUST use historical Set 1 (75kg x 8), NOT routine
      final adHocSet1 = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 1,
      );
      expect(adHocSet1.source, GhostSource.history);
      expect(adHocSet1.weightKg, 75.0);
      expect(adHocSet1.reps, 8);

      // Test Case B: Ad-hoc workout adding Set 2 when only Set 1 is in history:
      // Active workout has done Set 1 with 80kg x 6.
      // Set 2 must fall back to the last set done in the exercise (80kg x 6).
      final activeSets = [
        const WorkoutSet(
          id: 'act_1',
          sessionId: 'act_sess',
          sessionExerciseId: 'act_se',
          exerciseId: 'ex_bench',
          setNumber: 1,
          weightKg: 80.0,
          reps: 6,
          isCompleted: true,
        ),
      ];
      final adHocSet2 = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 2,
        activeSessionSets: activeSets,
      );
      expect(adHocSet2.source, GhostSource.previousSet);
      expect(adHocSet2.weightKg, 80.0);
      expect(adHocSet2.reps, 6);

      // Test Case C: Workout started from routine -> MUST use routine target (90kg x 5)
      final routineStartedSet1 = await service.resolveGhostSet(
        exerciseId: 'ex_bench',
        setNumber: 1,
        routineTargetSet: routineSet,
      );
      expect(routineStartedSet1.source, GhostSource.routineTarget);
      expect(routineStartedSet1.weightKg, 90.0);
      expect(routineStartedSet1.reps, 5);
    });
  });
}
