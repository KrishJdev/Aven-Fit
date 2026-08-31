// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoutineSet _$RoutineSetFromJson(Map<String, dynamic> json) => _RoutineSet(
  id: json['id'] as String,
  routineExerciseId: json['routineExerciseId'] as String,
  position: (json['position'] as num?)?.toInt() ?? 1,
  setType:
      $enumDecodeNullable(_$SetTypeEnumMap, json['setType']) ?? SetType.normal,
  targetReps: (json['targetReps'] as num?)?.toInt(),
  targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
  targetRpe: (json['targetRpe'] as num?)?.toDouble(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RoutineSetToJson(_RoutineSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routineExerciseId': instance.routineExerciseId,
      'position': instance.position,
      'setType': _$SetTypeEnumMap[instance.setType]!,
      'targetReps': instance.targetReps,
      'targetWeightKg': instance.targetWeightKg,
      'targetRpe': instance.targetRpe,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$SetTypeEnumMap = {
  SetType.normal: 'normal',
  SetType.warmup: 'warmup',
  SetType.dropSet: 'dropSet',
  SetType.failure: 'failure',
};
