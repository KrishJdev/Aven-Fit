// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoutineExercise _$RoutineExerciseFromJson(Map<String, dynamic> json) =>
    _RoutineExercise(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      exerciseId: json['exerciseId'] as String,
      exercise: json['exercise'] == null
          ? null
          : Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      exerciseName: json['exerciseName'] as String?,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 90,
      notes: json['notes'] as String?,
      targetSetsCount: (json['targetSetsCount'] as num?)?.toInt(),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      targetReps: (json['targetReps'] as num?)?.toInt(),
      targetRpe: (json['targetRpe'] as num?)?.toDouble(),
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => RoutineSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RoutineSet>[],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RoutineExerciseToJson(_RoutineExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routineId': instance.routineId,
      'exerciseId': instance.exerciseId,
      'exercise': instance.exercise?.toJson(),
      'exerciseName': instance.exerciseName,
      'orderIndex': instance.orderIndex,
      'restSeconds': instance.restSeconds,
      'notes': instance.notes,
      'targetSetsCount': instance.targetSetsCount,
      'targetWeightKg': instance.targetWeightKg,
      'targetReps': instance.targetReps,
      'targetRpe': instance.targetRpe,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
