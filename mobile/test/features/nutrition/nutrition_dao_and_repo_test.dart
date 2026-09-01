import 'dart:convert';
import 'dart:io';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/nutrition/data/food_seed_loader.dart';
import 'package:aven_fit/features/nutrition/data/nutrition_local_source.dart';
import 'package:aven_fit/features/nutrition/data/nutrition_repository.dart';
import 'package:aven_fit/features/nutrition/domain/food_item.dart';
import 'package:aven_fit/features/nutrition/domain/logged_meal_item.dart';
import 'package:aven_fit/features/nutrition/domain/meal_type.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hermetic asset bundle for the repository's first-run seed path.
class _FakeFoodsBundle extends AssetBundle {
  _FakeFoodsBundle(this.json);

  final String json;

  @override
  Future<String> loadString(String key, {bool cache = true}) async => json;

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NutritionDao + NutritionRepository (WU-4.3)', () {
    late AppDatabase db;
    late NutritionRepository repo;
    late List<Map<String, dynamic>> assetEntries;

    setUpAll(() async {
      final foodsJson =
          await File('assets/data/indian_foods.json').readAsString();
      assetEntries =
          (jsonDecode(foodsJson) as List<dynamic>).cast<Map<String, dynamic>>();
    });

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = NutritionRepositoryImpl(
        db,
        seedBundle: _FakeFoodsBundle(jsonEncode(assetEntries)),
      );
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> seedCatalog() async {
      await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );
    }

    Future<FoodItem> foodByName(String name) async {
      final results = await repo.searchFoods(query: name);
      expect(results, isNotEmpty, reason: 'catalog must contain $name');
      return results.firstWhere((f) => f.name == name);
    }

    DateTime today() => LoggedMealItem.normalizeDay(DateTime.now());

    group('Food search (catalog)', () {
      test("Search 'dal' matches the catalog under 300ms (L1)", () async {
        await seedCatalog();

        final stopwatch = Stopwatch()..start();
        final results = await repo.searchFoods(query: 'dal');
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(300));
        expect(results.length, greaterThanOrEqualTo(10));
        expect(
          results.map((f) => f.name),
          containsAll(['Moong Dal Tadka', 'Toor Dal (Arhar)', 'Dal Makhani']),
        );
      });

      test('vegOnly filters out non-veg results (FSSAI indicator, L10)',
          () async {
        await seedCatalog();

        final chicken = await repo.searchFoods(query: 'chicken');
        expect(chicken, isNotEmpty);
        expect(chicken.every((f) => !f.isVeg), isTrue);

        final vegChicken = await repo.searchFoods(
          query: 'chicken',
          vegOnly: true,
        );
        expect(vegChicken, isEmpty);

        final paneer = await repo.searchFoods(query: 'paneer', vegOnly: true);
        expect(paneer, isNotEmpty);
        expect(paneer.every((f) => f.isVeg), isTrue);
      });

      test('satvikOnly restricts to the §11.10 vrat set', () async {
        await seedCatalog();

        final sabudana = await repo.searchFoods(
          query: 'sabudana',
          satvikOnly: true,
        );
        expect(sabudana, isNotEmpty);
        expect(sabudana.every((f) => f.isSatvik && f.isVeg), isTrue);

        final makhana = await repo.searchFoods(
          query: 'makhana',
          satvikOnly: true,
        );
        expect(makhana.map((f) => f.name), contains('Makhana (Fox Nuts)'));

        // Cooked dishes with onion/garlic never pass the satvik gate.
        final biryani = await repo.searchFoods(
          query: 'biryani',
          satvikOnly: true,
        );
        expect(biryani, isEmpty);
      });

      test('getFoodItemById returns the exact entry / null when unknown',
          () async {
        await seedCatalog();

        final paneer = await repo.getFoodItemById(
          (await foodByName('Paneer (Raw)')).id,
        );
        expect(paneer, isNotNull);
        expect(paneer!.householdServingUnit, 'g');
        expect(paneer.servingSizeG, 100);
        expect(paneer.householdUnitGramsRatio, 100);
        expect(paneer.caloriesKcal, 265);
        expect(paneer.proteinG, 18);

        expect(await repo.getFoodItemById('missing_id'), isNull);
      });
    });

    group('Meal logging & daily views', () {
      test('logMealItem snapshots the exact katori math (J3)', () async {
        await seedCatalog();
        final dal = await foodByName('Moong Dal Tadka');

        final item = await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.lunch,
          quantityServings: 1,
        );

        // Default unit is the food's household unit — 1 katori = 150 g.
        expect(item.servingUnitUsed, 'katori');
        expect(item.calculatedKcal, closeTo(105, 0.001));
        expect(item.calculatedProteinG, closeTo(5.5, 0.001));
        expect(item.date, today());
        expect(item.mealType, MealType.lunch);

        final entry = (await repo.watchDailyLog(item.date).first).single;
        expect(entry.food.name, 'Moong Dal Tadka');
        expect(entry.item.id, item.id);
      });

      test('Gram passthrough logging (50 g paneer)', () async {
        await seedCatalog();
        final paneer = await foodByName('Paneer (Raw)');

        final item = await repo.logMealItem(
          foodItemId: paneer.id,
          mealType: MealType.snack,
          quantityServings: 50,
          servingUnit: 'g',
        );

        expect(item.calculatedKcal, closeTo(132.5, 0.001));
        expect(item.calculatedProteinG, closeTo(9, 0.001));
      });

      test('Daily log buckets by local-midnight day (no cross-day bleed)',
          () async {
        await seedCatalog();
        final dal = await foodByName('Moong Dal Tadka');
        final yesterday = today().subtract(const Duration(days: 1));

        await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.lunch,
          quantityServings: 1,
          date: today(),
        );
        await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.snack,
          quantityServings: 1,
          date: yesterday,
        );

        final todayLog = await repo.watchDailyLog(today()).first;
        final yesterdayLog = await repo.watchDailyLog(yesterday).first;

        expect(todayLog, hasLength(1));
        expect(todayLog.single.item.mealType, MealType.lunch);
        expect(yesterdayLog, hasLength(1));
        expect(yesterdayLog.single.item.mealType, MealType.snack);
      });

      test('Daily totals equal the sum of the item snapshots', () async {
        await seedCatalog();
        final roti = await foodByName('Roti (Whole Wheat)');
        final dal = await foodByName('Moong Dal Tadka');
        final banana = await foodByName('Banana (Medium)');

        final items = [
          await repo.logMealItem(
            foodItemId: roti.id,
            mealType: MealType.breakfast,
            quantityServings: 2,
          ),
          await repo.logMealItem(
            foodItemId: dal.id,
            mealType: MealType.lunch,
            quantityServings: 1.5,
          ),
          await repo.logMealItem(
            foodItemId: banana.id,
            mealType: MealType.snack,
            quantityServings: 1,
          ),
        ];

        final totals = await repo.watchDailyTotals(today()).first;

        expect(totals.itemCount, 3);
        expect(
          totals.kcal,
          closeTo(
            items.fold<double>(0, (sum, i) => sum + i.calculatedKcal),
            0.001,
          ),
        );
        expect(
          totals.proteinG,
          closeTo(
            items.fold<double>(0, (sum, i) => sum + i.calculatedProteinG),
            0.001,
          ),
        );
        expect(
          totals.carbsG,
          closeTo(
            items.fold<double>(0, (sum, i) => sum + i.calculatedCarbsG),
            0.001,
          ),
        );
        expect(
          totals.fatG,
          closeTo(
            items.fold<double>(0, (sum, i) => sum + i.calculatedFatG),
            0.001,
          ),
        );

        // Unknown fiber stays unknown — null until some item carries data.
        final knownFibers = items
            .map((i) => i.calculatedFiberG)
            .whereType<double>()
            .toList();
        if (knownFibers.isEmpty) {
          expect(totals.fiberG, isNull);
        } else {
          expect(
            totals.fiberG,
            closeTo(
              knownFibers.fold<double>(0, (sum, f) => sum + f),
              0.001,
            ),
          );
        }
      });

      test('watchDailyTotals re-emits as items are logged (L8 reactive)',
          () async {
        await seedCatalog();
        final dal = await foodByName('Moong Dal Tadka');

        final emissions = <DailyNutritionTotals>[];
        final sub = repo.watchDailyTotals(today()).listen(emissions.add);
        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(emissions, isNotEmpty);
        expect(emissions.last.itemCount, 0);

        await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.lunch,
          quantityServings: 1,
        );
        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(emissions.last.itemCount, 1);
        expect(emissions.last.kcal, closeTo(105, 0.01));

        await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.dinner,
          quantityServings: 1,
        );
        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(emissions.last.itemCount, 2);

        await sub.cancel();
      });

      test('preWorkout meal type round-trips through the tolerant parse',
          () async {
        await seedCatalog();
        final dal = await foodByName('Moong Dal Tadka');

        final item = await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.preWorkout,
          quantityServings: 0.5,
        );

        final entry = (await repo.watchDailyLog(item.date).first).single;
        expect(entry.item.mealType, MealType.preWorkout);
      });

      test('logMealItem rejects an unknown food id', () async {
        await expectLater(
          repo.logMealItem(
            foodItemId: 'does_not_exist',
            mealType: MealType.lunch,
            quantityServings: 1,
          ),
          throwsStateError,
        );
      });
    });

    group('Quantity stepper & deletion', () {
      test('updateMealItemQuantity recalculates the snapshot via scaleFor',
          () async {
        await seedCatalog();
        final dal = await foodByName('Moong Dal Tadka');

        final original = await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.lunch,
          quantityServings: 1,
          notes: 'home cooked',
        );

        final updated = await repo.updateMealItemQuantity(original.id, 1.5);

        expect(updated, isNotNull);
        expect(updated!.calculatedKcal, closeTo(157.5, 0.001));
        // Identity preserved — only quantity and macro snapshot move.
        expect(updated.id, original.id);
        expect(updated.date, original.date);
        expect(updated.mealType, MealType.lunch);
        expect(updated.servingUnitUsed, 'katori');
        expect(updated.notes, 'home cooked');
        // Drift stores timestamps at second resolution — compare there.
        expect(
          updated.loggedAt!.millisecondsSinceEpoch ~/ 1000,
          original.loggedAt!.millisecondsSinceEpoch ~/ 1000,
        );

        // Persisted: totals reflect the recalculated snapshot.
        final totals = await repo.watchDailyTotals(today()).first;
        expect(totals.itemCount, 1);
        expect(totals.kcal, closeTo(157.5, 0.001));
      });

      test('updateMealItemQuantity returns null for an unknown id',
          () async {
        expect(await repo.updateMealItemQuantity('missing_id', 2), isNull);
      });

      test('deleteMealItem removes the row and shrinks the totals', () async {
        await seedCatalog();
        final dal = await foodByName('Moong Dal Tadka');
        final first = await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.lunch,
          quantityServings: 1,
        );
        final second = await repo.logMealItem(
          foodItemId: dal.id,
          mealType: MealType.dinner,
          quantityServings: 2,
        );

        expect(await repo.deleteMealItem(first.id), isTrue);

        final log = await repo.watchDailyLog(today()).first;
        expect(log, hasLength(1));
        expect(log.single.item.id, second.id);

        final totals = await repo.watchDailyTotals(today()).first;
        expect(totals.itemCount, 1);
        expect(totals.kcal, closeTo(second.calculatedKcal, 0.001));

        expect(await repo.deleteMealItem(first.id), isFalse);
      });
    });

    group('Custom foods', () {
      test('createCustomFood persists an isCustom row and is searchable',
          () async {
        await seedCatalog();

        final created = await repo.createCustomFood(
          name: 'Ghar Ki Dal',
          servingSizeG: 100,
          householdServingUnit: 'bowl',
          householdUnitGramsRatio: 300,
          caloriesKcal: 120,
          proteinG: 6,
          carbsG: 15,
          fatG: 3,
          isVeg: true,
          foodCategory: 'DAL_LENTIL',
        );

        expect(created.isCustom, isTrue);
        expect(created.id, startsWith('food_custom_'));
        expect(created.householdServingUnit, 'bowl');

        final found = await repo.searchFoods(query: 'ghar ki');
        expect(found, hasLength(1));
        expect(found.single.id, created.id);
      });

      test('Custom food logs through its own household unit', () async {
        final created = await repo.createCustomFood(
          name: 'Ghar Ki Dal',
          servingSizeG: 100,
          householdServingUnit: 'bowl',
          householdUnitGramsRatio: 300,
          caloriesKcal: 120,
          proteinG: 6,
          carbsG: 15,
          fatG: 3,
          isVeg: true,
        );

        final logged = await repo.logMealItem(
          foodItemId: created.id,
          mealType: MealType.dinner,
          quantityServings: 2,
        );

        // 2 bowls = 600 g = 6 standard servings → 720 kcal / 36 g protein.
        expect(logged.servingUnitUsed, 'bowl');
        expect(logged.calculatedKcal, closeTo(720, 0.001));
        expect(logged.calculatedProteinG, closeTo(36, 0.001));

        final totals = await repo.watchDailyTotals(today()).first;
        expect(totals.kcal, closeTo(720, 0.001));
      });
    });

    group('Nutrition goals', () {
      test('No row means no goals — the L4 meaningful absence', () async {
        expect(await repo.getNutritionGoals(), isNull);
        expect(await repo.watchNutritionGoals().first, isNull);
      });

      test('setNutritionGoals upserts the singleton and re-emits', () async {
        final first = await repo.setNutritionGoals(
          targetCalories: 2000,
          targetProteinG: 150,
          targetCarbsG: 250,
          targetFatG: 60,
        );
        expect(first.id, 'default');
        expect(first.targetCalories, 2000);
        expect(first.targetProteinG, 150);

        final fromWatch = await repo.watchNutritionGoals().first;
        expect(fromWatch, isNotNull);
        expect(fromWatch!.targetCarbsG, 250);

        // Second set replaces the same singleton row — never a second row.
        final second = await repo.setNutritionGoals(
          targetCalories: 2200,
          targetProteinG: 160,
          targetCarbsG: 240,
          targetFatG: 55,
        );
        expect(second.targetCalories, 2200);

        final rows = await db.select(db.nutritionGoals).get();
        expect(rows, hasLength(1));
        expect(rows.single.targetCalories, 2200);
        expect(rows.single.targetProteinG, 160);
      });
    });

    group('Seed wiring (WU-4.2 contract)', () {
      test('repository.seedInitialData loads the bundled catalog once',
          () async {
        final count = await repo.seedInitialData();
        expect(count, greaterThanOrEqualTo(900));
        expect(count, await FoodSeedLoader.countFoodItems(db));

        // First-run guard: the second call is a no-op.
        final again = await repo.seedInitialData();
        expect(again, count);
        expect(await FoodSeedLoader.countFoodItems(db), count);
      });
    });
  });
}
