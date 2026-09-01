import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/nutrition/data/nutrition_repository.dart';
import 'package:aven_fit/features/nutrition/domain/food_item.dart';
import 'package:aven_fit/features/nutrition/domain/logged_meal_item.dart';
import 'package:aven_fit/features/nutrition/domain/meal_type.dart';
import 'package:aven_fit/features/nutrition/presentation/nutrition_dashboard_controller.dart';
import 'package:aven_fit/features/nutrition/presentation/nutrition_dashboard_state.dart';
import 'package:aven_fit/features/nutrition/presentation/nutrition_screen.dart';
import 'package:aven_fit/features/nutrition/presentation/widgets/macro_progress_bar.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late NutritionRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = NutritionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<FoodItem> seedDal() => repo.createCustomFood(
        name: 'Dashboard Dal',
        servingSizeG: 150,
        householdServingUnit: 'katori',
        householdUnitGramsRatio: 150,
        caloriesKcal: 105,
        proteinG: 6,
        carbsG: 18,
        fatG: 2,
        isVeg: true,
      );

  Future<FoodItem> seedRice() => repo.createCustomFood(
        name: 'Dashboard Rice',
        servingSizeG: 200,
        householdServingUnit: 'bowl',
        householdUnitGramsRatio: 200,
        caloriesKcal: 260,
        proteinG: 5,
        carbsG: 55,
        fatG: 1,
        isVeg: true,
      );

  group('NutritionDashboardController (WU-4.5)', () {
    late ProviderContainer container;
    // Keep-alive: without a listener the autoDispose controller is
    // disposed between reads.
    late ProviderSubscription<dynamic> sub;

    setUp(() {
      container = ProviderContainer(
        overrides: [nutritionRepositoryProvider.overrideWithValue(repo)],
      );
      sub = container.listen(nutritionDashboardControllerProvider, (_, _) {});
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    /// Polls until the reactive streams have emitted a matching state
    /// (drift re-emits asynchronously after each write).
    Future<NutritionDashboardState> waitForState(
      bool Function(NutritionDashboardState) predicate,
    ) async {
      for (var i = 0; i < 200; i++) {
        final state = container.read(nutritionDashboardControllerProvider);
        if (predicate(state)) return state;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      fail('dashboard state never reached the expected condition');
    }

    test('streams the daily log and totals across meals (§11.1)', () async {
      final dal = await seedDal();
      final rice = await seedRice();
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.lunch, quantityServings: 1.5);
      await repo.logMealItem(
          foodItemId: rice.id, mealType: MealType.snack, quantityServings: 1);

      // Wait for a consistent snapshot — entries and totals streams emit
      // independently, so an intermediate rebuild can pair new entries
      // with stale totals.
      final state = await waitForState(
        (s) => s.entries.length == 3 && (s.totals?.kcal ?? 0) > 520,
      );

      // Totals == sum of the denormalized snapshots: 105 + 157.5 + 260.
      expect(state.totals!.kcal, closeTo(522.5, 0.001));
      expect(state.totals!.proteinG, closeTo(6 + 9 + 5, 0.001));
      expect(state.consumedKcal, closeTo(522.5, 0.001));

      // Meal bucketing in §11.1 section order.
      expect(state.mealEntries[MealType.breakfast], hasLength(1));
      expect(state.mealEntries[MealType.lunch], hasLength(1));
      expect(state.mealEntries[MealType.dinner], isEmpty);
      expect(state.mealEntries[MealType.snack], hasLength(1));
      expect(state.mealKcal(MealType.breakfast), closeTo(105, 0.001));
      expect(state.mealKcal(MealType.lunch), closeTo(157.5, 0.001));
      expect(state.mealKcal(MealType.snack), closeTo(260, 0.001));
    });

    test('L4: no goals is a meaningful absence; setting goals flips the card',
        () async {
      final dal = await seedDal();
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.lunch, quantityServings: 2);
      await waitForState((s) => s.entries.length == 1);

      // No goals row → the calories-remaining card is hidden entirely.
      var state = container.read(nutritionDashboardControllerProvider);
      expect(state.hasCalorieGoal, isFalse);
      expect(state.caloriesRemaining, 0);

      await repo.setNutritionGoals(
        targetCalories: 2000,
        targetProteinG: 100,
        targetCarbsG: 250,
        targetFatG: 60,
      );
      state = await waitForState(
        (s) => s.hasCalorieGoal && (s.totals?.kcal ?? 0) > 200,
      );

      expect(state.goals!.targetCalories, 2000);
      expect(state.caloriesRemaining, closeTo(2000 - 210, 0.001));
    });

    test('over-target day keeps the remaining math neutral (L4)', () async {
      final dal = await seedDal();
      await repo.setNutritionGoals(targetCalories: 100);
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.lunch, quantityServings: 1);

      final state = await waitForState(
        (s) => s.hasCalorieGoal && (s.totals?.kcal ?? 0) > 100,
      );
      // 105 kcal consumed vs a 100 kcal target → −5, a plain fact (the UI
      // renders it grey, never red).
      expect(state.caloriesRemaining, closeTo(-5, 0.001));
    });

    test('day navigation re-subscribes to the selected day (§11.1)',
        () async {
      final dal = await seedDal();
      final today = LoggedMealItem.normalizeDay(DateTime.now());
      final yesterday = LoggedMealItem.normalizeDay(
        today.subtract(const Duration(days: 1)),
      );
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await repo.logMealItem(
        foodItemId: dal.id,
        mealType: MealType.breakfast,
        quantityServings: 1,
        date: yesterday,
      );

      final dayController = container.read(selectedNutritionDayProvider.notifier);
      var state = await waitForState(
        (s) => s.day == today && s.entries.length == 1,
      );
      expect(state.day, today);

      dayController.previousDay();
      state = await waitForState(
        (s) => s.day == yesterday && s.entries.length == 1,
      );
      // The yesterday view shows only yesterday's item.
      expect(state.entries.single.item.date, yesterday);

      dayController.nextDay();
      state = await waitForState(
        (s) => s.day == today && s.entries.length == 1,
      );
      expect(state.mealKcal(MealType.breakfast), closeTo(105, 0.001));
    });

    test('inline stepper recomputes <100ms and totals self-heal (§11.2)',
        () async {
      final dal = await seedDal();
      final item = await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.lunch, quantityServings: 1);
      await waitForState((s) => s.entries.length == 1);

      final controller =
          container.read(nutritionDashboardControllerProvider.notifier);
      final stopwatch = Stopwatch()..start();
      await controller.updateItemQuantity(item.id, 2.0);
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      final state = await waitForState(
        (s) => (s.totals?.kcal ?? 0) > 200,
      );
      expect(state.entries.single.item.quantityServings, 2.0);
      expect(state.totals!.kcal, closeTo(210, 0.001));
      expect(state.mealKcal(MealType.lunch), closeTo(210, 0.001));
    });

    test('removeItem deletes the row and totals self-heal (L7)', () async {
      final dal = await seedDal();
      final rice = await seedRice();
      final dalItem = await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await repo.logMealItem(
          foodItemId: rice.id, mealType: MealType.lunch, quantityServings: 1);
      await waitForState((s) => s.entries.length == 2);

      final controller =
          container.read(nutritionDashboardControllerProvider.notifier);
      await controller.removeItem(dalItem.id);

      final state = await waitForState(
        (s) => s.entries.length == 1 && (s.totals?.kcal ?? 0) < 300,
      );
      expect(state.entries.single.food.name, 'Dashboard Rice');
      expect(state.totals!.kcal, closeTo(260, 0.001));
    });
  });

  group('NutritionScreen widget (WU-4.5)', () {
    late ProviderContainer container;

    Future<void> pumpDashboard(WidgetTester tester) async {
      // UncontrolledProviderScope pattern for drift-stream-backed screens.
      container = ProviderContainer(
        overrides: [nutritionRepositoryProvider.overrideWithValue(repo)],
      );
      final router = GoRouter(
        initialLocation: '/nutrition',
        routes: [
          GoRoute(
            path: '/nutrition',
            builder: (_, _) => const NutritionScreen(),
          ),
          GoRoute(
            path: '/foods',
            builder: (context, state) => Scaffold(
              body: Text(
                'FOODS STUB meal=${state.uri.queryParameters['meal'] ?? 'none'}',
                key: const ValueKey('foods_stub'),
              ),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: ThemeData.dark()
                .copyWith(scaffoldBackgroundColor: AppTheme.oledBlack),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drain before tearDown closes the DB (probed empirically): unmount
      // the tree so autoDispose providers cancel their drift stream
      // subscriptions, dispose the container, and pump so drift's
      // stream-close cleanup timers fire. Without this, `db.close()` in
      // tearDown awaits a cleanup timer that can never fire after the
      // fake-async body ends and hangs the whole suite.
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pump(const Duration(milliseconds: 100));
      });
    }

    /// Real-time wait for a stream re-emission after an in-test mutation,
    /// then a settle pass so the fake-async zone renders the new state.
    Future<void> pumpUntil(
      WidgetTester tester,
      bool Function() done,
    ) async {
      await tester.runAsync(() async {
        for (var i = 0; i < 100; i++) {
          if (done()) return;
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      });
      await tester.pumpAndSettle();
    }

    bool dashboardShows(bool Function(NutritionDashboardState) predicate) {
      final state = container.read(nutritionDashboardControllerProvider);
      return predicate(state);
    }

    testWidgets('renders the four meal sections, items, and totals',
        (tester) async {
      final dal = await seedDal();
      final rice = await seedRice();
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await repo.logMealItem(
          foodItemId: rice.id, mealType: MealType.lunch, quantityServings: 1);
      await pumpDashboard(tester);

      expect(find.text('NUTRITION'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('BREAKFAST'), findsOneWidget);
      expect(find.text('LUNCH'), findsOneWidget);
      expect(find.text('DINNER'), findsOneWidget);
      expect(find.text('SNACKS'), findsOneWidget);

      // Logged items with their household serving line.
      expect(find.text('Dashboard Dal'), findsOneWidget);
      expect(find.text('1 katori · 150 g · 6 g protein'), findsOneWidget);
      expect(find.text('105 kcal'), findsOneWidget);
      expect(find.text('260 kcal'), findsOneWidget);

      // Daily totals summary sits below the fold.
      await tester.scrollUntilVisible(
        find.text('DAILY TOTALS'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('365'), findsOneWidget);
    });

    testWidgets('hides the calories-remaining card without goals (L4)',
        (tester) async {
      final dal = await seedDal();
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await pumpDashboard(tester);

      expect(find.byKey(const ValueKey('calories_remaining_card')),
          findsNothing);
      expect(find.text('CALORIES REMAINING'), findsNothing);
      expect(find.text('CALORIES OVER TARGET'), findsNothing);
    });

    testWidgets('shows the calories card with goals; protein is first-class',
        (tester) async {
      final dal = await seedDal();
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 2);
      await repo.setNutritionGoals(
        targetCalories: 2000,
        targetProteinG: 100,
        targetCarbsG: 250,
        targetFatG: 60,
      );
      await pumpDashboard(tester);

      expect(find.byKey(const ValueKey('calories_remaining_card')),
          findsOneWidget);
      expect(find.text('CALORIES REMAINING'), findsOneWidget);
      expect(find.text('1790'), findsOneWidget); // 2000 − 210.
      expect(find.text('210 of 2000'), findsOneWidget);

      // Protein renders first-class: emphasized bar with its target.
      final proteinBar = find.byWidgetPredicate(
        (w) => w is MacroProgressBar && w.label == 'PROTEIN',
      );
      expect(proteinBar, findsOneWidget);
      final protein = tester.widget<MacroProgressBar>(proteinBar);
      expect(protein.emphasized, isTrue);
      expect(protein.target, 100);
      expect(protein.consumed, closeTo(12, 0.001));
      expect(find.text('12 / 100 g'), findsOneWidget);

      // Carbs and fat bars carry their own targets.
      final carbs = tester.widget<MacroProgressBar>(find.byWidgetPredicate(
        (w) => w is MacroProgressBar && w.label == 'CARBS',
      ));
      expect(carbs.target, 250);
      expect(carbs.emphasized, isFalse);
    });

    testWidgets('over-target day renders the neutral fact — never red (L4)',
        (tester) async {
      final dal = await seedDal();
      await repo.setNutritionGoals(targetCalories: 100);
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await pumpDashboard(tester);

      expect(find.text('CALORIES OVER TARGET'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // |100 − 105|, grey not red.

      // Zero macro targets render no bar visual — a percentage of nothing
      // would be a fake verdict (L4/L6). The row itself still shows grams.
      final barVisual = find.descendant(
        of: find.byType(MacroProgressBar),
        matching: find.byType(FractionallySizedBox),
      );
      expect(barVisual, findsNothing);
    });

    testWidgets('day navigation switches the label and the data (§11.1)',
        (tester) async {
      final dal = await seedDal();
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await pumpDashboard(tester);

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('Dashboard Dal'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('day_prev')));
      await pumpUntil(
        tester,
        () => dashboardShows((s) => s.day == _yesterday()),
      );
      expect(find.text('YESTERDAY'), findsOneWidget);
      // Today's item is not in yesterday's view; sections are designed-empty.
      expect(find.text('Dashboard Dal'), findsNothing);
      expect(find.text('Nothing logged yet.'), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('day_next')));
      await pumpUntil(
        tester,
        () => dashboardShows((s) => s.day == _today() && s.entries.isNotEmpty),
      );
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('Dashboard Dal'), findsOneWidget);
    });

    testWidgets('stepper recomputes macros and writes through (§11.2/L7)',
        (tester) async {
      final dal = await seedDal();
      await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await pumpDashboard(tester);

      final itemId = container
          .read(nutritionDashboardControllerProvider)
          .entries
          .single
          .item
          .id;

      await tester.tap(find.byKey(ValueKey('step_up_$itemId')));
      await pumpUntil(
        tester,
        () => dashboardShows((s) => (s.totals?.kcal ?? 0) > 150),
      );

      expect(find.text('1.5'), findsOneWidget);
      expect(find.text('1.5 katori · 225 g · 9 g protein'), findsOneWidget);
      expect(find.text('157.5 kcal'), findsOneWidget);

      // Write-through: the persisted row carries the recomputed snapshot.
      final rows = await db.select(db.loggedMealItems).get();
      expect(rows.single.quantityServings, 1.5);
      expect(rows.single.calculatedKcal, closeTo(157.5, 0.001));
    });

    testWidgets('remove requires confirmation, then deletes (§11.2/L7)',
        (tester) async {
      final dal = await seedDal();
      final item = await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await pumpDashboard(tester);

      await tester.tap(find.byKey(ValueKey('remove_item_${item.id}')));
      await tester.pumpAndSettle();

      // Confirmation first — data never silently vanishes.
      expect(find.text('Remove item?'), findsOneWidget);
      expect(find.text('Remove "Dashboard Dal" from this meal?'),
          findsOneWidget);

      await tester.tap(find.text('REMOVE'));
      await pumpUntil(
        tester,
        () => dashboardShows((s) => s.entries.isEmpty),
      );

      expect(find.text('Dashboard Dal'), findsNothing);
      expect(find.text('Nothing logged yet.'), findsWidgets);
      final rows = await db.select(db.loggedMealItems).get();
      expect(rows, isEmpty);
    });

    testWidgets('cancel keeps the item when the remove dialog is dismissed',
        (tester) async {
      final dal = await seedDal();
      final item = await repo.logMealItem(
          foodItemId: dal.id, mealType: MealType.breakfast, quantityServings: 1);
      await pumpDashboard(tester);

      await tester.tap(find.byKey(ValueKey('remove_item_${item.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Dal'), findsOneWidget);
      final rows = await db.select(db.loggedMealItems).get();
      expect(rows, hasLength(1));
    });

    testWidgets('Add Food opens the food search with the meal hint',
        (tester) async {
      await pumpDashboard(tester);

      await tester.tap(find.byKey(const ValueKey('add_food_lunch')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('foods_stub')), findsOneWidget);
      expect(find.textContaining('meal=lunch'), findsOneWidget);
    });
  });
}

DateTime _today() => LoggedMealItem.normalizeDay(DateTime.now());

DateTime _yesterday() =>
    LoggedMealItem.normalizeDay(DateTime.now().subtract(const Duration(days: 1)));
