import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/nutrition/data/food_seed_loader.dart';
import 'package:aven_fit/features/nutrition/domain/food_item.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hermetic asset bundle for exercising the rootBundle path of the loader.
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

  group('FoodSeedLoader with In-Memory Drift SQLite (WU-4.2)', () {
    late AppDatabase db;
    late List<Map<String, dynamic>> assetEntries;

    setUpAll(() async {
      final foodsJson =
          await File('assets/data/indian_foods.json').readAsString();
      assetEntries =
          (jsonDecode(foodsJson) as List<dynamic>).cast<Map<String, dynamic>>();
    });

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Future<List<FoodItemRow>> seedAll() async {
      await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );
      return db.select(db.foodItems).get();
    }

    test('Seed loader populates every bundled entry (201 verified + expansion)',
        () async {
      final inserted = await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );
      final count = await FoodSeedLoader.countFoodItems(db);

      expect(inserted, assetEntries.length);
      expect(count, inserted);
      // The agreed curated band: 201 verified entries plus the expansion.
      expect(count, greaterThanOrEqualTo(900));
    });

    test('First-run guard skips seeding when foods already exist', () async {
      await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );
      final before = await FoodSeedLoader.countFoodItems(db);

      // Corrupt one row to prove the guard leaves existing data untouched.
      await (db.update(db.foodItems)
            ..where((tbl) => tbl.name.equals('Roti (Whole Wheat)')))
          .write(const FoodItemsCompanion(name: Value('Tampered')));
      final seededAgain = await FoodSeedLoader.seedInitialData(
        db,
        bundle: _FakeFoodsBundle(jsonEncode(assetEntries)),
      );

      expect(seededAgain, before);
      final tampered = await (db.select(db.foodItems)
            ..where((tbl) => tbl.name.equals('Tampered')))
          .getSingle();
      expect(tampered.name, 'Tampered');
    });

    test('Force re-seed restores tampered rows (insertOrReplace idempotency)',
        () async {
      await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );
      await (db.update(db.foodItems)
            ..where((tbl) => tbl.name.equals('Roti (Whole Wheat)')))
          .write(const FoodItemsCompanion(name: Value('Tampered')));

      final seeded = await FoodSeedLoader.seedInitialData(
        db,
        bundle: _FakeFoodsBundle(jsonEncode(assetEntries)),
        force: true,
      );
      expect(seeded, await FoodSeedLoader.countFoodItems(db));

      final roti = await (db.select(db.foodItems)
            ..where((tbl) => tbl.name.equals('Roti (Whole Wheat)')))
          .getSingle();
      expect(roti.name, 'Roti (Whole Wheat)');
      expect(roti.servingSizeG, 40);
      expect(roti.caloriesKcal, 104);
    });

    test("Search 'dal' returns multiple results in under 300ms", () async {
      await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );

      final stopwatch = Stopwatch()..start();
      final results = await (db.select(db.foodItems)
            ..where((tbl) => tbl.name.lower().contains('dal')))
          .get();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(300));
      expect(results.length, greaterThanOrEqualTo(10));
      final names = results.map((f) => f.name).toList();
      expect(
        names,
        containsAll(['Moong Dal Tadka', 'Toor Dal (Arhar)', 'Dal Makhani']),
      );
    });

    test("Search 'paneer' returns results with correct household units",
        () async {
      await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );

      final results = await (db.select(db.foodItems)
            ..where((tbl) => tbl.name.lower().contains('paneer')))
          .get();

      expect(results.length, greaterThanOrEqualTo(10));

      final rawPaneer = results.singleWhere((f) => f.name == 'Paneer (Raw)');
      expect(rawPaneer.householdServingUnit, 'g');
      expect(rawPaneer.servingSizeG, 100);
      expect(rawPaneer.householdUnitGramsRatio, 100);
      expect(rawPaneer.caloriesKcal, 265);
      expect(rawPaneer.proteinG, 18);

      final butterMasala =
          results.singleWhere((f) => f.name == 'Paneer Butter Masala');
      expect(butterMasala.householdServingUnit, 'katori');
      expect(butterMasala.householdUnitGramsRatio, 200);
      expect(butterMasala.caloriesKcal, 320);
    });

    test('Dal entries use calibrated katori household units (J3 contract)',
        () async {
      await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );

      final dals = await (db.select(db.foodItems)
            ..where((tbl) => tbl.name.lower().contains('dal')))
          .get();

      final katoriDals =
          dals.where((f) => f.householdServingUnit == 'katori').toList();
      expect(katoriDals, isNotEmpty);
      for (final dal in katoriDals) {
        expect(dal.householdUnitGramsRatio, isNotNull);
        expect(dal.householdUnitGramsRatio, greaterThan(0));
      }
    });

    test('Veg flag is populated across the catalog (FSSAI indicator)',
        () async {
      final rows = await seedAll();

      final nonVeg = rows.where((row) => !row.isVeg).toList();
      expect(rows.where((row) => row.isVeg), hasLength(greaterThan(700)));
      expect(nonVeg, hasLength(greaterThan(100)));

      // Satvik implies vegetarian — never the reverse.
      for (final row in nonVeg) {
        expect(row.isSatvik, isFalse, reason: '${row.name} must not be satvik');
      }
    });

    test('§11.10 satvik set is flagged (sabudana, kuttu, makhana, fruits)',
        () async {
      final rows = await seedAll();

      final satvik = rows.where((row) => row.isSatvik).toList();
      expect(satvik, hasLength(greaterThanOrEqualTo(100)));

      final names = satvik.map((f) => f.name).toList();
      expect(names, contains('Sabudana Khichdi'));
      expect(names, contains('Makhana (Fox Nuts)'));
      expect(names, contains('Kuttu Ki Roti'));
      expect(names, contains('Singhare Ki Puri (2 pcs)'));
      expect(names, contains('Banana (Medium)'));
    });

    test('Every row passes data-integrity invariants (reliable data gate)',
        () async {
      final rows = await seedAll();
      expect(rows, hasLength(assetEntries.length));

      for (final row in rows) {
        expect(row.servingSizeG, greaterThan(0), reason: row.name);
        expect(row.householdServingUnit, isNotEmpty, reason: row.name);
        // Atwater check: kcal ≈ 4P + 4C + 9F within a generous tolerance —
        // catches absurd entries that would corrupt daily totals (L6).
        final derived = 4 * row.proteinG + 4 * row.carbsG + 9 * row.fatG;
        final tolerance = max(25.0, row.caloriesKcal * 0.2);
        expect(
          (derived - row.caloriesKcal).abs(),
          lessThanOrEqualTo(tolerance),
          reason: '${row.name}: kcal=${row.caloriesKcal} derived=$derived',
        );
        expect(row.isCustom, isFalse, reason: row.name);
        expect(row.barcode, isNull, reason: row.name);
      }
    });

    test('Domain macro math on a seeded row (1 katori dal exactness, J3)',
        () async {
      await FoodSeedLoader.seedFromJsonString(
        db,
        foodsJson: jsonEncode(assetEntries),
      );

      final row = await (db.select(db.foodItems)
            ..where((tbl) => tbl.name.equals('Moong Dal Tadka')))
          .getSingle();
      final food = FoodItem(
        id: row.id,
        name: row.name,
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
      );

      // 1 katori = 150 g → exact per-serving macros.
      final macros = food.scaleFor(quantityServings: 1, servingUnit: 'katori');
      expect(macros.grams, 150);
      expect(macros.kcal, closeTo(105, 0.001));
      expect(macros.proteinG, closeTo(5.5, 0.001));

      // 1.5 katori = 225 g → linear scaling.
      final oneAndHalf =
          food.scaleFor(quantityServings: 1.5, servingUnit: 'katori');
      expect(oneAndHalf.grams, 225);
      expect(oneAndHalf.kcal, closeTo(157.5, 0.001));

      // Gram passthrough.
      final grams = food.scaleFor(quantityServings: 50, servingUnit: 'g');
      expect(grams.grams, 50);
    });
  });
}
