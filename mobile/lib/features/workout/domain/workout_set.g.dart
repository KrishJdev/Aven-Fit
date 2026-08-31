// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => _WorkoutSet(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  sessionExerciseId: json['sessionExerciseId'] as String,
  exerciseId: json['exerciseId'] as String?,
  setNumber: (json['setNumber'] as num).toInt(),
  weightKg: (json['weightKg'] as num).toDouble(),
  reps: (json['reps'] as num).toInt(),
  isCompleted: json['isCompleted'] as bool? ?? false,
  type: $enumDecodeNullable(_$SetTypeEnumMap, json['type']) ?? SetType.normal,
  rpe: (json['rpe'] as num?)?.toDouble(),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  isPr: json['isPr'] as bool? ?? false,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$WorkoutSetToJson(_WorkoutSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'sessionExerciseId': instance.sessionExerciseId,
      'exerciseId': instance.exerciseId,
      'setNumber': instance.setNumber,
      'weightKg': instance.weightKg,
      'reps': instance.reps,
      'isCompleted': instance.isCompleted,
      'type': _$SetTypeEnumMap[instance.type]!,
      'rpe': instance.rpe,
      'completedAt': instance.completedAt?.toIso8601String(),
      'isPr': instance.isPr,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$SetTypeEnumMap = {
  SetType.normal: 'normal',
  SetType.warmup: 'warmup',
  SetType.dropSet: 'dropSet',
  SetType.failure: 'failure',
};
