import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../exercise/data/exercise_tables.dart';
import '../../workout/data/workout_tables.dart';
import 'pr_tables.dart';

part 'pr_local_source.g.dart';

/// A completed, non-warmup working set eligible for PR replay, with the
/// effective timestamp used to order history chronologically.
class PRReplaySet {
  final WorkoutSetRow set;
  final DateTime effectiveAt;

  const PRReplaySet({required this.set, required this.effectiveAt});
}

/// DAO providing PR record storage and the working-set history replay input
/// for the PR detection engine (WU-3.6, FEATURES.md §10.2).
@DriftAccessor(tables: [
  PersonalRecords,
  Exercises,
  WorkoutSessions,
  SessionExercises,
  WorkoutSets,
])
class PrDao extends DatabaseAccessor<AppDatabase> with _$PrDaoMixin {
  PrDao(super.db);

  /// All stored PR rows for an exercise.
  Future<List<PersonalRecordRow>> getRecordsForExercise(String exerciseId) {
    return (select(personalRecords)
          ..where((t) => t.exerciseId.equals(exerciseId)))
        .get();
  }

  /// All stored PR rows across every exercise.
  Future<List<PersonalRecordRow>> getAllRecords() =>
      select(personalRecords).get();

  /// Finds the current best record for (exercise, record type).
  ///
  /// [weightKg] non-null matches the weight-keyed `maxRepsAtWeight` row for
  /// that weight; null matches the weight-less rows of the other types.
  Future<PersonalRecordRow?> findRecord({
    required String exerciseId,
    required String recordType,
    double? weightKg,
  }) {
    return (select(personalRecords)
          ..where((t) => t.exerciseId.equals(exerciseId))
          ..where((t) => t.recordType.equals(recordType))
          ..where((t) =>
              weightKg != null ? t.weightKg.equals(weightKg) : t.weightKg.isNull())
          ..limit(1))
        .getSingleOrNull();
  }

  /// Inserts a new PR row.
  Future<void> insertRecord({
    required String id,
    required String exerciseId,
    required String recordType,
    required double value,
    double? weightKg,
    required DateTime achievedAt,
    String? sessionId,
    String? setId,
  }) {
    final now = DateTime.now();
    return into(personalRecords).insert(
      PersonalRecordsCompanion.insert(
        id: id,
        exerciseId: exerciseId,
        recordType: recordType,
        value: value,
        weightKg: Value(weightKg),
        achievedAt: achievedAt,
        sessionId: Value(sessionId),
        setId: Value(setId),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Overwrites an existing record row with a new best (same identity, new
  /// value and achievement source).
  Future<void> updateRecord({
    required String id,
    required double value,
    required DateTime achievedAt,
    String? sessionId,
    String? setId,
  }) {
    return (update(personalRecords)..where((t) => t.id.equals(id))).write(
      PersonalRecordsCompanion(
        value: Value(value),
        achievedAt: Value(achievedAt),
        sessionId: Value(sessionId),
        setId: Value(setId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Removes every stored PR row for an exercise (recompute step 1).
  Future<int> clearRecordsForExercise(String exerciseId) {
    return (delete(personalRecords)
          ..where((t) => t.exerciseId.equals(exerciseId)))
        .go();
  }

  /// Every completed, non-warmup working set ever logged for an exercise in
  /// non-discarded sessions, ordered oldest → newest — the replay input for
  /// `PRRepository.recomputePRs` (detection == recompute parity, §10.2).
  Future<List<PRReplaySet>> getReplayableWorkingSets(String exerciseId) async {
    final query = select(workoutSets).join([
      innerJoin(
        workoutSessions,
        workoutSessions.id.equalsExp(workoutSets.sessionId),
      ),
    ])
      ..where(workoutSets.exerciseId.equals(exerciseId))
      ..where(workoutSets.isCompleted.equals(true))
      ..where(workoutSets.setType.equals('warmup').not())
      ..where(workoutSets.weightKg.isBiggerThanValue(0))
      ..where(workoutSets.reps.isBiggerThanValue(0))
      ..where(workoutSessions.status.equals('discarded').not());

    final rows = await query.get();
    final result = <PRReplaySet>[];
    for (final row in rows) {
      final s = row.readTable(workoutSets);
      final session = row.readTable(workoutSessions);
      final effectiveAt =
          s.completedAt ?? session.completedAt ?? session.startedAt;
      result.add(PRReplaySet(set: s, effectiveAt: effectiveAt));
    }
    result.sort((a, b) => a.effectiveAt.compareTo(b.effectiveAt));
    return result;
  }
}
