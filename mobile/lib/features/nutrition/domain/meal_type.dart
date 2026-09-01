/// The meal buckets a logged item can belong to (WU-4.1, FEATURES.md §11.1).
///
/// P0 uses the four main meals; the pre/post-workout buckets exist in the
/// schema ahead of the `[P1][PROPOSED]` surface so adding them never needs
/// a migration. Stored as a string in both SQLite and JSON.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,

  /// `[P1][PROPOSED]` — schema-ready, surfaced later.
  preWorkout,

  /// `[P1][PROPOSED]` — schema-ready, surfaced later.
  postWorkout;

  /// Section label used across the dashboard UI.
  String get label => switch (this) {
        MealType.breakfast => 'BREAKFAST',
        MealType.lunch => 'LUNCH',
        MealType.dinner => 'DINNER',
        MealType.snack => 'SNACKS',
        MealType.preWorkout => 'PRE-WORKOUT',
        MealType.postWorkout => 'POST-WORKOUT',
      };

  /// Tolerant parse from the stored `meal_type` column or JSON — accepts
  /// any casing and separator style ('BREAKFAST', 'pre_workout',
  /// 'post-workout', 'Snack'). Unknown values fall back to
  /// [MealType.snack], the conventional catch-all bucket, so a malformed
  /// row can never crash a read (L6).
  static MealType fromName(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    for (final type in MealType.values) {
      if (type.name.toLowerCase() == normalized) return type;
    }
    return MealType.snack;
  }
}
