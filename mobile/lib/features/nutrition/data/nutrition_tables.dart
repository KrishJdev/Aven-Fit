import 'package:drift/drift.dart';

/// Drift SQLite tables for the Indian Nutrition Engine (WU-4.1,
/// FEATURES.md §11) — the local-first mirror of the backend V5/V9 shapes,
/// extended with the household-serving and satvik fields the moat runs on
/// (L10). All reads/writes are local SQLite; zero network (L2).

/// One curated (or user-created) food entry. Macros are **per standard
/// serving** (`servingSizeG` grams) — the same shape as the backend seed
/// (40 g roti = 104 kcal).
@DataClassName('FoodItemRow')
class FoodItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Brand/manufacturer; null for home-cooked and recipe items.
  TextColumn get brand => text().nullable()();

  /// Grams in one standard serving.
  RealColumn get servingSizeG => real()();

  /// Household unit label ("katori", "roti", "dosa", "glass", "g" ...).
  TextColumn get householdServingUnit => text()();

  /// Grams per household unit; null falls back to [servingSizeG].
  RealColumn get householdUnitGramsRatio => real().nullable()();

  RealColumn get caloriesKcal => real()();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();

  /// Nullable like the backend — unknown fiber stays unknown.
  RealColumn get fiberG => real().nullable()();

  /// FSSAI veg indicator (L10).
  BoolColumn get isVeg => boolean().withDefault(const Constant(false))();

  /// Vrat-friendly set membership (§11.10, ships with WU-4.2 data).
  BoolColumn get isSatvik => boolean().withDefault(const Constant(false))();

  /// Curated category ("GRAIN", "DAL_LENTIL" ...) for filters.
  TextColumn get foodCategory => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get barcode => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// One logged item in a meal. The calculated macros are a denormalized
/// snapshot taken at log time so day totals stay stable across food-entry
/// edits (matching the backend `nutrition_entry_items` shape). Deleting a
/// food cascades to its logged items (L7).
@DataClassName('LoggedMealItemRow')
class LoggedMealItems extends Table {
  TextColumn get id => text()();

  /// The meal's calendar day (local midnight) — the dashboard bucket key.
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()();
  TextColumn get foodItemId =>
      text().references(FoodItems, #id, onDelete: KeyAction.cascade)();
  RealColumn get quantityServings => real()();
  TextColumn get servingUnitUsed => text()();
  RealColumn get calculatedKcal => real()();
  RealColumn get calculatedProteinG => real().withDefault(const Constant(0))();
  RealColumn get calculatedCarbsG => real().withDefault(const Constant(0))();
  RealColumn get calculatedFatG => real().withDefault(const Constant(0))();
  RealColumn get calculatedFiberG => real().nullable()();

  /// Exact log timestamp for ordering within a meal.
  DateTimeColumn get loggedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// The user's daily macro targets — a single 'default' row per device.
/// **No row = no goals set** (the L4 hidden-card state), so absence is
/// meaningful and must be preserved.
@DataClassName('NutritionGoalRow')
class NutritionGoals extends Table {
  /// Singleton row key ('default').
  TextColumn get id => text()();
  RealColumn get targetCalories => real()();
  RealColumn get targetProteinG => real().withDefault(const Constant(0))();
  RealColumn get targetCarbsG => real().withDefault(const Constant(0))();
  RealColumn get targetFatG => real().withDefault(const Constant(0))();

  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
