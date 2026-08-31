// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ghost_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GhostSet _$GhostSetFromJson(Map<String, dynamic> json) => _GhostSet(
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  reps: (json['reps'] as num?)?.toInt(),
  rpe: (json['rpe'] as num?)?.toDouble(),
  setType:
      $enumDecodeNullable(_$SetTypeEnumMap, json['setType']) ?? SetType.normal,
  source:
      $enumDecodeNullable(_$GhostSourceEnumMap, json['source']) ??
      GhostSource.none,
);

Map<String, dynamic> _$GhostSetToJson(_GhostSet instance) => <String, dynamic>{
  'weightKg': instance.weightKg,
  'reps': instance.reps,
  'rpe': instance.rpe,
  'setType': _$SetTypeEnumMap[instance.setType]!,
  'source': _$GhostSourceEnumMap[instance.source]!,
};

const _$SetTypeEnumMap = {
  SetType.normal: 'normal',
  SetType.warmup: 'warmup',
  SetType.dropSet: 'dropSet',
  SetType.failure: 'failure',
};

const _$GhostSourceEnumMap = {
  GhostSource.history: 'history',
  GhostSource.routineTarget: 'routineTarget',
  GhostSource.previousSet: 'previousSet',
  GhostSource.none: 'none',
};
