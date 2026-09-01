import 'dart:io';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/nutrition/data/food_seed_loader.dart';
import 'package:aven_fit/features/nutrition/data/nutrition_repository.dart';
import 'package:aven_fit/features/nutrition/domain/food_item.dart';
import 'package:aven_fit/features/nutrition/domain/logged_meal_item.dart';
import 'package:aven_fit/features/nutrition/domain/meal_type.dart';
import 'package:aven_fit/features/nutrition/presentation/food_detail_controller.dart';
import 'package:aven_fit/features/nutrition/presentation/food_detail_screen.dart';
import 'package:aven_fit/features/nutrition/presentation/food_detail_state.dart';
import 'package:aven_fit/features/nutrition/presentation/food_search_controller.dart';
import 'package:aven_fit/features/nutrition/presentation/food_search_screen.dart';
import 'package:aven_fit/features/nutrition/presentation/food_search_state.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

  late AppDatabase db;
  late NutritionRepository repo;
  late String assetJson;

  setUpAll(() async {
    assetJson = await File('assets/data/indian_foods.json').readAsString();
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = NutritionRepositoryImpl(
      db,
      seedBundle: _FakeFoodsBundle(assetJson),
    );
    await FoodSeedLoader.seedFromJsonString(db, foodsJson: assetJson);
  });

  tearDown(() async {
    await db.close();
  });

  Future<FoodItem> foodByName(String name) async {
    final results = await repo.searchFoods(query: name);
    expect(results, isNotEmpty, reason: 'catalog must contain $name');
    return results.firstWhere((f) => f.name == name);
  }

  group('FoodSearchController (WU-4.4)', () {
    late ProviderContainer container;
    // Keep-alive: without a listener, the autoDispose controller is
    // disposed during the debounce waits below.
    late ProviderSubscription<AsyncValue<FoodSearchState>> sub;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          nutritionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      sub = container.listen(foodSearchControllerProvider, (_, _) {});
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    test('build seeds the catalog on first launch and loads the full list',
        () async {
      final state = await container.read(foodSearchControllerProvider.future);

      expect(state.foods.length, greaterThanOrEqualTo(900));
      expect(state.hasActiveFilters, isFalse);
    });

    test('setSearchQuery filters results after the debounce window',
        () async {
      await container.read(foodSearchControllerProvider.future);
      final notifier = container.read(foodSearchControllerProvider.notifier);

      notifier.setSearchQuery('dal');

      // The query reflects immediately; results are still the full catalog.
      var state = container.read(foodSearchControllerProvider).value!;
      expect(state.searchQuery, 'dal');
      expect(state.foods.length, greaterThanOrEqualTo(900));

      await Future<void>.delayed(kFoodSearchDebounce);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      state = container.read(foodSearchControllerProvider).value!;
      expect(state.foods.length, lessThan(900));
      expect(state.foods, isNotEmpty);
      for (final food in state.foods) {
        final matches = food.name.toLowerCase().contains('dal') ||
            (food.brand?.toLowerCase().contains('dal') ?? false);
        expect(matches, isTrue, reason: food.name);
      }
    });

    test('vegOnly toggle filters out non-veg results (FSSAI, L10)', () async {
      await container.read(foodSearchControllerProvider.future);
      final notifier = container.read(foodSearchControllerProvider.notifier);

      await notifier.toggleVegOnly();
      var state = container.read(foodSearchControllerProvider).value!;
      expect(state.vegOnly, isTrue);
      expect(state.foods, isNotEmpty);
      expect(state.foods.every((f) => f.isVeg), isTrue);

      notifier.setSearchQuery('chicken');
      await Future<void>.delayed(kFoodSearchDebounce);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      state = container.read(foodSearchControllerProvider).value!;
      expect(state.foods, isEmpty);
    });

    test('satvikOnly toggle restricts to the §11.10 vrat set', () async {
      await container.read(foodSearchControllerProvider.future);
      final notifier = container.read(foodSearchControllerProvider.notifier);

      notifier.setSearchQuery('sabudana');
      await Future<void>.delayed(kFoodSearchDebounce);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await notifier.toggleSatvikOnly();
      final state = container.read(foodSearchControllerProvider).value!;
      expect(state.satvikOnly, isTrue);
      expect(state.foods, isNotEmpty);
      expect(state.foods.every((f) => f.isSatvik && f.isVeg), isTrue);
    });

    test('clearFilters restores the full catalog', () async {
      await container.read(foodSearchControllerProvider.future);
      final notifier = container.read(foodSearchControllerProvider.notifier);

      await notifier.toggleVegOnly();
      notifier.setSearchQuery('dal');
      await Future<void>.delayed(kFoodSearchDebounce);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(
        container.read(foodSearchControllerProvider).value!.hasActiveFilters,
        isTrue,
      );

      await notifier.clearFilters();
      final state = container.read(foodSearchControllerProvider).value!;
      expect(state.hasActiveFilters, isFalse);
      expect(state.foods.length, greaterThanOrEqualTo(900));
    });
  });

  group('FoodSearchScreen widget (WU-4.4)', () {
    testWidgets('Renders header, chips, tiles, and filters via search',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [nutritionRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppTheme.oledBlack,
            ),
            home: const FoodSearchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('FOOD DATABASE'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('VEG ONLY'), findsOneWidget);
      // The chip plus SATVIK badges on visible tiles.
      expect(find.text('SATVIK'), findsWidgets);

      // Search "dal" → results appear after the debounce (<300ms window).
      await tester.enterText(find.byType(TextField), 'dal');
      await tester.pump();
      await tester.pump(kFoodSearchDebounce);
      await tester.pumpAndSettle();

      expect(find.byType(VegMark), findsWidgets);

      // 'Moong Dal Tadka' sits below the fold (ListView.builder) — scroll
      // to it (the list's Scrollable is the LAST in the tree; the chips
      // bar owns the first horizontal one) and assert its serving line.
      await tester.scrollUntilVisible(
        find.text('Moong Dal Tadka'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(find.text('Moong Dal Tadka'), findsOneWidget);
      // Several dal entries share the calibrated 150 g katori serving.
      expect(find.text('1 katori · 150 g'), findsWidgets);
    });

    testWidgets('Zero-result query shows a designed empty state (L6)',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [nutritionRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppTheme.oledBlack,
            ),
            home: const FoodSearchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzzz_no_such_food');
      await tester.pump();
      await tester.pump(kFoodSearchDebounce);
      await tester.pumpAndSettle();

      expect(find.text('No foods match your search.'), findsOneWidget);
      expect(find.text('CLEAR FILTERS'), findsOneWidget);

      await tester.tap(find.text('CLEAR FILTERS'));
      await tester.pumpAndSettle();

      expect(find.text('No foods match your search.'), findsNothing);
    });
  });

  group('FoodDetailController (WU-4.4)', () {
    late ProviderContainer container;
    late ProviderSubscription<AsyncValue<FoodDetailState?>> sub;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          nutritionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      sub = container.listen(
        foodDetailControllerProvider('keepalive'),
        (_, _) {},
      );
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    test('build loads the food with household-unit defaults', () async {
      final dal = await foodByName('Moong Dal Tadka');
      final state =
          await container.read(foodDetailControllerProvider(dal.id).future);

      expect(state, isNotNull);
      expect(state!.food.name, 'Moong Dal Tadka');
      expect(state.quantity, 1);
      expect(state.unit, 'katori');
      expect(state.mealType, MealType.snack);
      expect(state.unitOptions, ['katori', 'g']);

      // 1 katori = 150 g → exact per-serving macros.
      expect(state.macros.kcal, closeTo(105, 0.001));
      expect(state.macros.proteinG, closeTo(5.5, 0.001));
    });

    test('unknown id resolves to the designed not-found state', () async {
      final state =
          await container.read(foodDetailControllerProvider('missing').future);
      expect(state, isNull);
    });

    test('Quantity/unit changes recompute macros instantly (<100ms, L1)',
        () async {
      final dal = await foodByName('Moong Dal Tadka');
      final notifier =
          container.read(foodDetailControllerProvider(dal.id).notifier);
      await container.read(foodDetailControllerProvider(dal.id).future);

      final stopwatch = Stopwatch()..start();
      notifier.setQuantity(1.5);
      var state = container.read(foodDetailControllerProvider(dal.id)).value!;
      final kcal = state.macros.kcal;
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(kcal, closeTo(157.5, 0.001));
      expect(state.macros.grams, 225);

      // Gram passthrough: 50 g of a 150 g-serving dal.
      notifier.selectUnit('g');
      notifier.setQuantity(50);
      state = container.read(foodDetailControllerProvider(dal.id)).value!;
      expect(state.macros.grams, 50);
      expect(state.macros.kcal, closeTo(35, 0.001));
    });

    test('selectMeal switches the target bucket', () async {
      final dal = await foodByName('Moong Dal Tadka');
      final notifier =
          container.read(foodDetailControllerProvider(dal.id).notifier);
      await container.read(foodDetailControllerProvider(dal.id).future);

      notifier.selectMeal(MealType.lunch);
      final state = container.read(foodDetailControllerProvider(dal.id)).value!;
      expect(state.mealType, MealType.lunch);
    });

    test('log() writes through and lands the item in the daily log (L7)',
        () async {
      final dal = await foodByName('Moong Dal Tadka');
      final notifier =
          container.read(foodDetailControllerProvider(dal.id).notifier);
      await container.read(foodDetailControllerProvider(dal.id).future);

      notifier.selectMeal(MealType.lunch);
      final item = await notifier.log();

      expect(item, isNotNull);
      expect(item!.mealType, MealType.lunch);
      expect(item.calculatedKcal, closeTo(105, 0.001));

      final day = LoggedMealItem.normalizeDay(DateTime.now());
      final log = await repo.watchDailyLog(day).first;
      expect(log, hasLength(1));
      expect(log.single.item.id, item.id);
      expect(log.single.food.name, 'Moong Dal Tadka');
    });
  });

  group('FoodDetailScreen widget (WU-4.4)', () {
    Future<GoRouter> pumpDetail(WidgetTester tester, String path) async {
      final router = GoRouter(
        initialLocation: '/back',
        routes: [
          GoRoute(
            path: '/back',
            builder: (_, _) => const Scaffold(body: Text('BACK HOME')),
          ),
          GoRoute(
            path: '/foods/:id',
            builder: (context, state) => FoodDetailScreen(
              foodId: state.pathParameters['id']!,
              mealHint: state.uri.queryParameters['meal'],
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [nutritionRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp.router(
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppTheme.oledBlack,
            ),
            routerConfig: router,
          ),
        ),
      );
      router.push(path);
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('Renders nutrition panel, serving selector, and meal chips',
        (tester) async {
      final dal = await foodByName('Moong Dal Tadka');
      await pumpDetail(tester, '/foods/${dal.id}');

      expect(find.text('Moong Dal Tadka'), findsOneWidget);
      // Default: 1 katori → 105 kcal / 150 g, meal defaults to snacks.
      expect(find.text('105'), findsOneWidget);
      expect(find.text('≈ 150 g'), findsOneWidget);
      expect(find.text('PROTEIN'), findsOneWidget);
      expect(find.text('CARBS'), findsOneWidget);
      expect(find.text('FAT'), findsOneWidget);
      expect(find.text('FIBER'), findsOneWidget);
      expect(find.text('LOG TO SNACKS'), findsOneWidget);
    });

    testWidgets('Unknown fiber renders the "—" placeholder (L6)',
        (tester) async {
      final custom = await repo.createCustomFood(
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
      await pumpDetail(tester, '/foods/${custom.id}');

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('Quantity and meal chips update the panel instantly',
        (tester) async {
      final dal = await foodByName('Moong Dal Tadka');
      await pumpDetail(tester, '/foods/${dal.id}');

      await tester.tap(find.text('1.5'));
      await tester.pumpAndSettle();

      expect(find.text('157.5'), findsOneWidget);
      expect(find.text('≈ 225 g'), findsOneWidget);

      // The meal selector sits below the fold in the test viewport.
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('LUNCH'));
      await tester.pumpAndSettle();

      expect(find.text('LOG TO LUNCH'), findsOneWidget);
    });

    testWidgets('Custom quantity dialog applies the entered amount',
        (tester) async {
      final dal = await foodByName('Moong Dal Tadka');
      await pumpDetail(tester, '/foods/${dal.id}');

      await tester.tap(find.text('CUSTOM'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.text('APPLY'));
      await tester.pumpAndSettle();

      // 3 katori = 450 g → 3 × 105 kcal.
      expect(find.text('315'), findsOneWidget);
      expect(find.text('≈ 450 g'), findsOneWidget);
    });

    testWidgets('mealHint query param preselects the meal bucket',
        (tester) async {
      final dal = await foodByName('Moong Dal Tadka');
      await pumpDetail(tester, '/foods/${dal.id}?meal=breakfast');

      expect(find.text('LOG TO BREAKFAST'), findsOneWidget);
    });

    testWidgets('Log to Lunch writes through and pops back to the meal view',
        (tester) async {
      final dal = await foodByName('Moong Dal Tadka');
      await pumpDetail(tester, '/foods/${dal.id}');

      // The meal selector sits below the fold in the test viewport.
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('LUNCH'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('LOG TO LUNCH'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Popped back to the meal view.
      expect(find.text('BACK HOME'), findsOneWidget);

      // The item landed in today's lunch via SQLite write-through. (A
      // one-shot read — drift *streams* never emit their first value
      // inside the fake-async testWidgets zone.)
      final rows = await db.select(db.loggedMealItems).get();
      expect(rows, hasLength(1));
      expect(MealType.fromName(rows.single.mealType), MealType.lunch);
      expect(rows.single.calculatedKcal, closeTo(105, 0.001));
    });
  });
}
