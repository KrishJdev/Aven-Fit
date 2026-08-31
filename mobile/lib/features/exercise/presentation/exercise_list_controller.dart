import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/exercise_repository.dart';
import '../domain/muscle_group.dart';
import 'exercise_list_state.dart';

part 'exercise_list_controller.g.dart';

/// Riverpod AsyncNotifier managing the state and search filters of the Exercise Directory.
///
/// Implements Law L1 (<300ms search latency) and Law L2 (100% offline querying).
@riverpod
class ExerciseListController extends _$ExerciseListController {
  @override
  FutureOr<ExerciseListState> build() async {
    final repository = ref.watch(exerciseRepositoryProvider);

    // Ensure database is seeded on first load
    await repository.seedInitialData();

    final muscleGroups = await repository.getMuscleGroups();
    final exercises = await repository.searchExercises();

    return ExerciseListState(
      muscleGroups: muscleGroups,
      exercises: exercises,
    );
  }

  /// Updates the search query filter.
  Future<void> setSearchQuery(String query) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: query));
    await _refreshExercises();
  }

  /// Selects or deselects a muscle group filter.
  Future<void> selectMuscleGroup(String? muscleGroupId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newSelection =
        currentState.selectedMuscleGroupId == muscleGroupId ? null : muscleGroupId;

    state = AsyncValue.data(
      currentState.copyWith(selectedMuscleGroupId: newSelection),
    );
    await _refreshExercises();
  }

  /// Selects or deselects an equipment filter.
  Future<void> selectEquipment(Equipment? equipment) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newSelection =
        currentState.selectedEquipment == equipment ? null : equipment;

    state = AsyncValue.data(
      currentState.copyWith(selectedEquipment: newSelection),
    );
    await _refreshExercises();
  }

  /// Selects or deselects a category filter.
  Future<void> selectCategory(ExerciseCategory? category) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newSelection =
        currentState.selectedCategory == category ? null : category;

    state = AsyncValue.data(
      currentState.copyWith(selectedCategory: newSelection),
    );
    await _refreshExercises();
  }

  /// Toggles the favourites-only filter.
  Future<void> toggleFavouritesOnly() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(favouritesOnly: !currentState.favouritesOnly),
    );
    await _refreshExercises();
  }

  /// Toggles favourite status of an exercise with instantaneous write-through.
  Future<void> toggleFavourite(String exerciseId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final repository = ref.read(exerciseRepositoryProvider);
    final isFav = await repository.toggleFavourite(exerciseId);

    final updatedExercises = currentState.exercises.map((e) {
      if (e.id == exerciseId) {
        return e.copyWith(isFavourite: isFav);
      }
      return e;
    }).toList();

    // If favouritesOnly filter is active and item was un-favourited, filter it out
    final filtered = currentState.favouritesOnly
        ? updatedExercises.where((e) => e.isFavourite).toList()
        : updatedExercises;

    state = AsyncValue.data(
      currentState.copyWith(exercises: filtered),
    );
  }

  /// Clears all active filters and restores full exercise directory.
  Future<void> clearFilters() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: '',
        selectedMuscleGroupId: null,
        selectedEquipment: null,
        selectedCategory: null,
        favouritesOnly: false,
      ),
    );
    await _refreshExercises();
  }

  Future<void> _refreshExercises() async {
    final currentState = state.value;
    if (currentState == null) return;

    final repository = ref.read(exerciseRepositoryProvider);
    final results = await repository.searchExercises(
      query: currentState.searchQuery,
      muscleGroupId: currentState.selectedMuscleGroupId,
      equipment: currentState.selectedEquipment,
      category: currentState.selectedCategory,
      favouritesOnly: currentState.favouritesOnly ? true : null,
    );

    state = AsyncValue.data(
      currentState.copyWith(exercises: results),
    );
  }
}
