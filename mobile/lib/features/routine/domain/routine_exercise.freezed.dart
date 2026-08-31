// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutineExercise {

 String get id; String get routineId; String get exerciseId; Exercise? get exercise; String? get exerciseName; int get orderIndex; int get restSeconds; String? get notes; int? get targetSetsCount; double? get targetWeightKg; int? get targetReps; double? get targetRpe; List<RoutineSet> get sets; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineExerciseCopyWith<RoutineExercise> get copyWith => _$RoutineExerciseCopyWithImpl<RoutineExercise>(this as RoutineExercise, _$identity);

  /// Serializes this RoutineExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoutineExercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineExercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.routineId, _this.routineId) || other.routineId == _this.routineId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.exercise, _this.exercise) || other.exercise == _this.exercise)&&(identical(other.exerciseName, _this.exerciseName) || other.exerciseName == _this.exerciseName)&&(identical(other.orderIndex, _this.orderIndex) || other.orderIndex == _this.orderIndex)&&(identical(other.restSeconds, _this.restSeconds) || other.restSeconds == _this.restSeconds)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.targetSetsCount, _this.targetSetsCount) || other.targetSetsCount == _this.targetSetsCount)&&(identical(other.targetWeightKg, _this.targetWeightKg) || other.targetWeightKg == _this.targetWeightKg)&&(identical(other.targetReps, _this.targetReps) || other.targetReps == _this.targetReps)&&(identical(other.targetRpe, _this.targetRpe) || other.targetRpe == _this.targetRpe)&&const DeepCollectionEquality().equals(other.sets, _this.sets)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoutineExercise;
  return Object.hash(runtimeType,_this.id,_this.routineId,_this.exerciseId,_this.exercise,_this.exerciseName,_this.orderIndex,_this.restSeconds,_this.notes,_this.targetSetsCount,_this.targetWeightKg,_this.targetReps,_this.targetRpe,const DeepCollectionEquality().hash(_this.sets),_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as RoutineExercise;
  return 'RoutineExercise(id: ${_this.id}, routineId: ${_this.routineId}, exerciseId: ${_this.exerciseId}, exercise: ${_this.exercise}, exerciseName: ${_this.exerciseName}, orderIndex: ${_this.orderIndex}, restSeconds: ${_this.restSeconds}, notes: ${_this.notes}, targetSetsCount: ${_this.targetSetsCount}, targetWeightKg: ${_this.targetWeightKg}, targetReps: ${_this.targetReps}, targetRpe: ${_this.targetRpe}, sets: ${_this.sets}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $RoutineExerciseCopyWith<$Res>  {
  factory $RoutineExerciseCopyWith(RoutineExercise value, $Res Function(RoutineExercise) _then) = _$RoutineExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String routineId, String exerciseId, Exercise? exercise, String? exerciseName, int orderIndex, int restSeconds, String? notes, int? targetSetsCount, double? targetWeightKg, int? targetReps, double? targetRpe, List<RoutineSet> sets, DateTime? createdAt, DateTime? updatedAt
});


$ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class _$RoutineExerciseCopyWithImpl<$Res>
    implements $RoutineExerciseCopyWith<$Res> {
  _$RoutineExerciseCopyWithImpl(this._self, this._then);

  final RoutineExercise _self;
  final $Res Function(RoutineExercise) _then;

/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routineId = null,Object? exerciseId = null,Object? exercise = freezed,Object? exerciseName = freezed,Object? orderIndex = null,Object? restSeconds = null,Object? notes = freezed,Object? targetSetsCount = freezed,Object? targetWeightKg = freezed,Object? targetReps = freezed,Object? targetRpe = freezed,Object? sets = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(RoutineExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,targetSetsCount: freezed == targetSetsCount ? _self.targetSetsCount : targetSetsCount // ignore: cast_nullable_to_non_nullable
as int?,targetWeightKg: freezed == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,targetRpe: freezed == targetRpe ? _self.targetRpe : targetRpe // ignore: cast_nullable_to_non_nullable
as double?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<RoutineSet>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $ExerciseCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}


/// Adds pattern-matching-related methods to [RoutineExercise].
extension RoutineExercisePatterns on RoutineExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineExercise value)  $default,){
final _that = this;
switch (_that) {
case _RoutineExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineExercise value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String routineId,  String exerciseId,  Exercise? exercise,  String? exerciseName,  int orderIndex,  int restSeconds,  String? notes,  int? targetSetsCount,  double? targetWeightKg,  int? targetReps,  double? targetRpe,  List<RoutineSet> sets,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineExercise() when $default != null:
return $default(_that.id,_that.routineId,_that.exerciseId,_that.exercise,_that.exerciseName,_that.orderIndex,_that.restSeconds,_that.notes,_that.targetSetsCount,_that.targetWeightKg,_that.targetReps,_that.targetRpe,_that.sets,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String routineId,  String exerciseId,  Exercise? exercise,  String? exerciseName,  int orderIndex,  int restSeconds,  String? notes,  int? targetSetsCount,  double? targetWeightKg,  int? targetReps,  double? targetRpe,  List<RoutineSet> sets,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RoutineExercise():
return $default(_that.id,_that.routineId,_that.exerciseId,_that.exercise,_that.exerciseName,_that.orderIndex,_that.restSeconds,_that.notes,_that.targetSetsCount,_that.targetWeightKg,_that.targetReps,_that.targetRpe,_that.sets,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String routineId,  String exerciseId,  Exercise? exercise,  String? exerciseName,  int orderIndex,  int restSeconds,  String? notes,  int? targetSetsCount,  double? targetWeightKg,  int? targetReps,  double? targetRpe,  List<RoutineSet> sets,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RoutineExercise() when $default != null:
return $default(_that.id,_that.routineId,_that.exerciseId,_that.exercise,_that.exerciseName,_that.orderIndex,_that.restSeconds,_that.notes,_that.targetSetsCount,_that.targetWeightKg,_that.targetReps,_that.targetRpe,_that.sets,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineExercise extends RoutineExercise {
  const _RoutineExercise({required this.id, required this.routineId, required this.exerciseId, this.exercise, this.exerciseName, this.orderIndex = 0, this.restSeconds = 90, this.notes, this.targetSetsCount, this.targetWeightKg, this.targetReps, this.targetRpe,  List<RoutineSet> sets = const <RoutineSet>[], this.createdAt, this.updatedAt}): _sets = sets,super._();
  factory _RoutineExercise.fromJson(Map<String, dynamic> json) => _$RoutineExerciseFromJson(json);

@override final  String id;
@override final  String routineId;
@override final  String exerciseId;
@override final  Exercise? exercise;
@override final  String? exerciseName;
@override@JsonKey() final  int orderIndex;
@override@JsonKey() final  int restSeconds;
@override final  String? notes;
@override final  int? targetSetsCount;
@override final  double? targetWeightKg;
@override final  int? targetReps;
@override final  double? targetRpe;
 final  List<RoutineSet> _sets;
@override@JsonKey() List<RoutineSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineExerciseCopyWith<_RoutineExercise> get copyWith => __$RoutineExerciseCopyWithImpl<_RoutineExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.targetSetsCount, targetSetsCount) || other.targetSetsCount == targetSetsCount)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.targetRpe, targetRpe) || other.targetRpe == targetRpe)&&const DeepCollectionEquality().equals(other.sets, _sets)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,routineId,exerciseId,exercise,exerciseName,orderIndex,restSeconds,notes,targetSetsCount,targetWeightKg,targetReps,targetRpe,const DeepCollectionEquality().hash(_sets),createdAt,updatedAt);
}

@override
String toString() {
    return 'RoutineExercise(id: $id, routineId: $routineId, exerciseId: $exerciseId, exercise: $exercise, exerciseName: $exerciseName, orderIndex: $orderIndex, restSeconds: $restSeconds, notes: $notes, targetSetsCount: $targetSetsCount, targetWeightKg: $targetWeightKg, targetReps: $targetReps, targetRpe: $targetRpe, sets: $sets, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineExerciseCopyWith<$Res> implements $RoutineExerciseCopyWith<$Res> {
  factory _$RoutineExerciseCopyWith(_RoutineExercise value, $Res Function(_RoutineExercise) _then) = __$RoutineExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineId, String exerciseId, Exercise? exercise, String? exerciseName, int orderIndex, int restSeconds, String? notes, int? targetSetsCount, double? targetWeightKg, int? targetReps, double? targetRpe, List<RoutineSet> sets, DateTime? createdAt, DateTime? updatedAt
});


@override $ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class __$RoutineExerciseCopyWithImpl<$Res>
    implements _$RoutineExerciseCopyWith<$Res> {
  __$RoutineExerciseCopyWithImpl(this._self, this._then);

  final _RoutineExercise _self;
  final $Res Function(_RoutineExercise) _then;

/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineId = null,Object? exerciseId = null,Object? exercise = freezed,Object? exerciseName = freezed,Object? orderIndex = null,Object? restSeconds = null,Object? notes = freezed,Object? targetSetsCount = freezed,Object? targetWeightKg = freezed,Object? targetReps = freezed,Object? targetRpe = freezed,Object? sets = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RoutineExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,targetSetsCount: freezed == targetSetsCount ? _self.targetSetsCount : targetSetsCount // ignore: cast_nullable_to_non_nullable
as int?,targetWeightKg: freezed == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,targetRpe: freezed == targetRpe ? _self.targetRpe : targetRpe // ignore: cast_nullable_to_non_nullable
as double?,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<RoutineSet>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $ExerciseCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}

// dart format on
