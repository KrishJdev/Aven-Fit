import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../workout/data/workout_repository.dart';
import '../../workout/domain/workout_session.dart';
import '../../workout/domain/workout_set.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';

part 'routine_list_controller.g.dart';

/// Riverpod controller managing the routines list state and actions.
///
/// Implements Law L2 (offline stream), Law L3 (unlimited routines),
/// and Law L7 (write-through duplication, deletion with confirmation, and safe session start).
@riverpod
class RoutineListController extends _$RoutineListController {
  @override
  Stream<List<Routine>> build() {
    final repo = ref.watch(routineRepositoryProvider);
    return repo.watchAllRoutines();
  }

  /// Duplicates a routine into an independent clone (Law L7).
  Future<Routine> duplicateRoutine(String id, {String? newName}) async {
    final repo = ref.read(routineRepositoryProvider);
    return repo.duplicateRoutine(id, newName: newName);
  }

  /// Deletes a routine by ID (cascades to exercises and sets in SQLite).
  Future<bool> deleteRoutine(String id) async {
    final repo = ref.read(routineRepositoryProvider);
    return repo.deleteRoutine(id);
  }

  /// Starts a new active workout preloaded with this routine's exercises and targets in <1s.
  /// Original routine remains unmutated (Law L7).
  Future<WorkoutSession> startWorkoutFromRoutine(Routine routine) async {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final session = await workoutRepo.startWorkout(
      name: routine.name,
      routineId: routine.id,
    );

    for (final ex in routine.exercises) {
      final sessionEx = await workoutRepo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: ex.exerciseId,
        restSeconds: ex.restSeconds,
        notes: ex.notes,
      );

      if (ex.sets.isNotEmpty) {
        for (final s in ex.sets) {
          await workoutRepo.logSet(
            WorkoutSet(
              id: 'ws_${DateTime.now().microsecondsSinceEpoch}_${s.position}',
              sessionId: session.id,
              sessionExerciseId: sessionEx.id,
              exerciseId: ex.exerciseId,
              setNumber: s.position,
              weightKg: s.targetWeightKg ?? ex.targetWeightKg ?? 0.0,
              reps: s.targetReps ?? ex.targetReps ?? 0,
              type: s.setType,
              rpe: s.targetRpe ?? ex.targetRpe,
            ),
          );
        }
      } else if ((ex.targetSetsCount ?? 0) > 0) {
        for (var i = 1; i <= ex.targetSetsCount!; i++) {
          await workoutRepo.logSet(
            WorkoutSet(
              id: 'ws_${DateTime.now().microsecondsSinceEpoch}_$i',
              sessionId: session.id,
              sessionExerciseId: sessionEx.id,
              exerciseId: ex.exerciseId,
              setNumber: i,
              weightKg: ex.targetWeightKg ?? 0.0,
              reps: ex.targetReps ?? 0,
              rpe: ex.targetRpe,
            ),
          );
        }
      }
    }

    return session;
  }
}
