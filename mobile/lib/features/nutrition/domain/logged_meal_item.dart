import 'package:freezed_annotation/freezed_annotation.dart';

import 'food_item.dart';
import 'meal_type.dart';

part 'logged_meal_item.freezed.dart';
part 'logged_meal_item.g.dart';

/// Pure immutable domain entity for one logged item in a meal (WU-4.1,
/// FEATURES.md §11.1/§11.3).
///
/// The macro values are a **denormalized snapshot** taken at log time: the
/// day's totals stay stable even if the underlying food entry is later
/// edited or re-seeded (the same stability rule the backend entry items
/// follow). [date] is the meal's calendar day (local midnight) so the
/// dashboard can bucket without timezone math.
@freezed
abstract class LoggedMealItem with _$LoggedMealItem {
  const factory LoggedMealItem({
    required String id,
    required DateTime date,
    required MealType mealType,
    required String foodItemId,
    required double quantityServings,
    required String servingUnitUsed,
    required double calculatedKcal,
    @Default(0) double calculatedProteinG,
    @Default(0) double calculatedCarbsG,
    @Default(0) double calculatedFatG,
    double? calculatedFiberG,
    DateTime? loggedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _LoggedMealItem;

  factory LoggedMealItem.fromJson(Map<String, dynamic> json) =>
      _$LoggedMealItemFromJson(json);

  /// Builds a log entry from a [FoodItem], computing the macro snapshot
  /// through [FoodItem.scaleFor] — the single macro-math path in the app.
  static LoggedMealItem calculate({
    required String id,
    required DateTime date,
    required MealType mealType,
    required FoodItem food,
    required double quantityServings,
    String? servingUnit,
    String? notes,
    DateTime? loggedAt,
  }) {
    final unit = servingUnit ?? food.householdServingUnit;
    final macros = food.scaleFor(
      quantityServings: quantityServings,
      servingUnit: unit,
    );
    return LoggedMealItem(
      id: id,
      date: date,
      mealType: mealType,
      foodItemId: food.id,
      quantityServings: quantityServings,
      servingUnitUsed: unit,
      calculatedKcal: macros.kcal,
      calculatedProteinG: macros.proteinG,
      calculatedCarbsG: macros.carbsG,
      calculatedFatG: macros.fatG,
      calculatedFiberG: macros.fiberG,
      loggedAt: loggedAt ?? DateTime.now(),
      notes: notes,
    );
  }
}
