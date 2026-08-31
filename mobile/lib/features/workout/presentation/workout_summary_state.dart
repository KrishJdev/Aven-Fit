import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/session_exercise.dart';
import '../domain/workout_session.dart';
import '../domain/workout_set.dart';

part 'workout_summary_state.freezed.dart';

/// Immutable view state for the post-workout summary screen (FEATURES.md §8.5).
///
/// All stats are computed from the already-persisted SQLite session — warm-up
/// sets are excluded from working volume per Law L1.
@freezed
abstract class WorkoutSummaryState with _$WorkoutSummaryState {
  const factory WorkoutSummaryState({
    WorkoutSession? session,
    @Default(<SessionExercise>[]) List<SessionExercise> exercises,
    @Default(0) int weeklyWorkoutCount,
    @Default(kDefaultWeeklyGoal) int weeklyGoal,
  }) = _WorkoutSummaryState;

  const WorkoutSummaryState._();

  /// True when the requested session does not exist (designed L6 error state).
  bool get notFound => session == null;

  /// All sets across the session's exercises.
  List<WorkoutSet> get allSets => exercises.expand((e) => e.sets).toList();

  /// Session duration via epoch math (L8): the stored duration when present,
  /// otherwise `completedAt − startedAt`.
  int get durationSeconds {
    final s = session;
    if (s == null) return 0;
    if (s.durationSeconds != null && s.durationSeconds! > 0) {
      return s.durationSeconds!;
    }
    final completed = s.completedAt;
    if (completed == null) return 0;
    final seconds = completed.difference(s.startedAt).inSeconds;
    return seconds > 0 ? seconds : 0;
  }

  /// Count of completed sets (warm-ups included — they were still lifted).
  int get completedSetsCount => allSets.where((s) => s.isCompleted).length;

  /// Total working volume in kg — warm-up sets excluded per Law L1.
  double get totalVolumeKg =>
      exercises.fold<double>(0.0, (sum, e) => sum + e.totalVolumeKg);

  /// Number of PR sets hit in this session.
  int get prCount => allSets.where((s) => s.isCompleted && s.isPr).length;

  /// Whether the forgiving weekly goal is met (FEATURES.md §10 / §17).
  bool get weeklyGoalMet => weeklyWorkoutCount >= weeklyGoal;
}

/// Default forgiving weekly goal (FEATURES.md §5.2 — skipped setups yield 3/week)
/// until WU-X.2 introduces user-configurable streak settings.
const int kDefaultWeeklyGoal = 3;
