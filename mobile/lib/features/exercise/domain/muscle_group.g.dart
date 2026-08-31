// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseMuscleRef _$ExerciseMuscleRefFromJson(Map<String, dynamic> json) =>
    _ExerciseMuscleRef(
      muscleGroupId: json['muscleGroupId'] as String?,
      name: json['name'] as String,
      role:
          $enumDecodeNullable(_$MuscleRoleEnumMap, json['role']) ??
          MuscleRole.primary,
    );

Map<String, dynamic> _$ExerciseMuscleRefToJson(_ExerciseMuscleRef instance) =>
    <String, dynamic>{
      'muscleGroupId': instance.muscleGroupId,
      'name': instance.name,
      'role': _$MuscleRoleEnumMap[instance.role]!,
    };

const _$MuscleRoleEnumMap = {
  MuscleRole.primary: 'PRIMARY',
  MuscleRole.secondary: 'SECONDARY',
};

_MuscleGroup _$MuscleGroupFromJson(Map<String, dynamic> json) => _MuscleGroup(
  id: json['id'] as String,
  name: json['name'] as String,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MuscleGroupToJson(_MuscleGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'displayOrder': instance.displayOrder,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
