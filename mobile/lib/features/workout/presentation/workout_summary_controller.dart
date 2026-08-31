import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../progress/data/streak_repository.dart';
import '../data/workout_repository.dart';
import 'workout_summary_state.dart';

part 'workout_summary_controller.g.dart';

/// Riverpod controller computing post-workout summary stats (FEATURES.md §8.5).
///
/// Loads the fully persisted session from SQLite — zero network, zero live
/// re-fetch (L2/L7). Rendered immediately after Finish. The weekly-streak
/// badge reads the settings-driven forgiving goal via [StreakRepository]
/// (WU-X.2, §17) — the Monday week anchor lives in the streak domain so
/// every surface computes it identically.
@riverpod
class WorkoutSummaryController extends _$WorkoutSummaryController {
  @override
  Future<WorkoutSummaryState> build(String sessionId) async {
    final repository = ref.watch(workoutRepositoryProvider);
    final session = await repository.getSessionById(sessionId);

    if (session == null) {
      return const WorkoutSummaryState();
    }

    final streak = await ref.watch(streakRepositoryProvider).getStreakInfo();

    return WorkoutSummaryState(
      session: session,
      exercises: session.exercises,
      weeklyWorkoutCount: streak.workoutsThisWeek,
      weeklyGoal: streak.weeklyGoalDays,
    );
  }

  /// Inline rename with write-through (L7). Blank submissions fall back to
  /// 'Workout' per FEATURES.md §8.5.
  Future<void> renameWorkout(String newName) async {
    final current = state.value;
    final session = current?.session;
    if (current == null || session == null) return;

    final trimmed = newName.trim();
    final finalName = trimmed.isEmpty ? 'Workout' : trimmed;

    state = AsyncValue.data(
      current.copyWith(session: session.copyWith(name: finalName)),
    );

    await ref.read(workoutRepositoryProvider).renameSession(session.id, finalName);
  }
}
