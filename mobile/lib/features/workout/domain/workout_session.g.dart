// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    _WorkoutSession(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Workout',
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      status:
          $enumDecodeNullable(_$WorkoutStatusEnumMap, json['status']) ??
          WorkoutStatus.active,
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WorkoutSet>[],
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'status': _$WorkoutStatusEnumMap[instance.status]!,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
    };

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.active: 'active',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.discarded: 'discarded',
};
