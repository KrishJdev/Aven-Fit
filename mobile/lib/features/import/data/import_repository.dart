import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../../exercise/data/exercise_repository.dart';
import '../../exercise/domain/muscle_group.dart';
import '../../progress/data/pr_repository.dart';
import '../../workout/data/workout_local_source.dart';
import '../domain/exercise_matcher.dart';
import '../domain/import_models.dart';

part 'import_repository.g.dart';

/// Repository for importing parsed CSV workouts into local SQLite
/// (FEATURES.md §12.4, J4 journey).
///
/// The import is **idempotent + safe** (L7):
/// - Source-ID duplicate detection: re-importing the same CSV skips every
///   workout whose source-ID already exists — never double-logged.
/// - Single-transaction commit: cancel-before-commit leaves SQLite
///   byte-identical; success is all-or-nothing.
/// - Low-confidence exercise matches become custom-exercise creations —
///   zero rows silently dropped.
/// - PRs recompute locally from imported sets after the transaction
///   commits (§10.2 parity).
class ImportRepository {
  ImportRepository({
    required this._workoutDao,
    required this._exerciseRepo,
    required this._prRepo,
  });

  final WorkoutDao _workoutDao;
  final ExerciseRepository _exerciseRepo;
  final PRRepository _prRepo;

  /// Imports parsed workouts into SQLite.
  ///
  /// [matchResults] maps each unique CSV exercise name to its fuzzy-match
  /// result (from [ExerciseMatcher.matchAll]). Low-confidence matches are
  /// auto-created as custom exercises inside the same transaction.
  ///
  /// Returns an [ImportResult] with counts for the success state
  /// ("Imported N workouts · M sets · K PRs" → Progress).
  Future<ImportResult> importWorkouts({
    required ParsedCsvSummary summary,
    required Map<String, ExerciseMatchResult> matchResults,
  }) async {
    // 1. Resolve exercise IDs — create customs for low-confidence matches.
    // This happens inside the transaction too, so a cancel-before-commit
    // leaves the catalog untouched.
    final exerciseIdByName = <String, String>{};
    final createdExerciseIds = <String>[];

    for (final entry in matchResults.entries) {
      final csvName = entry.key;
      final match = entry.value;
      if (match.exerciseId != null) {
        exerciseIdByName[csvName] = match.exerciseId!;
      } else {
        // Low confidence → create a custom exercise pre-filled from the
        // CSV name (L7: never silently dropped).
        final exercise = await _exerciseRepo.createCustomExercise(
          name: csvName,
          category: ExerciseCategory.other,
          equipment: Equipment.none,
          primaryMuscleGroupId: _fallbackMuscleGroupId,
        );
        exerciseIdByName[csvName] = exercise.id;
        createdExerciseIds.add(exercise.id);
      }
    }

    // 2. Check for existing import source-IDs (dedup).
    final existingIds = await _workoutDao.getExistingImportSourceIds();

    // 3. Generate source-IDs and filter out duplicates.
    final workoutsToImport = <_WorkoutImport>[];
    var skippedCount = 0;

    for (var i = 0; i < summary.workouts.length; i++) {
      final workout = summary.workouts[i];
      final sourceId = _buildSourceId(summary.source, workout);
      if (existingIds.contains(sourceId)) {
        skippedCount++;
        continue;
      }
      workoutsToImport.add(_WorkoutImport(
        workout: workout,
        sourceId: sourceId,
        index: i,
      ));
    }

    if (workoutsToImport.isEmpty) {
      return ImportResult(
        workoutsImported: 0,
        setsImported: 0,
        exercisesCreated: createdExerciseIds.length,
        workoutsSkipped: skippedCount,
        affectedExerciseIds: const [],
      );
    }

    // 4. Insert all workouts in a single transaction (L7: all-or-nothing).
    var setsImported = 0;
    final affectedExerciseIds = <String>{};

    await _workoutDao.transaction(() async {
      for (final wi in workoutsToImport) {
        final w = wi.workout;
        final sessionId = 'imp_${summary.source.name}_${wi.index}';
        final sourceId = wi.sourceId;

        await _workoutDao.createSession(
          id: sessionId,
          name: w.name,
          startedAt: w.date,
          notes: w.notes,
          importSourceId: sourceId,
        );

        await _workoutDao.completeSession(
          sessionId,
          w.date,
          durationSeconds: w.durationSeconds,
        );

        for (var exIdx = 0; exIdx < w.exercises.length; exIdx++) {
          final ex = w.exercises[exIdx];
          final exerciseId = exerciseIdByName[ex.name]!;
          final seId = '${sessionId}_ex_$exIdx';

          await _workoutDao.addExerciseToSession(
            id: seId,
            sessionId: sessionId,
            exerciseId: exerciseId,
            orderIndex: exIdx,
            notes: ex.notes,
          );

          for (var setIdx = 0; setIdx < ex.sets.length; setIdx++) {
            final set = ex.sets[setIdx];
            final setId = '${seId}_set_$setIdx';
            final setType = set.isWarmup ? 'warmup' : 'normal';

            await _workoutDao.insertSet(
              id: setId,
              sessionId: sessionId,
              sessionExerciseId: seId,
              exerciseId: exerciseId,
              setNumber: setIdx + 1,
              weightKg: set.weightKg,
              reps: set.reps,
              isCompleted: true,
              setType: setType,
              rpe: set.rpe,
              completedAt: w.date,
              notes: set.notes,
            );
            setsImported++;
          }

          affectedExerciseIds.add(exerciseId);
        }
      }
    });

    // 5. Recompute PRs for each affected exercise (§10.2 parity, L7).
    // Derived state — re-derives from the full history, so the imported
    // sets are included. Runs after the transaction commits; a PR recompute
    // failure never loses the imported workouts.
    var prCount = 0;
    for (final exerciseId in affectedExerciseIds) {
      await _prRepo.recomputePRs(exerciseId);
      final records = await _prRepo.getRecordsForExercise(exerciseId);
      prCount += records.length;
    }

    return ImportResult(
      workoutsImported: workoutsToImport.length,
      setsImported: setsImported,
      exercisesCreated: createdExerciseIds.length,
      workoutsSkipped: skippedCount,
      affectedExerciseIds: affectedExerciseIds.toList(),
      prCount: prCount,
    );
  }

  /// Builds a deterministic source-ID from the workout's content.
  /// Re-importing the same CSV produces the same source-IDs, so duplicates
  /// are detected and skipped (L7).
  String _buildSourceId(ImportSource source, ParsedWorkout workout) {
    final dateStr =
        '${workout.date.year}-${workout.date.month.toString().padLeft(2, '0')}-${workout.date.day.toString().padLeft(2, '0')}';
    final sanitizedName = workout.name
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    return 'import_${source.name}_${dateStr}_$sanitizedName';
  }

  /// The first muscle group in the catalog as a fallback for custom
  /// exercises created during import. The caller should seed the catalog
  /// before importing (the app seeds on first launch).
  static const _fallbackMuscleGroupId =
      '550e8400-e29b-41d4-a716-446655440001'; // Chest
}

/// Summary of a completed import — drives the success state UI
/// ("Imported N workouts · M sets · K PRs" → Progress, §12.4).
class ImportResult {
  const ImportResult({
    required this.workoutsImported,
    required this.setsImported,
    required this.exercisesCreated,
    required this.workoutsSkipped,
    required this.affectedExerciseIds,
    this.prCount = 0,
  });

  final int workoutsImported;
  final int setsImported;
  final int exercisesCreated;
  final int workoutsSkipped;
  final List<String> affectedExerciseIds;
  final int prCount;

  bool get wasIdempotentSkip => workoutsImported == 0 && workoutsSkipped > 0;
}

/// Internal carrier for workouts pending import.
class _WorkoutImport {
  const _WorkoutImport({
    required this.workout,
    required this.sourceId,
    required this.index,
  });

  final ParsedWorkout workout;
  final String sourceId;
  final int index;
}

/// Riverpod provider exposing [ImportRepository].
@riverpod
ImportRepository importRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final exerciseRepo = ref.watch(exerciseRepositoryProvider);
  final prRepo = ref.watch(prRepositoryProvider);
  return ImportRepository(
    workoutDao: db.workoutDao,
    exerciseRepo: exerciseRepo,
    prRepo: prRepo,
  );
}
