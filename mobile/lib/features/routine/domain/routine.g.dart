// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Routine _$RoutineFromJson(Map<String, dynamic> json) => _Routine(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  userId: json['userId'] as String?,
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => RoutineExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoutineExercise>[],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RoutineToJson(_Routine instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'userId': instance.userId,
  'exercises': instance.exercises.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
