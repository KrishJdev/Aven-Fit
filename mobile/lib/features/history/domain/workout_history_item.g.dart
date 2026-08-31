// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutHistoryItem _$WorkoutHistoryItemFromJson(Map<String, dynamic> json) =>
    _WorkoutHistoryItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Workout',
      date: DateTime.parse(json['date'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 0,
      totalSetsCount: (json['totalSetsCount'] as num?)?.toInt() ?? 0,
      totalVolumeKg: (json['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
      prCount: (json['prCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WorkoutHistoryItemToJson(_WorkoutHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'exerciseCount': instance.exerciseCount,
      'totalSetsCount': instance.totalSetsCount,
      'totalVolumeKg': instance.totalVolumeKg,
      'prCount': instance.prCount,
    };
