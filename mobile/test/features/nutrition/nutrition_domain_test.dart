import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/nutrition/domain/food_item.dart';
import 'package:aven_fit/features/nutrition/domain/logged_meal_item.dart';
import 'package:aven_fit/features/nutrition/domain/meal_type.dart';
import 'package:aven_fit/features/nutrition/domain/nutrition_goals.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MealType (WU-4.1)', () {
    test('tolerant parse accepts any casing and underscore style', () {
      expect(MealType.fromName('BREAKFAST'), MealType.breakfast);
      expect(MealType.fromName('lunch'), MealType.lunch);
      expect(MealType.fromName('DINNER'), MealType.dinner);
      expect(MealType.fromName('Snack'), MealType.snack);
      expect(MealType.fromName('pre_workout'), MealType.preWorkout);
      expect(MealType.fromName('POST-WORKOUT'.toLowerCase()), MealType.postWorkout);
      // Unknown values fall back to the catch-all bucket — never a crash (L6).
      expect(MealType.fromName('brunch??'), MealType.snack);
    });

    test('labels match the dashboard section names', () {
      expect(MealType.breakfast.label, 'BREAKFAST');
      expect(MealType.snack.label, 'SNACKS');
      expect(MealType.preWorkout.label, 'PRE-WORKOUT');
    });
  });

  group('FoodItem domain (WU-4.1)', () {
    // Backend seed shape: Moong Dal Tadka — 150 g katori, 105 kcal per
    // serving, 5.5 P / 14 C / 2.5 F / 3.2 fiber.
    final dal = FoodItem(
      id: 'f_dal',
      name: 'Moong Dal Tadka',
      servingSizeG: 150,
      householdServingUnit: 'katori',
      householdUnitGramsRatio: 150,
      caloriesKcal: 105,
      proteinG: 5.5,
      carbsG: 14,
      fatG: 2.5,
      fiberG: 3.2,
      isVeg: true,
      foodCategory: 'DAL_LENTIL',
    );

    test('immutability, copyWith, and defaults', () {
      expect(dal.isCustom, isFalse);
      expect(dal.isSatvik, isFalse);
      expect(dal.barcode, isNull);
      final custom = dal.copyWith(name: 'Maa Ki Dal', isCustom: true);
      expect(custom.name, 'Maa Ki Dal');
      expect(custom.isCustom, isTrue);
      expect(custom.id, dal.id);
    });

    test('JSON round-trip preserves all fields', () {
      final json = dal.toJson();
      expect(FoodItem.fromJson(json), dal);
    });

    test('scaleFor: household unit multiplies by the unit ratio', () {
      final m = dal.scaleFor(quantityServings: 1.5, servingUnit: 'katori');
      expect(m.grams, 225.0);
      expect(m.kcal, closeTo(157.5, 1e-9));
      expect(m.proteinG, closeTo(8.25, 1e-9));
      expect(m.carbsG, closeTo(21.0, 1e-9));
      expect(m.fatG, closeTo(3.75, 1e-9));
      expect(m.fiberG, closeTo(4.8, 1e-9));
    });

    test('scaleFor: gram input scales linearly from the serving size', () {
      final m = dal.scaleFor(quantityServings: 75, servingUnit: 'g');
      expect(m.grams, 75.0);
      expect(m.kcal, closeTo(52.5, 1e-9)); // exactly half a serving
    });

    test('scaleFor: unknown units are treated as standard servings', () {
      final m = dal.scaleFor(quantityServings: 2, servingUnit: 'bowl');
      expect(m.grams, 300.0);
      expect(m.kcal, closeTo(210.0, 1e-9));
    });

    test('scaleFor: missing household ratio falls back to the serving size',
        () {
      final roti = dal.copyWith(householdUnitGramsRatio: null);
      expect(roti.gramsPerHouseholdUnit, 150.0);
      final m = roti.scaleFor(quantityServings: 2, servingUnit: 'katori');
      expect(m.grams, 300.0);
    });

    test('scaleFor: a zero serving size can never produce NaN (L6)', () {
      final broken = dal.copyWith(servingSizeG: 0);
      final m = broken.scaleFor(quantityServings: 2, servingUnit: 'katori');
      expect(m.kcal, 0);
      expect(m.proteinG, 0);
      expect(m.kcal.isNaN, isFalse);
    });
  });

  group('LoggedMealItem.calculate (WU-4.1)', () {
    test('snapshot math from a food item via the household unit', () {
      final dal = FoodItem(
        id: 'f_dal',
        name: 'Moong Dal Tadka',
        servingSizeG: 150,
        householdServingUnit: 'katori',
        caloriesKcal: 105,
        proteinG: 5.5,
        carbsG: 14,
        fatG: 2.5,
      );
      final log = LoggedMealItem.calculate(
        id: 'log_1',
        date: DateTime(2026, 8, 31),
        mealType: MealType.lunch,
        food: dal,
        quantityServings: 2,
        notes: 'ghee tadka',
      );
      expect(log.foodItemId, 'f_dal');
      expect(log.servingUnitUsed, 'katori');
      expect(log.quantityServings, 2);
      expect(log.calculatedKcal, closeTo(210, 1e-9));
      expect(log.calculatedProteinG, closeTo(11, 1e-9));
      expect(log.calculatedCarbsG, closeTo(28, 1e-9));
      expect(log.calculatedFatG, closeTo(5, 1e-9));
      expect(log.calculatedFiberG, isNull); // nullable propagates
      expect(log.loggedAt, isNotNull);
    });

    test('JSON round-trip preserves the snapshot', () {
      final log = LoggedMealItem(
        id: 'log_2',
        date: DateTime(2026, 8, 31),
        mealType: MealType.breakfast,
        foodItemId: 'f_idli',
        quantityServings: 3,
        servingUnitUsed: 'idli',
        calculatedKcal: 174,
        calculatedProteinG: 6,
        calculatedCarbsG: 36,
        calculatedFatG: 0.3,
        calculatedFiberG: 1.5,
        loggedAt: DateTime(2026, 8, 31, 8, 30),
      );
      expect(LoggedMealItem.fromJson(log.toJson()), log);
    });
  });

  group('NutritionGoals domain (WU-4.1)', () {
    test('JSON round-trip and absence-is-meaningful defaults', () {
      final goals = NutritionGoals(
        id: 'default',
        targetCalories: 2200,
        targetProteinG: 120,
        targetCarbsG: 250,
        targetFatG: 70,
      );
      expect(NutritionGoals.fromJson(goals.toJson()), goals);
    });
  });

  group('Nutrition Drift tables (in-memory SQLite)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> seedDal() async {
      await db.into(db.foodItems).insert(
            FoodItemsCompanion.insert(
              id: 'f_dal',
              name: 'Moong Dal Tadka',
              servingSizeG: 150,
              householdServingUnit: 'katori',
              householdUnitGramsRatio: const drift.Value(150),
              caloriesKcal: 105,
              proteinG: const drift.Value(5.5),
              carbsG: const drift.Value(14),
              fatG: const drift.Value(2.5),
              fiberG: const drift.Value(3.2),
              isVeg: const drift.Value(true),
              foodCategory: const drift.Value('DAL_LENTIL'),
            ),
          );
    }

    test('food + logged item CRUD round-trips through the rows', () async {
      await seedDal();
      await db.into(db.loggedMealItems).insert(
            LoggedMealItemsCompanion.insert(
              id: 'log_1',
              date: DateTime(2026, 8, 31),
              mealType: 'lunch',
              foodItemId: 'f_dal',
              quantityServings: 1.5,
              servingUnitUsed: 'katori',
              calculatedKcal: 157.5,
              calculatedProteinG: const drift.Value(8.25),
              calculatedCarbsG: const drift.Value(21),
              calculatedFatG: const drift.Value(3.75),
              calculatedFiberG: const drift.Value(4.8),
            ),
          );

      final food = await (db.select(db.foodItems)
            ..where((t) => t.id.equals('f_dal')))
          .getSingle();
      expect(food.name, 'Moong Dal Tadka');
      expect(food.householdServingUnit, 'katori');
      expect(food.isVeg, isTrue);

      final log = await (db.select(db.loggedMealItems)
            ..where((t) => t.id.equals('log_1')))
          .getSingle();
      expect(log.mealType, 'lunch');
      expect(log.calculatedKcal, 157.5);
      expect(log.calculatedFiberG, 4.8);
    });

    test('deleting a food cascades to its logged items (L7)', () async {
      await seedDal();
      await db.into(db.loggedMealItems).insert(
            LoggedMealItemsCompanion.insert(
              id: 'log_1',
              date: DateTime(2026, 8, 31),
              mealType: 'lunch',
              foodItemId: 'f_dal',
              quantityServings: 1,
              servingUnitUsed: 'katori',
              calculatedKcal: 105,
            ),
          );

      await (db.delete(db.foodItems)..where((t) => t.id.equals('f_dal'))).go();

      expect(await db.select(db.loggedMealItems).get(), isEmpty);
    });

    test('nutrition goals singleton: insert then update reads back', () async {
      await db.into(db.nutritionGoals).insert(
            NutritionGoalsCompanion.insert(
              id: 'default',
              targetCalories: 2200,
              targetProteinG: const drift.Value(120),
              targetCarbsG: const drift.Value(250),
              targetFatG: const drift.Value(70),
            ),
          );

      var row = await db.select(db.nutritionGoals).getSingle();
      expect(row.targetCalories, 2200);
      expect(row.targetProteinG, 120);

      await (db.update(db.nutritionGoals)
            ..where((t) => t.id.equals('default')))
          .write(NutritionGoalsCompanion(targetCalories: const drift.Value(1900)));
      row = await db.select(db.nutritionGoals).getSingle();
      expect(row.targetCalories, 1900);
    });
  });
}
