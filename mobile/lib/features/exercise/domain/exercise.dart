import 'package:freezed_annotation/freezed_annotation.dart';

import 'muscle_group.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

/// Pure immutable domain entity representing an exercise in the local library or custom catalog.
///
/// Complies with Law L2 (offline catalog) and Feature Spec §9.
@freezed
abstract class Exercise with _$Exercise {
  const Exercise._();

  const factory Exercise({
    required String id,
    required String name,
    String? description,
    @Default(ExerciseCategory.other) ExerciseCategory category,
    @Default(Equipment.none) Equipment equipment,
    @Default(false) bool isCustom,
    @Default(false) bool isFavourite,
    @Default(false) bool isTimeBased,
    @Default(false) bool isCardio,
    String? primaryMuscle,
    @Default(<String>[]) List<String> secondaryMuscles,
    @Default(<ExerciseMuscleRef>[]) List<ExerciseMuscleRef> muscleRefs,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  /// Convenient aliases matching specifications across codebase
  String? get instructions => description;
  String? get muscleGroupPrimary => primaryMuscle;
  List<String> get muscleGroupsSecondary => secondaryMuscles;
  Equipment get equipmentType => equipment;
}
