import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/workout_repository.dart';
import 'workout_summary_state.dart';

part 'workout_summary_controller.g.dart';

/// Riverpod controller computing post-workout summary stats (FEATURES.md §8.5).
///
/// Loads the fully persisted session from SQLite — zero network, zero live
/// re-fetch (L2/L7). Rendered immediately after Finish.
@riverpod
class WorkoutSummaryController extends _$WorkoutSummaryController {
  @override
  Future<WorkoutSummaryState> build(String sessionId) async {
    final repository = ref.watch(workoutRepositoryProvider);
    final session = await repository.getSessionById(sessionId);

    if (session == null) {
      return const WorkoutSummaryState();
    }

    final weekStart = _startOfWeek(DateTime.now());
    final weeklyCount =
        await repository.getCompletedWorkoutCountSince(weekStart);

    return WorkoutSummaryState(
      session: session,
      exercises: session.exercises,
      weeklyWorkoutCount: weeklyCount,
      weeklyGoal: kDefaultWeeklyGoal,
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

  /// Monday 00:00 of the week containing [now].
  static DateTime _startOfWeek(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - DateTime.monday));
  }
}
