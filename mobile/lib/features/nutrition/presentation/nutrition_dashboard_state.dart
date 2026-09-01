import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/nutrition_local_source.dart' show DailyNutritionTotals;
import '../domain/meal_type.dart';
import '../domain/nutrition_goals.dart';
import '../domain/nutrition_log_entry.dart';

part 'nutrition_dashboard_state.freezed.dart';

/// Pure immutable UI state for the Nutrition Dashboard (WU-4.5,
/// FEATURES.md §11.1). Everything arrives from reactive SQLite streams
/// (L8): the day's log, its derived totals, and the goals singleton.
/// Totals are derived state — recomputed per emission, never persisted
/// (L7).
@freezed
abstract class NutritionDashboardState with _$NutritionDashboardState {
  const factory NutritionDashboardState({
    required DateTime day,
    @Default(<NutritionLogEntry>[]) List<NutritionLogEntry> entries,
    DailyNutritionTotals? totals,
    NutritionGoals? goals,
  }) = _NutritionDashboardState;

  const NutritionDashboardState._();

  /// Whether an effective calorie goal exists. **No goals row (or a zero
  /// target) hides the calories-remaining card entirely — never a nag**
  /// (L4 meaningful absence).
  bool get hasCalorieGoal => goals != null && goals!.targetCalories > 0;

  /// Consumed kcal for the day (0 until the first totals emission).
  double get consumedKcal => totals?.kcal ?? 0;

  /// Calories left vs the goal. Can go negative on an over-target day —
  /// a neutral fact, never a red alarm (L4).
  double get caloriesRemaining =>
      hasCalorieGoal ? goals!.targetCalories - consumedKcal : 0;

  /// The day's items grouped per P0 meal bucket, in §11.1 section order.
  Map<MealType, List<NutritionLogEntry>> get mealEntries {
    final grouped = <MealType, List<NutritionLogEntry>>{};
    for (final meal in const [
      MealType.breakfast,
      MealType.lunch,
      MealType.dinner,
      MealType.snack,
    ]) {
      grouped[meal] = entries.where((e) => e.item.mealType == meal).toList();
    }
    return grouped;
  }

  /// Subtotal kcal of one meal bucket (sum of the denormalized log-time
  /// snapshots — stable across food-entry edits, §11.3).
  double mealKcal(MealType meal) => entries
      .where((e) => e.item.mealType == meal)
      .fold(0, (sum, e) => sum + e.item.calculatedKcal);
}
