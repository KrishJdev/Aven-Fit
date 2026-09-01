// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logged_meal_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoggedMealItem _$LoggedMealItemFromJson(Map<String, dynamic> json) =>
    _LoggedMealItem(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      foodItemId: json['foodItemId'] as String,
      quantityServings: (json['quantityServings'] as num).toDouble(),
      servingUnitUsed: json['servingUnitUsed'] as String,
      calculatedKcal: (json['calculatedKcal'] as num).toDouble(),
      calculatedProteinG: (json['calculatedProteinG'] as num?)?.toDouble() ?? 0,
      calculatedCarbsG: (json['calculatedCarbsG'] as num?)?.toDouble() ?? 0,
      calculatedFatG: (json['calculatedFatG'] as num?)?.toDouble() ?? 0,
      calculatedFiberG: (json['calculatedFiberG'] as num?)?.toDouble(),
      loggedAt: json['loggedAt'] == null
          ? null
          : DateTime.parse(json['loggedAt'] as String),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LoggedMealItemToJson(_LoggedMealItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'foodItemId': instance.foodItemId,
      'quantityServings': instance.quantityServings,
      'servingUnitUsed': instance.servingUnitUsed,
      'calculatedKcal': instance.calculatedKcal,
      'calculatedProteinG': instance.calculatedProteinG,
      'calculatedCarbsG': instance.calculatedCarbsG,
      'calculatedFatG': instance.calculatedFatG,
      'calculatedFiberG': instance.calculatedFiberG,
      'loggedAt': instance.loggedAt?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
  MealType.preWorkout: 'preWorkout',
  MealType.postWorkout: 'postWorkout',
};
