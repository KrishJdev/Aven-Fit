// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logged_meal_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoggedMealItem {

 String get id; DateTime get date; MealType get mealType; String get foodItemId; double get quantityServings; String get servingUnitUsed; double get calculatedKcal; double get calculatedProteinG; double get calculatedCarbsG; double get calculatedFatG; double? get calculatedFiberG; DateTime? get loggedAt; String? get notes; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of LoggedMealItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoggedMealItemCopyWith<LoggedMealItem> get copyWith => _$LoggedMealItemCopyWithImpl<LoggedMealItem>(this as LoggedMealItem, _$identity);

  /// Serializes this LoggedMealItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoggedMealItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoggedMealItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.mealType, _this.mealType) || other.mealType == _this.mealType)&&(identical(other.foodItemId, _this.foodItemId) || other.foodItemId == _this.foodItemId)&&(identical(other.quantityServings, _this.quantityServings) || other.quantityServings == _this.quantityServings)&&(identical(other.servingUnitUsed, _this.servingUnitUsed) || other.servingUnitUsed == _this.servingUnitUsed)&&(identical(other.calculatedKcal, _this.calculatedKcal) || other.calculatedKcal == _this.calculatedKcal)&&(identical(other.calculatedProteinG, _this.calculatedProteinG) || other.calculatedProteinG == _this.calculatedProteinG)&&(identical(other.calculatedCarbsG, _this.calculatedCarbsG) || other.calculatedCarbsG == _this.calculatedCarbsG)&&(identical(other.calculatedFatG, _this.calculatedFatG) || other.calculatedFatG == _this.calculatedFatG)&&(identical(other.calculatedFiberG, _this.calculatedFiberG) || other.calculatedFiberG == _this.calculatedFiberG)&&(identical(other.loggedAt, _this.loggedAt) || other.loggedAt == _this.loggedAt)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoggedMealItem;
  return Object.hash(runtimeType,_this.id,_this.date,_this.mealType,_this.foodItemId,_this.quantityServings,_this.servingUnitUsed,_this.calculatedKcal,_this.calculatedProteinG,_this.calculatedCarbsG,_this.calculatedFatG,_this.calculatedFiberG,_this.loggedAt,_this.notes,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as LoggedMealItem;
  return 'LoggedMealItem(id: ${_this.id}, date: ${_this.date}, mealType: ${_this.mealType}, foodItemId: ${_this.foodItemId}, quantityServings: ${_this.quantityServings}, servingUnitUsed: ${_this.servingUnitUsed}, calculatedKcal: ${_this.calculatedKcal}, calculatedProteinG: ${_this.calculatedProteinG}, calculatedCarbsG: ${_this.calculatedCarbsG}, calculatedFatG: ${_this.calculatedFatG}, calculatedFiberG: ${_this.calculatedFiberG}, loggedAt: ${_this.loggedAt}, notes: ${_this.notes}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $LoggedMealItemCopyWith<$Res>  {
  factory $LoggedMealItemCopyWith(LoggedMealItem value, $Res Function(LoggedMealItem) _then) = _$LoggedMealItemCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, MealType mealType, String foodItemId, double quantityServings, String servingUnitUsed, double calculatedKcal, double calculatedProteinG, double calculatedCarbsG, double calculatedFatG, double? calculatedFiberG, DateTime? loggedAt, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$LoggedMealItemCopyWithImpl<$Res>
    implements $LoggedMealItemCopyWith<$Res> {
  _$LoggedMealItemCopyWithImpl(this._self, this._then);

  final LoggedMealItem _self;
  final $Res Function(LoggedMealItem) _then;

/// Create a copy of LoggedMealItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? mealType = null,Object? foodItemId = null,Object? quantityServings = null,Object? servingUnitUsed = null,Object? calculatedKcal = null,Object? calculatedProteinG = null,Object? calculatedCarbsG = null,Object? calculatedFatG = null,Object? calculatedFiberG = freezed,Object? loggedAt = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(LoggedMealItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,foodItemId: null == foodItemId ? _self.foodItemId : foodItemId // ignore: cast_nullable_to_non_nullable
as String,quantityServings: null == quantityServings ? _self.quantityServings : quantityServings // ignore: cast_nullable_to_non_nullable
as double,servingUnitUsed: null == servingUnitUsed ? _self.servingUnitUsed : servingUnitUsed // ignore: cast_nullable_to_non_nullable
as String,calculatedKcal: null == calculatedKcal ? _self.calculatedKcal : calculatedKcal // ignore: cast_nullable_to_non_nullable
as double,calculatedProteinG: null == calculatedProteinG ? _self.calculatedProteinG : calculatedProteinG // ignore: cast_nullable_to_non_nullable
as double,calculatedCarbsG: null == calculatedCarbsG ? _self.calculatedCarbsG : calculatedCarbsG // ignore: cast_nullable_to_non_nullable
as double,calculatedFatG: null == calculatedFatG ? _self.calculatedFatG : calculatedFatG // ignore: cast_nullable_to_non_nullable
as double,calculatedFiberG: freezed == calculatedFiberG ? _self.calculatedFiberG : calculatedFiberG // ignore: cast_nullable_to_non_nullable
as double?,loggedAt: freezed == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoggedMealItem].
extension LoggedMealItemPatterns on LoggedMealItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoggedMealItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoggedMealItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoggedMealItem value)  $default,){
final _that = this;
switch (_that) {
case _LoggedMealItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoggedMealItem value)?  $default,){
final _that = this;
switch (_that) {
case _LoggedMealItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  MealType mealType,  String foodItemId,  double quantityServings,  String servingUnitUsed,  double calculatedKcal,  double calculatedProteinG,  double calculatedCarbsG,  double calculatedFatG,  double? calculatedFiberG,  DateTime? loggedAt,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoggedMealItem() when $default != null:
return $default(_that.id,_that.date,_that.mealType,_that.foodItemId,_that.quantityServings,_that.servingUnitUsed,_that.calculatedKcal,_that.calculatedProteinG,_that.calculatedCarbsG,_that.calculatedFatG,_that.calculatedFiberG,_that.loggedAt,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  MealType mealType,  String foodItemId,  double quantityServings,  String servingUnitUsed,  double calculatedKcal,  double calculatedProteinG,  double calculatedCarbsG,  double calculatedFatG,  double? calculatedFiberG,  DateTime? loggedAt,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _LoggedMealItem():
return $default(_that.id,_that.date,_that.mealType,_that.foodItemId,_that.quantityServings,_that.servingUnitUsed,_that.calculatedKcal,_that.calculatedProteinG,_that.calculatedCarbsG,_that.calculatedFatG,_that.calculatedFiberG,_that.loggedAt,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  MealType mealType,  String foodItemId,  double quantityServings,  String servingUnitUsed,  double calculatedKcal,  double calculatedProteinG,  double calculatedCarbsG,  double calculatedFatG,  double? calculatedFiberG,  DateTime? loggedAt,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _LoggedMealItem() when $default != null:
return $default(_that.id,_that.date,_that.mealType,_that.foodItemId,_that.quantityServings,_that.servingUnitUsed,_that.calculatedKcal,_that.calculatedProteinG,_that.calculatedCarbsG,_that.calculatedFatG,_that.calculatedFiberG,_that.loggedAt,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoggedMealItem implements LoggedMealItem {
  const _LoggedMealItem({required this.id, required this.date, required this.mealType, required this.foodItemId, required this.quantityServings, required this.servingUnitUsed, required this.calculatedKcal, this.calculatedProteinG = 0, this.calculatedCarbsG = 0, this.calculatedFatG = 0, this.calculatedFiberG, this.loggedAt, this.notes, this.createdAt, this.updatedAt});
  factory _LoggedMealItem.fromJson(Map<String, dynamic> json) => _$LoggedMealItemFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  MealType mealType;
@override final  String foodItemId;
@override final  double quantityServings;
@override final  String servingUnitUsed;
@override final  double calculatedKcal;
@override@JsonKey() final  double calculatedProteinG;
@override@JsonKey() final  double calculatedCarbsG;
@override@JsonKey() final  double calculatedFatG;
@override final  double? calculatedFiberG;
@override final  DateTime? loggedAt;
@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of LoggedMealItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoggedMealItemCopyWith<_LoggedMealItem> get copyWith => __$LoggedMealItemCopyWithImpl<_LoggedMealItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoggedMealItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoggedMealItem&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.foodItemId, foodItemId) || other.foodItemId == foodItemId)&&(identical(other.quantityServings, quantityServings) || other.quantityServings == quantityServings)&&(identical(other.servingUnitUsed, servingUnitUsed) || other.servingUnitUsed == servingUnitUsed)&&(identical(other.calculatedKcal, calculatedKcal) || other.calculatedKcal == calculatedKcal)&&(identical(other.calculatedProteinG, calculatedProteinG) || other.calculatedProteinG == calculatedProteinG)&&(identical(other.calculatedCarbsG, calculatedCarbsG) || other.calculatedCarbsG == calculatedCarbsG)&&(identical(other.calculatedFatG, calculatedFatG) || other.calculatedFatG == calculatedFatG)&&(identical(other.calculatedFiberG, calculatedFiberG) || other.calculatedFiberG == calculatedFiberG)&&(identical(other.loggedAt, loggedAt) || other.loggedAt == loggedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,date,mealType,foodItemId,quantityServings,servingUnitUsed,calculatedKcal,calculatedProteinG,calculatedCarbsG,calculatedFatG,calculatedFiberG,loggedAt,notes,createdAt,updatedAt);
}

@override
String toString() {
    return 'LoggedMealItem(id: $id, date: $date, mealType: $mealType, foodItemId: $foodItemId, quantityServings: $quantityServings, servingUnitUsed: $servingUnitUsed, calculatedKcal: $calculatedKcal, calculatedProteinG: $calculatedProteinG, calculatedCarbsG: $calculatedCarbsG, calculatedFatG: $calculatedFatG, calculatedFiberG: $calculatedFiberG, loggedAt: $loggedAt, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LoggedMealItemCopyWith<$Res> implements $LoggedMealItemCopyWith<$Res> {
  factory _$LoggedMealItemCopyWith(_LoggedMealItem value, $Res Function(_LoggedMealItem) _then) = __$LoggedMealItemCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, MealType mealType, String foodItemId, double quantityServings, String servingUnitUsed, double calculatedKcal, double calculatedProteinG, double calculatedCarbsG, double calculatedFatG, double? calculatedFiberG, DateTime? loggedAt, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$LoggedMealItemCopyWithImpl<$Res>
    implements _$LoggedMealItemCopyWith<$Res> {
  __$LoggedMealItemCopyWithImpl(this._self, this._then);

  final _LoggedMealItem _self;
  final $Res Function(_LoggedMealItem) _then;

/// Create a copy of LoggedMealItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? mealType = null,Object? foodItemId = null,Object? quantityServings = null,Object? servingUnitUsed = null,Object? calculatedKcal = null,Object? calculatedProteinG = null,Object? calculatedCarbsG = null,Object? calculatedFatG = null,Object? calculatedFiberG = freezed,Object? loggedAt = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_LoggedMealItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,foodItemId: null == foodItemId ? _self.foodItemId : foodItemId // ignore: cast_nullable_to_non_nullable
as String,quantityServings: null == quantityServings ? _self.quantityServings : quantityServings // ignore: cast_nullable_to_non_nullable
as double,servingUnitUsed: null == servingUnitUsed ? _self.servingUnitUsed : servingUnitUsed // ignore: cast_nullable_to_non_nullable
as String,calculatedKcal: null == calculatedKcal ? _self.calculatedKcal : calculatedKcal // ignore: cast_nullable_to_non_nullable
as double,calculatedProteinG: null == calculatedProteinG ? _self.calculatedProteinG : calculatedProteinG // ignore: cast_nullable_to_non_nullable
as double,calculatedCarbsG: null == calculatedCarbsG ? _self.calculatedCarbsG : calculatedCarbsG // ignore: cast_nullable_to_non_nullable
as double,calculatedFatG: null == calculatedFatG ? _self.calculatedFatG : calculatedFatG // ignore: cast_nullable_to_non_nullable
as double,calculatedFiberG: freezed == calculatedFiberG ? _self.calculatedFiberG : calculatedFiberG // ignore: cast_nullable_to_non_nullable
as double?,loggedAt: freezed == loggedAt ? _self.loggedAt : loggedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
