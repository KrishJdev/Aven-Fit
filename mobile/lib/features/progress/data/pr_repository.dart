import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../../workout/domain/workout_set.dart';
import '../domain/pr_record.dart';
import 'pr_local_source.dart';

part 'pr_repository.g.dart';

/// Contract for the PR detection engine (WU-3.6, FEATURES.md §10.2).
///
/// PRs are computed locally and incrementally at set-save time — no
/// recalculation sweep, no network (L2). Warm-up sets never count.
abstract class PRRepository {
  /// Detects and persists new PRs for a just-confirmed set by comparing it
  /// against the stored records for the exercise.
  ///
  /// Returns the list of records achieved by this set (empty when none);
  /// each achieved record is upserted in the same call. Only completed,
  /// non-warmup sets with positive weight and reps are eligible.
  Future<List<PRRecord>> detectPRs({
    required String exerciseId,
    required WorkoutSet set,
  });

  /// Rebuilds every PR row for an exercise from scratch by replaying all
  /// completed working-set history chronologically through the same
  /// detection math (detection == recompute parity; the self-healing path
  /// used after set edits/deletes, §10.2 L7).
  Future<void> recomputePRs(String exerciseId);

  /// Current best records for one exercise.
  Future<List<PRRecord>> getRecordsForExercise(String exerciseId);

  /// Current best records across all exercises.
  Future<List<PRRecord>> getAllRecords();

  /// Reactive vault view (WU-X.3): every PR joined with its exercise
  /// name, newest achievement first — the Progress preview and the
  /// full vault share this one stream.
  Stream<List<PRVaultEntry>> watchVault();
}

/// Production implementation of [PRRepository] backed by Drift SQLite DAO.
class PRRepositoryImpl implements PRRepository {
  PRRepositoryImpl(this._dao);

  final PrDao _dao;
  static int _idCounter = 0;

  String _nextId() =>
      'pr_${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  @override
  Future<List<PRRecord>> detectPRs({
    required String exerciseId,
    required WorkoutSet set,
  }) async {
    // §10.2: warm-up sets never count; unconfirmed sets and empty values
    // (0 kg / 0 reps) can never produce a record.
    if (!set.isCompleted ||
        set.type == SetType.warmup ||
        set.weightKg <= 0 ||
        set.reps <= 0) {
      return const [];
    }

    final achievedAt = set.completedAt ?? DateTime.now();
    // Candidate values of this set for each tracked record type. A record is
    // beaten only by a strictly greater value (equal keeps the earlier date).
    final candidates = <RecordType, ({double value, double? weightKg})>{
      RecordType.maxWeight: (value: set.weightKg, weightKg: null),
      RecordType.epley1rm: (
        value: PRRecord.epleyE1RM(weightKg: set.weightKg, reps: set.reps),
        weightKg: null,
      ),
      RecordType.maxRepsAtWeight: (
        value: set.reps.toDouble(),
        weightKg: set.weightKg,
      ),
      RecordType.volume: (value: set.weightKg * set.reps, weightKg: null),
    };

    final newPRs = <PRRecord>[];
    for (final entry in candidates.entries) {
      final existing = await _dao.findRecord(
        exerciseId: exerciseId,
        recordType: entry.key.name,
        weightKg: entry.value.weightKg,
      );
      if (existing != null && entry.value.value <= existing.value) continue;

      final recordId = existing?.id ?? _nextId();
      if (existing == null) {
        await _dao.insertRecord(
          id: recordId,
          exerciseId: exerciseId,
          recordType: entry.key.name,
          value: entry.value.value,
          weightKg: entry.value.weightKg,
          achievedAt: achievedAt,
          sessionId: set.sessionId,
          setId: set.id,
        );
      } else {
        await _dao.updateRecord(
          id: recordId,
          value: entry.value.value,
          achievedAt: achievedAt,
          sessionId: set.sessionId,
          setId: set.id,
        );
      }

      newPRs.add(PRRecord(
        id: recordId,
        exerciseId: exerciseId,
        recordType: entry.key,
        value: entry.value.value,
        weightKg: entry.value.weightKg,
        achievedAt: achievedAt,
        sessionId: set.sessionId,
        setId: set.id,
      ));
    }
    return newPRs;
  }

  @override
  Future<void> recomputePRs(String exerciseId) async {
    final history = await _dao.getReplayableWorkingSets(exerciseId);
    await _dao.transaction(() async {
      await _dao.clearRecordsForExercise(exerciseId);
      for (final entry in history) {
        await detectPRs(exerciseId: exerciseId, set: _mapRowToSet(entry.set));
      }
    });
  }

  @override
  Stream<List<PRVaultEntry>> watchVault() => _dao.watchVault();

  @override
  Future<List<PRRecord>> getRecordsForExercise(String exerciseId) async {
    final rows = await _dao.getRecordsForExercise(exerciseId);
    return rows.map(_mapRowToRecord).toList();
  }

  @override
  Future<List<PRRecord>> getAllRecords() async {
    final rows = await _dao.getAllRecords();
    return rows.map(_mapRowToRecord).toList();
  }

  PRRecord _mapRowToRecord(PersonalRecordRow row) {
    return PRRecord(
      id: row.id,
      exerciseId: row.exerciseId,
      recordType: RecordType.fromName(row.recordType),
      value: row.value,
      weightKg: row.weightKg,
      achievedAt: row.achievedAt,
      sessionId: row.sessionId,
      setId: row.setId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  WorkoutSet _mapRowToSet(WorkoutSetRow row) {
    return WorkoutSet(
      id: row.id,
      sessionId: row.sessionId,
      sessionExerciseId: row.sessionExerciseId,
      exerciseId: row.exerciseId,
      setNumber: row.setNumber,
      weightKg: row.weightKg,
      reps: row.reps,
      isCompleted: row.isCompleted,
      type: _parseSetType(row.setType),
      rpe: row.rpe,
      completedAt: row.completedAt,
      isPr: row.isPr,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SetType _parseSetType(String value) {
    switch (value.toLowerCase()) {
      case 'warmup':
        return SetType.warmup;
      case 'dropset':
      case 'drop_set':
      case 'drop':
        return SetType.dropSet;
      case 'failure':
        return SetType.failure;
      default:
        return SetType.normal;
    }
  }
}

/// Riverpod provider exposing [PRRepository] to feature controllers.
@riverpod
PRRepository prRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return PRRepositoryImpl(db.prDao);
}
