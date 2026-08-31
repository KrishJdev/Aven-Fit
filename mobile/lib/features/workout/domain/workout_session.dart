import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout_set.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

/// Status lifecycle of a workout session.
enum WorkoutStatus {
  active,
  completed,
  discarded,
}

/// Pure immutable domain entity representing a complete workout session.
@freezed
abstract class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required String id,
    @Default('Workout') String name,
    required DateTime startedAt,
    DateTime? completedAt,
    @Default(WorkoutStatus.active) WorkoutStatus status,
    @Default(<WorkoutSet>[]) List<WorkoutSet> sets,
    String? notes,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}
