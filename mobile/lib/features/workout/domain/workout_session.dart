import 'package:freezed_annotation/freezed_annotation.dart';

import 'session_exercise.dart';
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
  const WorkoutSession._();

  const factory WorkoutSession({
    required String id,
    String? userId,
    String? routineId,
    @Default('Workout') String name,
    required DateTime startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    @Default(WorkoutStatus.active) WorkoutStatus status,
    @Default(false) bool isPaused,
    /// Epoch of the last moment the session timer ticked — the freeze point
    /// while paused (`last_resumed_at` pattern, FEATURES.md §8.1 / L8).
    DateTime? lastResumedAt,
    @Default(0) int pausedDurationSeconds,
    @Default(<SessionExercise>[]) List<SessionExercise> exercises,
    @Default(<WorkoutSet>[]) List<WorkoutSet> sets,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);

  /// Wall-clock seconds the session has been running — pure epoch math,
  /// zero CPU polling (L8):
  ///
  /// * running:   `now − startedAt − pausedDuration`
  /// * paused:    frozen at the pause moment (`lastResumedAt − startedAt − pausedDuration`)
  /// * completed: stored `durationSeconds` when present, else the epoch math
  /// * discarded: frozen at the last tick so stale sessions never keep counting
  int elapsedSecondsNow([DateTime? now]) {
    final at = now ?? DateTime.now();
    final int elapsed;
    switch (status) {
      case WorkoutStatus.completed:
        final stored = durationSeconds;
        if (stored != null) return stored < 0 ? 0 : stored;
        elapsed = (completedAt ?? at).difference(startedAt).inSeconds;
      case WorkoutStatus.active when isPaused:
        elapsed = (lastResumedAt ?? startedAt).difference(startedAt).inSeconds;
      case WorkoutStatus.active:
        elapsed = at.difference(startedAt).inSeconds;
      case WorkoutStatus.discarded:
        elapsed = (lastResumedAt ?? startedAt).difference(startedAt).inSeconds;
    }
    final value = elapsed - pausedDurationSeconds;
    return value < 0 ? 0 : value;
  }

  /// Total number of sets across all exercises
  int get totalSetsCount => exercises.isNotEmpty
      ? exercises.fold<int>(0, (sum, e) => sum + e.setsCount)
      : sets.length;

  /// Count of completed sets
  int get completedSetsCount => exercises.isNotEmpty
      ? exercises.fold<int>(0, (sum, e) => sum + e.completedSetsCount)
      : sets.where((s) => s.isCompleted).length;

  /// Total working volume lifted in kg (excluding warmup sets per Law L1)
  double get totalVolumeKg => exercises.isNotEmpty
      ? exercises.fold<double>(0.0, (sum, e) => sum + e.totalVolumeKg)
      : sets
          .where((s) => s.isCompleted && s.type != SetType.warmup)
          .fold<double>(0.0, (sum, s) => sum + (s.weightKg * s.reps));
}
