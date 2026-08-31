import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/exercise_repository.dart';
import '../domain/exercise.dart';

part 'exercise_detail_controller.g.dart';

/// Riverpod AsyncNotifier managing the state and actions of a single exercise detail view.
@riverpod
class ExerciseDetailController extends _$ExerciseDetailController {
  @override
  FutureOr<Exercise?> build(String exerciseId) async {
    final repository = ref.watch(exerciseRepositoryProvider);
    return repository.getExerciseById(exerciseId);
  }

  /// Toggles the favourite status of this exercise.
  Future<void> toggleFavourite() async {
    final current = state.value;
    if (current == null) return;

    final repository = ref.read(exerciseRepositoryProvider);
    final isFav = await repository.toggleFavourite(current.id);

    state = AsyncValue.data(current.copyWith(isFavourite: isFav));
  }

  /// Deletes this exercise if it is a custom exercise.
  Future<bool> deleteExercise() async {
    final current = state.value;
    if (current == null || !current.isCustom) return false;

    final repository = ref.read(exerciseRepositoryProvider);
    final success = await repository.deleteCustomExercise(current.id);
    return success;
  }
}
