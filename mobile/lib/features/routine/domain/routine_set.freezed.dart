// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutineSet {

 String get id; String get routineExerciseId; int get position; SetType get setType; int? get targetReps; double? get targetWeightKg; double? get targetRpe; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RoutineSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineSetCopyWith<RoutineSet> get copyWith => _$RoutineSetCopyWithImpl<RoutineSet>(this as RoutineSet, _$identity);

  /// Serializes this RoutineSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoutineSet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineSet&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.routineExerciseId, _this.routineExerciseId) || other.routineExerciseId == _this.routineExerciseId)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.setType, _this.setType) || other.setType == _this.setType)&&(identical(other.targetReps, _this.targetReps) || other.targetReps == _this.targetReps)&&(identical(other.targetWeightKg, _this.targetWeightKg) || other.targetWeightKg == _this.targetWeightKg)&&(identical(other.targetRpe, _this.targetRpe) || other.targetRpe == _this.targetRpe)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoutineSet;
  return Object.hash(runtimeType,_this.id,_this.routineExerciseId,_this.position,_this.setType,_this.targetReps,_this.targetWeightKg,_this.targetRpe,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as RoutineSet;
  return 'RoutineSet(id: ${_this.id}, routineExerciseId: ${_this.routineExerciseId}, position: ${_this.position}, setType: ${_this.setType}, targetReps: ${_this.targetReps}, targetWeightKg: ${_this.targetWeightKg}, targetRpe: ${_this.targetRpe}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $RoutineSetCopyWith<$Res>  {
  factory $RoutineSetCopyWith(RoutineSet value, $Res Function(RoutineSet) _then) = _$RoutineSetCopyWithImpl;
@useResult
$Res call({
 String id, String routineExerciseId, int position, SetType setType, int? targetReps, double? targetWeightKg, double? targetRpe, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$RoutineSetCopyWithImpl<$Res>
    implements $RoutineSetCopyWith<$Res> {
  _$RoutineSetCopyWithImpl(this._self, this._then);

  final RoutineSet _self;
  final $Res Function(RoutineSet) _then;

/// Create a copy of RoutineSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routineExerciseId = null,Object? position = null,Object? setType = null,Object? targetReps = freezed,Object? targetWeightKg = freezed,Object? targetRpe = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(RoutineSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineExerciseId: null == routineExerciseId ? _self.routineExerciseId : routineExerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,setType: null == setType ? _self.setType : setType // ignore: cast_nullable_to_non_nullable
as SetType,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,targetWeightKg: freezed == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,targetRpe: freezed == targetRpe ? _self.targetRpe : targetRpe // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineSet].
extension RoutineSetPatterns on RoutineSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineSet value)  $default,){
final _that = this;
switch (_that) {
case _RoutineSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineSet value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String routineExerciseId,  int position,  SetType setType,  int? targetReps,  double? targetWeightKg,  double? targetRpe,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineSet() when $default != null:
return $default(_that.id,_that.routineExerciseId,_that.position,_that.setType,_that.targetReps,_that.targetWeightKg,_that.targetRpe,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String routineExerciseId,  int position,  SetType setType,  int? targetReps,  double? targetWeightKg,  double? targetRpe,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RoutineSet():
return $default(_that.id,_that.routineExerciseId,_that.position,_that.setType,_that.targetReps,_that.targetWeightKg,_that.targetRpe,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String routineExerciseId,  int position,  SetType setType,  int? targetReps,  double? targetWeightKg,  double? targetRpe,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RoutineSet() when $default != null:
return $default(_that.id,_that.routineExerciseId,_that.position,_that.setType,_that.targetReps,_that.targetWeightKg,_that.targetRpe,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineSet implements RoutineSet {
  const _RoutineSet({required this.id, required this.routineExerciseId, this.position = 1, this.setType = SetType.normal, this.targetReps, this.targetWeightKg, this.targetRpe, this.createdAt, this.updatedAt});
  factory _RoutineSet.fromJson(Map<String, dynamic> json) => _$RoutineSetFromJson(json);

@override final  String id;
@override final  String routineExerciseId;
@override@JsonKey() final  int position;
@override@JsonKey() final  SetType setType;
@override final  int? targetReps;
@override final  double? targetWeightKg;
@override final  double? targetRpe;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RoutineSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineSetCopyWith<_RoutineSet> get copyWith => __$RoutineSetCopyWithImpl<_RoutineSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineSetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineSet&&(identical(other.id, id) || other.id == id)&&(identical(other.routineExerciseId, routineExerciseId) || other.routineExerciseId == routineExerciseId)&&(identical(other.position, position) || other.position == position)&&(identical(other.setType, setType) || other.setType == setType)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.targetRpe, targetRpe) || other.targetRpe == targetRpe)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,routineExerciseId,position,setType,targetReps,targetWeightKg,targetRpe,createdAt,updatedAt);
}

@override
String toString() {
    return 'RoutineSet(id: $id, routineExerciseId: $routineExerciseId, position: $position, setType: $setType, targetReps: $targetReps, targetWeightKg: $targetWeightKg, targetRpe: $targetRpe, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineSetCopyWith<$Res> implements $RoutineSetCopyWith<$Res> {
  factory _$RoutineSetCopyWith(_RoutineSet value, $Res Function(_RoutineSet) _then) = __$RoutineSetCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineExerciseId, int position, SetType setType, int? targetReps, double? targetWeightKg, double? targetRpe, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$RoutineSetCopyWithImpl<$Res>
    implements _$RoutineSetCopyWith<$Res> {
  __$RoutineSetCopyWithImpl(this._self, this._then);

  final _RoutineSet _self;
  final $Res Function(_RoutineSet) _then;

/// Create a copy of RoutineSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineExerciseId = null,Object? position = null,Object? setType = null,Object? targetReps = freezed,Object? targetWeightKg = freezed,Object? targetRpe = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RoutineSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineExerciseId: null == routineExerciseId ? _self.routineExerciseId : routineExerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,setType: null == setType ? _self.setType : setType // ignore: cast_nullable_to_non_nullable
as SetType,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,targetWeightKg: freezed == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,targetRpe: freezed == targetRpe ? _self.targetRpe : targetRpe // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
