import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../workout/data/workout_repository.dart';
import '../../workout/domain/workout_session.dart';
import '../../workout/domain/workout_set.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';

part 'routine_detail_controller.g.dart';

/// Riverpod controller managing a specific routine's detail state and live session startup.
///
/// Implements Law L2 (reactive stream from SQLite), Law L7 (non-destructive session start
/// and write-through edits), and Law L1 (<1s startup latency).
@riverpod
class RoutineDetailController extends _$RoutineDetailController {
  @override
  Stream<Routine?> build(String routineId) {
    final repo = ref.watch(routineRepositoryProvider);
    return repo.watchRoutineById(routineId);
  }

  /// Starts a live workout session preloaded with this routine's exercises and target sets.
  /// Original routine is guaranteed to remain 100% unmutated (Law L7).
  Future<WorkoutSession?> startWorkout() async {
    final routine = await ref.read(routineRepositoryProvider).getRoutineById(routineId);
    if (routine == null) return null;

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

  /// Clones this routine non-destructively (Law L7).
  Future<Routine> duplicateRoutine({String? newName}) async {
    final repo = ref.read(routineRepositoryProvider);
    return repo.duplicateRoutine(routineId, newName: newName);
  }

  /// Deletes this routine by ID.
  Future<bool> deleteRoutine() async {
    final repo = ref.read(routineRepositoryProvider);
    return repo.deleteRoutine(routineId);
  }
}
