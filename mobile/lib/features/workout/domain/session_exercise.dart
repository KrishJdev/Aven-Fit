import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercise/domain/exercise.dart';
import 'workout_set.dart';

part 'session_exercise.freezed.dart';
part 'session_exercise.g.dart';

/// Pure immutable domain entity representing an exercise slot within a workout session.
///
/// Links a session to an exercise definition and contains all logged or planned sets for that exercise.
/// Complies with Law L1 (instantaneous set logging), Law L2 (offline-first), and Law L7 (write-through).
@freezed
abstract class SessionExercise with _$SessionExercise {
  const SessionExercise._();

  const factory SessionExercise({
    required String id,
    required String sessionId,
    required String exerciseId,
    Exercise? exercise,
    String? exerciseName,
    @Default(0) int orderIndex,
    @Default(90) int restSeconds,
    String? notes,
    @Default(<WorkoutSet>[]) List<WorkoutSet> sets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SessionExercise;

  factory SessionExercise.fromJson(Map<String, dynamic> json) =>
      _$SessionExerciseFromJson(json);

  /// 0-based order index alias
  int get position => orderIndex;

  /// Total number of sets in this exercise block
  int get setsCount => sets.length;

  /// Completed sets count
  int get completedSetsCount => sets.where((s) => s.isCompleted).length;

  /// Total working volume lifted in kg (excluding warmup sets per Law L1)
  double get totalVolumeKg => sets
      .where((s) => s.isCompleted && s.type != SetType.warmup)
      .fold<double>(0.0, (sum, s) => sum + (s.weightKg * s.reps));
}
