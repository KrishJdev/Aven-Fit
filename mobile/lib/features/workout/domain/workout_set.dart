import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_set.freezed.dart';
part 'workout_set.g.dart';

/// Supported types of workout sets.
enum SetType {
  normal,
  warmup,
  dropSet,
  failure,
}

/// Pure immutable domain entity representing a single logged or planned set.
///
/// Complies with Law L1 (instantaneous logging) and Law L7 (write-through persistence).
@freezed
abstract class WorkoutSet with _$WorkoutSet {
  const factory WorkoutSet({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required double weightKg,
    required int reps,
    @Default(false) bool isCompleted,
    @Default(SetType.normal) SetType type,
    double? rpe,
  }) = _WorkoutSet;

  factory WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);
}
