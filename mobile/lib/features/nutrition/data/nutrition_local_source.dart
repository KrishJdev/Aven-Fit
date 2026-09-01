import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/logged_meal_item.dart';
import 'nutrition_tables.dart';

part 'nutrition_local_source.g.dart';

/// One logged meal item joined with its food entry — the raw display
/// payload for the daily log (macro snapshot alongside food data).
class LoggedItemWithFood {
  const LoggedItemWithFood({required this.item, required this.food});

  final LoggedMealItemRow item;
  final FoodItemRow food;
}

/// Aggregated macro totals for one calendar day (WU-4.3). Derived state —
/// recomputed from the logged-item snapshots on every read, never persisted,
/// so edits/deletes self-heal (L7/L8).
class DailyNutritionTotals {
  const DailyNutritionTotals({
    required this.itemCount,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG,
  });

  /// How many items make up these totals (dashboard "N items" chip).
  final int itemCount;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  /// Sum of *known* fiber only — null when no logged item carries fiber
  /// data (unknown stays unknown, never silently zeroed).
  final double? fiberG;
}

/// DAO for the Indian Nutrition Engine (WU-4.3, FEATURES.md §11): food
/// catalog search, meal logging with reactive daily views, custom foods,
/// and the goals singleton. All reads/writes are local SQLite — zero
/// network (L2), <300ms search and <100ms log targets (L1).
@DriftAccessor(tables: [FoodItems, LoggedMealItems, NutritionGoals])
class NutritionDao extends DatabaseAccessor<AppDatabase>
    with _$NutritionDaoMixin {
  NutritionDao(super.db);

  /// Singleton goals row key. **No row = no goals set** — the L4
  /// hidden-card state is meaningful absence.
  static const String defaultGoalsId = 'default';

  /// Searches the food catalog by name or brand (case-insensitive LIKE —
  /// sub-300ms over the bundled catalog) with the veg/satvik filters the
  /// moat surfaces (L10, §11.10).
  Future<List<FoodItemRow>> searchFoods({
    String? query,
    bool vegOnly = false,
    bool satvikOnly = false,
  }) {
    final selectQuery = select(foodItems);
    final trimmed = query?.trim().toLowerCase() ?? '';
    if (trimmed.isNotEmpty) {
      final term = '%$trimmed%';
      selectQuery.where(
        (tbl) => tbl.name.lower().like(term) | tbl.brand.lower().like(term),
      );
    }
    if (vegOnly) {
      selectQuery.where((tbl) => tbl.isVeg.equals(true));
    }
    if (satvikOnly) {
      selectQuery.where((tbl) => tbl.isSatvik.equals(true));
    }
    selectQuery.orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return selectQuery.get();
  }

  /// Retrieves a single food entry by ID (detail screen lookup).
  Future<FoodItemRow?> getFoodItemById(String id) {
    return (select(foodItems)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a food row (custom-food creation; seeding batches separately
  /// through [FoodSeedLoader]).
  Future<void> insertFoodItem(FoodItemsCompanion entry) {
    return into(foodItems).insert(entry);
  }

  /// Streams every logged item of [day] (local-midnight bucket) joined
  /// with its food, ordered by log time. Re-emits on any log mutation or
  /// food-catalog change — the dashboard's reactive source.
  Stream<List<LoggedItemWithFood>> watchDailyLog(DateTime day) {
    final joined = select(loggedMealItems).join([
      innerJoin(foodItems, foodItems.id.equalsExp(loggedMealItems.foodItemId)),
    ]);
    // The stored date IS the local-midnight bucket (writes normalize
    // through LoggedMealItem.normalizeDay) — reads bucket through the
    // same anchor so equality never misses.
    joined.where(loggedMealItems.date.equals(LoggedMealItem.normalizeDay(day)));
    joined.orderBy([OrderingTerm.asc(loggedMealItems.loggedAt)]);
    return joined.watch().map(
          (rows) => rows
              .map(
                (row) => LoggedItemWithFood(
                  item: row.readTable(loggedMealItems),
                  food: row.readTable(foodItems),
                ),
              )
              .toList(),
        );
  }

  /// Reactive daily totals — derived from the log stream (L8: recomputed
  /// per emission, never a stored aggregate).
  Stream<DailyNutritionTotals> watchDailyTotals(DateTime day) {
    return watchDailyLog(day).map(_sumTotals);
  }

  /// Retrieves one logged item joined with its food (the quantity-update
  /// recompute needs both).
  Future<LoggedItemWithFood?> getLoggedItemWithFood(String id) async {
    final joined = select(loggedMealItems).join([
      innerJoin(foodItems, foodItems.id.equalsExp(loggedMealItems.foodItemId)),
    ]);
    joined.where(loggedMealItems.id.equals(id));
    final rows = await joined.get();
    if (rows.isEmpty) return null;
    return LoggedItemWithFood(
      item: rows.first.readTable(loggedMealItems),
      food: rows.first.readTable(foodItems),
    );
  }

  /// Inserts a logged item (the denormalized snapshot was already computed
  /// through `FoodItem.scaleFor` by the repository — single macro path).
  Future<void> insertMealItem(LoggedMealItemsCompanion entry) {
    return into(loggedMealItems).insert(entry);
  }

  /// Rewrites the denormalized macro snapshot after a quantity change —
  /// the write-through half of the inline stepper.
  Future<void> updateMealItemSnapshot({
    required String id,
    required double quantityServings,
    required double calculatedKcal,
    required double calculatedProteinG,
    required double calculatedCarbsG,
    required double calculatedFatG,
    required double? calculatedFiberG,
  }) {
    return (update(loggedMealItems)..where((tbl) => tbl.id.equals(id))).write(
      LoggedMealItemsCompanion(
        quantityServings: Value(quantityServings),
        calculatedKcal: Value(calculatedKcal),
        calculatedProteinG: Value(calculatedProteinG),
        calculatedCarbsG: Value(calculatedCarbsG),
        calculatedFatG: Value(calculatedFatG),
        calculatedFiberG: Value(calculatedFiberG),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes one logged item. UI owns the confirmation dialog (L7 — data
  /// deletion itself stays presentation-free).
  Future<int> deleteMealItem(String id) {
    return (delete(loggedMealItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// The goals singleton row, or null before the first goal set (L4).
  Future<NutritionGoalRow?> getNutritionGoals() {
    return (select(nutritionGoals)
          ..where((t) => t.id.equals(defaultGoalsId))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Reactive goals singleton — emits null while unset so the dashboard
  /// can hide the calories-remaining card entirely (never a nag, L4).
  Stream<NutritionGoalRow?> watchNutritionGoals() {
    return (select(nutritionGoals)
          ..where((t) => t.id.equals(defaultGoalsId))
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Upserts the goals singleton row (insert or update paths, mirroring
  /// the streak settings singleton).
  Future<void> upsertNutritionGoals(NutritionGoalsCompanion entry) async {
    final existing = await getNutritionGoals();
    if (existing == null) {
      await into(nutritionGoals).insert(entry);
    } else {
      await (update(nutritionGoals)
            ..where((t) => t.id.equals(defaultGoalsId)))
          .write(entry);
    }
  }

  DailyNutritionTotals _sumTotals(List<LoggedItemWithFood> entries) {
    var kcal = 0.0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    double? fiber;
    for (final entry in entries) {
      final item = entry.item;
      kcal += item.calculatedKcal;
      protein += item.calculatedProteinG;
      carbs += item.calculatedCarbsG;
      fat += item.calculatedFatG;
      final itemFiber = item.calculatedFiberG;
      if (itemFiber != null) {
        fiber = (fiber ?? 0) + itemFiber;
      }
    }
    return DailyNutritionTotals(
      itemCount: entries.length,
      kcal: kcal,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      fiberG: fiber,
    );
  }
}
