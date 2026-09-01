// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FoodDetailState {

 FoodItem get food; double get quantity;/// null → scale in the food's own household unit.
 String? get servingUnit; MealType get mealType; bool get isLogging; String? get loggedItemId; String? get errorMessage;
/// Create a copy of FoodDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodDetailStateCopyWith<FoodDetailState> get copyWith => _$FoodDetailStateCopyWithImpl<FoodDetailState>(this as FoodDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FoodDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodDetailState&&(identical(other.food, _this.food) || other.food == _this.food)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.servingUnit, _this.servingUnit) || other.servingUnit == _this.servingUnit)&&(identical(other.mealType, _this.mealType) || other.mealType == _this.mealType)&&(identical(other.isLogging, _this.isLogging) || other.isLogging == _this.isLogging)&&(identical(other.loggedItemId, _this.loggedItemId) || other.loggedItemId == _this.loggedItemId)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as FoodDetailState;
  return Object.hash(runtimeType,_this.food,_this.quantity,_this.servingUnit,_this.mealType,_this.isLogging,_this.loggedItemId,_this.errorMessage);
}

@override
String toString() {
  final _this = this as FoodDetailState;
  return 'FoodDetailState(food: ${_this.food}, quantity: ${_this.quantity}, servingUnit: ${_this.servingUnit}, mealType: ${_this.mealType}, isLogging: ${_this.isLogging}, loggedItemId: ${_this.loggedItemId}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $FoodDetailStateCopyWith<$Res>  {
  factory $FoodDetailStateCopyWith(FoodDetailState value, $Res Function(FoodDetailState) _then) = _$FoodDetailStateCopyWithImpl;
@useResult
$Res call({
 FoodItem food, double quantity, String? servingUnit, MealType mealType, bool isLogging, String? loggedItemId, String? errorMessage
});


$FoodItemCopyWith<$Res> get food;

}
/// @nodoc
class _$FoodDetailStateCopyWithImpl<$Res>
    implements $FoodDetailStateCopyWith<$Res> {
  _$FoodDetailStateCopyWithImpl(this._self, this._then);

  final FoodDetailState _self;
  final $Res Function(FoodDetailState) _then;

/// Create a copy of FoodDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? food = null,Object? quantity = null,Object? servingUnit = freezed,Object? mealType = null,Object? isLogging = null,Object? loggedItemId = freezed,Object? errorMessage = freezed,}) {
  return _then(FoodDetailState(
food: null == food ? _self.food : food // ignore: cast_nullable_to_non_nullable
as FoodItem,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,servingUnit: freezed == servingUnit ? _self.servingUnit : servingUnit // ignore: cast_nullable_to_non_nullable
as String?,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,isLogging: null == isLogging ? _self.isLogging : isLogging // ignore: cast_nullable_to_non_nullable
as bool,loggedItemId: freezed == loggedItemId ? _self.loggedItemId : loggedItemId // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of FoodDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodItemCopyWith<$Res> get food {
  
  return $FoodItemCopyWith<$Res>(_self.food, (value) {
    return _then(_self.copyWith(food: value));
  });
}
}


/// Adds pattern-matching-related methods to [FoodDetailState].
extension FoodDetailStatePatterns on FoodDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodDetailState value)  $default,){
final _that = this;
switch (_that) {
case _FoodDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _FoodDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FoodItem food,  double quantity,  String? servingUnit,  MealType mealType,  bool isLogging,  String? loggedItemId,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodDetailState() when $default != null:
return $default(_that.food,_that.quantity,_that.servingUnit,_that.mealType,_that.isLogging,_that.loggedItemId,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FoodItem food,  double quantity,  String? servingUnit,  MealType mealType,  bool isLogging,  String? loggedItemId,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _FoodDetailState():
return $default(_that.food,_that.quantity,_that.servingUnit,_that.mealType,_that.isLogging,_that.loggedItemId,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FoodItem food,  double quantity,  String? servingUnit,  MealType mealType,  bool isLogging,  String? loggedItemId,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _FoodDetailState() when $default != null:
return $default(_that.food,_that.quantity,_that.servingUnit,_that.mealType,_that.isLogging,_that.loggedItemId,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _FoodDetailState extends FoodDetailState {
  const _FoodDetailState({required this.food, this.quantity = 1, this.servingUnit, this.mealType = MealType.snack, this.isLogging = false, this.loggedItemId, this.errorMessage}): super._();
  

@override final  FoodItem food;
@override@JsonKey() final  double quantity;
/// null → scale in the food's own household unit.
@override final  String? servingUnit;
@override@JsonKey() final  MealType mealType;
@override@JsonKey() final  bool isLogging;
@override final  String? loggedItemId;
@override final  String? errorMessage;

/// Create a copy of FoodDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodDetailStateCopyWith<_FoodDetailState> get copyWith => __$FoodDetailStateCopyWithImpl<_FoodDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodDetailState&&(identical(other.food, food) || other.food == food)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.servingUnit, servingUnit) || other.servingUnit == servingUnit)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.isLogging, isLogging) || other.isLogging == isLogging)&&(identical(other.loggedItemId, loggedItemId) || other.loggedItemId == loggedItemId)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,food,quantity,servingUnit,mealType,isLogging,loggedItemId,errorMessage);
}

@override
String toString() {
    return 'FoodDetailState(food: $food, quantity: $quantity, servingUnit: $servingUnit, mealType: $mealType, isLogging: $isLogging, loggedItemId: $loggedItemId, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$FoodDetailStateCopyWith<$Res> implements $FoodDetailStateCopyWith<$Res> {
  factory _$FoodDetailStateCopyWith(_FoodDetailState value, $Res Function(_FoodDetailState) _then) = __$FoodDetailStateCopyWithImpl;
@override @useResult
$Res call({
 FoodItem food, double quantity, String? servingUnit, MealType mealType, bool isLogging, String? loggedItemId, String? errorMessage
});


@override $FoodItemCopyWith<$Res> get food;

}
/// @nodoc
class __$FoodDetailStateCopyWithImpl<$Res>
    implements _$FoodDetailStateCopyWith<$Res> {
  __$FoodDetailStateCopyWithImpl(this._self, this._then);

  final _FoodDetailState _self;
  final $Res Function(_FoodDetailState) _then;

/// Create a copy of FoodDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? food = null,Object? quantity = null,Object? servingUnit = freezed,Object? mealType = null,Object? isLogging = null,Object? loggedItemId = freezed,Object? errorMessage = freezed,}) {
  return _then(_FoodDetailState(
food: null == food ? _self.food : food // ignore: cast_nullable_to_non_nullable
as FoodItem,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,servingUnit: freezed == servingUnit ? _self.servingUnit : servingUnit // ignore: cast_nullable_to_non_nullable
as String?,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,isLogging: null == isLogging ? _self.isLogging : isLogging // ignore: cast_nullable_to_non_nullable
as bool,loggedItemId: freezed == loggedItemId ? _self.loggedItemId : loggedItemId // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of FoodDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodItemCopyWith<$Res> get food {
  
  return $FoodItemCopyWith<$Res>(_self.food, (value) {
    return _then(_self.copyWith(food: value));
  });
}
}

// dart format on
