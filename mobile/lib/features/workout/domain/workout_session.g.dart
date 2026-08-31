// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    _WorkoutSession(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      routineId: json['routineId'] as String?,
      name: json['name'] as String? ?? 'Workout',
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      status:
          $enumDecodeNullable(_$WorkoutStatusEnumMap, json['status']) ??
          WorkoutStatus.active,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => SessionExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SessionExercise>[],
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WorkoutSet>[],
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'routineId': instance.routineId,
      'name': instance.name,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'status': _$WorkoutStatusEnumMap[instance.status]!,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.active: 'active',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.discarded: 'discarded',
};
