import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../domain/food_item.dart';
import '../domain/logged_meal_item.dart';
import '../domain/meal_type.dart';
import '../domain/nutrition_goals.dart';
import '../domain/nutrition_log_entry.dart';
import 'food_seed_loader.dart';
import 'nutrition_local_source.dart';

part 'nutrition_repository.g.dart';

/// Contract defining the Indian Nutrition Engine's data operations
/// (WU-4.3, FEATURES.md §11). Every path is local SQLite — zero network
/// (L2); every macro number flows through `FoodItem.scaleFor`.
abstract class NutritionRepository {
  /// Searches the food catalog (name/brand) with the veg/satvik filters.
  Future<List<FoodItem>> searchFoods({
    String? query,
    bool vegOnly = false,
    bool satvikOnly = false,
  });

  /// Retrieves a single food entry by ID (null when unknown).
  Future<FoodItem?> getFoodItemById(String id);

  /// Creates a user-defined food entry ([FoodItem.isCustom] true).
  Future<FoodItem> createCustomFood({
    required String name,
    String? brand,
    required double servingSizeG,
    required String householdServingUnit,
    double? householdUnitGramsRatio,
    required double caloriesKcal,
    double proteinG = 0,
    double carbsG = 0,
    double fatG = 0,
    double? fiberG,
    required bool isVeg,
    bool isSatvik = false,
    String? foodCategory,
  });

  /// Logs one meal item, computing the denormalized macro snapshot at log
  /// time so day totals stay stable across food-entry edits (§11.3).
  /// [date] defaults to today, bucketed to local midnight.
  Future<LoggedMealItem> logMealItem({
    required String foodItemId,
    required MealType mealType,
    required double quantityServings,
    String? servingUnit,
    DateTime? date,
    String? notes,
  });

  /// Inline-stepper quantity change — recomputes the macro snapshot
  /// through the food's per-serving math (sub-100ms, L1) while preserving
  /// the log day, meal bucket and timestamp. Null when the id is unknown.
  Future<LoggedMealItem?> updateMealItemQuantity(
    String itemId,
    double newQuantityServings,
  );

  /// Deletes one logged item (true when a row was removed). The UI owns
  /// the confirmation dialog.
  Future<bool> deleteMealItem(String itemId);

  /// Reactive daily log for [day] (local-midnight bucket), items joined
  /// with their food entries.
  Stream<List<NutritionLogEntry>> watchDailyLog(DateTime day);

  /// Reactive daily macro totals — derived on every read, never stored.
  Stream<DailyNutritionTotals> watchDailyTotals(DateTime day);

  /// The goals row, or null when unset (L4 meaningful absence).
  Future<NutritionGoals?> getNutritionGoals();

  /// Reactive goals singleton — emits null while unset so the dashboard
  /// hides the calories-remaining card entirely (never a nag, L4).
  Stream<NutritionGoals?> watchNutritionGoals();

  /// Upserts the daily macro targets (the 'default' singleton row).
  Future<NutritionGoals> setNutritionGoals({
    required double targetCalories,
    double targetProteinG = 0,
    double targetCarbsG = 0,
    double targetFatG = 0,
  });

  /// Loads the bundled Indian food catalog on first run (WU-4.2 wiring —
  /// the presentation controller calls this once before first search).
  Future<int> seedInitialData({bool force = false});
}

/// Production implementation of [NutritionRepository] backed by
/// [NutritionDao].
class NutritionRepositoryImpl implements NutritionRepository {
  NutritionRepositoryImpl(this._db, {this.seedBundle});

  final AppDatabase _db;

  /// Hermetic test seam for the first-run asset load (null → rootBundle).
  final AssetBundle? seedBundle;

  static int _idCounter = 0;

  NutritionDao get _dao => _db.nutritionDao;

  @override
  Future<List<FoodItem>> searchFoods({
    String? query,
    bool vegOnly = false,
    bool satvikOnly = false,
  }) async {
    final rows = await _dao.searchFoods(
      query: query,
      vegOnly: vegOnly,
      satvikOnly: satvikOnly,
    );
    return rows.map(_mapFood).toList();
  }

  @override
  Future<FoodItem?> getFoodItemById(String id) async {
    final row = await _dao.getFoodItemById(id);
    return row == null ? null : _mapFood(row);
  }

  @override
  Future<FoodItem> createCustomFood({
    required String name,
    String? brand,
    required double servingSizeG,
    required String householdServingUnit,
    double? householdUnitGramsRatio,
    required double caloriesKcal,
    double proteinG = 0,
    double carbsG = 0,
    double fatG = 0,
    double? fiberG,
    required bool isVeg,
    bool isSatvik = false,
    String? foodCategory,
  }) async {
    final id =
        'food_custom_${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';
    final now = DateTime.now();
    await _dao.insertFoodItem(
      FoodItemsCompanion(
        id: Value(id),
        name: Value(name),
        brand: Value(brand),
        servingSizeG: Value(servingSizeG),
        householdServingUnit: Value(householdServingUnit),
        householdUnitGramsRatio: Value(householdUnitGramsRatio),
        caloriesKcal: Value(caloriesKcal),
        proteinG: Value(proteinG),
        carbsG: Value(carbsG),
        fatG: Value(fatG),
        fiberG: Value(fiberG),
        isVeg: Value(isVeg),
        isSatvik: Value(isSatvik),
        foodCategory: Value(foodCategory),
        isCustom: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    final created = await getFoodItemById(id);
    return created!;
  }

  @override
  Future<LoggedMealItem> logMealItem({
    required String foodItemId,
    required MealType mealType,
    required double quantityServings,
    String? servingUnit,
    DateTime? date,
    String? notes,
  }) async {
    final foodRow = await _dao.getFoodItemById(foodItemId);
    if (foodRow == null) {
      throw StateError('Cannot log meal item: food $foodItemId not found');
    }
    final item = LoggedMealItem.calculate(
      id: 'meal_${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}',
      date: LoggedMealItem.normalizeDay(date ?? DateTime.now()),
      mealType: mealType,
      food: _mapFood(foodRow),
      quantityServings: quantityServings,
      servingUnit: servingUnit,
      notes: notes,
    );
    await _dao.insertMealItem(
      LoggedMealItemsCompanion(
        id: Value(item.id),
        date: Value(item.date),
        mealType: Value(item.mealType.name),
        foodItemId: Value(item.foodItemId),
        quantityServings: Value(item.quantityServings),
        servingUnitUsed: Value(item.servingUnitUsed),
        calculatedKcal: Value(item.calculatedKcal),
        calculatedProteinG: Value(item.calculatedProteinG),
        calculatedCarbsG: Value(item.calculatedCarbsG),
        calculatedFatG: Value(item.calculatedFatG),
        calculatedFiberG: Value(item.calculatedFiberG),
        loggedAt: Value(item.loggedAt),
        notes: Value(item.notes),
      ),
    );
    return item;
  }

  @override
  Future<LoggedMealItem?> updateMealItemQuantity(
    String itemId,
    double newQuantityServings,
  ) async {
    final joined = await _dao.getLoggedItemWithFood(itemId);
    if (joined == null) return null;
    final row = joined.item;
    // Recompute through the single macro-math path while preserving the
    // log's day/meal/timestamp identity — only quantity and snapshot move.
    final updated = LoggedMealItem.calculate(
      id: row.id,
      date: row.date,
      mealType: MealType.fromName(row.mealType),
      food: _mapFood(joined.food),
      quantityServings: newQuantityServings,
      servingUnit: row.servingUnitUsed,
      notes: row.notes,
      loggedAt: row.loggedAt,
    );
    await _dao.updateMealItemSnapshot(
      id: updated.id,
      quantityServings: updated.quantityServings,
      calculatedKcal: updated.calculatedKcal,
      calculatedProteinG: updated.calculatedProteinG,
      calculatedCarbsG: updated.calculatedCarbsG,
      calculatedFatG: updated.calculatedFatG,
      calculatedFiberG: updated.calculatedFiberG,
    );
    return updated;
  }

  @override
  Future<bool> deleteMealItem(String itemId) async {
    final affected = await _dao.deleteMealItem(itemId);
    return affected > 0;
  }

  @override
  Stream<List<NutritionLogEntry>> watchDailyLog(DateTime day) {
    return _dao.watchDailyLog(day).map(
          (rows) => rows
              .map(
                (row) => NutritionLogEntry(
                  item: _mapLoggedItem(row.item),
                  food: _mapFood(row.food),
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<DailyNutritionTotals> watchDailyTotals(DateTime day) {
    return _dao.watchDailyTotals(day);
  }

  @override
  Future<NutritionGoals?> getNutritionGoals() async {
    final row = await _dao.getNutritionGoals();
    return row == null ? null : _mapGoals(row);
  }

  @override
  Stream<NutritionGoals?> watchNutritionGoals() {
    return _dao.watchNutritionGoals().map((row) => row == null
        ? null
        : _mapGoals(row));
  }

  @override
  Future<NutritionGoals> setNutritionGoals({
    required double targetCalories,
    double targetProteinG = 0,
    double targetCarbsG = 0,
    double targetFatG = 0,
  }) async {
    await _dao.upsertNutritionGoals(
      NutritionGoalsCompanion(
        id: const Value(NutritionDao.defaultGoalsId),
        targetCalories: Value(targetCalories),
        targetProteinG: Value(targetProteinG),
        targetCarbsG: Value(targetCarbsG),
        targetFatG: Value(targetFatG),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final stored = await _dao.getNutritionGoals();
    return _mapGoals(stored!);
  }

  @override
  Future<int> seedInitialData({bool force = false}) {
    return FoodSeedLoader.seedInitialData(
      _db,
      bundle: seedBundle,
      force: force,
    );
  }

  FoodItem _mapFood(FoodItemRow row) {
    return FoodItem(
      id: row.id,
      name: row.name,
      brand: row.brand,
      servingSizeG: row.servingSizeG,
      householdServingUnit: row.householdServingUnit,
      householdUnitGramsRatio: row.householdUnitGramsRatio,
      caloriesKcal: row.caloriesKcal,
      proteinG: row.proteinG,
      carbsG: row.carbsG,
      fatG: row.fatG,
      fiberG: row.fiberG,
      isVeg: row.isVeg,
      isSatvik: row.isSatvik,
      foodCategory: row.foodCategory,
      isCustom: row.isCustom,
      barcode: row.barcode,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  LoggedMealItem _mapLoggedItem(LoggedMealItemRow row) {
    return LoggedMealItem(
      id: row.id,
      date: row.date,
      mealType: MealType.fromName(row.mealType),
      foodItemId: row.foodItemId,
      quantityServings: row.quantityServings,
      servingUnitUsed: row.servingUnitUsed,
      calculatedKcal: row.calculatedKcal,
      calculatedProteinG: row.calculatedProteinG,
      calculatedCarbsG: row.calculatedCarbsG,
      calculatedFatG: row.calculatedFatG,
      calculatedFiberG: row.calculatedFiberG,
      loggedAt: row.loggedAt,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  NutritionGoals _mapGoals(NutritionGoalRow row) {
    return NutritionGoals(
      id: row.id,
      targetCalories: row.targetCalories,
      targetProteinG: row.targetProteinG,
      targetCarbsG: row.targetCarbsG,
      targetFatG: row.targetFatG,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

/// Riverpod provider exposing [NutritionRepository] to presentation
/// controllers.
@riverpod
NutritionRepository nutritionRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return NutritionRepositoryImpl(db);
}
