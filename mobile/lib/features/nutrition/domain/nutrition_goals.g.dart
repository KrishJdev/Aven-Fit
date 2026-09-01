// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_goals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NutritionGoals _$NutritionGoalsFromJson(Map<String, dynamic> json) =>
    _NutritionGoals(
      id: json['id'] as String,
      targetCalories: (json['targetCalories'] as num).toDouble(),
      targetProteinG: (json['targetProteinG'] as num?)?.toDouble() ?? 0,
      targetCarbsG: (json['targetCarbsG'] as num?)?.toDouble() ?? 0,
      targetFatG: (json['targetFatG'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NutritionGoalsToJson(_NutritionGoals instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetCalories': instance.targetCalories,
      'targetProteinG': instance.targetProteinG,
      'targetCarbsG': instance.targetCarbsG,
      'targetFatG': instance.targetFatG,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
