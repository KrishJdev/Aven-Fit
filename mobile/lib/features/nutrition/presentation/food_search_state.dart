import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/food_item.dart';

part 'food_search_state.freezed.dart';

/// Pure immutable state representing the Food Database Search screen
/// (WU-4.4, FEATURES.md §11.3).
@freezed
abstract class FoodSearchState with _$FoodSearchState {
  const factory FoodSearchState({
    @Default('') String searchQuery,
    @Default(false) bool vegOnly,
    @Default(false) bool satvikOnly,
    @Default(<FoodItem>[]) List<FoodItem> foods,
  }) = _FoodSearchState;

  const FoodSearchState._();

  /// Whether any filter is currently active.
  bool get hasActiveFilters => searchQuery.isNotEmpty || vegOnly || satvikOnly;
}
