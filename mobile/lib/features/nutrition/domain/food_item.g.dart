// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => _FoodItem(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String?,
  servingSizeG: (json['servingSizeG'] as num).toDouble(),
  householdServingUnit: json['householdServingUnit'] as String,
  householdUnitGramsRatio: (json['householdUnitGramsRatio'] as num?)
      ?.toDouble(),
  caloriesKcal: (json['caloriesKcal'] as num).toDouble(),
  proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
  carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
  fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
  fiberG: (json['fiberG'] as num?)?.toDouble(),
  isVeg: json['isVeg'] as bool? ?? false,
  isSatvik: json['isSatvik'] as bool? ?? false,
  foodCategory: json['foodCategory'] as String?,
  isCustom: json['isCustom'] as bool? ?? false,
  barcode: json['barcode'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FoodItemToJson(_FoodItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'brand': instance.brand,
  'servingSizeG': instance.servingSizeG,
  'householdServingUnit': instance.householdServingUnit,
  'householdUnitGramsRatio': instance.householdUnitGramsRatio,
  'caloriesKcal': instance.caloriesKcal,
  'proteinG': instance.proteinG,
  'carbsG': instance.carbsG,
  'fatG': instance.fatG,
  'fiberG': instance.fiberG,
  'isVeg': instance.isVeg,
  'isSatvik': instance.isSatvik,
  'foodCategory': instance.foodCategory,
  'isCustom': instance.isCustom,
  'barcode': instance.barcode,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
