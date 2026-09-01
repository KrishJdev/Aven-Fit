import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/food_item.dart';
import '../domain/meal_type.dart';

part 'food_detail_state.freezed.dart';

/// Pure immutable state representing the Food Item Detail screen
/// (WU-4.4, FEATURES.md §11.4).
///
/// The macros are **never stored** — [macros] recomputes through
/// [FoodItem.scaleFor] (the single macro-math path) on every state change,
/// so a quantity tap re-renders instantly with pure local math (<100ms,
/// L1/L8).
@freezed
abstract class FoodDetailState with _$FoodDetailState {
  const factory FoodDetailState({
    required FoodItem food,
    @Default(1) double quantity,
    /// null → scale in the food's own household unit.
    String? servingUnit,
    @Default(MealType.snack) MealType mealType,
    @Default(false) bool isLogging,
    String? loggedItemId,
    String? errorMessage,
  }) = _FoodDetailState;

  const FoodDetailState._();

  /// The unit currently used for scaling (the food's household unit by
  /// default — "1 katori", "2 roti" are first-class units, L10).
  String get unit => servingUnit ?? food.householdServingUnit;

  /// Macros for the current quantity + unit — pure recomputation, no
  /// persistence (L8-style derived state).
  FoodItemMacros get macros =>
      food.scaleFor(quantityServings: quantity, servingUnit: unit);

  /// Serving unit choices: the food's own household unit + grams. Foods
  /// whose household unit IS grams collapse to the single 'g' option.
  List<String> get unitOptions {
    final household = food.householdServingUnit;
    if (household.trim().toLowerCase() == 'g') return const ['g'];
    return [household, 'g'];
  }
}
