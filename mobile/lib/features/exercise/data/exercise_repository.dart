import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../domain/exercise.dart';
import '../domain/muscle_group.dart';
import 'exercise_local_source.dart';
import 'exercise_seed_loader.dart';

part 'exercise_repository.g.dart';

/// Contract defining exercise and muscle group operations.
abstract class ExerciseRepository {
  /// Retrieves all muscle groups ordered by displayOrder.
  Future<List<MuscleGroup>> getMuscleGroups();

  /// Streams all muscle groups ordered by displayOrder.
  Stream<List<MuscleGroup>> watchMuscleGroups();

  /// Searches exercises matching query and optional filters.
  Future<List<Exercise>> searchExercises({
    String? query,
    ExerciseCategory? category,
    Equipment? equipment,
    String? muscleGroupId,
    bool? favouritesOnly,
  });

  /// Streams exercises matching query and optional filters.
  Stream<List<Exercise>> watchExercises({
    String? query,
    ExerciseCategory? category,
    Equipment? equipment,
    String? muscleGroupId,
    bool? favouritesOnly,
  });

  /// Retrieves a single exercise by ID.
  Future<Exercise?> getExerciseById(String id);

  /// Streams a single exercise by ID.
  Stream<Exercise?> watchExerciseById(String id);

  /// Toggles favourite status of an exercise.
  Future<bool> toggleFavourite(String id);

  /// Creates a custom user exercise with muscle group associations.
  Future<Exercise> createCustomExercise({
    required String name,
    String? description,
    required ExerciseCategory category,
    required Equipment equipment,
    required String primaryMuscleGroupId,
    List<String> secondaryMuscleGroupIds = const [],
    bool isTimeBased = false,
    bool isCardio = false,
  });

  /// Deletes a custom user exercise.
  Future<bool> deleteCustomExercise(String id);

  /// Seeds initial bundled data on first-run.
  Future<int> seedInitialData({bool force = false});
}

/// Production implementation of [ExerciseRepository] backed by [ExerciseDao].
class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._dao);

  final ExerciseDao _dao;

  @override
  Future<List<MuscleGroup>> getMuscleGroups() async {
    final rows = await _dao.getMuscleGroups();
    return rows.map(_mapRowToMuscleGroup).toList();
  }

  @override
  Stream<List<MuscleGroup>> watchMuscleGroups() {
    return _dao.watchMuscleGroups().map((rows) {
      return rows.map(_mapRowToMuscleGroup).toList();
    });
  }

  @override
  Future<List<Exercise>> searchExercises({
    String? query,
    ExerciseCategory? category,
    Equipment? equipment,
    String? muscleGroupId,
    bool? favouritesOnly,
  }) async {
    final items = await _dao.searchExercises(
      query: query,
      category: category?.name.toUpperCase(),
      equipment: equipment != null ? _equipmentToDbString(equipment) : null,
      muscleGroupId: muscleGroupId,
      favouritesOnly: favouritesOnly,
    );
    return items.map(_mapWithMusclesToExercise).toList();
  }

  @override
  Stream<List<Exercise>> watchExercises({
    String? query,
    ExerciseCategory? category,
    Equipment? equipment,
    String? muscleGroupId,
    bool? favouritesOnly,
  }) {
    return _dao
        .watchExercises(
      query: query,
      category: category?.name.toUpperCase(),
      equipment: equipment != null ? _equipmentToDbString(equipment) : null,
      muscleGroupId: muscleGroupId,
      favouritesOnly: favouritesOnly,
    )
        .map((items) {
      return items.map(_mapWithMusclesToExercise).toList();
    });
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final item = await _dao.getExerciseById(id);
    if (item == null) return null;
    return _mapWithMusclesToExercise(item);
  }

  @override
  Stream<Exercise?> watchExerciseById(String id) {
    return _dao.watchExerciseById(id).map((item) {
      if (item == null) return null;
      return _mapWithMusclesToExercise(item);
    });
  }

  @override
  Future<bool> toggleFavourite(String id) {
    return _dao.toggleFavourite(id);
  }

  @override
  Future<Exercise> createCustomExercise({
    required String name,
    String? description,
    required ExerciseCategory category,
    required Equipment equipment,
    required String primaryMuscleGroupId,
    List<String> secondaryMuscleGroupIds = const [],
    bool isTimeBased = false,
    bool isCardio = false,
  }) async {
    final id = 'ex_custom_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();

    final exCompanion = ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      category: Value(category.name.toUpperCase()),
      equipment: Value(_equipmentToDbString(equipment)),
      isCustom: const Value(true),
      isFavourite: const Value(false),
      isTimeBased: Value(isTimeBased),
      isCardio: Value(isCardio),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final linkCompanions = <ExerciseMuscleGroupsCompanion>[
      ExerciseMuscleGroupsCompanion(
        id: Value('${id}_$primaryMuscleGroupId'),
        exerciseId: Value(id),
        muscleGroupId: Value(primaryMuscleGroupId),
        role: const Value('PRIMARY'),
        createdAt: Value(now),
      ),
    ];

    for (final secId in secondaryMuscleGroupIds) {
      if (secId != primaryMuscleGroupId) {
        linkCompanions.add(
          ExerciseMuscleGroupsCompanion(
            id: Value('${id}_$secId'),
            exerciseId: Value(id),
            muscleGroupId: Value(secId),
            role: const Value('SECONDARY'),
            createdAt: Value(now),
          ),
        );
      }
    }

    await _dao.createCustomExercise(
      exercise: exCompanion,
      muscleLinks: linkCompanions,
    );

    final created = await getExerciseById(id);
    return created!;
  }

  @override
  Future<bool> deleteCustomExercise(String id) async {
    final count = await _dao.deleteCustomExercise(id);
    return count > 0;
  }

  @override
  Future<int> seedInitialData({bool force = false}) {
    return ExerciseSeedLoader.seedInitialData(_dao, force: force);
  }

  MuscleGroup _mapRowToMuscleGroup(MuscleGroupRow row) {
    return MuscleGroup(
      id: row.id,
      name: row.name,
      displayOrder: row.displayOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Exercise _mapWithMusclesToExercise(ExerciseWithMuscles item) {
    final row = item.exercise;
    final primaryList =
        item.muscles.where((m) => m.role == 'PRIMARY').toList();
    final secondaryList =
        item.muscles.where((m) => m.role == 'SECONDARY').toList();

    final primaryName =
        primaryList.isNotEmpty ? primaryList.first.muscleGroup.name : null;
    final secondaryNames =
        secondaryList.map((m) => m.muscleGroup.name).toList();

    final refs = item.muscles.map((m) {
      return ExerciseMuscleRef(
        muscleGroupId: m.muscleGroup.id,
        name: m.muscleGroup.name,
        role: m.role == 'PRIMARY' ? MuscleRole.primary : MuscleRole.secondary,
      );
    }).toList();

    return Exercise(
      id: row.id,
      name: row.name,
      description: row.description,
      category: _parseCategory(row.category),
      equipment: _parseEquipment(row.equipment),
      isCustom: row.isCustom,
      isFavourite: row.isFavourite,
      isTimeBased: row.isTimeBased,
      isCardio: row.isCardio,
      primaryMuscle: primaryName,
      secondaryMuscles: secondaryNames,
      muscleRefs: refs,
      createdById: row.createdById,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
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

  String _equipmentToDbString(Equipment eq) {
    switch (eq) {
      case Equipment.smithMachine:
        return 'SMITH_MACHINE';
      default:
        return eq.name.toUpperCase();
    }
  }
}

/// Riverpod provider exposing [ExerciseRepository] to presentation controllers.
@riverpod
ExerciseRepository exerciseRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExerciseRepositoryImpl(db.exerciseDao);
}
