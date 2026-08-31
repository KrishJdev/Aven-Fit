// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pr_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PRRecord _$PRRecordFromJson(Map<String, dynamic> json) => _PRRecord(
  id: json['id'] as String,
  exerciseId: json['exerciseId'] as String,
  recordType: $enumDecode(_$RecordTypeEnumMap, json['recordType']),
  value: (json['value'] as num).toDouble(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  achievedAt: DateTime.parse(json['achievedAt'] as String),
  sessionId: json['sessionId'] as String?,
  setId: json['setId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PRRecordToJson(_PRRecord instance) => <String, dynamic>{
  'id': instance.id,
  'exerciseId': instance.exerciseId,
  'recordType': _$RecordTypeEnumMap[instance.recordType]!,
  'value': instance.value,
  'weightKg': instance.weightKg,
  'achievedAt': instance.achievedAt.toIso8601String(),
  'sessionId': instance.sessionId,
  'setId': instance.setId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$RecordTypeEnumMap = {
  RecordType.maxWeight: 'maxWeight',
  RecordType.epley1rm: 'epley1rm',
  RecordType.maxRepsAtWeight: 'maxRepsAtWeight',
  RecordType.volume: 'volume',
};
