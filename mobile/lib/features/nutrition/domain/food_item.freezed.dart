// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodItem {

 String get id; String get name; String? get brand; double get servingSizeG; String get householdServingUnit; double? get householdUnitGramsRatio; double get caloriesKcal; double get proteinG; double get carbsG; double get fatG; double? get fiberG; bool get isVeg; bool get isSatvik; String? get foodCategory; bool get isCustom; String? get barcode; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodItemCopyWith<FoodItem> get copyWith => _$FoodItemCopyWithImpl<FoodItem>(this as FoodItem, _$identity);

  /// Serializes this FoodItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FoodItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.servingSizeG, _this.servingSizeG) || other.servingSizeG == _this.servingSizeG)&&(identical(other.householdServingUnit, _this.householdServingUnit) || other.householdServingUnit == _this.householdServingUnit)&&(identical(other.householdUnitGramsRatio, _this.householdUnitGramsRatio) || other.householdUnitGramsRatio == _this.householdUnitGramsRatio)&&(identical(other.caloriesKcal, _this.caloriesKcal) || other.caloriesKcal == _this.caloriesKcal)&&(identical(other.proteinG, _this.proteinG) || other.proteinG == _this.proteinG)&&(identical(other.carbsG, _this.carbsG) || other.carbsG == _this.carbsG)&&(identical(other.fatG, _this.fatG) || other.fatG == _this.fatG)&&(identical(other.fiberG, _this.fiberG) || other.fiberG == _this.fiberG)&&(identical(other.isVeg, _this.isVeg) || other.isVeg == _this.isVeg)&&(identical(other.isSatvik, _this.isSatvik) || other.isSatvik == _this.isSatvik)&&(identical(other.foodCategory, _this.foodCategory) || other.foodCategory == _this.foodCategory)&&(identical(other.isCustom, _this.isCustom) || other.isCustom == _this.isCustom)&&(identical(other.barcode, _this.barcode) || other.barcode == _this.barcode)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FoodItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.brand,_this.servingSizeG,_this.householdServingUnit,_this.householdUnitGramsRatio,_this.caloriesKcal,_this.proteinG,_this.carbsG,_this.fatG,_this.fiberG,_this.isVeg,_this.isSatvik,_this.foodCategory,_this.isCustom,_this.barcode,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as FoodItem;
  return 'FoodItem(id: ${_this.id}, name: ${_this.name}, brand: ${_this.brand}, servingSizeG: ${_this.servingSizeG}, householdServingUnit: ${_this.householdServingUnit}, householdUnitGramsRatio: ${_this.householdUnitGramsRatio}, caloriesKcal: ${_this.caloriesKcal}, proteinG: ${_this.proteinG}, carbsG: ${_this.carbsG}, fatG: ${_this.fatG}, fiberG: ${_this.fiberG}, isVeg: ${_this.isVeg}, isSatvik: ${_this.isSatvik}, foodCategory: ${_this.foodCategory}, isCustom: ${_this.isCustom}, barcode: ${_this.barcode}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $FoodItemCopyWith<$Res>  {
  factory $FoodItemCopyWith(FoodItem value, $Res Function(FoodItem) _then) = _$FoodItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? brand, double servingSizeG, String householdServingUnit, double? householdUnitGramsRatio, double caloriesKcal, double proteinG, double carbsG, double fatG, double? fiberG, bool isVeg, bool isSatvik, String? foodCategory, bool isCustom, String? barcode, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$FoodItemCopyWithImpl<$Res>
    implements $FoodItemCopyWith<$Res> {
  _$FoodItemCopyWithImpl(this._self, this._then);

  final FoodItem _self;
  final $Res Function(FoodItem) _then;

/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brand = freezed,Object? servingSizeG = null,Object? householdServingUnit = null,Object? householdUnitGramsRatio = freezed,Object? caloriesKcal = null,Object? proteinG = null,Object? carbsG = null,Object? fatG = null,Object? fiberG = freezed,Object? isVeg = null,Object? isSatvik = null,Object? foodCategory = freezed,Object? isCustom = null,Object? barcode = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(FoodItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,servingSizeG: null == servingSizeG ? _self.servingSizeG : servingSizeG // ignore: cast_nullable_to_non_nullable
as double,householdServingUnit: null == householdServingUnit ? _self.householdServingUnit : householdServingUnit // ignore: cast_nullable_to_non_nullable
as String,householdUnitGramsRatio: freezed == householdUnitGramsRatio ? _self.householdUnitGramsRatio : householdUnitGramsRatio // ignore: cast_nullable_to_non_nullable
as double?,caloriesKcal: null == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as double,proteinG: null == proteinG ? _self.proteinG : proteinG // ignore: cast_nullable_to_non_nullable
as double,carbsG: null == carbsG ? _self.carbsG : carbsG // ignore: cast_nullable_to_non_nullable
as double,fatG: null == fatG ? _self.fatG : fatG // ignore: cast_nullable_to_non_nullable
as double,fiberG: freezed == fiberG ? _self.fiberG : fiberG // ignore: cast_nullable_to_non_nullable
as double?,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,isSatvik: null == isSatvik ? _self.isSatvik : isSatvik // ignore: cast_nullable_to_non_nullable
as bool,foodCategory: freezed == foodCategory ? _self.foodCategory : foodCategory // ignore: cast_nullable_to_non_nullable
as String?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodItem].
extension FoodItemPatterns on FoodItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodItem value)  $default,){
final _that = this;
switch (_that) {
case _FoodItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodItem value)?  $default,){
final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? brand,  double servingSizeG,  String householdServingUnit,  double? householdUnitGramsRatio,  double caloriesKcal,  double proteinG,  double carbsG,  double fatG,  double? fiberG,  bool isVeg,  bool isSatvik,  String? foodCategory,  bool isCustom,  String? barcode,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.servingSizeG,_that.householdServingUnit,_that.householdUnitGramsRatio,_that.caloriesKcal,_that.proteinG,_that.carbsG,_that.fatG,_that.fiberG,_that.isVeg,_that.isSatvik,_that.foodCategory,_that.isCustom,_that.barcode,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? brand,  double servingSizeG,  String householdServingUnit,  double? householdUnitGramsRatio,  double caloriesKcal,  double proteinG,  double carbsG,  double fatG,  double? fiberG,  bool isVeg,  bool isSatvik,  String? foodCategory,  bool isCustom,  String? barcode,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FoodItem():
return $default(_that.id,_that.name,_that.brand,_that.servingSizeG,_that.householdServingUnit,_that.householdUnitGramsRatio,_that.caloriesKcal,_that.proteinG,_that.carbsG,_that.fatG,_that.fiberG,_that.isVeg,_that.isSatvik,_that.foodCategory,_that.isCustom,_that.barcode,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? brand,  double servingSizeG,  String householdServingUnit,  double? householdUnitGramsRatio,  double caloriesKcal,  double proteinG,  double carbsG,  double fatG,  double? fiberG,  bool isVeg,  bool isSatvik,  String? foodCategory,  bool isCustom,  String? barcode,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FoodItem() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.servingSizeG,_that.householdServingUnit,_that.householdUnitGramsRatio,_that.caloriesKcal,_that.proteinG,_that.carbsG,_that.fatG,_that.fiberG,_that.isVeg,_that.isSatvik,_that.foodCategory,_that.isCustom,_that.barcode,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodItem extends FoodItem {
  const _FoodItem({required this.id, required this.name, this.brand, required this.servingSizeG, required this.householdServingUnit, this.householdUnitGramsRatio, required this.caloriesKcal, this.proteinG = 0, this.carbsG = 0, this.fatG = 0, this.fiberG, this.isVeg = false, this.isSatvik = false, this.foodCategory, this.isCustom = false, this.barcode, this.createdAt, this.updatedAt}): super._();
  factory _FoodItem.fromJson(Map<String, dynamic> json) => _$FoodItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? brand;
@override final  double servingSizeG;
@override final  String householdServingUnit;
@override final  double? householdUnitGramsRatio;
@override final  double caloriesKcal;
@override@JsonKey() final  double proteinG;
@override@JsonKey() final  double carbsG;
@override@JsonKey() final  double fatG;
@override final  double? fiberG;
@override@JsonKey() final  bool isVeg;
@override@JsonKey() final  bool isSatvik;
@override final  String? foodCategory;
@override@JsonKey() final  bool isCustom;
@override final  String? barcode;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodItemCopyWith<_FoodItem> get copyWith => __$FoodItemCopyWithImpl<_FoodItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.servingSizeG, servingSizeG) || other.servingSizeG == servingSizeG)&&(identical(other.householdServingUnit, householdServingUnit) || other.householdServingUnit == householdServingUnit)&&(identical(other.householdUnitGramsRatio, householdUnitGramsRatio) || other.householdUnitGramsRatio == householdUnitGramsRatio)&&(identical(other.caloriesKcal, caloriesKcal) || other.caloriesKcal == caloriesKcal)&&(identical(other.proteinG, proteinG) || other.proteinG == proteinG)&&(identical(other.carbsG, carbsG) || other.carbsG == carbsG)&&(identical(other.fatG, fatG) || other.fatG == fatG)&&(identical(other.fiberG, fiberG) || other.fiberG == fiberG)&&(identical(other.isVeg, isVeg) || other.isVeg == isVeg)&&(identical(other.isSatvik, isSatvik) || other.isSatvik == isSatvik)&&(identical(other.foodCategory, foodCategory) || other.foodCategory == foodCategory)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,brand,servingSizeG,householdServingUnit,householdUnitGramsRatio,caloriesKcal,proteinG,carbsG,fatG,fiberG,isVeg,isSatvik,foodCategory,isCustom,barcode,createdAt,updatedAt);
}

@override
String toString() {
    return 'FoodItem(id: $id, name: $name, brand: $brand, servingSizeG: $servingSizeG, householdServingUnit: $householdServingUnit, householdUnitGramsRatio: $householdUnitGramsRatio, caloriesKcal: $caloriesKcal, proteinG: $proteinG, carbsG: $carbsG, fatG: $fatG, fiberG: $fiberG, isVeg: $isVeg, isSatvik: $isSatvik, foodCategory: $foodCategory, isCustom: $isCustom, barcode: $barcode, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FoodItemCopyWith<$Res> implements $FoodItemCopyWith<$Res> {
  factory _$FoodItemCopyWith(_FoodItem value, $Res Function(_FoodItem) _then) = __$FoodItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? brand, double servingSizeG, String householdServingUnit, double? householdUnitGramsRatio, double caloriesKcal, double proteinG, double carbsG, double fatG, double? fiberG, bool isVeg, bool isSatvik, String? foodCategory, bool isCustom, String? barcode, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$FoodItemCopyWithImpl<$Res>
    implements _$FoodItemCopyWith<$Res> {
  __$FoodItemCopyWithImpl(this._self, this._then);

  final _FoodItem _self;
  final $Res Function(_FoodItem) _then;

/// Create a copy of FoodItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = freezed,Object? servingSizeG = null,Object? householdServingUnit = null,Object? householdUnitGramsRatio = freezed,Object? caloriesKcal = null,Object? proteinG = null,Object? carbsG = null,Object? fatG = null,Object? fiberG = freezed,Object? isVeg = null,Object? isSatvik = null,Object? foodCategory = freezed,Object? isCustom = null,Object? barcode = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_FoodItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,servingSizeG: null == servingSizeG ? _self.servingSizeG : servingSizeG // ignore: cast_nullable_to_non_nullable
as double,householdServingUnit: null == householdServingUnit ? _self.householdServingUnit : householdServingUnit // ignore: cast_nullable_to_non_nullable
as String,householdUnitGramsRatio: freezed == householdUnitGramsRatio ? _self.householdUnitGramsRatio : householdUnitGramsRatio // ignore: cast_nullable_to_non_nullable
as double?,caloriesKcal: null == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as double,proteinG: null == proteinG ? _self.proteinG : proteinG // ignore: cast_nullable_to_non_nullable
as double,carbsG: null == carbsG ? _self.carbsG : carbsG // ignore: cast_nullable_to_non_nullable
as double,fatG: null == fatG ? _self.fatG : fatG // ignore: cast_nullable_to_non_nullable
as double,fiberG: freezed == fiberG ? _self.fiberG : fiberG // ignore: cast_nullable_to_non_nullable
as double?,isVeg: null == isVeg ? _self.isVeg : isVeg // ignore: cast_nullable_to_non_nullable
as bool,isSatvik: null == isSatvik ? _self.isSatvik : isSatvik // ignore: cast_nullable_to_non_nullable
as bool,foodCategory: freezed == foodCategory ? _self.foodCategory : foodCategory // ignore: cast_nullable_to_non_nullable
as String?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
