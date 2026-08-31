import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_info.freezed.dart';

/// Default forgiving weekly goal (FEATURES.md §5.2 — skipped setup yields
/// 3/week); also the database default for the streak settings row.
const int kDefaultWeeklyGoal = 3;

/// Immutable forgiving-streak state (WU-X.2, FEATURES.md §17 / §5.2).
///
/// The headline streak is the **forgiving weekly streak**: "workouts this
/// week vs. goal (3–6)", never a punishing daily chain. Weeks are
/// Monday-anchored; a week meeting the goal extends the chain, a lapsed
/// week below goal resets it gently (a fact, never a verdict — L4), and
/// the in-progress current week can never break the chain mid-week.
@freezed
abstract class StreakInfo with _$StreakInfo {
  const factory StreakInfo({
    @Default(kDefaultWeeklyGoal) int weeklyGoalDays,
    @Default(0) int workoutsThisWeek,
    @Default(0) int currentStreakWeeks,
  }) = _StreakInfo;

  const StreakInfo._();

  /// Whether this week already meets the goal (drives the Summary badge
  /// and the Home "X of Y" stat).
  bool get weeklyGoalMet => workoutsThisWeek >= weeklyGoalDays;

  /// "2 of 4" glance display (FEATURES.md §5.2).
  String get weeklyProgressDisplay => '$workoutsThisWeek of $weeklyGoalDays';

  /// Adherence-neutral streak display; empty when the chain is at zero so
  /// the UI can simply omit it (L4 — no shaming).
  String get streakDisplay =>
      currentStreakWeeks <= 0 ? '' : '$currentStreakWeeks week${currentStreakWeeks == 1 ? '' : 's'}';

  /// Monday 00:00 of the week containing [date] — the single week anchor
  /// for every streak computation.
  static DateTime startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// Pure forgiving-weekly-streak math over the effective completion dates
  /// of every completed workout. Weeks are bucketed Monday-anchored; the
  /// chain counts backwards from the current week (met) or last week
  /// (still in progress — never punished mid-week, L4), stopping at the
  /// first unmet week within history. Weeks before the first-ever workout
  /// are pre-history, not misses.
  static StreakInfo compute({
    required DateTime now,
    required int weeklyGoalDays,
    required List<DateTime> completedWorkoutDates,
  }) {
    final goal = weeklyGoalDays < 1 ? kDefaultWeeklyGoal : weeklyGoalDays;
    if (completedWorkoutDates.isEmpty) {
      return StreakInfo(weeklyGoalDays: goal);
    }

    final perWeek = <DateTime, int>{};
    for (final date in completedWorkoutDates) {
      final week = startOfWeek(date);
      perWeek[week] = (perWeek[week] ?? 0) + 1;
    }
    final thisWeek = startOfWeek(now);
    final workoutsThisWeek = perWeek[thisWeek] ?? 0;
    final firstWeek =
        perWeek.keys.reduce((a, b) => a.isBefore(b) ? a : b);

    var streak = 0;
    var cursor = workoutsThisWeek >= goal
        ? thisWeek
        : thisWeek.subtract(const Duration(days: 7));
    while (!cursor.isBefore(firstWeek)) {
      if ((perWeek[cursor] ?? 0) >= goal) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    return StreakInfo(
      weeklyGoalDays: goal,
      workoutsThisWeek: workoutsThisWeek,
      currentStreakWeeks: streak,
    );
  }
}
