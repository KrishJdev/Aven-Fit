import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../../exercise/domain/exercise.dart';
import '../../exercise/domain/muscle_group.dart';
import '../domain/session_exercise.dart';
import '../domain/workout_session.dart';
import '../domain/workout_set.dart';
import 'workout_local_source.dart';

part 'workout_repository.g.dart';

/// Contract defining workout data operations for the domain & presentation layers.
abstract class WorkoutRepository {
  Stream<WorkoutSession?> watchActiveSession();
  Future<WorkoutSession?> getActiveSession();
  Future<WorkoutSession?> getSessionById(String id);
  Stream<List<SessionExercise>> watchSessionExercises(String sessionId);
  Future<List<SessionExercise>> getSessionExercises(String sessionId);
  Stream<List<WorkoutSet>> watchSessionSets(String sessionId);
  Future<List<WorkoutSet>> getSetsForSession(String sessionId);
  Future<List<WorkoutSet>> getLastCompletedSetsForExercise(String exerciseId);
  Future<WorkoutSession> startWorkout({
    String name = 'Workout',
    String? routineId,
    String? notes,
  });
  Future<SessionExercise> addExerciseToSession({
    required String sessionId,
    required String exerciseId,
    int? restSeconds,
    String? notes,
  });
  Future<void> removeExerciseFromSession(String sessionExerciseId);
  Future<void> reorderSessionExercises(
    String sessionId,
    List<String> orderedSessionExerciseIds,
  );
  Future<void> logSet(WorkoutSet set);
  Future<void> updateSet(WorkoutSet set);
  Future<void> deleteSet(String setId);
  Future<void> finishWorkout(
    String sessionId, {
    int? durationSeconds,
    String? notes,
  });
  Future<void> cancelWorkout(String sessionId);
}

/// Production implementation of [WorkoutRepository] backed by Drift SQLite DAO.
class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._dao);

  final WorkoutDao _dao;

  @override
  Stream<WorkoutSession?> watchActiveSession() {
    return _dao.watchActiveSession().asyncMap((row) async {
      if (row == null) return null;
      final sessionWithEx = await _dao.getSessionWithExercises(row.id);
      if (sessionWithEx == null) {
        return _mapRowToSession(row);
      }
      return _mapSessionWithExercisesToSession(sessionWithEx);
    });
  }

  @override
  Future<WorkoutSession?> getActiveSession() async {
    final row = await _dao.getActiveSession();
    if (row == null) return null;
    final sessionWithEx = await _dao.getSessionWithExercises(row.id);
    if (sessionWithEx == null) {
      return _mapRowToSession(row);
    }
    return _mapSessionWithExercisesToSession(sessionWithEx);
  }

  @override
  Future<WorkoutSession?> getSessionById(String id) async {
    final sessionWithEx = await _dao.getSessionWithExercises(id);
    if (sessionWithEx == null) {
      final row = await _dao.getSessionById(id);
      if (row == null) return null;
      return _mapRowToSession(row);
    }
    return _mapSessionWithExercisesToSession(sessionWithEx);
  }

  @override
  Stream<List<SessionExercise>> watchSessionExercises(String sessionId) {
    return _dao.watchSessionExercisesWithSets(sessionId).map((list) {
      return list.map(_mapSessionExerciseWithSetsToDomain).toList();
    });
  }

  @override
  Future<List<SessionExercise>> getSessionExercises(String sessionId) async {
    final list = await _dao.getSessionExercisesWithSets(sessionId);
    return list.map(_mapSessionExerciseWithSetsToDomain).toList();
  }

  @override
  Stream<List<WorkoutSet>> watchSessionSets(String sessionId) {
    return _dao.watchSessionSets(sessionId).map((rows) {
      return rows.map(_mapRowToSet).toList();
    });
  }

  @override
  Future<List<WorkoutSet>> getSetsForSession(String sessionId) async {
    final rows = await _dao.getSessionSets(sessionId);
    return rows.map(_mapRowToSet).toList();
  }

  @override
  Future<List<WorkoutSet>> getLastCompletedSetsForExercise(
    String exerciseId,
  ) async {
    final rows = await _dao.getLastCompletedSetsForExercise(exerciseId);
    return rows.map(_mapRowToSet).toList();
  }

  @override
  Future<WorkoutSession> startWorkout({
    String name = 'Workout',
    String? routineId,
    String? notes,
  }) async {
    final sessionId = 'ws_${DateTime.now().microsecondsSinceEpoch}';
    final startedAt = DateTime.now();
    await _dao.createSession(
      id: sessionId,
      name: name,
      startedAt: startedAt,
      routineId: routineId,
      notes: notes,
    );

    return WorkoutSession(
      id: sessionId,
      name: name,
      routineId: routineId,
      startedAt: startedAt,
      status: WorkoutStatus.active,
      exercises: const [],
      sets: const [],
      notes: notes,
    );
  }

  @override
  Future<SessionExercise> addExerciseToSession({
    required String sessionId,
    required String exerciseId,
    int? restSeconds,
    String? notes,
  }) async {
    final existing = await _dao.getSessionExercisesWithSets(sessionId);
    final orderIndex = existing.length;
    final sessionExerciseId = 'se_${DateTime.now().microsecondsSinceEpoch}';

    await _dao.addExerciseToSession(
      id: sessionExerciseId,
      sessionId: sessionId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
      restSeconds: restSeconds ?? 90,
      notes: notes,
    );

    final updatedList = await _dao.getSessionExercisesWithSets(sessionId);
    final found = updatedList.firstWhere(
      (e) => e.sessionExercise.id == sessionExerciseId,
    );
    return _mapSessionExerciseWithSetsToDomain(found);
  }

  @override
  Future<void> removeExerciseFromSession(String sessionExerciseId) async {
    await _dao.removeExerciseFromSession(sessionExerciseId);
  }

  @override
  Future<void> reorderSessionExercises(
    String sessionId,
    List<String> orderedSessionExerciseIds,
  ) {
    return _dao.reorderSessionExercises(sessionId, orderedSessionExerciseIds);
  }

  @override
  Future<void> logSet(WorkoutSet set) async {
    await _dao.insertSet(
      id: set.id,
      sessionId: set.sessionId,
      sessionExerciseId: set.sessionExerciseId,
      exerciseId: set.exerciseId,
      setNumber: set.setNumber,
      weightKg: set.weightKg,
      reps: set.reps,
      isCompleted: set.isCompleted,
      setType: set.type.name,
      rpe: set.rpe,
      completedAt: set.completedAt,
      isPr: set.isPr,
      notes: set.notes,
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
      completedAt: set.completedAt,
      isPr: set.isPr,
      notes: set.notes,
    );
  }

  @override
  Future<void> deleteSet(String setId) async {
    await _dao.deleteSetRecord(setId);
  }

  @override
  Future<void> finishWorkout(
    String sessionId, {
    int? durationSeconds,
    String? notes,
  }) async {
    await _dao.completeSession(
      sessionId,
      DateTime.now(),
      durationSeconds: durationSeconds,
      notes: notes,
    );
  }

  @override
  Future<void> cancelWorkout(String sessionId) async {
    await _dao.discardSession(sessionId);
  }

  WorkoutSession _mapRowToSession(WorkoutSessionRow row) {
    return WorkoutSession(
      id: row.id,
      userId: row.userId,
      routineId: row.routineId,
      name: row.name,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      durationSeconds: row.durationSeconds,
      status: _parseStatus(row.status),
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  WorkoutSession _mapSessionWithExercisesToSession(SessionWithExercises item) {
    final exercises =
        item.exercises.map(_mapSessionExerciseWithSetsToDomain).toList();
    final allSets = exercises.expand((e) => e.sets).toList();

    return WorkoutSession(
      id: item.session.id,
      userId: item.session.userId,
      routineId: item.session.routineId,
      name: item.session.name,
      startedAt: item.session.startedAt,
      completedAt: item.session.completedAt,
      durationSeconds: item.session.durationSeconds,
      status: _parseStatus(item.session.status),
      exercises: exercises,
      sets: allSets,
      notes: item.session.notes,
      createdAt: item.session.createdAt,
      updatedAt: item.session.updatedAt,
    );
  }

  SessionExercise _mapSessionExerciseWithSetsToDomain(
    SessionExerciseWithSets item,
  ) {
    final sets = item.sets.map(_mapRowToSet).toList();
    final exRow = item.exercise;
    final exerciseDomain = exRow != null
        ? Exercise(
            id: exRow.id,
            name: exRow.name,
            description: exRow.description,
            category: _parseCategory(exRow.category),
            equipment: _parseEquipment(exRow.equipment),
            isCustom: exRow.isCustom,
            isFavourite: exRow.isFavourite,
            isTimeBased: exRow.isTimeBased,
            isCardio: exRow.isCardio,
            createdById: exRow.createdById,
            createdAt: exRow.createdAt,
            updatedAt: exRow.updatedAt,
          )
        : null;

    return SessionExercise(
      id: item.sessionExercise.id,
      sessionId: item.sessionExercise.sessionId,
      exerciseId: item.sessionExercise.exerciseId,
      exercise: exerciseDomain,
      exerciseName: exRow?.name,
      orderIndex: item.sessionExercise.orderIndex,
      restSeconds: item.sessionExercise.restSeconds,
      notes: item.sessionExercise.notes,
      sets: sets,
      createdAt: item.sessionExercise.createdAt,
      updatedAt: item.sessionExercise.updatedAt,
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

  WorkoutStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return WorkoutStatus.completed;
      case 'discarded':
      case 'cancelled':
        return WorkoutStatus.discarded;
      default:
        return WorkoutStatus.active;
    }
  }

  SetType _parseSetType(String type) {
    switch (type.toLowerCase()) {
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

  ExerciseCategory _parseCategory(String value) {
    return ExerciseCategory.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ExerciseCategory.other,
    );
  }

  Equipment _parseEquipment(String value) {
    final clean = value.replaceAll('_', '').toLowerCase();
    return Equipment.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == clean ||
          e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Equipment.none,
    );
  }
}

/// Riverpod provider exposing [WorkoutRepository] to feature controllers.
@riverpod
WorkoutRepository workoutRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return WorkoutRepositoryImpl(db.workoutDao);
}
