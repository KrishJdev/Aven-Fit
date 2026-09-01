// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_goals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NutritionGoals {

 String get id; double get targetCalories; double get targetProteinG; double get targetCarbsG; double get targetFatG; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionGoalsCopyWith<NutritionGoals> get copyWith => _$NutritionGoalsCopyWithImpl<NutritionGoals>(this as NutritionGoals, _$identity);

  /// Serializes this NutritionGoals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NutritionGoals;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionGoals&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.targetCalories, _this.targetCalories) || other.targetCalories == _this.targetCalories)&&(identical(other.targetProteinG, _this.targetProteinG) || other.targetProteinG == _this.targetProteinG)&&(identical(other.targetCarbsG, _this.targetCarbsG) || other.targetCarbsG == _this.targetCarbsG)&&(identical(other.targetFatG, _this.targetFatG) || other.targetFatG == _this.targetFatG)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NutritionGoals;
  return Object.hash(runtimeType,_this.id,_this.targetCalories,_this.targetProteinG,_this.targetCarbsG,_this.targetFatG,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as NutritionGoals;
  return 'NutritionGoals(id: ${_this.id}, targetCalories: ${_this.targetCalories}, targetProteinG: ${_this.targetProteinG}, targetCarbsG: ${_this.targetCarbsG}, targetFatG: ${_this.targetFatG}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $NutritionGoalsCopyWith<$Res>  {
  factory $NutritionGoalsCopyWith(NutritionGoals value, $Res Function(NutritionGoals) _then) = _$NutritionGoalsCopyWithImpl;
@useResult
$Res call({
 String id, double targetCalories, double targetProteinG, double targetCarbsG, double targetFatG, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$NutritionGoalsCopyWithImpl<$Res>
    implements $NutritionGoalsCopyWith<$Res> {
  _$NutritionGoalsCopyWithImpl(this._self, this._then);

  final NutritionGoals _self;
  final $Res Function(NutritionGoals) _then;

/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetCalories = null,Object? targetProteinG = null,Object? targetCarbsG = null,Object? targetFatG = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(NutritionGoals(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetCalories: null == targetCalories ? _self.targetCalories : targetCalories // ignore: cast_nullable_to_non_nullable
as double,targetProteinG: null == targetProteinG ? _self.targetProteinG : targetProteinG // ignore: cast_nullable_to_non_nullable
as double,targetCarbsG: null == targetCarbsG ? _self.targetCarbsG : targetCarbsG // ignore: cast_nullable_to_non_nullable
as double,targetFatG: null == targetFatG ? _self.targetFatG : targetFatG // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NutritionGoals].
extension NutritionGoalsPatterns on NutritionGoals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionGoals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionGoals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionGoals value)  $default,){
final _that = this;
switch (_that) {
case _NutritionGoals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionGoals value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionGoals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double targetCalories,  double targetProteinG,  double targetCarbsG,  double targetFatG,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionGoals() when $default != null:
return $default(_that.id,_that.targetCalories,_that.targetProteinG,_that.targetCarbsG,_that.targetFatG,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double targetCalories,  double targetProteinG,  double targetCarbsG,  double targetFatG,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NutritionGoals():
return $default(_that.id,_that.targetCalories,_that.targetProteinG,_that.targetCarbsG,_that.targetFatG,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double targetCalories,  double targetProteinG,  double targetCarbsG,  double targetFatG,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NutritionGoals() when $default != null:
return $default(_that.id,_that.targetCalories,_that.targetProteinG,_that.targetCarbsG,_that.targetFatG,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NutritionGoals implements NutritionGoals {
  const _NutritionGoals({required this.id, required this.targetCalories, this.targetProteinG = 0, this.targetCarbsG = 0, this.targetFatG = 0, this.createdAt, this.updatedAt});
  factory _NutritionGoals.fromJson(Map<String, dynamic> json) => _$NutritionGoalsFromJson(json);

@override final  String id;
@override final  double targetCalories;
@override@JsonKey() final  double targetProteinG;
@override@JsonKey() final  double targetCarbsG;
@override@JsonKey() final  double targetFatG;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionGoalsCopyWith<_NutritionGoals> get copyWith => __$NutritionGoalsCopyWithImpl<_NutritionGoals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NutritionGoalsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionGoals&&(identical(other.id, id) || other.id == id)&&(identical(other.targetCalories, targetCalories) || other.targetCalories == targetCalories)&&(identical(other.targetProteinG, targetProteinG) || other.targetProteinG == targetProteinG)&&(identical(other.targetCarbsG, targetCarbsG) || other.targetCarbsG == targetCarbsG)&&(identical(other.targetFatG, targetFatG) || other.targetFatG == targetFatG)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,targetCalories,targetProteinG,targetCarbsG,targetFatG,createdAt,updatedAt);
}

@override
String toString() {
    return 'NutritionGoals(id: $id, targetCalories: $targetCalories, targetProteinG: $targetProteinG, targetCarbsG: $targetCarbsG, targetFatG: $targetFatG, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NutritionGoalsCopyWith<$Res> implements $NutritionGoalsCopyWith<$Res> {
  factory _$NutritionGoalsCopyWith(_NutritionGoals value, $Res Function(_NutritionGoals) _then) = __$NutritionGoalsCopyWithImpl;
@override @useResult
$Res call({
 String id, double targetCalories, double targetProteinG, double targetCarbsG, double targetFatG, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$NutritionGoalsCopyWithImpl<$Res>
    implements _$NutritionGoalsCopyWith<$Res> {
  __$NutritionGoalsCopyWithImpl(this._self, this._then);

  final _NutritionGoals _self;
  final $Res Function(_NutritionGoals) _then;

/// Create a copy of NutritionGoals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetCalories = null,Object? targetProteinG = null,Object? targetCarbsG = null,Object? targetFatG = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_NutritionGoals(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetCalories: null == targetCalories ? _self.targetCalories : targetCalories // ignore: cast_nullable_to_non_nullable
as double,targetProteinG: null == targetProteinG ? _self.targetProteinG : targetProteinG // ignore: cast_nullable_to_non_nullable
as double,targetCarbsG: null == targetCarbsG ? _self.targetCarbsG : targetCarbsG // ignore: cast_nullable_to_non_nullable
as double,targetFatG: null == targetFatG ? _self.targetFatG : targetFatG // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
