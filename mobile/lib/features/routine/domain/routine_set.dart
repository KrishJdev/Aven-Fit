import 'package:freezed_annotation/freezed_annotation.dart';

import '../../workout/domain/workout_set.dart';

part 'routine_set.freezed.dart';
part 'routine_set.g.dart';

/// Pure immutable domain entity representing a planned set in a routine exercise.
///
/// Complies with Law L2 (offline-first routines) and matches backend `routine_sets` schema.
@freezed
abstract class RoutineSet with _$RoutineSet {
  const factory RoutineSet({
    required String id,
    required String routineExerciseId,
    @Default(1) int position,
    @Default(SetType.normal) SetType setType,
    int? targetReps,
    double? targetWeightKg,
    double? targetRpe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RoutineSet;

  factory RoutineSet.fromJson(Map<String, dynamic> json) =>
      _$RoutineSetFromJson(json);
}
