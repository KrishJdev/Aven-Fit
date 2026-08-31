import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/routine_exercise.dart';

part 'routine_editor_state.freezed.dart';
part 'routine_editor_state.g.dart';

/// UI state for the Routine Builder / Editor screen.
///
/// Implements Law L2 (offline editing) and Law L6 (designed validation & error states).
@freezed
abstract class RoutineEditorState with _$RoutineEditorState {
  const RoutineEditorState._();

  const factory RoutineEditorState({
    String? routineId,
    @Default('') String name,
    @Default('') String description,
    @Default(<RoutineExercise>[]) List<RoutineExercise> exercises,
    @Default(false) bool isSaving,
    @Default(false) bool isSaved,
    String? errorMessage,
  }) = _RoutineEditorState;

  factory RoutineEditorState.fromJson(Map<String, dynamic> json) =>
      _$RoutineEditorStateFromJson(json);

  /// Whether this is a new routine creation or an edit of an existing routine.
  bool get isNew => routineId == null || routineId!.isEmpty;

  /// Total number of planned sets across all exercises.
  int get totalSets => exercises.fold<int>(0, (sum, e) => sum + e.setsCount);

  /// Estimated duration in minutes based on sets and rest times.
  int get estimatedDurationMinutes {
    final secs = exercises.fold<int>(0, (sum, e) {
      final sets = e.setsCount;
      if (sets <= 0) return sum;
      final executionTime = sets * 45;
      final restTime = (sets > 1 ? sets - 1 : 0) * e.restSeconds;
      return sum + executionTime + restTime;
    });
    return (secs / 60).ceil();
  }

  /// Whether the current form state is valid for submission.
  bool get isValid => name.trim().isNotEmpty;
}
