// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  category:
      $enumDecodeNullable(_$ExerciseCategoryEnumMap, json['category']) ??
      ExerciseCategory.other,
  equipment:
      $enumDecodeNullable(_$EquipmentEnumMap, json['equipment']) ??
      Equipment.none,
  isCustom: json['isCustom'] as bool? ?? false,
  isFavourite: json['isFavourite'] as bool? ?? false,
  isTimeBased: json['isTimeBased'] as bool? ?? false,
  isCardio: json['isCardio'] as bool? ?? false,
  primaryMuscle: json['primaryMuscle'] as String?,
  secondaryMuscles:
      (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  muscleRefs:
      (json['muscleRefs'] as List<dynamic>?)
          ?.map((e) => ExerciseMuscleRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ExerciseMuscleRef>[],
  createdById: json['createdById'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': _$ExerciseCategoryEnumMap[instance.category]!,
  'equipment': _$EquipmentEnumMap[instance.equipment]!,
  'isCustom': instance.isCustom,
  'isFavourite': instance.isFavourite,
  'isTimeBased': instance.isTimeBased,
  'isCardio': instance.isCardio,
  'primaryMuscle': instance.primaryMuscle,
  'secondaryMuscles': instance.secondaryMuscles,
  'muscleRefs': instance.muscleRefs.map((e) => e.toJson()).toList(),
  'createdById': instance.createdById,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$ExerciseCategoryEnumMap = {
  ExerciseCategory.barbell: 'BARBELL',
  ExerciseCategory.dumbbell: 'DUMBBELL',
  ExerciseCategory.machine: 'MACHINE',
  ExerciseCategory.cable: 'CABLE',
  ExerciseCategory.bodyweight: 'BODYWEIGHT',
  ExerciseCategory.cardio: 'CARDIO',
  ExerciseCategory.stretching: 'STRETCHING',
  ExerciseCategory.other: 'OTHER',
};

const _$EquipmentEnumMap = {
  Equipment.barbell: 'BARBELL',
  Equipment.dumbbell: 'DUMBBELL',
  Equipment.machine: 'MACHINE',
  Equipment.cable: 'CABLE',
  Equipment.kettlebell: 'KETTLEBELL',
  Equipment.band: 'BAND',
  Equipment.bodyweight: 'BODYWEIGHT',
  Equipment.smithMachine: 'SMITH_MACHINE',
  Equipment.other: 'OTHER',
  Equipment.none: 'NONE',
};
