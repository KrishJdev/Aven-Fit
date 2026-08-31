// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_summary_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkoutSummaryState {

 WorkoutSession? get session; List<SessionExercise> get exercises; int get weeklyWorkoutCount; int get weeklyGoal;
/// Create a copy of WorkoutSummaryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSummaryStateCopyWith<WorkoutSummaryState> get copyWith => _$WorkoutSummaryStateCopyWithImpl<WorkoutSummaryState>(this as WorkoutSummaryState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkoutSummaryState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSummaryState&&(identical(other.session, _this.session) || other.session == _this.session)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises)&&(identical(other.weeklyWorkoutCount, _this.weeklyWorkoutCount) || other.weeklyWorkoutCount == _this.weeklyWorkoutCount)&&(identical(other.weeklyGoal, _this.weeklyGoal) || other.weeklyGoal == _this.weeklyGoal));
}


@override
int get hashCode {
  final _this = this as WorkoutSummaryState;
  return Object.hash(runtimeType,_this.session,const DeepCollectionEquality().hash(_this.exercises),_this.weeklyWorkoutCount,_this.weeklyGoal);
}

@override
String toString() {
  final _this = this as WorkoutSummaryState;
  return 'WorkoutSummaryState(session: ${_this.session}, exercises: ${_this.exercises}, weeklyWorkoutCount: ${_this.weeklyWorkoutCount}, weeklyGoal: ${_this.weeklyGoal})';
}


}

/// @nodoc
abstract mixin class $WorkoutSummaryStateCopyWith<$Res>  {
  factory $WorkoutSummaryStateCopyWith(WorkoutSummaryState value, $Res Function(WorkoutSummaryState) _then) = _$WorkoutSummaryStateCopyWithImpl;
@useResult
$Res call({
 WorkoutSession? session, List<SessionExercise> exercises, int weeklyWorkoutCount, int weeklyGoal
});


$WorkoutSessionCopyWith<$Res>? get session;

}
/// @nodoc
class _$WorkoutSummaryStateCopyWithImpl<$Res>
    implements $WorkoutSummaryStateCopyWith<$Res> {
  _$WorkoutSummaryStateCopyWithImpl(this._self, this._then);

  final WorkoutSummaryState _self;
  final $Res Function(WorkoutSummaryState) _then;

/// Create a copy of WorkoutSummaryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? session = freezed,Object? exercises = null,Object? weeklyWorkoutCount = null,Object? weeklyGoal = null,}) {
  return _then(WorkoutSummaryState(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as WorkoutSession?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,weeklyWorkoutCount: null == weeklyWorkoutCount ? _self.weeklyWorkoutCount : weeklyWorkoutCount // ignore: cast_nullable_to_non_nullable
as int,weeklyGoal: null == weeklyGoal ? _self.weeklyGoal : weeklyGoal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of WorkoutSummaryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $WorkoutSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkoutSummaryState].
extension WorkoutSummaryStatePatterns on WorkoutSummaryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSummaryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSummaryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSummaryState value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSummaryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSummaryState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSummaryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WorkoutSession? session,  List<SessionExercise> exercises,  int weeklyWorkoutCount,  int weeklyGoal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSummaryState() when $default != null:
return $default(_that.session,_that.exercises,_that.weeklyWorkoutCount,_that.weeklyGoal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WorkoutSession? session,  List<SessionExercise> exercises,  int weeklyWorkoutCount,  int weeklyGoal)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSummaryState():
return $default(_that.session,_that.exercises,_that.weeklyWorkoutCount,_that.weeklyGoal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WorkoutSession? session,  List<SessionExercise> exercises,  int weeklyWorkoutCount,  int weeklyGoal)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSummaryState() when $default != null:
return $default(_that.session,_that.exercises,_that.weeklyWorkoutCount,_that.weeklyGoal);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutSummaryState extends WorkoutSummaryState {
  const _WorkoutSummaryState({this.session,  List<SessionExercise> exercises = const <SessionExercise>[], this.weeklyWorkoutCount = 0, this.weeklyGoal = kDefaultWeeklyGoal}): _exercises = exercises,super._();
  

@override final  WorkoutSession? session;
 final  List<SessionExercise> _exercises;
@override@JsonKey() List<SessionExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@JsonKey() final  int weeklyWorkoutCount;
@override@JsonKey() final  int weeklyGoal;

/// Create a copy of WorkoutSummaryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSummaryStateCopyWith<_WorkoutSummaryState> get copyWith => __$WorkoutSummaryStateCopyWithImpl<_WorkoutSummaryState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSummaryState&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other.exercises, _exercises)&&(identical(other.weeklyWorkoutCount, weeklyWorkoutCount) || other.weeklyWorkoutCount == weeklyWorkoutCount)&&(identical(other.weeklyGoal, weeklyGoal) || other.weeklyGoal == weeklyGoal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,session,const DeepCollectionEquality().hash(_exercises),weeklyWorkoutCount,weeklyGoal);
}

@override
String toString() {
    return 'WorkoutSummaryState(session: $session, exercises: $exercises, weeklyWorkoutCount: $weeklyWorkoutCount, weeklyGoal: $weeklyGoal)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSummaryStateCopyWith<$Res> implements $WorkoutSummaryStateCopyWith<$Res> {
  factory _$WorkoutSummaryStateCopyWith(_WorkoutSummaryState value, $Res Function(_WorkoutSummaryState) _then) = __$WorkoutSummaryStateCopyWithImpl;
@override @useResult
$Res call({
 WorkoutSession? session, List<SessionExercise> exercises, int weeklyWorkoutCount, int weeklyGoal
});


@override $WorkoutSessionCopyWith<$Res>? get session;

}
/// @nodoc
class __$WorkoutSummaryStateCopyWithImpl<$Res>
    implements _$WorkoutSummaryStateCopyWith<$Res> {
  __$WorkoutSummaryStateCopyWithImpl(this._self, this._then);

  final _WorkoutSummaryState _self;
  final $Res Function(_WorkoutSummaryState) _then;

/// Create a copy of WorkoutSummaryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = freezed,Object? exercises = null,Object? weeklyWorkoutCount = null,Object? weeklyGoal = null,}) {
  return _then(_WorkoutSummaryState(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as WorkoutSession?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,weeklyWorkoutCount: null == weeklyWorkoutCount ? _self.weeklyWorkoutCount : weeklyWorkoutCount // ignore: cast_nullable_to_non_nullable
as int,weeklyGoal: null == weeklyGoal ? _self.weeklyGoal : weeklyGoal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of WorkoutSummaryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $WorkoutSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

// dart format on
