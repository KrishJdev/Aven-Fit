import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../domain/workout_session.dart';
import '../domain/workout_set.dart';
import 'workout_local_source.dart';

part 'workout_repository.g.dart';

/// Contract defining workout data operations for the domain & presentation layers.
abstract class WorkoutRepository {
  Stream<WorkoutSession?> watchActiveSession();
  Stream<List<WorkoutSet>> watchSessionSets(String sessionId);
  Future<WorkoutSession?> getActiveSession();
  Future<List<WorkoutSet>> getSetsForSession(String sessionId);
  Future<WorkoutSession> startWorkout({String name = 'Workout'});
  Future<void> logSet(WorkoutSet set);
  Future<void> updateSet(WorkoutSet set);
  Future<void> deleteSet(String setId);
  Future<void> finishWorkout(String sessionId);
  Future<void> cancelWorkout(String sessionId);
}

/// Production implementation of [WorkoutRepository] backed by Drift SQLite DAO.
class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._dao);

  final WorkoutDao _dao;

  @override
  Stream<WorkoutSession?> watchActiveSession() {
    return _dao.watchActiveSession().map((row) {
      if (row == null) return null;
      return _mapRowToSession(row);
    });
  }

  @override
  Stream<List<WorkoutSet>> watchSessionSets(String sessionId) {
    return _dao.watchSessionSets(sessionId).map((rows) {
      return rows.map((r) => _mapRowToSet(r)).toList();
    });
  }

  @override
  Future<WorkoutSession?> getActiveSession() async {
    final row = await _dao.getActiveSession();
    if (row == null) return null;
    return _mapRowToSession(row);
  }

  @override
  Future<List<WorkoutSet>> getSetsForSession(String sessionId) async {
    final rows = await _dao.getSessionSets(sessionId);
    return rows.map((r) => _mapRowToSet(r)).toList();
  }

  @override
  Future<WorkoutSession> startWorkout({String name = 'Workout'}) async {
    final sessionId = 'ws_${DateTime.now().microsecondsSinceEpoch}';
    final startedAt = DateTime.now();
    await _dao.createSession(
      id: sessionId,
      name: name,
      startedAt: startedAt,
    );

    return WorkoutSession(
      id: sessionId,
      name: name,
      startedAt: startedAt,
      status: WorkoutStatus.active,
      sets: const [],
    );
  }

  @override
  Future<void> logSet(WorkoutSet set) async {
    await _dao.insertSet(
      id: set.id,
      sessionId: set.sessionId,
      exerciseId: set.exerciseId,
      setNumber: set.setNumber,
      weightKg: set.weightKg,
      reps: set.reps,
      isCompleted: set.isCompleted,
      setType: set.type.name,
      rpe: set.rpe,
    );
  }

  @override
  Future<void> updateSet(WorkoutSet set) async {
    await _dao.updateSetRecord(
      id: set.id,
      weightKg: set.weightKg,
      reps: set.reps,
      isCompleted: set.isCompleted,
      setType: set.type.name,
      rpe: set.rpe,
    );
  }

  @override
  Future<void> deleteSet(String setId) async {
    await _dao.deleteSetRecord(setId);
  }

  @override
  Future<void> finishWorkout(String sessionId) async {
    await _dao.completeSession(sessionId, DateTime.now());
  }

  @override
  Future<void> cancelWorkout(String sessionId) async {
    await _dao.discardSession(sessionId);
  }

  WorkoutSession _mapRowToSession(WorkoutSessionRow row) {
    return WorkoutSession(
      id: row.id,
      name: row.name,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      status: _parseStatus(row.status),
      notes: row.notes,
    );
  }

  WorkoutSet _mapRowToSet(WorkoutSetRow row) {
    return WorkoutSet(
      id: row.id,
      sessionId: row.sessionId,
      exerciseId: row.exerciseId,
      setNumber: row.setNumber,
      weightKg: row.weightKg,
      reps: row.reps,
      isCompleted: row.isCompleted,
      type: _parseSetType(row.setType),
      rpe: row.rpe,
    );
  }

  WorkoutStatus _parseStatus(String status) {
    switch (status) {
      case 'completed':
        return WorkoutStatus.completed;
      case 'discarded':
        return WorkoutStatus.discarded;
      default:
        return WorkoutStatus.active;
    }
  }

  SetType _parseSetType(String type) {
    switch (type) {
      case 'warmup':
        return SetType.warmup;
      case 'dropSet':
        return SetType.dropSet;
      case 'failure':
        return SetType.failure;
      default:
        return SetType.normal;
    }
  }
}

/// Riverpod provider exposing [WorkoutRepository] to feature controllers.
@riverpod
WorkoutRepository workoutRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return WorkoutRepositoryImpl(db.workoutDao);
}
