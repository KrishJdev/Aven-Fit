import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../../exercise/domain/exercise.dart';
import '../../exercise/domain/muscle_group.dart';
import '../../workout/domain/workout_set.dart';
import '../domain/routine.dart';
import '../domain/routine_exercise.dart';
import '../domain/routine_set.dart';
import 'routine_local_source.dart';

part 'routine_repository.g.dart';

/// Contract defining workout routine operations.
abstract class RoutineRepository {
  /// Streams all routines with their associated exercises and sets.
  Stream<List<Routine>> watchAllRoutines();

  /// Retrieves all routines asynchronously.
  Future<List<Routine>> getAllRoutines();

  /// Streams a single routine by ID with its exercises and sets.
  Stream<Routine?> watchRoutineById(String id);

  /// Retrieves a single routine by ID with its exercises and sets.
  Future<Routine?> getRoutineById(String id);

  /// Creates a new routine with optional initial exercises and sets.
  Future<Routine> createRoutine({
    required String name,
    String? description,
    String? userId,
    List<RoutineExercise> exercises = const [],
  });

  /// Updates an existing routine's metadata, exercises, and sets.
  Future<Routine> updateRoutine(Routine routine);

  /// Deletes a routine by ID (cascades to exercises and sets in SQLite).
  Future<bool> deleteRoutine(String id);

  /// Duplicates a routine and all its nested exercises and target sets.
  Future<Routine> duplicateRoutine(String id, {String? newName});

  /// Reorders exercises within a routine.
  Future<void> reorderExercises(
    String routineId,
    List<String> orderedRoutineExerciseIds,
  );

  /// Adds a single exercise to a routine with target configurations.
  Future<RoutineExercise> addExerciseToRoutine({
    required String routineId,
    required String exerciseId,
    int? orderIndex,
    int restSeconds = 90,
    int targetSetsCount = 3,
    double? targetWeightKg,
    int? targetReps,
    double? targetRpe,
    String? notes,
    List<RoutineSet> sets = const [],
  });

  /// Removes an exercise entry from a routine.
  Future<bool> removeExerciseFromRoutine(String routineExerciseId);
}

/// Production implementation of [RoutineRepository] backed by [RoutineDao].
class RoutineRepositoryImpl implements RoutineRepository {
  RoutineRepositoryImpl(this._dao);

  final RoutineDao _dao;

  @override
  Stream<List<Routine>> watchAllRoutines() {
    return _dao.watchAllRoutines().map((list) {
      return list.map(_mapWithExercisesToRoutine).toList();
    });
  }

  @override
  Future<List<Routine>> getAllRoutines() async {
    final list = await _dao.getAllRoutines();
    return list.map(_mapWithExercisesToRoutine).toList();
  }

  @override
  Stream<Routine?> watchRoutineById(String id) {
    return _dao.watchRoutineById(id).map((item) {
      if (item == null) return null;
      return _mapWithExercisesToRoutine(item);
    });
  }

  @override
  Future<Routine?> getRoutineById(String id) async {
    final item = await _dao.getRoutineById(id);
    if (item == null) return null;
    return _mapWithExercisesToRoutine(item);
  }

  @override
  Future<Routine> createRoutine({
    required String name,
    String? description,
    String? userId,
    List<RoutineExercise> exercises = const [],
  }) async {
    final routineId = 'r_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();

    final routineCompanion = RoutinesCompanion(
      id: Value(routineId),
      userId: Value(userId),
      name: Value(name.trim()),
      description: Value(description?.trim()),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final exercisesCompanions = <RoutineExercisesCompanion>[];
    final setsCompanions = <RoutineSetsCompanion>[];

    for (var i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      final exId = ex.id.isNotEmpty
          ? ex.id
          : 're_${DateTime.now().microsecondsSinceEpoch}_$i';

      exercisesCompanions.add(
        RoutineExercisesCompanion(
          id: Value(exId),
          routineId: Value(routineId),
          exerciseId: Value(ex.exerciseId),
          orderIndex: Value(i),
          restSeconds: Value(ex.restSeconds),
          notes: Value(ex.notes),
          targetSetsCount: Value(ex.targetSetsCount ?? ex.sets.length),
          targetWeightKg: Value(ex.targetWeightKg),
          targetReps: Value(ex.targetReps),
          targetRpe: Value(ex.targetRpe),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final sets = ex.sets.isNotEmpty
          ? ex.sets
          : List.generate(
              ex.targetSetsCount ?? 3,
              (setIdx) => RoutineSet(
                id: 'rs_${DateTime.now().microsecondsSinceEpoch}_${i}_$setIdx',
                routineExerciseId: exId,
                position: setIdx + 1,
                targetReps: ex.targetReps,
                targetWeightKg: ex.targetWeightKg,
                targetRpe: ex.targetRpe,
              ),
            );

      for (var sIdx = 0; sIdx < sets.length; sIdx++) {
        final s = sets[sIdx];
        setsCompanions.add(
          RoutineSetsCompanion(
            id: Value(s.id.isNotEmpty
                ? s.id
                : 'rs_${DateTime.now().microsecondsSinceEpoch}_${i}_$sIdx'),
            routineExerciseId: Value(exId),
            position: Value(s.position),
            setType: Value(s.setType.name),
            targetReps: Value(s.targetReps),
            targetWeightKg: Value(s.targetWeightKg),
            targetRpe: Value(s.targetRpe),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    }

    await _dao.createRoutine(
      routine: routineCompanion,
      exercisesList: exercisesCompanions,
      setsList: setsCompanions,
    );

    final created = await getRoutineById(routineId);
    return created!;
  }

  @override
  Future<Routine> updateRoutine(Routine routine) async {
    final now = DateTime.now();

    final routineCompanion = RoutinesCompanion(
      id: Value(routine.id),
      userId: Value(routine.userId),
      name: Value(routine.name.trim()),
      description: Value(routine.description?.trim()),
      createdAt: Value(routine.createdAt ?? now),
      updatedAt: Value(now),
    );

    final exercisesCompanions = <RoutineExercisesCompanion>[];
    final setsCompanions = <RoutineSetsCompanion>[];

    for (var i = 0; i < routine.exercises.length; i++) {
      final ex = routine.exercises[i];
      final exId = ex.id.isNotEmpty
          ? ex.id
          : 're_${DateTime.now().microsecondsSinceEpoch}_$i';

      exercisesCompanions.add(
        RoutineExercisesCompanion(
          id: Value(exId),
          routineId: Value(routine.id),
          exerciseId: Value(ex.exerciseId),
          orderIndex: Value(i),
          restSeconds: Value(ex.restSeconds),
          notes: Value(ex.notes),
          targetSetsCount: Value(ex.targetSetsCount ?? ex.sets.length),
          targetWeightKg: Value(ex.targetWeightKg),
          targetReps: Value(ex.targetReps),
          targetRpe: Value(ex.targetRpe),
          createdAt: Value(ex.createdAt ?? now),
          updatedAt: Value(now),
        ),
      );

      final sets = ex.sets.isNotEmpty
          ? ex.sets
          : List.generate(
              ex.targetSetsCount ?? 3,
              (setIdx) => RoutineSet(
                id: 'rs_${DateTime.now().microsecondsSinceEpoch}_${i}_$setIdx',
                routineExerciseId: exId,
                position: setIdx + 1,
                targetReps: ex.targetReps,
                targetWeightKg: ex.targetWeightKg,
                targetRpe: ex.targetRpe,
              ),
            );

      for (var sIdx = 0; sIdx < sets.length; sIdx++) {
        final s = sets[sIdx];
        setsCompanions.add(
          RoutineSetsCompanion(
            id: Value(s.id.isNotEmpty
                ? s.id
                : 'rs_${DateTime.now().microsecondsSinceEpoch}_${i}_$sIdx'),
            routineExerciseId: Value(exId),
            position: Value(s.position),
            setType: Value(s.setType.name),
            targetReps: Value(s.targetReps),
            targetWeightKg: Value(s.targetWeightKg),
            targetRpe: Value(s.targetRpe),
            createdAt: Value(s.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
      }
    }

    await _dao.updateRoutine(
      routine: routineCompanion,
      exercisesList: exercisesCompanions,
      setsList: setsCompanions,
    );

    final updated = await getRoutineById(routine.id);
    return updated!;
  }

  @override
  Future<bool> deleteRoutine(String id) async {
    final count = await _dao.deleteRoutine(id);
    return count > 0;
  }

  @override
  Future<Routine> duplicateRoutine(String id, {String? newName}) async {
    final newId = await _dao.duplicateRoutine(id, newName: newName);
    final cloned = await getRoutineById(newId);
    return cloned!;
  }

  @override
  Future<void> reorderExercises(
    String routineId,
    List<String> orderedRoutineExerciseIds,
  ) {
    return _dao.reorderExercises(routineId, orderedRoutineExerciseIds);
  }

  @override
  Future<RoutineExercise> addExerciseToRoutine({
    required String routineId,
    required String exerciseId,
    int? orderIndex,
    int restSeconds = 90,
    int targetSetsCount = 3,
    double? targetWeightKg,
    int? targetReps,
    double? targetRpe,
    String? notes,
    List<RoutineSet> sets = const [],
  }) async {
    final existing = await getRoutineById(routineId);
    final effectiveOrder = orderIndex ?? (existing?.exercises.length ?? 0);
    final exId = 're_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();

    final exCompanion = RoutineExercisesCompanion(
      id: Value(exId),
      routineId: Value(routineId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(effectiveOrder),
      restSeconds: Value(restSeconds),
      notes: Value(notes),
      targetSetsCount: Value(targetSetsCount),
      targetWeightKg: Value(targetWeightKg),
      targetReps: Value(targetReps),
      targetRpe: Value(targetRpe),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    final setsCompanions = <RoutineSetsCompanion>[];
    final setsList = sets.isNotEmpty
        ? sets
        : List.generate(
            targetSetsCount,
            (i) => RoutineSet(
              id: 'rs_${DateTime.now().microsecondsSinceEpoch}_$i',
              routineExerciseId: exId,
              position: i + 1,
              targetReps: targetReps,
              targetWeightKg: targetWeightKg,
              targetRpe: targetRpe,
            ),
          );

    for (var i = 0; i < setsList.length; i++) {
      final s = setsList[i];
      setsCompanions.add(
        RoutineSetsCompanion(
          id: Value(s.id.isNotEmpty
              ? s.id
              : 'rs_${DateTime.now().microsecondsSinceEpoch}_$i'),
          routineExerciseId: Value(exId),
          position: Value(s.position),
          setType: Value(s.setType.name),
          targetReps: Value(s.targetReps),
          targetWeightKg: Value(s.targetWeightKg),
          targetRpe: Value(s.targetRpe),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    await _dao.addExerciseToRoutine(
      exerciseEntry: exCompanion,
      setsList: setsCompanions,
    );

    final updatedRoutine = await getRoutineById(routineId);
    return updatedRoutine!.exercises.firstWhere((e) => e.id == exId);
  }

  @override
  Future<bool> removeExerciseFromRoutine(String routineExerciseId) async {
    final count = await _dao.removeExerciseFromRoutine(routineExerciseId);
    return count > 0;
  }

  Routine _mapWithExercisesToRoutine(RoutineWithExercises item) {
    final exercises = item.exercises.map(_mapExerciseWithSetsToDomain).toList();
    return Routine(
      id: item.routine.id,
      name: item.routine.name,
      description: item.routine.description,
      userId: item.routine.userId,
      exercises: exercises,
      createdAt: item.routine.createdAt,
      updatedAt: item.routine.updatedAt,
    );
  }

  RoutineExercise _mapExerciseWithSetsToDomain(RoutineExerciseWithSets item) {
    final sets = item.sets.map(_mapSetRowToDomain).toList();
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

    return RoutineExercise(
      id: item.routineExercise.id,
      routineId: item.routineExercise.routineId,
      exerciseId: item.routineExercise.exerciseId,
      exercise: exerciseDomain,
      exerciseName: exRow?.name,
      orderIndex: item.routineExercise.orderIndex,
      restSeconds: item.routineExercise.restSeconds,
      notes: item.routineExercise.notes,
      targetSetsCount: item.routineExercise.targetSetsCount,
      targetWeightKg: item.routineExercise.targetWeightKg,
      targetReps: item.routineExercise.targetReps,
      targetRpe: item.routineExercise.targetRpe,
      sets: sets,
      createdAt: item.routineExercise.createdAt,
      updatedAt: item.routineExercise.updatedAt,
    );
  }

  RoutineSet _mapSetRowToDomain(RoutineSetRow row) {
    return RoutineSet(
      id: row.id,
      routineExerciseId: row.routineExerciseId,
      position: row.position,
      setType: _parseSetType(row.setType),
      targetReps: row.targetReps,
      targetWeightKg: row.targetWeightKg,
      targetRpe: row.targetRpe,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SetType _parseSetType(String value) {
    return SetType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SetType.normal,
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
}

/// Riverpod provider exposing [RoutineRepository] to controllers.
@riverpod
RoutineRepository routineRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return RoutineRepositoryImpl(db.routineDao);
}
