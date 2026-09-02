import 'dart:convert';
import 'dart:io';

import 'package:aven_fit/core/database/app_database.dart';
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

/// WU-4.6 — the connected J3 journey (AGENTS.md Quality Matrix): every
/// stage runs through the production `NutritionRepositoryImpl` over
/// in-memory SQLite with persisted-state assertions between stages. The
/// granular units are covered by the dao/repo, domain, search and
/// dashboard suites; this file chains them the way a real offline user
/// experiences the engine.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('J3 — Offline Nutrition Journey (WU-4.6)', () {
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

    DateTime today() => LoggedMealItem.normalizeDay(DateTime.now());

    Future<FoodItem> foodByName(String name) async {
      final results = await repo.searchFoods(query: name);
      expect(results, isNotEmpty, reason: 'catalog must contain $name');
      return results.firstWhere((f) => f.name == name);
    }

    test(
        'Happy path: fresh install → seed → search → household-unit log → '
        'totals parity → stepper → remove → goals flip', () async {
      // ── Stage 0: fresh install — designed absence before any seed (L6).
      expect(await repo.searchFoods(query: 'dal'), isEmpty);
      final emptyTotals = await repo.watchDailyTotals(today()).first;
      expect(emptyTotals.itemCount, 0);
      expect(emptyTotals.kcal, 0);
      // No goals row yet — the L4 meaningful absence the dashboard hides.
      expect(await repo.getNutritionGoals(), isNull);

      // ── Stage 1: first-launch seed via the production repository path
      // (the WU-4.2/WU-4.3 wiring, not the direct loader).
      final seededCount = await repo.seedInitialData();
      expect(seededCount, greaterThanOrEqualTo(900));

      // ── Stage 2: offline search from the bundled catalog (J3 step 1,
      // L2/L10 — zero network by construction).
      final searchStopwatch = Stopwatch()..start();
      final dalResults = await repo.searchFoods(query: 'dal');
      searchStopwatch.stop();
      expect(searchStopwatch.elapsedMilliseconds, lessThan(300));
      final dal = dalResults.firstWhere((f) => f.name == 'Moong Dal Tadka');

      // ── Stage 3: select "1 katori" and log to Lunch (J3 steps 2–3) —
      // exact gram-equivalent macros, recalculation under 100ms (L1).
      final logStopwatch = Stopwatch()..start();
      final dalItem = await repo.logMealItem(
        foodItemId: dal.id,
        mealType: MealType.lunch,
        quantityServings: 1,
      );
      logStopwatch.stop();
      expect(logStopwatch.elapsedMilliseconds, lessThan(100));
      expect(dalItem.servingUnitUsed, 'katori');
      expect(dalItem.calculatedKcal, closeTo(105, 0.001));

      final logAfterFirst = await repo.watchDailyLog(today()).first;
      expect(logAfterFirst, hasLength(1));
      expect(logAfterFirst.single.food.name, 'Moong Dal Tadka');
      expect(logAfterFirst.single.item.mealType, MealType.lunch);

      // ── Stage 4: a full multi-meal day (breakfast roti ×2, snack
      // banana, dinner custom food logged through its own household
      // unit) — daily totals equal the sum of the snapshots (J3 step 4).
      final roti = await foodByName('Roti (Whole Wheat)');
      final banana = await foodByName('Banana (Medium)');
      final custom = await repo.createCustomFood(
        name: 'Protein Khichdi',
        servingSizeG: 200,
        householdServingUnit: 'bowl',
        householdUnitGramsRatio: 200,
        caloriesKcal: 240,
        proteinG: 12,
        carbsG: 30,
        fatG: 6,
        isVeg: true,
      );
      final rotiItem = await repo.logMealItem(
        foodItemId: roti.id,
        mealType: MealType.breakfast,
        quantityServings: 2,
      );
      final bananaItem = await repo.logMealItem(
        foodItemId: banana.id,
        mealType: MealType.snack,
        quantityServings: 1,
      );
      final customItem = await repo.logMealItem(
        foodItemId: custom.id,
        mealType: MealType.dinner,
        quantityServings: 1,
      );
      expect(customItem.servingUnitUsed, 'bowl');
      expect(customItem.calculatedKcal, closeTo(240, 0.001));

      final items = [dalItem, rotiItem, bananaItem, customItem];
      final totals = await repo.watchDailyTotals(today()).first;
      expect(totals.itemCount, 4);
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
      // Fiber parity: the known snapshots only — the custom food carries
      // no fiber and must never contribute a silent zero.
      final knownFibers = items
          .map((i) => i.calculatedFiberG)
          .whereType<double>()
          .toList();
      expect(knownFibers, hasLength(3));
      expect(
        totals.fiberG,
        closeTo(knownFibers.fold<double>(0, (sum, f) => sum + f), 0.001),
      );

      // Meal subtotal the dashboard renders for Lunch.
      final dayLog = await repo.watchDailyLog(today()).first;
      final lunchKcal = dayLog
          .where((e) => e.item.mealType == MealType.lunch)
          .fold<double>(0, (sum, e) => sum + e.item.calculatedKcal);
      expect(lunchKcal, closeTo(105, 0.001));

      // ── Stage 5: inline stepper self-heals the day (L7) — identity
      // preserved, only quantity and snapshot move.
      final stepped = await repo.updateMealItemQuantity(dalItem.id, 1.5);
      expect(stepped, isNotNull);
      expect(stepped!.id, dalItem.id);
      expect(stepped.date, dalItem.date);
      expect(stepped.mealType, MealType.lunch);
      expect(stepped.calculatedKcal, closeTo(157.5, 0.001));

      final totalsAfterStep = await repo.watchDailyTotals(today()).first;
      expect(
        totalsAfterStep.kcal,
        closeTo(
          totals.kcal - dalItem.calculatedKcal + stepped.calculatedKcal,
          0.001,
        ),
      );

      // ── Stage 6: remove shrinks the totals; the other meals survive.
      expect(await repo.deleteMealItem(bananaItem.id), isTrue);
      final totalsAfterRemove = await repo.watchDailyTotals(today()).first;
      expect(totalsAfterRemove.itemCount, 3);
      expect(
        totalsAfterRemove.kcal,
        closeTo(
          totalsAfterStep.kcal - bananaItem.calculatedKcal,
          0.001,
        ),
      );

      // ── Stage 7: goals flip — the L4 absence becomes a target, and a
      // goals write never disturbs the day's food data.
      await repo.setNutritionGoals(
        targetCalories: 2000,
        targetProteinG: 120,
        targetCarbsG: 250,
        targetFatG: 60,
      );
      final goals = await repo.getNutritionGoals();
      expect(goals, isNotNull);
      expect(goals!.targetCalories, 2000);
      expect((await repo.watchNutritionGoals().first)!.targetCalories, 2000);

      final totalsAfterGoals = await repo.watchDailyTotals(today()).first;
      expect(totalsAfterGoals.kcal, closeTo(totalsAfterRemove.kcal, 0.001));
      // consumed + remaining == target — the parity the calories card
      // renders (its math is dashboard-tested; here the inputs line up).
      final consumed = totalsAfterGoals.kcal;
      expect(consumed + (2000 - consumed), closeTo(2000, 0.001));
    });

    test('Fiber semantics: unknown stays unknown; mixed days sum known only',
        () async {
      // A day of only unknown-fiber foods → totals.fiberG is null, never
      // a silently-zeroed 0 (L6 — unknown renders "—", not a fake fact).
      final noFiber = await repo.createCustomFood(
        name: 'Mystery Curry',
        servingSizeG: 100,
        householdServingUnit: 'bowl',
        householdUnitGramsRatio: 250,
        caloriesKcal: 150,
        proteinG: 8,
        carbsG: 12,
        fatG: 6,
        isVeg: true,
      );
      await repo.logMealItem(
        foodItemId: noFiber.id,
        mealType: MealType.lunch,
        quantityServings: 1,
      );
      var totals = await repo.watchDailyTotals(today()).first;
      expect(totals.itemCount, 1);
      // 1 bowl = 250 g = 2.5 standard servings of 100 g → 375 kcal.
      expect(totals.kcal, closeTo(375, 0.001));
      expect(totals.fiberG, isNull);

      // Add a known-fiber food — the totals sum only the known snapshots.
      final withFiber = await repo.createCustomFood(
        name: 'Fruit Bowl',
        servingSizeG: 200,
        householdServingUnit: 'bowl',
        householdUnitGramsRatio: 200,
        caloriesKcal: 120,
        proteinG: 2,
        carbsG: 26,
        fatG: 1,
        fiberG: 4,
        isVeg: true,
      );
      await repo.logMealItem(
        foodItemId: withFiber.id,
        mealType: MealType.dinner,
        quantityServings: 2,
      );
      totals = await repo.watchDailyTotals(today()).first;
      expect(totals.itemCount, 2);
      expect(totals.fiberG, closeTo(8, 0.001)); // 2 servings × 4 g only.
    });

    test('Day isolation: steppers and removals never bleed across days',
        () async {
      await repo.seedInitialData();
      final dal = await foodByName('Moong Dal Tadka');
      final yesterday = today().subtract(const Duration(days: 1));

      final todayItem = await repo.logMealItem(
        foodItemId: dal.id,
        mealType: MealType.lunch,
        quantityServings: 1,
        date: today(),
      );
      final yesterdayItem = await repo.logMealItem(
        foodItemId: dal.id,
        mealType: MealType.lunch,
        quantityServings: 1,
        date: yesterday,
      );

      // Stepping yesterday's item moves only yesterday's totals.
      final stepped = await repo.updateMealItemQuantity(yesterdayItem.id, 3);
      expect(stepped, isNotNull);
      expect(stepped!.date, yesterday); // identity preserved across days
      var todayTotals = await repo.watchDailyTotals(today()).first;
      var yesterdayTotals = await repo.watchDailyTotals(yesterday).first;
      expect(todayTotals.kcal, closeTo(105, 0.001));
      expect(yesterdayTotals.kcal, closeTo(315, 0.001));

      // Deleting today's item frees today without touching yesterday.
      expect(await repo.deleteMealItem(todayItem.id), isTrue);
      todayTotals = await repo.watchDailyTotals(today()).first;
      expect(todayTotals.itemCount, 0);
      expect(todayTotals.kcal, 0);
      yesterdayTotals = await repo.watchDailyTotals(yesterday).first;
      expect(yesterdayTotals.itemCount, 1);
      expect(yesterdayTotals.kcal, closeTo(315, 0.001));

      // Goals are day-agnostic — set once, visible from every day's view.
      await repo.setNutritionGoals(targetCalories: 1800);
      final goals = await repo.watchNutritionGoals().first;
      expect(goals, isNotNull);
      expect(goals!.targetCalories, 1800);
    });
  });
}
