import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercise/domain/exercise.dart';
import '../../exercise/domain/muscle_group.dart';

part 'exercise_picker_state.freezed.dart';

/// Pure immutable state for the in-session exercise picker modal.
@freezed
abstract class ExercisePickerState with _$ExercisePickerState {
  const ExercisePickerState._();

  const factory ExercisePickerState({
    @Default('') String searchQuery,
    String? selectedMuscleGroupId,
    Equipment? selectedEquipment,
    @Default(false) bool favouritesOnly,
    @Default(false) bool showRecentOnly,
    @Default(<Exercise>[]) List<Exercise> recentExercises,
    @Default(<Exercise>[]) List<Exercise> allExercises,
    @Default(<MuscleGroup>[]) List<MuscleGroup> muscleGroups,
    @Default(false) bool isSearching,
  }) = _ExercisePickerState;

  /// Whether any active filter or search text is applied.
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedMuscleGroupId != null ||
      selectedEquipment != null ||
      favouritesOnly ||
      showRecentOnly;

  /// Computed filtered exercises matching active criteria.
  List<Exercise> get filteredExercises {
    var list = showRecentOnly ? recentExercises : allExercises;

    // Filter by search query
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      list = list.where((e) {
        final nameMatch = e.name.toLowerCase().contains(query);
        final muscleMatch =
            e.primaryMuscle?.toLowerCase().contains(query) ?? false;
        final equipMatch = e.equipment.name.toLowerCase().contains(query);
        return nameMatch || muscleMatch || equipMatch;
      }).toList();
    }

    // Filter by muscle group
    if (selectedMuscleGroupId != null) {
      list = list.where((e) {
        return e.primaryMuscle == selectedMuscleGroupId ||
            e.secondaryMuscles.contains(selectedMuscleGroupId) ||
            e.muscleRefs.any((m) => m.muscleGroupId == selectedMuscleGroupId);
      }).toList();
    }

    // Filter by equipment
    if (selectedEquipment != null) {
      list = list.where((e) => e.equipment == selectedEquipment).toList();
    }

    // Filter by favourites
    if (favouritesOnly) {
      list = list.where((e) => e.isFavourite).toList();
    }

    return list;
  }
}
