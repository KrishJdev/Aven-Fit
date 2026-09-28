/// Domain models for the CSV import engine (FEATURES.md §12.4).
///
/// These are intermediate/transient models parsed from Hevy or Strong CSV
/// exports — they never persist directly. The [ImportRepository] (chunk 2)
/// translates them into Drift companions inside a single transaction.
///
/// Plain Dart classes (not Freezed) — mirrors the sync DTO pattern
/// (`features/sync/domain/sync_models.dart`): intermediate data carriers
/// that don't need immutability codegen or JSON serialization.
library;

/// The source app whose CSV export format we're parsing.
enum ImportSource {
  strong,
  hevy;

  /// Tolerant parse from a header-row value — never throws.
  static ImportSource? fromHeader(String header) {
    final h = header.trim().toLowerCase();
    if (h.contains('weight unit') || h.contains('duration unit')) {
      return ImportSource.strong;
    }
    if (h.contains('weight (kg)') || h.contains('set type')) {
      return ImportSource.hevy;
    }
    return null;
  }
}

/// One parsed set row from the CSV — the unit of import.
class ParsedSet {
  const ParsedSet({
    required this.setOrder,
    required this.weightKg,
    required this.reps,
    this.isWarmup = false,
    this.rpe,
    this.notes,
    this.distanceKm,
    this.durationSeconds,
  });

  /// 1-based position within the exercise block.
  final int setOrder;

  /// Weight in kilograms (converted from lb if the source used imperial).
  final double weightKg;

  final int reps;

  /// Whether the source flagged this as a warm-up set (§8.1 `is_warmup`).
  final bool isWarmup;

  final double? rpe;
  final String? notes;
  final double? distanceKm;
  final int? durationSeconds;
}

/// One exercise block within a parsed workout — all sets for that exercise
/// in that session, in set-order.
class ParsedExercise {
  const ParsedExercise({
    required this.name,
    required this.sets,
    this.notes,
  });

  /// The exercise name exactly as it appears in the CSV (pre-matching).
  final String name;
  final List<ParsedSet> sets;
  final String? notes;
}

/// One parsed workout session from the CSV.
class ParsedWorkout {
  const ParsedWorkout({
    required this.date,
    required this.name,
    required this.exercises,
    this.durationSeconds,
    this.notes,
  });

  /// Session start timestamp (parsed from the CSV date column).
  final DateTime date;

  /// The workout name from the CSV (e.g. "Push Day", "Leg Day").
  final String name;

  /// Exercises in the order they appeared in the CSV.
  final List<ParsedExercise> exercises;

  final int? durationSeconds;
  final String? notes;

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);
}

/// The result of fuzzy-matching a parsed exercise name against the local
/// catalog — drives the mapping review UI (§12.4).
enum MatchConfidence {
  /// Exact or near-exact name match → auto-mapped silently.
  high,

  /// Token overlap above threshold → suggested, batch-reviewed.
  medium,

  /// No reasonable match → offer as custom-exercise creation (L7: never
  /// silently dropped).
  low,
}

/// A single exercise-name match result.
class ExerciseMatchResult {
  const ExerciseMatchResult({
    required this.originalName,
    required this.confidence,
    this.exerciseId,
    this.matchedName,
    this.score,
  });

  /// The name from the CSV.
  final String originalName;

  final MatchConfidence confidence;

  /// The local catalog exercise ID, null when unmatched (low confidence).
  final String? exerciseId;

  /// The local catalog exercise name, null when unmatched.
  final String? matchedName;

  /// 0.0–1.0 similarity score (null for exact matches — score is
  /// irrelevant when confidence is high via exact match).
  final double? score;

  bool get isMatched => confidence != MatchConfidence.low;
}

/// Summary of a parsed CSV file — the input to the mapping review UI.
class ParsedCsvSummary {
  const ParsedCsvSummary({
    required this.source,
    required this.workouts,
  });

  final ImportSource source;
  final List<ParsedWorkout> workouts;

  int get totalExercises =>
      workouts.fold(0, (sum, w) => sum + w.exercises.length);
  int get totalSets => workouts.fold(0, (sum, w) => sum + w.totalSets);
}
