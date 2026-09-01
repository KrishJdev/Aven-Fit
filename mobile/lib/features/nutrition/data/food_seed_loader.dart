import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';

/// Service for loading the bundled Indian food database into SQLite on first
/// run (WU-4.2). The asset carries the 201 backend-verified entries plus the
/// curated expansion (~950 total) with household serving units and the §11.10
/// satvik flags — a zero-network first-run experience (Law L2).
class FoodSeedLoader {
  static const String assetPath = 'assets/data/indian_foods.json';

  /// Loads the bundled food seed asset and populates SQLite on first run.
  /// Returns the number of food rows in the database after seeding.
  static Future<int> seedInitialData(
    AppDatabase db, {
    AssetBundle? bundle,
    bool force = false,
  }) async {
    final existingCount = await countFoodItems(db);
    if (existingCount > 0 && !force) {
      return existingCount;
    }

    final activeBundle = bundle ?? rootBundle;
    final foodsJson = await activeBundle.loadString(assetPath);

    return seedFromJsonString(db, foodsJson: foodsJson);
  }

  /// Seeds the database directly from a JSON string.
  static Future<int> seedFromJsonString(
    AppDatabase db, {
    required String foodsJson,
  }) async {
    final List<dynamic> foodsList = jsonDecode(foodsJson) as List<dynamic>;

    final companions = foodsList.map((item) {
      final map = item as Map<String, dynamic>;
      return FoodItemsCompanion(
        id: Value(map['id'] as String),
        name: Value(map['name'] as String),
        brand: Value(map['brand'] as String?),
        servingSizeG: Value((map['servingSizeG'] as num).toDouble()),
        householdServingUnit: Value(map['householdServingUnit'] as String),
        householdUnitGramsRatio: Value(
          (map['householdUnitGramsRatio'] as num?)?.toDouble(),
        ),
        caloriesKcal: Value((map['caloriesKcal'] as num).toDouble()),
        proteinG: Value((map['proteinG'] as num?)?.toDouble() ?? 0),
        carbsG: Value((map['carbsG'] as num?)?.toDouble() ?? 0),
        fatG: Value((map['fatG'] as num?)?.toDouble() ?? 0),
        fiberG: Value((map['fiberG'] as num?)?.toDouble()),
        isVeg: Value(map['isVeg'] as bool? ?? false),
        isSatvik: Value(map['isSatvik'] as bool? ?? false),
        foodCategory: Value(map['foodCategory'] as String?),
        isCustom: const Value(false),
        barcode: const Value(null),
      );
    }).toList();

    // insertOrReplace keeps force re-seeds idempotent (mirrors the exercise
    // seed loader's batch mode).
    await db.batch((b) {
      b.insertAll(db.foodItems, companions, mode: InsertMode.insertOrReplace);
    });

    return companions.length;
  }

  /// Counts the total number of food items in the database.
  static Future<int> countFoodItems(AppDatabase db) async {
    final countExp = db.foodItems.id.count();
    final query = db.selectOnly(db.foodItems)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
