import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/nutrition_repository.dart';
import 'food_search_state.dart';

part 'food_search_controller.g.dart';

/// Debounce window for free-text search — keystroke storms never re-query
/// SQLite; the final query runs once (FEATURES.md §11.3, <300ms target).
const Duration kFoodSearchDebounce = Duration(milliseconds: 300);

/// Riverpod AsyncNotifier managing the state and search filters of the
/// Food Database Search screen (WU-4.4).
///
/// Implements Law L1 (<300ms search latency), Law L2 (100% offline catalog,
/// seeded on first build), and Law L6 (every filter combination leaves a
/// designed state).
@riverpod
class FoodSearchController extends _$FoodSearchController {
  Timer? _debounce;

  @override
  FutureOr<FoodSearchState> build() async {
    ref.onDispose(() => _debounce?.cancel());

    final repository = ref.watch(nutritionRepositoryProvider);

    // Ensure the bundled catalog is loaded on first launch (WU-4.2 wiring —
    // mirrors ExerciseListController's seed path).
    await repository.seedInitialData();
    // The seed read can outlive the screen (autoDispose) — never touch ref
    // on a disposed provider.
    if (!ref.mounted) return const FoodSearchState();

    final foods = await repository.searchFoods();
    if (!ref.mounted) return const FoodSearchState();
    return FoodSearchState(foods: foods);
  }

  /// Updates the search query. The query reflects immediately; the result
  /// list refreshes after the [kFoodSearchDebounce] debounce. An empty
  /// query restores the full catalog without waiting.
  void setSearchQuery(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: query));

    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _refreshFoods();
      return;
    }
    _debounce = Timer(kFoodSearchDebounce, _refreshFoods);
  }

  /// Toggles the FSSAI veg-only filter (§11.3, L10).
  Future<void> toggleVegOnly() => _toggle('vegOnly');

  /// Toggles the satvik-only filter (§11.10 vrat set).
  Future<void> toggleSatvikOnly() => _toggle('satvikOnly');

  /// Clears all active filters and restores the full catalog.
  Future<void> clearFilters() async {
    final currentState = state.value;
    if (currentState == null) return;

    _debounce?.cancel();
    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: '',
        vegOnly: false,
        satvikOnly: false,
      ),
    );
    await _refreshFoods();
  }

  Future<void> _toggle(String which) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        vegOnly: which == 'vegOnly' ? !currentState.vegOnly : currentState.vegOnly,
        satvikOnly:
            which == 'satvikOnly' ? !currentState.satvikOnly : currentState.satvikOnly,
      ),
    );
    await _refreshFoods();
  }

  Future<void> _refreshFoods() async {
    final currentState = state.value;
    if (currentState == null) return;

    final repository = ref.read(nutritionRepositoryProvider);
    final results = await repository.searchFoods(
      query: currentState.searchQuery,
      vegOnly: currentState.vegOnly,
      satvikOnly: currentState.satvikOnly,
    );
    // The query can outlive the screen (debounce, autoDispose) — the
    // result is dropped, never written to a disposed notifier.
    if (!ref.mounted) return;

    // Guard against a newer edit while the query ran.
    final latest = state.value;
    if (latest == null) return;
    state = AsyncValue.data(latest.copyWith(foods: results));
  }
}
