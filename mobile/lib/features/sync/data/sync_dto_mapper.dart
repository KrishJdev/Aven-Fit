import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../routine/data/routine_local_source.dart';
import '../domain/sync_models.dart';

/// Bidirectional mapper between local Drift SQLite schema and backend Spring Boot PostgreSQL sync contract (Law L2, L7).
class SyncDtoMapper {
  const SyncDtoMapper._();

  // ---------------------------------------------------------------------------
  // Enum Translations
  // ---------------------------------------------------------------------------

  /// Mobile SQLite status ('active', 'completed', 'discarded') -> Backend ('IN_PROGRESS', 'COMPLETED', 'CANCELLED')
  static String workoutStatusToBackend(String localStatus) => switch (localStatus.toLowerCase()) {
        'completed' => 'COMPLETED',
        'discarded' => 'CANCELLED',
        'active' || _ => 'IN_PROGRESS',
      };

  /// Backend ('IN_PROGRESS', 'COMPLETED', 'CANCELLED') -> Mobile SQLite ('active', 'completed', 'discarded')
  static String workoutStatusToLocal(String backendStatus) => switch (backendStatus.toUpperCase()) {
        'COMPLETED' => 'completed',
        'CANCELLED' => 'discarded',
        'IN_PROGRESS' || _ => 'active',
      };

  /// Mobile SQLite setType ('normal', 'warmup', 'dropSet', 'failure') -> Backend ('NORMAL', 'WARMUP', 'DROP', 'FAILURE')
  static String setTypeToBackend(String localType) => switch (localType) {
        'warmup' => 'WARMUP',
        'dropSet' => 'DROP',
        'failure' => 'FAILURE',
        'normal' || _ => 'NORMAL',
      };

  /// Backend ('NORMAL', 'WARMUP', 'DROP', 'FAILURE') -> Mobile SQLite ('normal', 'warmup', 'dropSet', 'failure')
  static String setTypeToLocal(String backendType) => switch (backendType.toUpperCase()) {
        'WARMUP' => 'warmup',
        'DROP' => 'dropSet',
        'FAILURE' => 'failure',
        'NORMAL' || _ => 'normal',
      };

  // ---------------------------------------------------------------------------
  // Local SQLite -> Push SyncOperation
  // ---------------------------------------------------------------------------

  static SyncOperation workoutSessionToOperation(
    WorkoutSessionRow session, {
    String operation = 'CREATE',
    DateTime? clientTimestamp,
  }) {
    return SyncOperation(
      entityType: 'workout',
      entityId: session.id,
      operation: operation,
      clientTimestamp: clientTimestamp ?? session.updatedAt ?? session.startedAt,
      data: {
        'name': session.name,
        'startedAt': session.startedAt.toUtc().toIso8601String(),
        if (session.completedAt != null)
          'completedAt': session.completedAt!.toUtc().toIso8601String(),
        if (session.durationSeconds != null)
          'durationSeconds': session.durationSeconds,
        'status': workoutStatusToBackend(session.status),
        if (session.notes != null) 'notes': session.notes,
      },
    );
  }

  static SyncOperation sessionExerciseToOperation(
    SessionExerciseRow se, {
    String operation = 'CREATE',
    DateTime? clientTimestamp,
  }) {
    return SyncOperation(
      entityType: 'workout_exercise',
      entityId: se.id,
      operation: operation,
      clientTimestamp: clientTimestamp ?? se.updatedAt ?? se.createdAt,
      data: {
        'workoutId': se.sessionId,
        'exerciseId': se.exerciseId,
        'position': se.orderIndex,
        'restSeconds': se.restSeconds,
        if (se.notes != null) 'notes': se.notes,
      },
    );
  }

  static SyncOperation workoutSetToOperation(
    WorkoutSetRow set, {
    String operation = 'CREATE',
    DateTime? clientTimestamp,
  }) {
    return SyncOperation(
      entityType: 'workout_set',
      entityId: set.id,
      operation: operation,
      clientTimestamp: clientTimestamp ?? set.updatedAt ?? set.createdAt,
      data: {
        'workoutExerciseId': set.sessionExerciseId,
        'position': set.setNumber,
        'setType': setTypeToBackend(set.setType),
        'weightKg': set.weightKg,
        'reps': set.reps,
        if (set.rpe != null) 'rpe': set.rpe,
        'isCompleted': set.isCompleted,
        if (set.completedAt != null)
          'completedAt': set.completedAt!.toUtc().toIso8601String(),
        if (set.notes != null) 'notes': set.notes,
      },
    );
  }

  static SyncOperation routineToOperation(
    RoutineWithExercises r, {
    String operation = 'CREATE',
    DateTime? clientTimestamp,
  }) {
    return SyncOperation(
      entityType: 'routine',
      entityId: r.routine.id,
      operation: operation,
      clientTimestamp: clientTimestamp ?? r.routine.updatedAt ?? r.routine.createdAt,
      data: {
        'name': r.routine.name,
        if (r.routine.description != null)
          'description': r.routine.description,
        'exercises': r.exercises.map((re) => {
          'exerciseId': re.routineExercise.exerciseId,
          'position': re.routineExercise.orderIndex,
          'restSeconds': re.routineExercise.restSeconds,
          'sets': re.sets.map((s) => {
            'position': s.position,
            'setType': setTypeToBackend(s.setType),
            if (s.targetReps != null) 'targetReps': s.targetReps,
            if (s.targetWeightKg != null) 'targetWeightKg': s.targetWeightKg,
          }).toList(),
        }).toList(),
      },
    );
  }

  static SyncOperation foodItemToOperation(
    FoodItemRow food, {
    String operation = 'CREATE',
    DateTime? clientTimestamp,
  }) {
    return SyncOperation(
      entityType: 'food_item',
      entityId: food.id,
      operation: operation,
      clientTimestamp: clientTimestamp ?? food.updatedAt ?? food.createdAt,
      data: {
        'name': food.name,
        if (food.brand != null) 'brand': food.brand,
        'servingSize': food.servingSizeG,
        'servingUnit': food.householdServingUnit,
        'calories': food.caloriesKcal,
        'proteinG': food.proteinG,
        'carbsG': food.carbsG,
        'fatG': food.fatG,
        if (food.fiberG != null) 'fiberG': food.fiberG,
        'isVegetarian': food.isVeg,
        if (food.foodCategory != null) 'foodCategory': food.foodCategory,
      },
    );
  }

  static SyncOperation exerciseToOperation(
    ExerciseRow exercise, {
    String operation = 'CREATE',
    DateTime? clientTimestamp,
  }) {
    return SyncOperation(
      entityType: 'exercise',
      entityId: exercise.id,
      operation: operation,
      clientTimestamp: clientTimestamp ?? exercise.updatedAt ?? exercise.createdAt,
      data: {
        'name': exercise.name,
        if (exercise.description != null) 'description': exercise.description,
        'category': exercise.category,
        'equipment': exercise.equipment,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Backend Pull JSON -> Local Drift Companions
  // ---------------------------------------------------------------------------

  static WorkoutSessionsCompanion workoutDtoToSessionCompanion(
    Map<String, dynamic> json, {
    String? userId,
  }) {
    return WorkoutSessionsCompanion(
      id: Value(json['id'] as String),
      userId: Value(userId),
      name: Value(json['name'] as String? ?? 'Workout'),
      status: Value(workoutStatusToLocal(json['status'] as String? ?? 'IN_PROGRESS')),
      startedAt: Value(DateTime.parse(json['startedAt'] as String)),
      completedAt: Value(json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null),
      durationSeconds: Value(json['durationSeconds'] as int?),
      notes: Value(json['notes'] as String?),
      updatedAt: Value(DateTime.now()),
    );
  }

  static SessionExercisesCompanion workoutExerciseDtoToCompanion(
    String workoutId,
    Map<String, dynamic> json,
  ) {
    return SessionExercisesCompanion(
      id: Value(json['id'] as String),
      sessionId: Value(workoutId),
      exerciseId: Value(json['exerciseId'] as String),
      orderIndex: Value(json['position'] as int? ?? 0),
      restSeconds: Value(json['restSeconds'] as int? ?? 90),
      notes: Value(json['notes'] as String?),
      updatedAt: Value(DateTime.now()),
    );
  }

  static WorkoutSetsCompanion workoutSetDtoToCompanion(
    String sessionExerciseId,
    String sessionId,
    String? exerciseId,
    Map<String, dynamic> json,
  ) {
    return WorkoutSetsCompanion(
      id: Value(json['id'] as String),
      sessionId: Value(sessionId),
      sessionExerciseId: Value(sessionExerciseId),
      exerciseId: Value(exerciseId),
      setNumber: Value(json['position'] as int? ?? 1),
      setType: Value(setTypeToLocal(json['setType'] as String? ?? 'NORMAL')),
      weightKg: Value((json['weightKg'] as num?)?.toDouble() ?? 0.0),
      reps: Value(json['reps'] as int? ?? 0),
      rpe: Value((json['rpe'] as num?)?.toDouble()),
      isCompleted: Value(json['isCompleted'] as bool? ?? false),
      isPr: Value(json['isPr'] as bool? ?? false),
      completedAt: Value(json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null),
      notes: Value(json['notes'] as String?),
      updatedAt: Value(DateTime.now()),
    );
  }

  static ({
    RoutinesCompanion routine,
    List<RoutineExercisesCompanion> exercises,
    List<RoutineSetsCompanion> sets,
  }) routineDtoToCompanions(
    Map<String, dynamic> json, {
    String? userId,
  }) {
    final routineId = json['id'] as String;
    final now = DateTime.now();

    final routineComp = RoutinesCompanion(
      id: Value(routineId),
      userId: Value(userId),
      name: Value(json['name'] as String? ?? 'Routine'),
      description: Value(json['description'] as String?),
      createdAt: Value(json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : now),
      updatedAt: Value(json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : now),
    );

    final exercises = <RoutineExercisesCompanion>[];
    final sets = <RoutineSetsCompanion>[];

    final exerciseList = json['exercises'] as List<dynamic>? ?? const [];
    for (var i = 0; i < exerciseList.length; i++) {
      final exJson = exerciseList[i] as Map<String, dynamic>;
      final reId = exJson['id'] as String? ?? '${routineId}_re_$i';

      exercises.add(RoutineExercisesCompanion(
        id: Value(reId),
        routineId: Value(routineId),
        exerciseId: Value(exJson['exerciseId'] as String),
        orderIndex: Value(exJson['position'] as int? ?? i),
        restSeconds: Value(exJson['restSeconds'] as int? ?? 90),
        updatedAt: Value(now),
      ));

      final setList = exJson['sets'] as List<dynamic>? ?? const [];
      for (var j = 0; j < setList.length; j++) {
        final setJson = setList[j] as Map<String, dynamic>;
        final rsId = '${reId}_set_$j';

        sets.add(RoutineSetsCompanion(
          id: Value(rsId),
          routineExerciseId: Value(reId),
          position: Value(setJson['position'] as int? ?? (j + 1)),
          setType: Value(setTypeToLocal(setJson['setType'] as String? ?? 'NORMAL')),
          targetReps: Value(setJson['targetReps'] as int?),
          targetWeightKg: Value((setJson['targetWeightKg'] as num?)?.toDouble()),
          updatedAt: Value(now),
        ));
      }
    }

    return (routine: routineComp, exercises: exercises, sets: sets);
  }

  static FoodItemsCompanion foodItemDtoToCompanion(Map<String, dynamic> json) {
    final now = DateTime.now();
    return FoodItemsCompanion(
      id: Value(json['id'] as String),
      name: Value(json['name'] as String? ?? 'Food Item'),
      brand: Value(json['brand'] as String?),
      servingSizeG: Value((json['servingSize'] as num?)?.toDouble() ?? 100.0),
      householdServingUnit: Value(json['servingUnit'] as String? ?? 'g'),
      caloriesKcal: Value((json['calories'] as num?)?.toDouble() ?? 0.0),
      proteinG: Value((json['proteinG'] as num?)?.toDouble() ?? 0.0),
      carbsG: Value((json['carbsG'] as num?)?.toDouble() ?? 0.0),
      fatG: Value((json['fatG'] as num?)?.toDouble() ?? 0.0),
      fiberG: Value((json['fiberG'] as num?)?.toDouble()),
      isVeg: Value(json['isVegetarian'] as bool? ?? false),
      foodCategory: Value(json['foodCategory'] as String?),
      updatedAt: Value(now),
    );
  }

  static ExercisesCompanion exerciseDtoToCompanion(Map<String, dynamic> json) {
    final now = DateTime.now();
    return ExercisesCompanion(
      id: Value(json['id'] as String),
      name: Value(json['name'] as String? ?? 'Exercise'),
      description: Value(json['description'] as String?),
      category: Value(json['category'] as String? ?? 'OTHER'),
      equipment: Value(json['equipment'] as String? ?? 'NONE'),
      isCustom: Value(json['isCustom'] as bool? ?? false),
      updatedAt: Value(now),
    );
  }
}
