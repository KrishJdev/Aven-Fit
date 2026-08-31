import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'exercise_tables.dart';

part 'exercise_local_source.g.dart';

/// Representation of an exercise joined with its associated muscle groups.
class ExerciseWithMuscles {
  final ExerciseRow exercise;
  final List<MuscleGroupWithRole> muscles;

  ExerciseWithMuscles({
    required this.exercise,
    required this.muscles,
  });
}

/// Representation of a muscle group row with its role (PRIMARY / SECONDARY).
class MuscleGroupWithRole {
  final MuscleGroupRow muscleGroup;
  final String role;

  const MuscleGroupWithRole({
    required this.muscleGroup,
    required this.role,
  });
}

/// DAO providing reactive streams and local persistence for exercises and muscle groups.
///
/// Implements Law L1 (<3s writes), Law L2 (100% offline library), and Law L7 (write-through persistence).
@DriftAccessor(tables: [MuscleGroups, Exercises, ExerciseMuscleGroups])
class ExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseDaoMixin {
  ExerciseDao(super.db);

  /// Retrieves all muscle groups ordered by displayOrder.
  Future<List<MuscleGroupRow>> getMuscleGroups() {
    return (select(muscleGroups)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.displayOrder)]))
        .get();
  }

  /// Streams all muscle groups ordered by displayOrder.
  Stream<List<MuscleGroupRow>> watchMuscleGroups() {
    return (select(muscleGroups)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.displayOrder)]))
        .watch();
  }

  /// Streams exercises with matching criteria and their muscle group links.
  Stream<List<ExerciseWithMuscles>> watchExercises({
    String? query,
    String? category,
    String? equipment,
    String? muscleGroupId,
    bool? favouritesOnly,
  }) {
    final joined = _buildJoinedQuery(
      query: query,
      category: category,
      equipment: equipment,
      muscleGroupId: muscleGroupId,
      favouritesOnly: favouritesOnly,
    );

    return joined.watch().map(_groupJoinedResults);
  }

  /// Searches exercises matching criteria asynchronously.
  Future<List<ExerciseWithMuscles>> searchExercises({
    String? query,
    String? category,
    String? equipment,
    String? muscleGroupId,
    bool? favouritesOnly,
  }) async {
    final joined = _buildJoinedQuery(
      query: query,
      category: category,
      equipment: equipment,
      muscleGroupId: muscleGroupId,
      favouritesOnly: favouritesOnly,
    );

    final rows = await joined.get();
    return _groupJoinedResults(rows);
  }

  /// Retrieves a single exercise by ID with its muscle groups.
  Future<ExerciseWithMuscles?> getExerciseById(String id) async {
    final joined = select(exercises).join([
      leftOuterJoin(
        exerciseMuscleGroups,
        exerciseMuscleGroups.exerciseId.equalsExp(exercises.id),
      ),
      leftOuterJoin(
        muscleGroups,
        muscleGroups.id.equalsExp(exerciseMuscleGroups.muscleGroupId),
      ),
    ])..where(exercises.id.equals(id));

    final rows = await joined.get();
    final list = _groupJoinedResults(rows);
    return list.isEmpty ? null : list.first;
  }

  /// Streams a single exercise by ID with its muscle groups.
  Stream<ExerciseWithMuscles?> watchExerciseById(String id) {
    final joined = select(exercises).join([
      leftOuterJoin(
        exerciseMuscleGroups,
        exerciseMuscleGroups.exerciseId.equalsExp(exercises.id),
      ),
      leftOuterJoin(
        muscleGroups,
        muscleGroups.id.equalsExp(exerciseMuscleGroups.muscleGroupId),
      ),
    ])..where(exercises.id.equals(id));

    return joined.watch().map((rows) {
      final list = _groupJoinedResults(rows);
      return list.isEmpty ? null : list.first;
    });
  }

  /// Toggles the favourite status of an exercise.
  Future<bool> toggleFavourite(String id) async {
    final ex = await (select(exercises)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (ex == null) return false;
    final newFav = !ex.isFavourite;
    await (update(exercises)..where((tbl) => tbl.id.equals(id))).write(
      ExercisesCompanion(isFavourite: Value(newFav)),
    );
    return newFav;
  }

  /// Creates a custom exercise with associated muscle group links in a single transaction.
  Future<void> createCustomExercise({
    required ExercisesCompanion exercise,
    required List<ExerciseMuscleGroupsCompanion> muscleLinks,
  }) {
    return transaction(() async {
      await into(exercises).insert(exercise);
      if (muscleLinks.isNotEmpty) {
        await batch((b) {
          b.insertAll(exerciseMuscleGroups, muscleLinks);
        });
      }
    });
  }

  /// Deletes a custom exercise by ID. Built-in exercises (isCustom = false) cannot be deleted.
  Future<int> deleteCustomExercise(String id) {
    return (delete(exercises)
          ..where((tbl) => tbl.id.equals(id) & tbl.isCustom.equals(true)))
        .go();
  }

  /// Counts the total number of exercises in the database.
  Future<int> countExercises() async {
    final countExp = exercises.id.count();
    final query = selectOnly(exercises)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Counts the total number of muscle groups in the database.
  Future<int> countMuscleGroups() async {
    final countExp = muscleGroups.id.count();
    final query = selectOnly(muscleGroups)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Batch inserts muscle groups (used during initial database seeding).
  Future<void> batchInsertMuscleGroups(List<MuscleGroupsCompanion> rows) {
    return batch((b) {
      b.insertAll(muscleGroups, rows, mode: InsertMode.insertOrReplace);
    });
  }

  /// Batch inserts exercises and their muscle group links (used during initial database seeding).
  Future<void> batchInsertExercises({
    required List<ExercisesCompanion> exerciseRows,
    required List<ExerciseMuscleGroupsCompanion> linkRows,
  }) {
    return transaction(() async {
      await batch((b) {
        b.insertAll(exercises, exerciseRows, mode: InsertMode.insertOrReplace);
        b.insertAll(
            exerciseMuscleGroups, linkRows, mode: InsertMode.insertOrReplace);
      });
    });
  }

  JoinedSelectStatement _buildJoinedQuery({
    String? query,
    String? category,
    String? equipment,
    String? muscleGroupId,
    bool? favouritesOnly,
  }) {
    final joined = select(exercises).join([
      leftOuterJoin(
        exerciseMuscleGroups,
        exerciseMuscleGroups.exerciseId.equalsExp(exercises.id),
      ),
      leftOuterJoin(
        muscleGroups,
        muscleGroups.id.equalsExp(exerciseMuscleGroups.muscleGroupId),
      ),
    ]);

    if (query != null && query.trim().isNotEmpty) {
      final term = '%${query.trim().toLowerCase()}%';
      joined.where(
        exercises.name.lower().like(term) |
            exercises.description.lower().like(term),
      );
    }

    if (category != null && category.isNotEmpty) {
      joined.where(exercises.category.equals(category));
    }

    if (equipment != null && equipment.isNotEmpty) {
      joined.where(exercises.equipment.equals(equipment));
    }

    if (favouritesOnly == true) {
      joined.where(exercises.isFavourite.equals(true));
    }

    if (muscleGroupId != null && muscleGroupId.isNotEmpty) {
      joined.where(exerciseMuscleGroups.muscleGroupId.equals(muscleGroupId));
    }

    joined.orderBy([
      OrderingTerm.asc(exercises.name),
    ]);

    return joined;
  }

  List<ExerciseWithMuscles> _groupJoinedResults(List<TypedResult> rows) {
    final Map<String, ExerciseWithMuscles> map = {};
    for (final row in rows) {
      final ex = row.readTable(exercises);
      final mg = row.readTableOrNull(muscleGroups);
      final emg = row.readTableOrNull(exerciseMuscleGroups);

      final entry = map.putIfAbsent(
        ex.id,
        () => ExerciseWithMuscles(exercise: ex, muscles: []),
      );

      if (mg != null && emg != null) {
        final alreadyAdded = entry.muscles
            .any((m) => m.muscleGroup.id == mg.id && m.role == emg.role);
        if (!alreadyAdded) {
          entry.muscles.add(
            MuscleGroupWithRole(
              muscleGroup: mg,
              role: emg.role,
            ),
          );
        }
      }
    }
    return map.values.toList();
  }
}
