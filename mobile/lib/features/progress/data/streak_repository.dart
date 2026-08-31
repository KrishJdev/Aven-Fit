import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../domain/streak_info.dart';
import 'streak_local_source.dart';

part 'streak_repository.g.dart';

/// Contract for the forgiving weekly streak (WU-X.2, FEATURES.md §17).
///
/// The streak is never persisted — it is re-derived from the completed
/// workout history on every read, so edits/deletes self-heal (L7). All
/// computation is local SQLite + pure domain math; zero network (L2).
abstract class StreakRepository {
  /// Current streak state: weekly goal, workouts this week, and the
  /// forgiving consecutive-met-weeks count.
  Future<StreakInfo> getStreakInfo();

  /// Reactive streak state — re-emits whenever any workout session or the
  /// streak settings change. Drives the Home glance stats (§5.2).
  Stream<StreakInfo> watchStreakInfo();

  /// Persists the weekly goal (FEATURES.md §17 range 3–6; §5.2 quiz seeds
  /// it). Write-through (L7).
  Future<void> setWeeklyGoal(int days);
}

/// Production implementation of [StreakRepository] backed by Drift SQLite.
class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._dao);

  final StreakDao _dao;

  @override
  Future<StreakInfo> getStreakInfo() async {
    final goal =
        (await _dao.getSettings())?.weeklyGoalDays ?? kDefaultWeeklyGoal;
    final dates = await _dao.getCompletedWorkoutDates();
    return StreakInfo.compute(
      now: DateTime.now(),
      weeklyGoalDays: goal,
      completedWorkoutDates: dates,
    );
  }

  @override
  Stream<StreakInfo> watchStreakInfo() {
    return _dao.watchStreakInput().map((input) => StreakInfo.compute(
          now: DateTime.now(),
          weeklyGoalDays: input.weeklyGoalDays,
          completedWorkoutDates: input.completedDates,
        ));
  }

  @override
  Future<void> setWeeklyGoal(int days) => _dao.setWeeklyGoal(days);
}

/// Riverpod provider exposing [StreakRepository] to feature controllers.
@riverpod
StreakRepository streakRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return StreakRepositoryImpl(db.streakDao);
}

/// Reactive forgiving-streak state for the Home glance stats row (§5.2) —
/// re-emits whenever sessions or streak settings change (L8: no polling).
@riverpod
Stream<StreakInfo> watchStreakInfo(Ref ref) {
  return ref.watch(streakRepositoryProvider).watchStreakInfo();
}
