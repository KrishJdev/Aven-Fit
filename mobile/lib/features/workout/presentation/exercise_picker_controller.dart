import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../exercise/data/exercise_repository.dart';
import '../../exercise/domain/muscle_group.dart';
import '../data/workout_repository.dart';
import 'exercise_picker_state.dart';

part 'exercise_picker_controller.g.dart';

/// Riverpod controller managing search, filtering, and recent history for the in-session exercise picker.
///
/// Implements Law L1 (<100ms local filtering) and Law L2 (100% offline).
@riverpod
class ExercisePickerController extends _$ExercisePickerController {
  @override
  FutureOr<ExercisePickerState> build() async {
    final exerciseRepo = ref.watch(exerciseRepositoryProvider);
    final workoutRepo = ref.watch(workoutRepositoryProvider);

    final allExercises = await exerciseRepo.searchExercises();
    final muscleGroups = await exerciseRepo.getMuscleGroups();
    final recentExercises = await workoutRepo.getRecentExercises(limit: 10);

    return ExercisePickerState(
      allExercises: allExercises,
      muscleGroups: muscleGroups,
      recentExercises: recentExercises,
    );
  }

  /// Updates the debounced/live search query.
  void updateSearchQuery(String query) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(searchQuery: query));
  }

  /// Selects or deselects a muscle group filter chip.
  void setMuscleGroup(String? muscleGroupId) {
    final current = state.value;
    if (current == null) return;

    final newId =
        current.selectedMuscleGroupId == muscleGroupId ? null : muscleGroupId;
    state = AsyncValue.data(current.copyWith(selectedMuscleGroupId: newId));
  }

  /// Selects or deselects an equipment filter chip.
  void setEquipment(Equipment? equipment) {
    final current = state.value;
    if (current == null) return;

    final newEq = current.selectedEquipment == equipment ? null : equipment;
    state = AsyncValue.data(current.copyWith(selectedEquipment: newEq));
  }

  /// Toggles favourites-only filter.
  void toggleFavouritesOnly() {
    final current = state.value;
    if (current == null) return;

    final willEnable = !current.favouritesOnly;
    state = AsyncValue.data(current.copyWith(
      favouritesOnly: willEnable,
      showRecentOnly: willEnable ? false : current.showRecentOnly,
    ));
  }

  /// Toggles recent-history-only filter.
  void toggleRecentOnly() {
    final current = state.value;
    if (current == null) return;

    final willEnable = !current.showRecentOnly;
    state = AsyncValue.data(current.copyWith(
      showRecentOnly: willEnable,
      favouritesOnly: willEnable ? false : current.favouritesOnly,
    ));
  }

  /// Toggles favourite status of an exercise and updates local state optimistically.
  Future<void> toggleFavourite(String exerciseId) async {
    final current = state.value ?? await future;

    // Optimistic update
    final updatedAll = current.allExercises.map((e) {
      if (e.id == exerciseId) {
        return e.copyWith(isFavourite: !e.isFavourite);
      }
      return e;
    }).toList();

    final updatedRecent = current.recentExercises.map((e) {
      if (e.id == exerciseId) {
        return e.copyWith(isFavourite: !e.isFavourite);
      }
      return e;
    }).toList();

    state = AsyncValue.data(current.copyWith(
      allExercises: updatedAll,
      recentExercises: updatedRecent,
    ));

    // Write-through to SQLite
    final exerciseRepo = ref.read(exerciseRepositoryProvider);
    await exerciseRepo.toggleFavourite(exerciseId);
  }

  /// Clears all active search queries and filter chips.
  void clearFilters() {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(
      searchQuery: '',
      selectedMuscleGroupId: null,
      selectedEquipment: null,
      favouritesOnly: false,
      showRecentOnly: false,
    ));
  }
}
