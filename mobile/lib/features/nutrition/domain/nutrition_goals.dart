import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_goals.freezed.dart';
part 'nutrition_goals.g.dart';

/// Pure immutable domain entity for the user's daily macro targets (WU-4.1,
/// FEATURES.md §11.1).
///
/// A single 'default' row per device. **No row = no goals** — the
/// calories-remaining card is hidden entirely in that state (Law L4:
/// never a nag), so absence is meaningful and must be preserved.
@freezed
abstract class NutritionGoals with _$NutritionGoals {
  const factory NutritionGoals({
    required String id,
    required double targetCalories,
    @Default(0) double targetProteinG,
    @Default(0) double targetCarbsG,
    @Default(0) double targetFatG,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _NutritionGoals;

  factory NutritionGoals.fromJson(Map<String, dynamic> json) =>
      _$NutritionGoalsFromJson(json);
}
