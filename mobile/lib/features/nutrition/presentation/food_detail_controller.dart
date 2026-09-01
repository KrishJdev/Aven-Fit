import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/nutrition_repository.dart';
import '../domain/logged_meal_item.dart';
import '../domain/meal_type.dart';
import 'food_detail_state.dart';

part 'food_detail_controller.g.dart';

/// Riverpod AsyncNotifier managing the food detail view (WU-4.4,
/// FEATURES.md §11.4): serving unit + quantity selection with instant
/// macro scaling, meal bucket selection, and write-through logging.
@riverpod
class FoodDetailController extends _$FoodDetailController {
  @override
  FutureOr<FoodDetailState?> build(String foodId) async {
    final repository = ref.watch(nutritionRepositoryProvider);
    final food = await repository.getFoodItemById(foodId);
    if (food == null) return null;
    return FoodDetailState(food: food);
  }

  /// Updates the logged quantity (stepper chips / custom input). Values
  /// are clamped to a sane positive range — a zero quantity would zero
  /// the macros and a negative one is nonsense (L6).
  void setQuantity(double value) {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(
      current.copyWith(quantity: value.clamp(0.05, 10000)),
    );
  }

  /// Switches the serving unit (household unit ↔ grams).
  void selectUnit(String unit) {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(servingUnit: unit));
  }

  /// Selects the target meal bucket (§11.4).
  void selectMeal(MealType mealType) {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(mealType: mealType));
  }

  /// Persists the log through the repository (write-through to SQLite,
  /// L7) and returns the stored item — the screen pops back to the meal
  /// view on success. The dashboard's reactive daily-log stream picks the
  /// item up automatically.
  Future<LoggedMealItem?> log() async {
    final current = state.value;
    if (current == null) return null;

    state = AsyncValue.data(
      current.copyWith(isLogging: true, errorMessage: null),
    );
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      final item = await repository.logMealItem(
        foodItemId: current.food.id,
        mealType: current.mealType,
        quantityServings: current.quantity,
        servingUnit: current.unit,
      );

      // The write-through already happened — if the screen was dismissed
      // mid-log, skip the state touch and hand the item back.
      if (!ref.mounted) return item;

      final latest = state.value;
      if (latest != null) {
        state = AsyncValue.data(
          latest.copyWith(isLogging: false, loggedItemId: item.id),
        );
      }
      return item;
    } catch (_) {
      if (!ref.mounted) return null;
      final latest = state.value;
      if (latest != null) {
        state = AsyncValue.data(
          latest.copyWith(isLogging: false, errorMessage: 'Could not log item'),
        );
      }
      return null;
    }
  }
}
