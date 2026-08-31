import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/exercise.dart';
import '../domain/muscle_group.dart';

part 'exercise_list_state.freezed.dart';

/// Pure immutable state representing the Exercise Directory screen.
@freezed
abstract class ExerciseListState with _$ExerciseListState {
  const factory ExerciseListState({
    @Default('') String searchQuery,
    String? selectedMuscleGroupId,
    Equipment? selectedEquipment,
    ExerciseCategory? selectedCategory,
    @Default(false) bool favouritesOnly,
    @Default(<MuscleGroup>[]) List<MuscleGroup> muscleGroups,
    @Default(<Exercise>[]) List<Exercise> exercises,
    @Default(false) bool isSeeding,
    String? errorMessage,
  }) = _ExerciseListState;

  const ExerciseListState._();

  /// Whether any filter is currently active.
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedMuscleGroupId != null ||
      selectedEquipment != null ||
      selectedCategory != null ||
      favouritesOnly;
}
