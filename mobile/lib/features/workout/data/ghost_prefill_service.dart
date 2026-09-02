import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../routine/domain/routine_exercise.dart';
import '../../routine/domain/routine_set.dart';
import '../domain/ghost_set.dart';
import '../domain/workout_set.dart';
import 'workout_repository.dart';

part 'ghost_prefill_service.g.dart';

/// Service implementing the standard set population & ghost value fallback logic
/// defined in FEATURES.md §7.2 and §8.1.
///
/// Complies with Law L1 (instantaneous set suggestions) and Law L2 (100% offline).
class GhostPrefillService {
  const GhostPrefillService(this._workoutRepository);

  final WorkoutRepository _workoutRepository;

  /// Resolves the ghost suggestion for Set [setNumber] (1-based index) of [exerciseId].
  ///
  /// Priority order per FEATURES.md §7.2 / §8.1:
  /// 1. Routine Targets: Used ONLY when the workout is started from the routine section
  ///    ([routineTargetSet] or [routineExercise] explicitly provided).
  /// 2. Historic value: If Set $N \le$ Historical Count, prefill from historical Set $N$.
  /// 3. Last set done in exercise fallback: If historical Set $N$ is not available,
  ///    fall back to the last set done in this exercise in the current workout (Set $N-1$ or last active set).
  /// 4. Historical last set fallback: If $N >$ Historical Count and no active set exists,
  ///    fall back to the last historical set.
  /// 5. None fallback: Returns empty ghost if no prior data or targets exist.
  Future<GhostSet> resolveGhostSet({
    required String exerciseId,
    required int setNumber,
    List<WorkoutSet> activeSessionSets = const [],
    RoutineExercise? routineExercise,
    RoutineSet? routineTargetSet,
  }) async {
    // 1. Routine Target prefill (used ONLY when started from the routine section)
    if (routineTargetSet != null) {
      return GhostSet(
        weightKg: routineTargetSet.targetWeightKg,
        reps: routineTargetSet.targetReps,
        rpe: routineTargetSet.targetRpe,
        setType: routineTargetSet.setType,
        source: GhostSource.routineTarget,
      );
    }

    if (routineExercise != null) {
      final matchingRoutineSet = routineExercise.sets.where(
        (s) => s.position == setNumber,
      );
      if (matchingRoutineSet.isNotEmpty) {
        final target = matchingRoutineSet.first;
        return GhostSet(
          weightKg: target.targetWeightKg ?? routineExercise.targetWeightKg,
          reps: target.targetReps ?? routineExercise.targetReps,
          rpe: target.targetRpe ?? routineExercise.targetRpe,
          setType: target.setType,
          source: GhostSource.routineTarget,
        );
      }

      if (routineExercise.targetWeightKg != null ||
          routineExercise.targetReps != null) {
        return GhostSet(
          weightKg: routineExercise.targetWeightKg,
          reps: routineExercise.targetReps,
          rpe: routineExercise.targetRpe,
          source: GhostSource.routineTarget,
        );
      }
    }

    // 2. Fetch historical completed sets for this exercise
    final historicalSets =
        await _workoutRepository.getLastCompletedSetsForExercise(exerciseId);

    // Branch: Historic Set N match (N <= history count)
    if (historicalSets.isNotEmpty && setNumber <= historicalSets.length) {
      final histSet = historicalSets[setNumber - 1];
      return GhostSet(
        weightKg: histSet.weightKg,
        reps: histSet.reps,
        rpe: histSet.rpe,
        setType: histSet.type,
        source: GhostSource.history,
      );
    }

    // Branch: Fall back to last set done in the exercise in the current workout
    if (activeSessionSets.isNotEmpty) {
      final prevIndex = setNumber > 1
          ? activeSessionSets.indexWhere((s) => s.setNumber == setNumber - 1)
          : -1;
      final prevSet = prevIndex != -1
          ? activeSessionSets[prevIndex]
          : activeSessionSets.last;

      if (prevSet.weightKg > 0 || prevSet.reps > 0) {
        return GhostSet(
          weightKg: prevSet.weightKg,
          reps: prevSet.reps,
          rpe: prevSet.rpe,
          setType: prevSet.type,
          source: GhostSource.previousSet,
        );
      }
    }

    // Branch: Fall back to last historical set if history exists
    if (historicalSets.isNotEmpty) {
      final lastHistSet = historicalSets.last;
      return GhostSet(
        weightKg: lastHistSet.weightKg,
        reps: lastHistSet.reps,
        rpe: lastHistSet.rpe,
        setType: lastHistSet.type,
        source: GhostSource.history,
      );
    }

    // Branch: Empty fallback
    return const GhostSet(source: GhostSource.none);
  }

  /// Resolves ghost suggestions for all [totalSetsCount] sets of an exercise in batch.
  Future<List<GhostSet>> resolveGhostSetsForExercise({
    required String exerciseId,
    required int totalSetsCount,
    List<WorkoutSet> activeSessionSets = const [],
    RoutineExercise? routineExercise,
  }) async {
    final results = <GhostSet>[];
    for (var setNum = 1; setNum <= totalSetsCount; setNum++) {
      final ghost = await resolveGhostSet(
        exerciseId: exerciseId,
        setNumber: setNum,
        activeSessionSets: activeSessionSets,
        routineExercise: routineExercise,
      );
      results.add(ghost);
    }
    return results;
  }
}

/// Riverpod provider exposing [GhostPrefillService].
@riverpod
GhostPrefillService ghostPrefillService(Ref ref) {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  return GhostPrefillService(workoutRepo);
}
