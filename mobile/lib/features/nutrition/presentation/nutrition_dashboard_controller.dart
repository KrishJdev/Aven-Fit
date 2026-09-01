import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/nutrition_local_source.dart';
import '../data/nutrition_repository.dart';
import '../domain/logged_meal_item.dart';
import '../domain/nutrition_goals.dart';
import '../domain/nutrition_log_entry.dart';
import 'nutrition_dashboard_state.dart';

part 'nutrition_dashboard_controller.g.dart';

/// The dashboard's selected calendar day, bucketed to local midnight via
/// [LoggedMealItem.normalizeDay] — the single day-anchor every nutrition
/// read goes through (WU-4.3), so navigation never leaves a stray time
/// component. Defaults to today.
@riverpod
class SelectedNutritionDay extends _$SelectedNutritionDay {
  @override
  DateTime build() => LoggedMealItem.normalizeDay(DateTime.now());

  /// Jumps to [day] (bucketed to local midnight).
  void select(DateTime day) => state = LoggedMealItem.normalizeDay(day);

  /// Steps one day back (§11.1 day navigation).
  void previousDay() => state = LoggedMealItem.normalizeDay(
        state.subtract(const Duration(days: 1)),
      );

  /// Steps one day forward — the UI blocks stepping past today.
  void nextDay() => state =
      LoggedMealItem.normalizeDay(state.add(const Duration(days: 1)));

  /// Returns to today.
  void goToToday() => state = LoggedMealItem.normalizeDay(DateTime.now());
}

/// Reactive daily log for [day] — the dashboard's item source. Drift
/// re-emits on every log mutation and catalog change; zero polling (L8).
@riverpod
Stream<List<NutritionLogEntry>> dailyLogStream(Ref ref, DateTime day) {
  return ref.watch(nutritionRepositoryProvider).watchDailyLog(day);
}

/// Reactive daily macro totals for [day] — derived on every read from the
/// log snapshots, never stored, so edits/deletes self-heal (L7/L8).
@riverpod
Stream<DailyNutritionTotals> dailyTotalsStream(Ref ref, DateTime day) {
  return ref.watch(nutritionRepositoryProvider).watchDailyTotals(day);
}

/// Reactive goals singleton — emits null while unset so the dashboard
/// hides the calories-remaining card entirely (never a nag, L4).
@riverpod
Stream<NutritionGoals?> nutritionGoalsStream(Ref ref) {
  return ref.watch(nutritionRepositoryProvider).watchNutritionGoals();
}

/// Riverpod Notifier composing the Nutrition Dashboard state (WU-4.5,
/// FEATURES.md §11.1): the selected day plus the three reactive SQLite
/// streams (daily log, daily totals, goals). Re-emits whenever any source
/// changes — including day navigation, which re-subscribes through the
/// keyed stream providers.
///
/// Mutations are thin write-through pass-throughs to the repository; the
/// daily-log stream re-emits the resulting state, so the macro math is
/// never duplicated here (single path: [LoggedMealItem.calculate] →
/// `FoodItem.scaleFor`, L1/L7).
@riverpod
class NutritionDashboardController extends _$NutritionDashboardController {
  @override
  NutritionDashboardState build() {
    final day = ref.watch(selectedNutritionDayProvider);
    final logAsync = ref.watch(dailyLogStreamProvider(day));
    final totalsAsync = ref.watch(dailyTotalsStreamProvider(day));
    final goalsAsync = ref.watch(nutritionGoalsStreamProvider);

    return NutritionDashboardState(
      day: day,
      entries: logAsync.value ?? const [],
      totals: totalsAsync.value,
      goals: goalsAsync.value,
    );
  }

  /// Inline-stepper quantity change — recomputes the denormalized
  /// snapshot through the food's own math (<100ms, §11.2/L1) and writes
  /// through to SQLite; the daily-log stream re-emits the updated state.
  Future<void> updateItemQuantity(String itemId, double newQuantity) async {
    await ref
        .read(nutritionRepositoryProvider)
        .updateMealItemQuantity(itemId, newQuantity);
  }

  /// Removes one logged item. The UI owns the confirmation dialog
  /// (§11.2 — data never silently vanishes, L7).
  Future<void> removeItem(String itemId) async {
    await ref.read(nutritionRepositoryProvider).deleteMealItem(itemId);
  }
}
