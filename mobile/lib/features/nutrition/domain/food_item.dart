import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_item.freezed.dart';
part 'food_item.g.dart';

/// The computed macro payload for a logged quantity of a [FoodItem].
///
/// Grams are resolved first (household unit → grams), then every macro is
/// scaled linearly from the per-serving values (FEATURES.md §11.2/§11.3).
class FoodItemMacros {
  const FoodItemMacros({
    required this.grams,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG,
  });

  /// Total grams the logged quantity resolves to.
  final double grams;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  /// Nullable like the source column — unknown fiber stays unknown.
  final double? fiberG;
}

/// Pure immutable domain entity for one food entry (WU-4.1, FEATURES.md
/// §11.2).
///
/// Macro values are **per standard serving** (`servingSizeG` grams) —
/// matching the backend seed shape (40 g roti = 104 kcal). Household
/// servings ("1 katori", "2 roti") are first-class data (L10): the
/// household unit resolves to grams via [householdUnitGramsRatio], falling
/// back to the standard serving size when the per-entry ratio is absent.
@freezed
abstract class FoodItem with _$FoodItem {
  const factory FoodItem({
    required String id,
    required String name,
    String? brand,
    required double servingSizeG,
    required String householdServingUnit,
    double? householdUnitGramsRatio,
    required double caloriesKcal,
    @Default(0) double proteinG,
    @Default(0) double carbsG,
    @Default(0) double fatG,
    double? fiberG,
    @Default(false) bool isVeg,
    @Default(false) bool isSatvik,
    String? foodCategory,
    @Default(false) bool isCustom,
    String? barcode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FoodItem;

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);

  const FoodItem._();

  /// Grams in one household unit of this food.
  double get gramsPerHouseholdUnit =>
      householdUnitGramsRatio ?? servingSizeG;

  /// Scales the per-serving macros to the logged [quantityServings] of
  /// [servingUnit]:
  /// - `'g'` units take the quantity as grams directly,
  /// - the food's own household unit multiplies by [gramsPerHouseholdUnit],
  /// - any other unit is treated as standard servings.
  ///
  /// Zero/negative serving sizes can never divide — the result is zeroed
  /// so a malformed entry can never produce NaN in the daily totals (L6).
  FoodItemMacros scaleFor({
    required double quantityServings,
    required String servingUnit,
  }) {
    final unit = servingUnit.trim().toLowerCase();
    final double grams;
    if (unit == 'g' || unit == 'gram' || unit == 'grams') {
      grams = quantityServings;
    } else if (unit == householdServingUnit.trim().toLowerCase()) {
      grams = quantityServings * gramsPerHouseholdUnit;
    } else {
      grams = quantityServings * servingSizeG;
    }
    return FoodItemMacros(
      grams: grams,
      kcal: _scaled(caloriesKcal, grams),
      proteinG: _scaled(proteinG, grams),
      carbsG: _scaled(carbsG, grams),
      fatG: _scaled(fatG, grams),
      fiberG: fiberG == null ? null : _scaled(fiberG!, grams),
    );
  }

  double _scaled(double perServing, double grams) =>
      servingSizeG <= 0 ? 0 : perServing * grams / servingSizeG;
}
