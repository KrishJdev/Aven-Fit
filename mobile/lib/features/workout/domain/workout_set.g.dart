// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => _WorkoutSet(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  exerciseId: json['exerciseId'] as String,
  setNumber: (json['setNumber'] as num).toInt(),
  weightKg: (json['weightKg'] as num).toDouble(),
  reps: (json['reps'] as num).toInt(),
  isCompleted: json['isCompleted'] as bool? ?? false,
  type: $enumDecodeNullable(_$SetTypeEnumMap, json['type']) ?? SetType.normal,
  rpe: (json['rpe'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WorkoutSetToJson(_WorkoutSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'exerciseId': instance.exerciseId,
      'setNumber': instance.setNumber,
      'weightKg': instance.weightKg,
      'reps': instance.reps,
      'isCompleted': instance.isCompleted,
      'type': _$SetTypeEnumMap[instance.type]!,
      'rpe': instance.rpe,
    };

const _$SetTypeEnumMap = {
  SetType.normal: 'normal',
  SetType.warmup: 'warmup',
  SetType.dropSet: 'dropSet',
  SetType.failure: 'failure',
};
