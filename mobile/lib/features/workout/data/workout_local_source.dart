import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../exercise/data/exercise_tables.dart';
import 'workout_tables.dart';

part 'workout_local_source.g.dart';

/// Aggregation of a session row with its ordered session exercises and sets.
class SessionWithExercises {
  final WorkoutSessionRow session;
  final List<SessionExerciseWithSets> exercises;

  const SessionWithExercises({
    required this.session,
    required this.exercises,
  });
}

/// Aggregation of a session exercise row with its exercise catalog entry and sets.
class SessionExerciseWithSets {
  final SessionExerciseRow sessionExercise;
  final ExerciseRow? exercise;
  final List<WorkoutSetRow> sets;

  const SessionExerciseWithSets({
    required this.sessionExercise,
    required this.exercise,
    required this.sets,
  });
}

/// DAO providing reactive streams, joined queries, and local persistence for workout sessions,
/// session-exercises, and sets.
///
/// Implements Law L1 (<3s writes) and Law L2 (100% offline persistence).
@DriftAccessor(tables: [
  WorkoutSessions,
  SessionExercises,
  WorkoutSets,
  Exercises,
  MuscleGroups,
  ExerciseMuscleGroups,
])
class WorkoutDao extends DatabaseAccessor<AppDatabase> with _$WorkoutDaoMixin {
  WorkoutDao(super.db);

  /// Streams the currently active session (if any).
  Stream<WorkoutSessionRow?> watchActiveSession() {
    return (select(workoutSessions)
          ..where((tbl) => tbl.status.equals('active'))
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Retrieves the active session asynchronously.
  Future<WorkoutSessionRow?> getActiveSession() {
    return (select(workoutSessions)
          ..where((tbl) => tbl.status.equals('active'))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Retrieves session row by ID.
  Future<WorkoutSessionRow?> getSessionById(String id) {
    return (select(workoutSessions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Streams session with its ordered exercises and sets.
  Stream<SessionWithExercises?> watchSessionWithExercises(String sessionId) {
    final query = select(workoutSessions).join([
      leftOuterJoin(
        sessionExercises,
        sessionExercises.sessionId.equalsExp(workoutSessions.id),
      ),
      leftOuterJoin(
        exercises,
        exercises.id.equalsExp(sessionExercises.exerciseId),
      ),
    ])
      ..where(workoutSessions.id.equals(sessionId))
      ..orderBy([
        OrderingTerm.asc(sessionExercises.orderIndex),
      ]);

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return null;
      final results = await _buildSessionsFromJoined(rows);
      return results.isNotEmpty ? results.first : null;
    });
  }

  /// Retrieves session with its ordered exercises and sets asynchronously.
  Future<SessionWithExercises?> getSessionWithExercises(String sessionId) async {
    final query = select(workoutSessions).join([
      leftOuterJoin(
        sessionExercises,
        sessionExercises.sessionId.equalsExp(workoutSessions.id),
      ),
      leftOuterJoin(
        exercises,
        exercises.id.equalsExp(sessionExercises.exerciseId),
      ),
    ])
      ..where(workoutSessions.id.equals(sessionId))
      ..orderBy([
        OrderingTerm.asc(sessionExercises.orderIndex),
      ]);

    final rows = await query.get();
    if (rows.isEmpty) return null;
    final results = await _buildSessionsFromJoined(rows);
    return results.isNotEmpty ? results.first : null;
  }

  /// Streams all session exercises and sets for a given session.
  Stream<List<SessionExerciseWithSets>> watchSessionExercisesWithSets(String sessionId) {
    final query = select(sessionExercises).join([
      leftOuterJoin(
        exercises,
        exercises.id.equalsExp(sessionExercises.exerciseId),
      ),
    ])
      ..where(sessionExercises.sessionId.equals(sessionId))
      ..orderBy([
        OrderingTerm.asc(sessionExercises.orderIndex),
      ]);

    return query.watch().asyncMap(_buildSessionExercisesFromJoined);
  }

  /// Retrieves all session exercises and sets for a given session.
  Future<List<SessionExerciseWithSets>> getSessionExercisesWithSets(String sessionId) async {
    final query = select(sessionExercises).join([
      leftOuterJoin(
        exercises,
        exercises.id.equalsExp(sessionExercises.exerciseId),
      ),
    ])
      ..where(sessionExercises.sessionId.equals(sessionId))
      ..orderBy([
        OrderingTerm.asc(sessionExercises.orderIndex),
      ]);

    final rows = await query.get();
    return _buildSessionExercisesFromJoined(rows);
  }

  /// Streams all sets for a given session, sorted by setNumber.
  Stream<List<WorkoutSetRow>> watchSessionSets(String sessionId) {
    return (select(workoutSets)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.setNumber)]))
        .watch();
  }

  /// Retrieves all sets for a session asynchronously.
  Future<List<WorkoutSetRow>> getSessionSets(String sessionId) {
    return (select(workoutSets)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.setNumber)]))
        .get();
  }

  /// Retrieves the most recent completed performance sets for a specific exercise.
  Future<List<WorkoutSetRow>> getLastCompletedSetsForExercise(
    String exerciseId,
  ) async {
    final query = select(workoutSessions).join([
      innerJoin(
        sessionExercises,
        sessionExercises.sessionId.equalsExp(workoutSessions.id),
      ),
    ])
      ..where(workoutSessions.status.equals('completed'))
      ..where(sessionExercises.exerciseId.equals(exerciseId))
      ..orderBy([
        OrderingTerm.desc(workoutSessions.completedAt),
        OrderingTerm.desc(workoutSessions.startedAt),
      ])
      ..limit(1);

    final result = await query.getSingleOrNull();
    if (result == null) return const [];

    final sessionEx = result.readTable(sessionExercises);
    return (select(workoutSets)
          ..where((t) => t.sessionExerciseId.equals(sessionEx.id))
          ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .get();
  }

  /// Retrieves the distinct recent exercises used across completed workout sessions.
  Future<List<ExerciseRow>> getRecentExercises({int limit = 10}) async {
    final query = select(exercises).join([
      innerJoin(
        sessionExercises,
        sessionExercises.exerciseId.equalsExp(exercises.id),
      ),
      innerJoin(
        workoutSessions,
        workoutSessions.id.equalsExp(sessionExercises.sessionId),
      ),
    ])
      ..where(workoutSessions.status.equals('completed'))
      ..orderBy([
        OrderingTerm.desc(workoutSessions.completedAt),
        OrderingTerm.desc(workoutSessions.startedAt),
      ]);

    final rows = await query.get();
    final seen = <String>{};
    final distinctExercises = <ExerciseRow>[];

    for (final row in rows) {
      final ex = row.readTable(exercises);
      if (seen.add(ex.id)) {
        distinctExercises.add(ex);
        if (distinctExercises.length >= limit) break;
      }
    }

    return distinctExercises;
  }

  /// Inserts a new workout session row.
  Future<int> createSession({
    required String id,
    required String name,
    required DateTime startedAt,
    String? routineId,
    String? notes,
  }) {
    final now = DateTime.now();
    return into(workoutSessions).insert(
      WorkoutSessionsCompanion.insert(
        id: id,
        name: Value(name),
        startedAt: startedAt,
        status: const Value('active'),
        routineId: Value(routineId),
        notes: Value(notes),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Marks a session as completed.
  Future<int> completeSession(
    String id,
    DateTime completedAt, {
    int? durationSeconds,
    String? notes,
  }) {
    return (update(workoutSessions)..where((tbl) => tbl.id.equals(id))).write(
      WorkoutSessionsCompanion(
        status: const Value('completed'),
        completedAt: Value(completedAt),
        durationSeconds: Value(durationSeconds),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Discards/cancels an active session.
  Future<int> discardSession(String id) {
    return (update(workoutSessions)..where((tbl) => tbl.id.equals(id))).write(
      WorkoutSessionsCompanion(
        status: const Value('discarded'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Renames a session in place (inline rename write-through, Law L7).
  Future<int> renameSession(String id, String name) {
    return (update(workoutSessions)..where((tbl) => tbl.id.equals(id))).write(
      WorkoutSessionsCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Pauses the session timer — freezes elapsed time at the current moment
  /// by stamping [lastResumedAt] (the freeze point, §8.1 `last_resumed_at`
  /// pattern). Write-through, L7.
  Future<int> pauseSession(String id, DateTime pausedAt) {
    return (update(workoutSessions)..where((tbl) => tbl.id.equals(id))).write(
      WorkoutSessionsCompanion(
        isPaused: const Value(true),
        lastResumedAt: Value(pausedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Resumes the session timer — folds the just-elapsed pause span into
  /// [pausedDurationSeconds] and clears the freeze point (L7/L8).
  Future<int> resumeSession(String id, DateTime resumedAt) {
    return transaction(() async {
      final row = await (select(workoutSessions)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();
      final pausedAt = row.lastResumedAt;
      final pauseSpan =
          pausedAt == null ? 0 : resumedAt.difference(pausedAt).inSeconds;
      final accumulated = row.pausedDurationSeconds + (pauseSpan < 0 ? 0 : pauseSpan);
      return (update(workoutSessions)..where((tbl) => tbl.id.equals(id))).write(
        WorkoutSessionsCompanion(
          isPaused: const Value(false),
          lastResumedAt: const Value(null),
          pausedDurationSeconds: Value(accumulated),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// Adds an exercise to an active session.
  Future<void> addExerciseToSession({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int orderIndex,
    int restSeconds = 90,
    String? notes,
  }) {
    final now = DateTime.now();
    return into(sessionExercises).insert(
      SessionExercisesCompanion.insert(
        id: id,
        sessionId: sessionId,
        exerciseId: exerciseId,
        orderIndex: Value(orderIndex),
        restSeconds: Value(restSeconds),
        notes: Value(notes),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Removes an exercise entry from a session (cascade deletes its sets).
  Future<int> removeExerciseFromSession(String sessionExerciseId) {
    return (delete(sessionExercises)
          ..where((t) => t.id.equals(sessionExerciseId)))
        .go();
  }

  /// Reorders exercises within a session.
  /// Uses two-pass update with temporary negative offsets to prevent unique constraint collisions on `(sessionId, orderIndex)`.
  Future<void> reorderSessionExercises(
    String sessionId,
    List<String> orderedSessionExerciseIds,
  ) {
    return transaction(() async {
      final now = DateTime.now();
      // Step 1: Temporarily shift to negative indices
      for (var i = 0; i < orderedSessionExerciseIds.length; i++) {
        final seId = orderedSessionExerciseIds[i];
        await (update(sessionExercises)..where((t) => t.id.equals(seId))).write(
          SessionExercisesCompanion(
            orderIndex: Value(-(i + 1)),
            updatedAt: Value(now),
          ),
        );
      }
      // Step 2: Assign desired 0-indexed positions
      for (var i = 0; i < orderedSessionExerciseIds.length; i++) {
        final seId = orderedSessionExerciseIds[i];
        await (update(sessionExercises)..where((t) => t.id.equals(seId))).write(
          SessionExercisesCompanion(
            orderIndex: Value(i),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  /// Inserts a logged set.
  Future<int> insertSet({
    required String id,
    required String sessionId,
    required String sessionExerciseId,
    String? exerciseId,
    required int setNumber,
    required double weightKg,
    required int reps,
    bool isCompleted = false,
    String setType = 'normal',
    double? rpe,
    DateTime? completedAt,
    bool isPr = false,
    String? notes,
  }) {
    final now = DateTime.now();
    return into(workoutSets).insert(
      WorkoutSetsCompanion.insert(
        id: id,
        sessionId: sessionId,
        sessionExerciseId: sessionExerciseId,
        exerciseId: Value(exerciseId),
        setNumber: setNumber,
        weightKg: Value(weightKg),
        reps: Value(reps),
        isCompleted: Value(isCompleted),
        setType: Value(setType),
        rpe: Value(rpe),
        completedAt: Value(completedAt),
        isPr: Value(isPr),
        notes: Value(notes),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Updates an existing set record.
  Future<int> updateSetRecord({
    required String id,
    required double weightKg,
    required int reps,
    required bool isCompleted,
    required String setType,
    double? rpe,
    DateTime? completedAt,
    bool? isPr,
    String? notes,
  }) {
    return (update(workoutSets)..where((tbl) => tbl.id.equals(id))).write(
      WorkoutSetsCompanion(
        weightKg: Value(weightKg),
        reps: Value(reps),
        isCompleted: Value(isCompleted),
        setType: Value(setType),
        rpe: Value(rpe),
        completedAt: Value(completedAt),
        isPr: isPr != null ? Value(isPr) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a set record by ID.
  Future<int> deleteSetRecord(String id) {
    return (delete(workoutSets)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<SessionExerciseWithSets>> _buildSessionExercisesFromJoined(
    List<TypedResult> joinedRows,
  ) async {
    final list = <SessionExerciseWithSets>[];
    final seIds = <String>[];

    for (final row in joinedRows) {
      final se = row.readTable(sessionExercises);
      final ex = row.readTableOrNull(exercises);
      list.add(SessionExerciseWithSets(
        sessionExercise: se,
        exercise: ex,
        sets: const [],
      ));
      seIds.add(se.id);
    }

    if (seIds.isNotEmpty) {
      final setRows = await (select(workoutSets)
            ..where((t) => t.sessionExerciseId.isIn(seIds))
            ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
          .get();

      final setsBySeId = <String, List<WorkoutSetRow>>{};
      for (final s in setRows) {
        setsBySeId.putIfAbsent(s.sessionExerciseId, () => []).add(s);
      }

      for (var i = 0; i < list.length; i++) {
        final item = list[i];
        final sets = setsBySeId[item.sessionExercise.id] ?? const [];
        list[i] = SessionExerciseWithSets(
          sessionExercise: item.sessionExercise,
          exercise: item.exercise,
          sets: sets,
        );
      }
    }

    list.sort((a, b) =>
        a.sessionExercise.orderIndex.compareTo(b.sessionExercise.orderIndex));
    return list;
  }

  Future<List<SessionWithExercises>> _buildSessionsFromJoined(
    List<TypedResult> joinedRows,
  ) async {
    final sessionMap = <String, WorkoutSessionRow>{};
    final seMap = <String, List<SessionExerciseWithSets>>{};
    final seIds = <String>[];

    for (final row in joinedRows) {
      final ws = row.readTable(workoutSessions);
      sessionMap[ws.id] = ws;

      final se = row.readTableOrNull(sessionExercises);
      if (se != null) {
        final ex = row.readTableOrNull(exercises);
        final list = seMap.putIfAbsent(ws.id, () => []);
        if (!list.any((item) => item.sessionExercise.id == se.id)) {
          list.add(SessionExerciseWithSets(
            sessionExercise: se,
            exercise: ex,
            sets: const [],
          ));
          seIds.add(se.id);
        }
      }
    }

    if (seIds.isNotEmpty) {
      final setRows = await (select(workoutSets)
            ..where((t) => t.sessionExerciseId.isIn(seIds))
            ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
          .get();

      final setsBySeId = <String, List<WorkoutSetRow>>{};
      for (final s in setRows) {
        setsBySeId.putIfAbsent(s.sessionExerciseId, () => []).add(s);
      }

      for (final list in seMap.values) {
        for (var i = 0; i < list.length; i++) {
          final item = list[i];
          final sets = setsBySeId[item.sessionExercise.id] ?? const [];
          list[i] = SessionExerciseWithSets(
            sessionExercise: item.sessionExercise,
            exercise: item.exercise,
            sets: sets,
          );
        }
      }
    }

    final results = <SessionWithExercises>[];
    for (final s in sessionMap.values) {
      final exList = seMap[s.id] ?? [];
      exList.sort((a, b) =>
          a.sessionExercise.orderIndex.compareTo(b.sessionExercise.orderIndex));
      results.add(SessionWithExercises(session: s, exercises: exList));
    }
    return results;
  }
}
