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
  /// Priority order per FEATURES.md §7.2:
  /// 1. History match: If Set $N \le$ Historical Count, prefill from historical Set $N$.
  /// 2. Active Session Previous: If $N > 1$ and Set $N-1$ exists in current session, copy from Set $N-1$.
  /// 3. History Overflow Fallback: If $N >$ Historical Count and history exists, fall back to last historical set.
  /// 4. Routine Targets: If started from a routine with planned targets, prefill from routine targets.
  /// 5. None fallback: Returns empty ghost if no prior data or targets exist.
  Future<GhostSet> resolveGhostSet({
    required String exerciseId,
    required int setNumber,
    List<WorkoutSet> activeSessionSets = const [],
    RoutineExercise? routineExercise,
    RoutineSet? routineTargetSet,
  }) async {
    // 1. Fetch historical completed sets for this exercise
    final historicalSets =
        await _workoutRepository.getLastCompletedSetsForExercise(exerciseId);

    // Branch 1: Historical Set N match (N <= history count)
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

    // Branch 2: Previous Set N-1 in active session (for new/overflow sets)
    if (setNumber > 1 && activeSessionSets.isNotEmpty) {
      final prevIndex = activeSessionSets.indexWhere(
        (s) => s.setNumber == setNumber - 1,
      );
      if (prevIndex != -1) {
        final prevSet = activeSessionSets[prevIndex];
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
    }

    // Branch 3: Overflow fallback to last historical set
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

    // Branch 4: Routine Target prefill
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

    // Branch 5: Empty fallback
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
