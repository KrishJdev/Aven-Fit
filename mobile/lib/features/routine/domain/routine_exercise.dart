import 'package:freezed_annotation/freezed_annotation.dart';

import '../../exercise/domain/exercise.dart';
import 'routine_set.dart';

part 'routine_exercise.freezed.dart';
part 'routine_exercise.g.dart';

/// Pure immutable domain entity representing an exercise slot within a routine.
///
/// Complies with Law L2 (offline-first routines), Law L7 (write-through integrity),
/// and matches backend `routine_exercises` schema.
@freezed
abstract class RoutineExercise with _$RoutineExercise {
  const RoutineExercise._();

  const factory RoutineExercise({
    required String id,
    required String routineId,
    required String exerciseId,
    Exercise? exercise,
    String? exerciseName,
    @Default(0) int orderIndex,
    @Default(90) int restSeconds,
    String? notes,
    int? targetSetsCount,
    double? targetWeightKg,
    int? targetReps,
    double? targetRpe,
    @Default(<RoutineSet>[]) List<RoutineSet> sets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RoutineExercise;

  factory RoutineExercise.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseFromJson(json);

  /// 1-based or 0-based position aliases
  int get position => orderIndex;

  /// Effective number of target sets
  int get setsCount => sets.isNotEmpty ? sets.length : (targetSetsCount ?? 3);

  /// Readable target summary (e.g. "3 × 10 reps @ 60 kg" or "3 × reps")
  String get targetSummary {
    final count = setsCount;
    final reps = targetReps != null ? '$targetReps reps' : 'reps';
    final weight = targetWeightKg != null && targetWeightKg! > 0
        ? ' @ ${targetWeightKg!.toStringAsFixed(targetWeightKg! % 1 == 0 ? 0 : 1)} kg'
        : '';
    return '$count × $reps$weight';
  }
}
