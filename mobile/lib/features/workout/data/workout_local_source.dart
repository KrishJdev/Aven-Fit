import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'workout_tables.dart';

part 'workout_local_source.g.dart';

/// DAO providing reactive streams and local persistence for workout sessions and sets.
///
/// Implements Law L1 (<3s writes) and Law L2 (100% offline persistence).
@DriftAccessor(tables: [WorkoutSessions, WorkoutSets])
class WorkoutDao extends DatabaseAccessor<AppDatabase> with _$WorkoutDaoMixin {
  WorkoutDao(super.db);

  /// Streams the currently active session (if any).
  Stream<WorkoutSessionRow?> watchActiveSession() {
    return (select(workoutSessions)
          ..where((tbl) => tbl.status.equals('active'))
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Streams all sets for a given session, sorted by setNumber.
  Stream<List<WorkoutSetRow>> watchSessionSets(String sessionId) {
    return (select(workoutSets)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.setNumber)]))
        .watch();
  }

  /// Retrieves the active session asynchronously.
  Future<WorkoutSessionRow?> getActiveSession() {
    return (select(workoutSessions)
          ..where((tbl) => tbl.status.equals('active'))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Retrieves all sets for a session asynchronously.
  Future<List<WorkoutSetRow>> getSessionSets(String sessionId) {
    return (select(workoutSets)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.setNumber)]))
        .get();
  }

  /// Inserts a new workout session row.
  Future<int> createSession({
    required String id,
    required String name,
    required DateTime startedAt,
  }) {
    return into(workoutSessions).insert(
      WorkoutSessionsCompanion.insert(
        id: id,
        name: Value(name),
        startedAt: startedAt,
        status: const Value('active'),
      ),
    );
  }

  /// Marks a session as completed.
  Future<int> completeSession(String id, DateTime completedAt) {
    return (update(workoutSessions)..where((tbl) => tbl.id.equals(id))).write(
      WorkoutSessionsCompanion(
        status: const Value('completed'),
        completedAt: Value(completedAt),
      ),
    );
  }

  /// Discards/cancels an active session.
  Future<int> discardSession(String id) {
    return (update(workoutSessions)..where((tbl) => tbl.id.equals(id))).write(
      const WorkoutSessionsCompanion(
        status: Value('discarded'),
      ),
    );
  }

  /// Inserts a logged set.
  Future<int> insertSet({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required double weightKg,
    required int reps,
    bool isCompleted = false,
    String setType = 'normal',
    double? rpe,
  }) {
    return into(workoutSets).insert(
      WorkoutSetsCompanion.insert(
        id: id,
        sessionId: sessionId,
        exerciseId: exerciseId,
        setNumber: setNumber,
        weightKg: weightKg,
        reps: reps,
        isCompleted: Value(isCompleted),
        setType: Value(setType),
        rpe: Value(rpe),
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
  }) {
    return (update(workoutSets)..where((tbl) => tbl.id.equals(id))).write(
      WorkoutSetsCompanion(
        weightKg: Value(weightKg),
        reps: Value(reps),
        isCompleted: Value(isCompleted),
        setType: Value(setType),
        rpe: Value(rpe),
      ),
    );
  }

  /// Deletes a set record by ID.
  Future<int> deleteSetRecord(String id) {
    return (delete(workoutSets)..where((tbl) => tbl.id.equals(id))).go();
  }
}
