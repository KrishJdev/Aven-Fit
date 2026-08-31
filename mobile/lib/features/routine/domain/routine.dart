import 'package:freezed_annotation/freezed_annotation.dart';

import 'routine_exercise.dart';

part 'routine.freezed.dart';
part 'routine.g.dart';

/// Pure immutable domain entity representing a workout routine / template.
///
/// Complies with Law L2 (offline-first routines), Law L3 (unlimited routines forever),
/// and matches backend `routines` schema.
@freezed
abstract class Routine with _$Routine {
  const Routine._();

  const factory Routine({
    required String id,
    required String name,
    String? description,
    String? userId,
    @Default(<RoutineExercise>[]) List<RoutineExercise> exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Routine;

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);

  /// Number of distinct exercises in the routine
  int get exerciseCount => exercises.length;

  /// Total planned sets across all exercises
  int get totalSets => exercises.fold<int>(0, (sum, e) => sum + e.setsCount);

  /// Estimated duration in seconds:
  /// - ~45s per set (execution time)
  /// - Rest intervals between sets
  int get estimatedDurationSeconds {
    return exercises.fold<int>(0, (sum, e) {
      final sets = e.setsCount;
      if (sets <= 0) return sum;
      final executionTime = sets * 45;
      final restTime = (sets > 1 ? sets - 1 : 0) * e.restSeconds;
      return sum + executionTime + restTime;
    });
  }

  /// Estimated duration in minutes for UI display (rounded up)
  int get estimatedDurationMinutes {
    final secs = estimatedDurationSeconds;
    return (secs / 60).ceil();
  }
}
