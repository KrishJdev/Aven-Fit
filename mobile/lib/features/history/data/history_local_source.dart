import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../progress/domain/streak_info.dart';
import '../../routine/data/routine_tables.dart';
import '../../workout/data/workout_tables.dart';
import '../domain/lifetime_stats.dart';
import '../domain/week_stats.dart';
import '../domain/workout_history_item.dart';

part 'history_local_source.g.dart';

/// DAO powering workout history (WU-3.9, FEATURES.md §8.6/§8.7).
///
/// No new tables — history joins the workout and routine tables. All
/// mutations are transactional write-throughs with client-generated ids
/// (L2/L7); every query runs 100% offline from SQLite.
@DriftAccessor(tables: [
  WorkoutSessions,
  SessionExercises,
  WorkoutSets,
  Routines,
  RoutineExercises,
  RoutineSets,
])
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.db);

  static int _idCounter = 0;

  String _nextId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  /// Reactive, paginated feed of completed workouts, newest first, with
  /// per-session aggregates (completed sets, working volume excluding
  /// warm-ups per L1, and PR count).
  Stream<List<WorkoutHistoryItem>> watchCompletedWorkouts({
    int limit = 50,
    int offset = 0,
  }) {
    final query = select(workoutSessions)
      ..where((tbl) => tbl.status.equals('completed'))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.completedAt),
        (tbl) => OrderingTerm.desc(tbl.startedAt),
      ])
      ..limit(limit, offset: offset);

    return query.watch().asyncMap(_buildHistoryItems);
  }

  Future<List<WorkoutHistoryItem>> getCompletedWorkouts({
    int limit = 50,
    int offset = 0,
  }) async {
    final query = select(workoutSessions)
      ..where((tbl) => tbl.status.equals('completed'))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.completedAt),
        (tbl) => OrderingTerm.desc(tbl.startedAt),
      ])
      ..limit(limit, offset: offset);
    return _buildHistoryItems(await query.get());
  }

  Future<List<WorkoutHistoryItem>> _buildHistoryItems(
    List<WorkoutSessionRow> sessions,
  ) async {
    if (sessions.isEmpty) return const [];
    final sessionIds = sessions.map((s) => s.id).toList();

    // Batch-fetch the page's exercise blocks and their sets, then aggregate
    // in memory — two indexed queries per page, no N+1 (L2).
    final exRows = await (select(sessionExercises)
          ..where((t) => t.sessionId.isIn(sessionIds)))
        .get();
    final seIds = exRows.map((e) => e.id).toList();
    final setRows = seIds.isEmpty
        ? const <WorkoutSetRow>[]
        : await (select(workoutSets)
              ..where((t) => t.sessionExerciseId.isIn(seIds)))
            .get();

    final exerciseCountBySession = <String, int>{};
    for (final ex in exRows) {
      exerciseCountBySession[ex.sessionId] =
          (exerciseCountBySession[ex.sessionId] ?? 0) + 1;
    }
    final sessionIdBySet = {
      for (final ex in exRows) ex.id: ex.sessionId,
    };

    final setsCountBySession = <String, int>{};
    final volumeBySession = <String, double>{};
    final prCountBySession = <String, int>{};
    for (final set in setRows) {
      final sessionId = sessionIdBySet[set.sessionExerciseId];
      if (sessionId == null) continue;
      if (set.isCompleted) {
        setsCountBySession[sessionId] =
            (setsCountBySession[sessionId] ?? 0) + 1;
        if (set.setType != 'warmup') {
          volumeBySession[sessionId] =
              (volumeBySession[sessionId] ?? 0) + set.weightKg * set.reps;
        }
        if (set.isPr) {
          prCountBySession[sessionId] = (prCountBySession[sessionId] ?? 0) + 1;
        }
      }
    }

    final items = sessions.map((session) {
      final date = session.completedAt ?? session.startedAt;
      final storedDuration = session.durationSeconds;
      final duration = storedDuration ??
          (date.difference(session.startedAt).inSeconds -
                  session.pausedDurationSeconds)
              .clamp(0, 1 << 31);
      return WorkoutHistoryItem(
        id: session.id,
        name: session.name,
        date: date,
        durationSeconds: duration,
        exerciseCount: exerciseCountBySession[session.id] ?? 0,
        totalSetsCount: setsCountBySession[session.id] ?? 0,
        totalVolumeKg: volumeBySession[session.id] ?? 0.0,
        prCount: prCountBySession[session.id] ?? 0,
      );
    }).toList();

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Reactive lifetime aggregate for the Profile screen (WU-5.3,
  /// FEATURES.md §12.1). The cheap tracked query re-executes whenever
  /// either workout table changes (`readsFrom` covers both), and every
  /// re-emission recomputes the totals fresh from the tables — derived
  /// state is never stored, so edits/deletes self-heal (L7/L8).
  Stream<LifetimeStats> watchLifetimeStats() {
    return customSelect(
      'SELECT COUNT(*) AS session_count FROM workout_sessions',
      readsFrom: {workoutSessions, workoutSets},
    )
        .watchSingle()
        .asyncMap((_) => _computeLifetimeStats());
  }

  /// Recomputes the lifetime aggregate from the session/set tables. Set
  /// and volume semantics mirror the history feed exactly (confirmed
  /// sets only; warm-ups excluded from working volume, L1).
  Future<LifetimeStats> _computeLifetimeStats() async {
    final completed = await (select(workoutSessions)
          ..where((t) => t.status.equals('completed')))
        .get();
    final completedIds = completed.map((s) => s.id).toList();

    var setCount = 0;
    var volume = 0.0;
    if (completedIds.isNotEmpty) {
      final setRows = await (select(workoutSets)
            ..where((t) =>
                t.sessionId.isIn(completedIds) & t.isCompleted.equals(true)))
          .get();
      for (final set in setRows) {
        setCount++;
        if (set.setType != 'warmup') {
          volume += set.weightKg * set.reps;
        }
      }
    }

    // "Member since" anchor: earliest session that was never discarded
    // (an in-progress first workout already counts as training since).
    final first = await (select(workoutSessions)
          ..where((t) => t.status.isNotIn(const ['discarded'])))
        .get();
    final firstSessionAt = first.isEmpty
        ? null
        : first
            .map((s) => s.startedAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);

    return LifetimeStats(
      workoutCount: completed.length,
      completedSetCount: setCount,
      totalVolumeKg: volume,
      firstSessionAt: firstSessionAt,
    );
  }

  /// Reactive week-over-week glance (WU-X.1, FEATURES.md §7.1): this
  /// week's and last week's completed workouts, confirmed sets, and
  /// working volume (warm-ups excluded, L1), bucketed Monday-anchored
  /// through the single `StreakInfo.startOfWeek` anchor. Same
  /// dual-trigger pattern as the lifetime stats — derived, never stored.
  Stream<WeeklyGlance> watchWeeklyGlance() {
    return customSelect(
      'SELECT COUNT(*) AS session_count FROM workout_sessions',
      readsFrom: {workoutSessions, workoutSets},
    )
        .watchSingle()
        .asyncMap((_) => _computeWeeklyGlance());
  }

  /// Recomputes both week buckets fresh from the tables. A session's
  /// week is its effective completion date (`completedAt ?? startedAt`,
  /// the same effective date the streak counts by).
  Future<WeeklyGlance> _computeWeeklyGlance() async {
    final thisWeekStart = StreakInfo.startOfWeek(DateTime.now());
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final thisWeekEnd = thisWeekStart.add(const Duration(days: 7));

    final completed = await (select(workoutSessions)
          ..where((t) => t.status.equals('completed')))
        .get();
    final completedIds = completed.map((s) => s.id).toList();
    final setRows = completedIds.isEmpty
        ? const <WorkoutSetRow>[]
        : await (select(workoutSets)
              ..where((t) =>
                  t.sessionId.isIn(completedIds) & t.isCompleted.equals(true)))
            .get();
    final sessionById = {for (final s in completed) s.id: s};

    WeekStats bucketFor(DateTime weekStart, DateTime weekEnd) {
      var workoutCount = 0;
      var setCount = 0;
      var volume = 0.0;
      for (final session in completed) {
        final date = session.completedAt ?? session.startedAt;
        if (date.isBefore(weekStart) || !date.isBefore(weekEnd)) continue;
        workoutCount++;
      }
      for (final set in setRows) {
        final session = sessionById[set.sessionId];
        if (session == null) continue;
        final date = session.completedAt ?? session.startedAt;
        if (date.isBefore(weekStart) || !date.isBefore(weekEnd)) continue;
        setCount++;
        if (set.setType != 'warmup') {
          volume += set.weightKg * set.reps;
        }
      }
      return WeekStats(
        workoutCount: workoutCount,
        completedSetCount: setCount,
        volumeKg: volume,
      );
    }

    return (
      thisWeek: bucketFor(thisWeekStart, thisWeekEnd),
      lastWeek: bucketFor(lastWeekStart, thisWeekStart),
    );
  }

  /// Repeats a completed workout (§8.7): creates a new active session
  /// pre-loaded with the same exercises (order, rest, notes) and the same
  /// sets as *planned* rows (unconfirmed, PR flags cleared). The original
  /// session is never mutated (L7). Returns the new session id.
  Future<String> repeatWorkout(String sessionId) {
    return transaction(() async {
      final session = await (select(workoutSessions)
            ..where((t) => t.id.equals(sessionId)))
          .getSingleOrNull();
      if (session == null) {
        throw StateError('Cannot repeat a workout that does not exist');
      }

      final exRows = await (select(sessionExercises)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
      final seIds = exRows.map((e) => e.id).toList();
      final setRows = seIds.isEmpty
          ? const <WorkoutSetRow>[]
          : await (select(workoutSets)
                ..where((t) => t.sessionExerciseId.isIn(seIds))
                ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
              .get();

      final now = DateTime.now();
      final newSessionId = _nextId('ws');
      await into(workoutSessions).insert(
        WorkoutSessionsCompanion.insert(
          id: newSessionId,
          name: Value(session.name),
          startedAt: now,
          status: const Value('active'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final newSeIdByOldId = <String, String>{};
      for (var i = 0; i < exRows.length; i++) {
        final ex = exRows[i];
        final newSeId = _nextId('se');
        newSeIdByOldId[ex.id] = newSeId;
        await into(sessionExercises).insert(
          SessionExercisesCompanion.insert(
            id: newSeId,
            sessionId: newSessionId,
            exerciseId: ex.exerciseId,
            orderIndex: Value(ex.orderIndex),
            restSeconds: Value(ex.restSeconds),
            notes: Value(ex.notes),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      for (final set in setRows) {
        final newSeId = newSeIdByOldId[set.sessionExerciseId];
        if (newSeId == null) continue;
        await into(workoutSets).insert(
          WorkoutSetsCompanion.insert(
            id: _nextId('set'),
            sessionId: newSessionId,
            sessionExerciseId: newSeId,
            exerciseId: Value(set.exerciseId),
            setNumber: set.setNumber,
            weightKg: Value(set.weightKg),
            reps: Value(set.reps),
            // Repeated sets arrive as planned rows to re-confirm.
            isCompleted: const Value(false),
            setType: Value(set.setType),
            rpe: Value(set.rpe),
            isPr: const Value(false),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      return newSessionId;
    });
  }

  /// Converts a completed workout into a reusable routine (§8.7/§8.5):
  /// exercises keep their order/rest/notes and every performed set becomes a
  /// target set row (weight → targetWeightKg, reps → targetReps). Returns
  /// the new routine id.
  Future<String> saveWorkoutAsRoutine(String sessionId, String name) {
    return transaction(() async {
      final exRows = await (select(sessionExercises)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
          .get();
      if (exRows.isEmpty) {
        throw StateError('Workout has no exercises to save as a routine');
      }
      final seIds = exRows.map((e) => e.id).toList();
      final setRows = await (select(workoutSets)
            ..where((t) => t.sessionExerciseId.isIn(seIds))
            ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
          .get();

      final now = DateTime.now();
      final routineId = _nextId('rt');
      await into(routines).insert(
        RoutinesCompanion.insert(
          id: routineId,
          name: name,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      for (var i = 0; i < exRows.length; i++) {
        final ex = exRows[i];
        final exSets =
            setRows.where((s) => s.sessionExerciseId == ex.id).toList();
        final reId = _nextId('re');
        await into(routineExercises).insert(
          RoutineExercisesCompanion.insert(
            id: reId,
            routineId: routineId,
            exerciseId: ex.exerciseId,
            orderIndex: Value(ex.orderIndex),
            restSeconds: Value(ex.restSeconds),
            notes: Value(ex.notes),
            targetSetsCount: Value(exSets.length),
          ),
        );
        for (var j = 0; j < exSets.length; j++) {
          final set = exSets[j];
          await into(routineSets).insert(
            RoutineSetsCompanion.insert(
              id: _nextId('rse'),
              routineExerciseId: reId,
              position: Value(j + 1),
              setType: Value(set.setType),
              targetReps: Value(set.reps),
              targetWeightKg: Value(set.weightKg),
              targetRpe: Value(set.rpe),
            ),
          );
        }
      }

      return routineId;
    });
  }

  /// Deletes a completed workout entirely — the session row cascade removes
  /// its exercises, sets, and PR rows (FK cascade, L7). Returns the affected
  /// exercise ids so the caller can recompute personal records from the
  /// remaining history (self-healing parity, §10.2).
  Future<List<String>> deleteWorkout(String sessionId) {
    return transaction(() async {
      final exRows = await (select(sessionExercises)
            ..where((t) => t.sessionId.equals(sessionId)))
          .get();
      final exerciseIds = exRows.map((e) => e.exerciseId).toSet().toList();
      await (delete(workoutSessions)..where((t) => t.id.equals(sessionId)))
          .go();
      return exerciseIds;
    });
  }
}
