import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/import_repository.dart';
import '../domain/import_models.dart';

part 'import_state.freezed.dart';

enum ImportStatus {
  idle,
  parsing,
  preview,
  importing,
  success,
  error,
}

/// Pure immutable state representing the CSV Import flow (FEATURES.md §12.4, J4 journey).
@freezed
abstract class ImportState with _$ImportState {
  const factory ImportState({
    @Default(ImportStatus.idle) ImportStatus status,
    String? fileName,
    ParsedCsvSummary? summary,
    @Default(<String, ExerciseMatchResult>{})
    Map<String, ExerciseMatchResult> matchResults,
    ImportResult? result,
    String? errorMessage,
  }) = _ImportState;

  const ImportState._();

  List<ExerciseMatchResult> get highConfidenceMatches => matchResults.values
      .where((m) => m.confidence == MatchConfidence.high)
      .toList();

  List<ExerciseMatchResult> get mediumConfidenceMatches => matchResults.values
      .where((m) => m.confidence == MatchConfidence.medium)
      .toList();

  List<ExerciseMatchResult> get lowConfidenceMatches => matchResults.values
      .where((m) => m.confidence == MatchConfidence.low)
      .toList();

  DateTime? get earliestDate {
    if (summary == null || summary!.workouts.isEmpty) return null;
    return summary!.workouts
        .map((w) => w.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? get latestDate {
    if (summary == null || summary!.workouts.isEmpty) return null;
    return summary!.workouts
        .map((w) => w.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
}
