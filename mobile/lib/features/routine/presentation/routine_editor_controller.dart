import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../exercise/domain/exercise.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';
import '../domain/routine_exercise.dart';
import '../domain/routine_set.dart';
import 'routine_editor_state.dart';

part 'routine_editor_controller.g.dart';

/// Riverpod controller managing the routine creation / editing workflow.
///
/// Implements Law L2 (offline persistence), Law L6 (inline validation),
/// and Law L7 (write-through saves and crash-safe editing).
@riverpod
class RoutineEditorController extends _$RoutineEditorController {
  @override
  Future<RoutineEditorState> build(String? routineId) async {
    if (routineId != null && routineId.isNotEmpty) {
      final repo = ref.watch(routineRepositoryProvider);
      final routine = await repo.getRoutineById(routineId);
      if (routine != null) {
        return RoutineEditorState(
          routineId: routine.id,
          name: routine.name,
          description: routine.description ?? '',
          exercises: routine.exercises,
        );
      }
    }
    return const RoutineEditorState();
  }

  /// Updates the routine's name and clears validation error if valid.
  void updateName(String name) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(name: name, errorMessage: null));
  }

  /// Updates the routine's optional description.
  void updateDescription(String description) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(description: description));
  }

  /// Appends a new exercise to the routine with default set targets.
  void addExercise(Exercise exercise) {
    final current = state.value;
    if (current == null) return;

    final newExercise = RoutineExercise(
      id: 're_temp_${DateTime.now().microsecondsSinceEpoch}',
      routineId: current.routineId ?? '',
      exerciseId: exercise.id,
      exercise: exercise,
      exerciseName: exercise.name,
      orderIndex: current.exercises.length,
      restSeconds: 90,
      targetSetsCount: 3,
      targetReps: 10,
      targetWeightKg: 0.0,
      sets: List.generate(
        3,
        (i) => RoutineSet(
          id: 'rs_temp_${DateTime.now().microsecondsSinceEpoch}_$i',
          routineExerciseId: '',
          position: i + 1,
          targetReps: 10,
          targetWeightKg: 0.0,
        ),
      ),
    );

    state = AsyncData(current.copyWith(
      exercises: [...current.exercises, newExercise],
    ));
  }

  /// Updates targets and configurations for an exercise at the given index.
  void updateExercise(int index, RoutineExercise updated) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.exercises.length) return;

    final list = [...current.exercises];
    list[index] = updated;
    state = AsyncData(current.copyWith(exercises: list));
  }

  /// Removes an exercise entry from the routine and re-indexes the list.
  void removeExercise(int index) {
    final current = state.value;
    if (current == null || index < 0 || index >= current.exercises.length) return;

    final list = [...current.exercises]..removeAt(index);
    final reindexed = [
      for (var i = 0; i < list.length; i++)
        list[i].copyWith(orderIndex: i),
    ];
    state = AsyncData(current.copyWith(exercises: reindexed));
  }

  /// Reorders exercise cards in the list.
  void reorderExercises(int oldIndex, int newIndex) {
    final current = state.value;
    if (current == null) return;

    final list = [...current.exercises];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    final reindexed = [
      for (var i = 0; i < list.length; i++)
        list[i].copyWith(orderIndex: i),
    ];
    state = AsyncData(current.copyWith(exercises: reindexed));
  }

  /// Validates and saves the routine to SQLite write-through (Law L7).
  Future<bool> saveRoutine() async {
    final current = state.value;
    if (current == null) return false;

    if (current.name.trim().isEmpty) {
      state = AsyncData(current.copyWith(
        errorMessage: 'Routine name cannot be empty',
      ));
      return false;
    }

    state = AsyncData(current.copyWith(isSaving: true, errorMessage: null));

    try {
      final repo = ref.read(routineRepositoryProvider);

      if (current.isNew) {
        await repo.createRoutine(
          name: current.name.trim(),
          description: current.description.trim().isNotEmpty
              ? current.description.trim()
              : null,
          exercises: current.exercises,
        );
      } else {
        final routine = Routine(
          id: current.routineId!,
          name: current.name.trim(),
          description: current.description.trim().isNotEmpty
              ? current.description.trim()
              : null,
          exercises: current.exercises,
        );
        await repo.updateRoutine(routine);
      }

      state = AsyncData(current.copyWith(isSaving: false, isSaved: true));
      return true;
    } catch (e) {
      state = AsyncData(current.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save routine: $e',
      ));
      return false;
    }
  }
}
