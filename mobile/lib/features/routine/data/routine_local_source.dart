import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../exercise/data/exercise_tables.dart';
import '../../workout/data/workout_tables.dart';
import 'routine_tables.dart';

part 'routine_local_source.g.dart';

/// Aggregation of a routine row with its ordered exercises and sets.
class RoutineWithExercises {
  final RoutineRow routine;
  final List<RoutineExerciseWithSets> exercises;

  const RoutineWithExercises({
    required this.routine,
    required this.exercises,
  });
}

/// Aggregation of a routine exercise entry with its exercise details and target sets.
class RoutineExerciseWithSets {
  final RoutineExerciseRow routineExercise;
  final ExerciseRow? exercise;
  final List<RoutineSetRow> sets;

  const RoutineExerciseWithSets({
    required this.routineExercise,
    required this.exercise,
    required this.sets,
  });
}

/// Drift DAO providing reactive queries and transactions for workout routines.
///
/// Implements Law L1 (<3s writes), Law L2 (100% offline), Law L3 (unlimited routines),
/// and Law L7 (write-through persistence and non-destructive duplication).
@DriftAccessor(tables: [
  Routines,
  RoutineExercises,
  RoutineSets,
  Exercises,
  MuscleGroups,
  ExerciseMuscleGroups,
  WorkoutSessions,
])
class RoutineDao extends DatabaseAccessor<AppDatabase>
    with _$RoutineDaoMixin {
  RoutineDao(super.db);

  /// Reactive id of the suggested routine (WU-X.1 Home, FEATURES.md
  /// §7.1: "most-used routine"). P0 heuristic: the routine started in
  /// the newest non-discarded session; when no routine has ever been
  /// used, the newest-created routine. Re-emits when sessions or the
  /// routine catalog change (L8).
  Stream<String?> watchSuggestedRoutineId() {
    return customSelect(
      'SELECT routine_id, MAX(started_at) AS last_used_at '
      'FROM workout_sessions '
      'WHERE routine_id IS NOT NULL AND status != ? '
      'GROUP BY routine_id '
      'ORDER BY last_used_at DESC '
      'LIMIT 1',
      variables: [Variable<String>('discarded')],
      readsFrom: {workoutSessions, routines},
    ).watchSingle().asyncMap((row) async {
      final usedId = row.readNullable<String>('routine_id');
      if (usedId != null) {
        return usedId;
      }
      // Nothing used yet → the newest-created routine.
      final newest = await (select(routines)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      return newest?.id;
    });
  }

  /// Streams all routines with their associated exercises and sets.
  Stream<List<RoutineWithExercises>> watchAllRoutines() {
    final query = select(routines).join([
      leftOuterJoin(
        routineExercises,
        routineExercises.routineId.equalsExp(routines.id),
      ),
      leftOuterJoin(
        exercises,
        exercises.id.equalsExp(routineExercises.exerciseId),
      ),
    ])
      ..orderBy([
        OrderingTerm.asc(routines.name),
        OrderingTerm.asc(routineExercises.orderIndex),
      ]);

    return query.watch().asyncMap(_buildRoutinesFromJoined);
  }

  /// Retrieves all routines asynchronously with their associated exercises.
  Future<List<RoutineWithExercises>> getAllRoutines() async {
    final query = select(routines).join([
      leftOuterJoin(
        routineExercises,
        routineExercises.routineId.equalsExp(routines.id),
      ),
      leftOuterJoin(
        exercises,
        exercises.id.equalsExp(routineExercises.exerciseId),
      ),
    ])
      ..orderBy([
        OrderingTerm.asc(routines.name),
        OrderingTerm.asc(routineExercises.orderIndex),
      ]);

    final rows = await query.get();
    return _buildRoutinesFromJoined(rows);
  }

  /// Streams a single routine by ID with its exercises and sets.
  Stream<RoutineWithExercises?> watchRoutineById(String id) {
    final query = select(routines).join([
      leftOuterJoin(
        routineExercises,
        routineExercises.routineId.equalsExp(routines.id),
      ),
      leftOuterJoin(
        exercises,
        exercises.id.equalsExp(routineExercises.exerciseId),
      ),
    ])
      ..where(routines.id.equals(id))
      ..orderBy([
        OrderingTerm.asc(routineExercises.orderIndex),
      ]);

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return null;
      final results = await _buildRoutinesFromJoined(rows);
      return results.isNotEmpty ? results.first : null;
    });
  }

  /// Retrieves a single routine by ID with its exercises and sets.
  Future<RoutineWithExercises?> getRoutineById(String id) async {
    final query = select(routines).join([
      leftOuterJoin(
        routineExercises,
        routineExercises.routineId.equalsExp(routines.id),
      ),
      leftOuterJoin(
        exercises,
        exercises.id.equalsExp(routineExercises.exerciseId),
      ),
    ])
      ..where(routines.id.equals(id))
      ..orderBy([
        OrderingTerm.asc(routineExercises.orderIndex),
      ]);

    final rows = await query.get();
    if (rows.isEmpty) return null;
    final results = await _buildRoutinesFromJoined(rows);
    return results.isNotEmpty ? results.first : null;
  }

  /// Creates a routine, its exercise entries, and target sets in a single transaction.
  Future<void> createRoutine({
    required RoutinesCompanion routine,
    List<RoutineExercisesCompanion> exercisesList = const [],
    List<RoutineSetsCompanion> setsList = const [],
  }) {
    return transaction(() async {
      await into(routines).insert(routine);
      for (final ex in exercisesList) {
        await into(routineExercises).insert(ex);
      }
      for (final s in setsList) {
        await into(routineSets).insert(s);
      }
    });
  }

  /// Updates routine metadata and replaces its exercise entries & sets.
  Future<void> updateRoutine({
    required RoutinesCompanion routine,
    required List<RoutineExercisesCompanion> exercisesList,
    required List<RoutineSetsCompanion> setsList,
  }) {
    return transaction(() async {
      await update(routines).replace(routine);
      // Delete old exercises (cascades to routineSets)
      await (delete(routineExercises)
            ..where((t) => t.routineId.equals(routine.id.value)))
          .go();

      for (final ex in exercisesList) {
        await into(routineExercises).insert(ex);
      }
      for (final s in setsList) {
        await into(routineSets).insert(s);
      }
    });
  }

  /// Deletes a routine by ID (cascades to exercises and sets in SQLite).
  Future<int> deleteRoutine(String id) {
    return (delete(routines)..where((t) => t.id.equals(id))).go();
  }

  /// Adds a single exercise to a routine.
  Future<void> addExerciseToRoutine({
    required RoutineExercisesCompanion exerciseEntry,
    List<RoutineSetsCompanion> setsList = const [],
  }) {
    return transaction(() async {
      await into(routineExercises).insert(exerciseEntry);
      for (final s in setsList) {
        await into(routineSets).insert(s);
      }
    });
  }

  /// Removes an exercise entry from a routine.
  Future<int> removeExerciseFromRoutine(String routineExerciseId) {
    return (delete(routineExercises)
          ..where((t) => t.id.equals(routineExerciseId)))
        .go();
  }

  /// Reorders exercises in a routine by updating their orderIndex values.
  ///
  /// Uses a two-pass update with temporary negative offsets to prevent SQLite
  /// unique constraint collisions on `(routineId, orderIndex)`.
  Future<void> reorderExercises(
    String routineId,
    List<String> orderedRoutineExerciseIds,
  ) {
    return transaction(() async {
      final now = DateTime.now();
      // Step 1: Temporarily shift to negative indices to clear target slots
      for (var i = 0; i < orderedRoutineExerciseIds.length; i++) {
        final reId = orderedRoutineExerciseIds[i];
        await (update(routineExercises)..where((t) => t.id.equals(reId))).write(
          RoutineExercisesCompanion(
            orderIndex: Value(-(i + 1)),
            updatedAt: Value(now),
          ),
        );
      }
      // Step 2: Assign final desired 0-indexed positions
      for (var i = 0; i < orderedRoutineExerciseIds.length; i++) {
        final reId = orderedRoutineExerciseIds[i];
        await (update(routineExercises)..where((t) => t.id.equals(reId))).write(
          RoutineExercisesCompanion(
            orderIndex: Value(i),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  /// Duplicates a routine and all its nested exercises and target sets (Law L7).
  Future<String> duplicateRoutine(
    String routineId, {
    String? newName,
  }) {
    return transaction(() async {
      final existing = await getRoutineById(routineId);
      if (existing == null) {
        throw ArgumentError('Routine with ID $routineId not found');
      }

      final newRoutineId = 'r_${DateTime.now().microsecondsSinceEpoch}';
      final now = DateTime.now();

      await into(routines).insert(
        RoutinesCompanion(
          id: Value(newRoutineId),
          userId: Value(existing.routine.userId),
          name: Value(newName ?? '${existing.routine.name} (Copy)'),
          description: Value(existing.routine.description),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      for (var i = 0; i < existing.exercises.length; i++) {
        final ex = existing.exercises[i];
        final newExerciseId =
            're_${DateTime.now().microsecondsSinceEpoch}_$i';

        await into(routineExercises).insert(
          RoutineExercisesCompanion(
            id: Value(newExerciseId),
            routineId: Value(newRoutineId),
            exerciseId: Value(ex.routineExercise.exerciseId),
            orderIndex: Value(ex.routineExercise.orderIndex),
            restSeconds: Value(ex.routineExercise.restSeconds),
            notes: Value(ex.routineExercise.notes),
            targetSetsCount: Value(ex.routineExercise.targetSetsCount),
            targetWeightKg: Value(ex.routineExercise.targetWeightKg),
            targetReps: Value(ex.routineExercise.targetReps),
            targetRpe: Value(ex.routineExercise.targetRpe),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        for (final s in ex.sets) {
          final newSetId =
              'rs_${DateTime.now().microsecondsSinceEpoch}_${s.position}';
          await into(routineSets).insert(
            RoutineSetsCompanion(
              id: Value(newSetId),
              routineExerciseId: Value(newExerciseId),
              position: Value(s.position),
              setType: Value(s.setType),
              targetReps: Value(s.targetReps),
              targetWeightKg: Value(s.targetWeightKg),
              targetRpe: Value(s.targetRpe),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
      }

      return newRoutineId;
    });
  }

  Future<List<RoutineWithExercises>> _buildRoutinesFromJoined(
    List<TypedResult> joinedRows,
  ) async {
    final routineMap = <String, RoutineRow>{};
    final exerciseMap = <String, List<RoutineExerciseWithSets>>{};
    final exerciseIds = <String>[];

    for (final row in joinedRows) {
      final r = row.readTable(routines);
      routineMap[r.id] = r;

      final re = row.readTableOrNull(routineExercises);
      if (re != null) {
        final ex = row.readTableOrNull(exercises);
        final list = exerciseMap.putIfAbsent(r.id, () => []);
        if (!list.any((item) => item.routineExercise.id == re.id)) {
          list.add(RoutineExerciseWithSets(
            routineExercise: re,
            exercise: ex,
            sets: const [],
          ));
          exerciseIds.add(re.id);
        }
      }
    }

    if (exerciseIds.isNotEmpty) {
      final setRows = await (select(routineSets)
            ..where((t) => t.routineExerciseId.isIn(exerciseIds))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();

      final setsByExId = <String, List<RoutineSetRow>>{};
      for (final s in setRows) {
        setsByExId.putIfAbsent(s.routineExerciseId, () => []).add(s);
      }

      for (final list in exerciseMap.values) {
        for (var i = 0; i < list.length; i++) {
          final item = list[i];
          final sets = setsByExId[item.routineExercise.id] ?? const [];
          list[i] = RoutineExerciseWithSets(
            routineExercise: item.routineExercise,
            exercise: item.exercise,
            sets: sets,
          );
        }
      }
    }

    final results = <RoutineWithExercises>[];
    for (final r in routineMap.values) {
      final exList = exerciseMap[r.id] ?? [];
      exList.sort((a, b) =>
          a.routineExercise.orderIndex.compareTo(b.routineExercise.orderIndex));
      results.add(RoutineWithExercises(routine: r, exercises: exList));
    }
    return results;
  }
}
