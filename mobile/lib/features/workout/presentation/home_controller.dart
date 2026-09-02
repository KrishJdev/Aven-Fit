import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../history/data/history_repository.dart';
import '../../history/domain/week_stats.dart';
import '../../history/domain/workout_history_item.dart';
import '../../nutrition/data/nutrition_local_source.dart';
import '../../nutrition/data/nutrition_repository.dart';
import '../../nutrition/domain/nutrition_goals.dart';
import '../../progress/data/streak_repository.dart';
import '../../routine/data/routine_repository.dart';
import '../../routine/domain/routine.dart';
import '../../routine/presentation/routine_list_controller.dart';
import '../data/workout_repository.dart';
import 'active_workout_controller.dart';
import 'home_state.dart';

part 'home_controller.g.dart';

/// Reactive week-over-week glance for the Home stats (§7.1): drift
/// re-emits on any session/set change — zero polling (L8).
@riverpod
Stream<WeeklyGlance> weeklyGlanceStream(Ref ref) {
  return ref.watch(historyRepositoryProvider).watchWeeklyGlance();
}

/// Recent logs feed for Home — the last 10 completed workouts (§7.1),
/// same reactive source as the full history list.
@riverpod
Stream<List<WorkoutHistoryItem>> recentWorkoutsStream(Ref ref) {
  return ref.watch(historyRepositoryProvider).watchCompletedWorkouts(
        limit: 10,
      );
}

/// All routines (name-ordered) — the suggestion pool (§7.1).
@riverpod
Stream<List<Routine>> allRoutinesStream(Ref ref) {
  return ref.watch(routineRepositoryProvider).watchAllRoutines();
}

/// Reactive id of the most-recently used routine (§7.1 P0 heuristic).
@riverpod
Stream<String?> suggestedRoutineIdStream(Ref ref) {
  return ref.watch(routineRepositoryProvider).watchSuggestedRoutineId();
}

/// Goals singleton for the calories chip — null while unset so the chip
/// is hidden entirely (never a nag, L4).
@riverpod
Stream<NutritionGoals?> homeNutritionGoalsStream(Ref ref) {
  return ref.watch(nutritionRepositoryProvider).watchNutritionGoals();
}

/// Today's logged totals for the calories chip (§7.1). The DAO buckets
/// through the single local-midnight day anchor.
@riverpod
Stream<DailyNutritionTotals> homeTodayTotalsStream(Ref ref) {
  return ref.watch(nutritionRepositoryProvider).watchDailyTotals(
        DateTime.now(),
      );
}

/// Riverpod Notifier composing the Home dashboard state (WU-X.1,
/// FEATURES.md §7.1): the active session, streak, week-over-week glance,
/// recent logs, suggested routine, and today's nutrition summary. Every
/// field streams from local SQLite — re-emits on any source change,
/// zero polling (L2/L8).
@riverpod
class HomeController extends _$HomeController {
  @override
  HomeState build() {
    final activeSession = ref.watch(watchActiveSessionProvider).value;
    final streak = ref.watch(watchStreakInfoProvider).value;
    final weeklyGlance = ref.watch(weeklyGlanceStreamProvider).value;
    final recentWorkouts =
        ref.watch(recentWorkoutsStreamProvider).value ??
            const <WorkoutHistoryItem>[];
    final routines =
        ref.watch(allRoutinesStreamProvider).value ?? const <Routine>[];
    final suggestedId = ref.watch(suggestedRoutineIdStreamProvider).value;
    final goals = ref.watch(homeNutritionGoalsStreamProvider).value;
    final todayTotals = ref.watch(homeTodayTotalsStreamProvider).value;

    return HomeState(
      activeSession: activeSession,
      streak: streak,
      weeklyGlance: weeklyGlance,
      recentWorkouts: recentWorkouts,
      suggestedRoutine:
          HomeState.pickSuggestedRoutine(routines, suggestedId),
      goals: goals,
      todayTotals: todayTotals,
    );
  }

  /// One-tap start of the suggested routine (§7.1) — reuses the exact
  /// <1s write-through path the Routines tab uses (L1/L7; the original
  /// routine stays unmutated). Returns the new session id, or null when
  /// no routine is suggested. The one-session rule is a UI concern and
  /// runs before this in the screen.
  Future<String?> startSuggestedRoutine() async {
    final routine = state.suggestedRoutine;
    if (routine == null) return null;
    final session = await ref
        .read(routineListControllerProvider.notifier)
        .startWorkoutFromRoutine(routine);
    return session.id;
  }

  /// Starts a fresh empty workout session (FEATURES.md §5.1 / §7.1).
  Future<String> startNewWorkout([String? name]) async {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final sessionName =
        name ?? ActiveWorkoutController.generateDefaultWorkoutName();
    final session = await workoutRepo.startWorkout(name: sessionName);
    return session.id;
  }
}
