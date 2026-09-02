import 'package:freezed_annotation/freezed_annotation.dart';

import '../../history/domain/week_stats.dart';
import '../../history/domain/workout_history_item.dart';
import '../../nutrition/data/nutrition_local_source.dart';
import '../../nutrition/domain/nutrition_goals.dart';
import '../../progress/domain/streak_info.dart';
import '../../routine/domain/routine.dart';
import '../domain/workout_session.dart';

part 'home_state.freezed.dart';

/// Immutable Home dashboard state (WU-X.1, FEATURES.md §7.1): the resume
/// banner, suggested routine, glance stats, and recent logs, all composed
/// from reactive local streams. Pure state — every display string comes
/// from the domain models or the statics below.
@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    WorkoutSession? activeSession,
    StreakInfo? streak,
    WeeklyGlance? weeklyGlance,
    @Default(<WorkoutHistoryItem>[]) List<WorkoutHistoryItem> recentWorkouts,
    Routine? suggestedRoutine,
    NutritionGoals? goals,
    DailyNutritionTotals? todayTotals,
  }) = _HomeState;

  /// §5.1 first-run: nothing completed yet — the giant CTA becomes the
  /// 60-second-goal "START FIRST WORKOUT".
  bool get isFirstRun => recentWorkouts.isEmpty;

  /// §7.1/§11.1: goals unset → the calories chip is hidden entirely
  /// (meaningful absence, never a nag — L4).
  bool get hasCalorieGoal => goals != null && goals!.targetCalories > 0;

  /// Calories left today; negative means over target — a neutral fact,
  /// never colored as a verdict (L4). Null when goals/totals are unset.
  double? get caloriesRemaining {
    final goals = this.goals;
    final totals = todayTotals;
    if (goals == null || goals.targetCalories <= 0 || totals == null) {
      return null;
    }
    return goals.targetCalories - totals.kcal;
  }

  /// ▲/▼ volume delta vs last week in percent. Null when there is no
  /// baseline (last week empty) — a percentage of nothing would be a
  /// fake verdict (L6); use [volumeIsNewThisWeek] for that case instead.
  double? get volumeDeltaPercent {
    final glance = weeklyGlance;
    if (glance == null) return null;
    final last = glance.lastWeek.volumeKg;
    if (last <= 0) return null;
    return (glance.thisWeek.volumeKg - last) / last * 100;
  }

  /// First-ever training week: volume exists but no baseline to compare
  /// against — shown as a neutral "▲ NEW" fact, not a percentage.
  bool get volumeIsNewThisWeek {
    final glance = weeklyGlance;
    if (glance == null) return false;
    return glance.lastWeek.volumeKg <= 0 && glance.thisWeek.volumeKg > 0;
  }

  /// §7.1 time-of-day microcopy.
  static String greetingLabel(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) return 'GOOD MORNING';
    if (hour >= 12 && hour < 17) return 'GOOD AFTERNOON';
    if (hour >= 17 && hour < 21) return 'GOOD EVENING';
    return 'GOOD NIGHT';
  }

  /// "MONDAY · SEP 2" date line under the greeting.
  static String dateLabel(DateTime now) {
    const weekdays = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY',
    ];
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${weekdays[now.weekday - 1]} · ${months[now.month - 1]} ${now.day}';
  }

  /// §7.1 suggested routine (P0 = most-recently used): the routine the
  /// last non-discarded session started from; before any routine has
  /// been used, the first of the (name-ordered) catalog. Null with no
  /// routines at all.
  static Routine? pickSuggestedRoutine(
    List<Routine> routines,
    String? lastUsedRoutineId,
  ) {
    if (routines.isEmpty) return null;
    if (lastUsedRoutineId != null) {
      for (final routine in routines) {
        if (routine.id == lastUsedRoutineId) return routine;
      }
    }
    return routines.first;
  }
}
