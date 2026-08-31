import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/session_exercise.dart';
import '../domain/workout_session.dart';
import '../domain/workout_set.dart';

part 'active_workout_state.freezed.dart';

/// Immutable view state for the active workout logging screen.
///
/// Designed to support 100% offline usage, sub-3s logging, and epoch math timers.
@freezed
abstract class ActiveWorkoutState with _$ActiveWorkoutState {
  const factory ActiveWorkoutState({
    required WorkoutSession? session,
    @Default(<SessionExercise>[]) List<SessionExercise> exercises,
    @Default(<WorkoutSet>[]) List<WorkoutSet> sets,
    @Default(0) int elapsedSeconds,
    /// True when the state came from a launch-time SQLite restore after an
    /// app kill (WU-3.8, §8.1 "restored session" state).
    @Default(false) bool wasRestored,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _ActiveWorkoutState;

  const ActiveWorkoutState._();

  /// Whether an active session is currently running.
  bool get hasActiveSession =>
      session != null && session?.status == WorkoutStatus.active;

  /// Count of completed sets in the active session.
  int get completedSetsCount => sets.isNotEmpty
      ? sets.where((s) => s.isCompleted).length
      : exercises.fold<int>(0, (sum, e) => sum + e.completedSetsCount);

  /// Total working volume lifted in kg (excluding warmup sets per Law L1).
  double get totalVolumeKg => sets.isNotEmpty
      ? sets
          .where((s) => s.isCompleted && s.type != SetType.warmup)
          .fold<double>(0.0, (sum, s) => sum + (s.weightKg * s.reps))
      : exercises.fold<double>(0.0, (sum, e) => sum + e.totalVolumeKg);

  /// Total number of exercises in the active session.
  int get exerciseCount => exercises.length;
}
