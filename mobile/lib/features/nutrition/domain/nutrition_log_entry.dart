import 'food_item.dart';
import 'logged_meal_item.dart';

/// One logged meal item joined with its food entry (WU-4.3).
///
/// The dashboard's display payload: the log-time macro [item] snapshot
/// plus the [food] data the UI renders (name, household serving unit,
/// veg/satvik flags). A plain carrier — the join lives in the data layer,
/// the UI never sees drift rows.
class NutritionLogEntry {
  const NutritionLogEntry({required this.item, required this.food});

  final LoggedMealItem item;
  final FoodItem food;
}
