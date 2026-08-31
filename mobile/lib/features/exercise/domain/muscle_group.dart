import 'package:freezed_annotation/freezed_annotation.dart';

part 'muscle_group.freezed.dart';
part 'muscle_group.g.dart';

/// Target role of a muscle in an exercise (Primary driver vs Secondary stabilizer/synergist).
enum MuscleRole {
  @JsonValue('PRIMARY')
  primary,
  @JsonValue('SECONDARY')
  secondary,
}

/// Equipment types supported for exercises.
enum Equipment {
  @JsonValue('BARBELL')
  barbell,
  @JsonValue('DUMBBELL')
  dumbbell,
  @JsonValue('MACHINE')
  machine,
  @JsonValue('CABLE')
  cable,
  @JsonValue('KETTLEBELL')
  kettlebell,
  @JsonValue('BAND')
  band,
  @JsonValue('BODYWEIGHT')
  bodyweight,
  @JsonValue('SMITH_MACHINE')
  smithMachine,
  @JsonValue('OTHER')
  other,
  @JsonValue('NONE')
  none,
}

/// Exercise movement category / discipline.
enum ExerciseCategory {
  @JsonValue('BARBELL')
  barbell,
  @JsonValue('DUMBBELL')
  dumbbell,
  @JsonValue('MACHINE')
  machine,
  @JsonValue('CABLE')
  cable,
  @JsonValue('BODYWEIGHT')
  bodyweight,
  @JsonValue('CARDIO')
  cardio,
  @JsonValue('STRETCHING')
  stretching,
  @JsonValue('OTHER')
  other,
}

/// Reference mapping between an exercise and a muscle group.
@freezed
abstract class ExerciseMuscleRef with _$ExerciseMuscleRef {
  const factory ExerciseMuscleRef({
    String? muscleGroupId,
    required String name,
    @Default(MuscleRole.primary) MuscleRole role,
  }) = _ExerciseMuscleRef;

  factory ExerciseMuscleRef.fromJson(Map<String, dynamic> json) =>
      _$ExerciseMuscleRefFromJson(json);
}

/// Pure immutable domain entity representing a target anatomical muscle group.
@freezed
abstract class MuscleGroup with _$MuscleGroup {
  const factory MuscleGroup({
    required String id,
    required String name,
    @Default(0) int displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MuscleGroup;

  factory MuscleGroup.fromJson(Map<String, dynamic> json) =>
      _$MuscleGroupFromJson(json);
}
