import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/exercise_repository.dart';
import '../domain/exercise.dart';
import '../domain/muscle_group.dart';

part 'create_custom_exercise_controller.g.dart';

/// Riverpod AsyncNotifier managing custom exercise creation and validation.
///
/// Implements Law L2 (offline creation) and Law L6 (inline unique name validation).
@riverpod
class CreateCustomExerciseController
    extends _$CreateCustomExerciseController {
  @override
  FutureOr<List<MuscleGroup>> build() async {
    final repository = ref.watch(exerciseRepositoryProvider);
    return repository.getMuscleGroups();
  }

  /// Validates inputs and creates a new custom exercise.
  ///
  /// Returns the created [Exercise] on success, or throws an [ArgumentError] with user-facing message.
  Future<Exercise> createExercise({
    required String name,
    String? description,
    required String primaryMuscleGroupId,
    List<String> secondaryMuscleGroupIds = const [],
    required Equipment equipment,
    required ExerciseCategory category,
    bool isTimeBased = false,
    bool isCardio = false,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Exercise name is required.');
    }

    final repository = ref.read(exerciseRepositoryProvider);

    // Enforce name uniqueness against existing catalog (Law L6)
    final existing = await repository.searchExercises(query: trimmedName);
    final isDuplicate = existing.any(
      (e) => e.name.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (isDuplicate) {
      throw ArgumentError(
        'An exercise named "$trimmedName" already exists. Please choose a unique name.',
      );
    }

    return repository.createCustomExercise(
      name: trimmedName,
      description: description?.trim().isEmpty == true ? null : description?.trim(),
      primaryMuscleGroupId: primaryMuscleGroupId,
      secondaryMuscleGroupIds: secondaryMuscleGroupIds,
      equipment: equipment,
      category: category,
      isTimeBased: isTimeBased,
      isCardio: isCardio,
    );
  }
}
