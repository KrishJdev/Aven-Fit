import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../exercise/data/exercise_repository.dart';
import '../data/file_picker_service.dart';
import '../data/import_repository.dart';
import '../domain/csv_parser.dart';
import '../domain/exercise_matcher.dart';
import '../domain/import_models.dart';
import 'import_state.dart';

part 'import_controller.g.dart';

/// Riverpod controller managing the CSV Import lifecycle (FEATURES.md §12.4).
@riverpod
class ImportController extends _$ImportController {
  @override
  ImportState build() {
    return const ImportState();
  }

  /// Triggers system file picker to select a CSV file, parses it, and computes exercise matches.
  Future<void> pickAndParseFile() async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final picked = await picker.pickCsvFile();
      if (picked == null) {
        // User cancelled picker
        return;
      }
      await parseCsvContent(picked.content, fileName: picked.name);
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Parses CSV text and computes exercise matches against the local exercise catalog.
  Future<void> parseCsvContent(String content, {String? fileName}) async {
    state = state.copyWith(
      status: ImportStatus.parsing,
      fileName: fileName,
      errorMessage: null,
    );

    try {
      final parseResult = const CsvParser().parse(content);
      if (parseResult.summary.workouts.isEmpty) {
        state = state.copyWith(
          status: ImportStatus.error,
          errorMessage: 'No workouts found in the CSV file.',
        );
        return;
      }

      // Fetch exercise catalog to run fuzzy matching
      final exerciseRepo = ref.read(exerciseRepositoryProvider);
      final catalog = await exerciseRepo.searchExercises();
      final matcher = ExerciseMatcher(catalog);

      final uniqueNames = parseResult.summary.workouts
          .expand((w) => w.exercises.map((e) => e.name))
          .toSet();

      final matchResults = matcher.matchAll(uniqueNames);

      state = state.copyWith(
        status: ImportStatus.preview,
        summary: parseResult.summary,
        matchResults: matchResults,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Updates the match resolution for a specific CSV exercise name during preview review.
  void updateExerciseMatch(String csvName, ExerciseMatchResult newMatch) {
    if (state.status != ImportStatus.preview) return;
    final updated = Map<String, ExerciseMatchResult>.from(state.matchResults);
    updated[csvName] = newMatch;
    state = state.copyWith(matchResults: updated);
  }

  /// Commits the parsed workouts into SQLite via [ImportRepository].
  Future<void> startImport() async {
    if (state.summary == null || state.status != ImportStatus.preview) {
      return;
    }

    state = state.copyWith(status: ImportStatus.importing, errorMessage: null);

    try {
      final repo = ref.read(importRepositoryProvider);
      final result = await repo.importWorkouts(
        summary: state.summary!,
        matchResults: state.matchResults,
      );

      state = state.copyWith(
        status: ImportStatus.success,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: 'Import failed: $e',
      );
    }
  }

  /// Resets state back to idle.
  void reset() {
    state = const ImportState();
  }
}
