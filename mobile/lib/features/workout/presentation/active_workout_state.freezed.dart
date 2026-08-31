// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_workout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActiveWorkoutState {

 WorkoutSession? get session; List<SessionExercise> get exercises; List<WorkoutSet> get sets; int get elapsedSeconds; bool get isRestTimerRunning; int get restTimerDurationSeconds; int get restTimerRemainingSeconds; bool get isSaving; String? get errorMessage;
/// Create a copy of ActiveWorkoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveWorkoutStateCopyWith<ActiveWorkoutState> get copyWith => _$ActiveWorkoutStateCopyWithImpl<ActiveWorkoutState>(this as ActiveWorkoutState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActiveWorkoutState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveWorkoutState&&(identical(other.session, _this.session) || other.session == _this.session)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises)&&const DeepCollectionEquality().equals(other.sets, _this.sets)&&(identical(other.elapsedSeconds, _this.elapsedSeconds) || other.elapsedSeconds == _this.elapsedSeconds)&&(identical(other.isRestTimerRunning, _this.isRestTimerRunning) || other.isRestTimerRunning == _this.isRestTimerRunning)&&(identical(other.restTimerDurationSeconds, _this.restTimerDurationSeconds) || other.restTimerDurationSeconds == _this.restTimerDurationSeconds)&&(identical(other.restTimerRemainingSeconds, _this.restTimerRemainingSeconds) || other.restTimerRemainingSeconds == _this.restTimerRemainingSeconds)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as ActiveWorkoutState;
  return Object.hash(runtimeType,_this.session,const DeepCollectionEquality().hash(_this.exercises),const DeepCollectionEquality().hash(_this.sets),_this.elapsedSeconds,_this.isRestTimerRunning,_this.restTimerDurationSeconds,_this.restTimerRemainingSeconds,_this.isSaving,_this.errorMessage);
}

@override
String toString() {
  final _this = this as ActiveWorkoutState;
  return 'ActiveWorkoutState(session: ${_this.session}, exercises: ${_this.exercises}, sets: ${_this.sets}, elapsedSeconds: ${_this.elapsedSeconds}, isRestTimerRunning: ${_this.isRestTimerRunning}, restTimerDurationSeconds: ${_this.restTimerDurationSeconds}, restTimerRemainingSeconds: ${_this.restTimerRemainingSeconds}, isSaving: ${_this.isSaving}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $ActiveWorkoutStateCopyWith<$Res>  {
  factory $ActiveWorkoutStateCopyWith(ActiveWorkoutState value, $Res Function(ActiveWorkoutState) _then) = _$ActiveWorkoutStateCopyWithImpl;
@useResult
$Res call({
 WorkoutSession? session, List<SessionExercise> exercises, List<WorkoutSet> sets, int elapsedSeconds, bool isRestTimerRunning, int restTimerDurationSeconds, int restTimerRemainingSeconds, bool isSaving, String? errorMessage
});


$WorkoutSessionCopyWith<$Res>? get session;

}
/// @nodoc
class _$ActiveWorkoutStateCopyWithImpl<$Res>
    implements $ActiveWorkoutStateCopyWith<$Res> {
  _$ActiveWorkoutStateCopyWithImpl(this._self, this._then);

  final ActiveWorkoutState _self;
  final $Res Function(ActiveWorkoutState) _then;

/// Create a copy of ActiveWorkoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? session = freezed,Object? exercises = null,Object? sets = null,Object? elapsedSeconds = null,Object? isRestTimerRunning = null,Object? restTimerDurationSeconds = null,Object? restTimerRemainingSeconds = null,Object? isSaving = null,Object? errorMessage = freezed,}) {
  return _then(ActiveWorkoutState(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as WorkoutSession?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<WorkoutSet>,elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as int,isRestTimerRunning: null == isRestTimerRunning ? _self.isRestTimerRunning : isRestTimerRunning // ignore: cast_nullable_to_non_nullable
as bool,restTimerDurationSeconds: null == restTimerDurationSeconds ? _self.restTimerDurationSeconds : restTimerDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,restTimerRemainingSeconds: null == restTimerRemainingSeconds ? _self.restTimerRemainingSeconds : restTimerRemainingSeconds // ignore: cast_nullable_to_non_nullable
as int,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ActiveWorkoutState
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


/// Adds pattern-matching-related methods to [ActiveWorkoutState].
extension ActiveWorkoutStatePatterns on ActiveWorkoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveWorkoutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveWorkoutState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveWorkoutState value)  $default,){
final _that = this;
switch (_that) {
case _ActiveWorkoutState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveWorkoutState value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveWorkoutState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WorkoutSession? session,  List<SessionExercise> exercises,  List<WorkoutSet> sets,  int elapsedSeconds,  bool isRestTimerRunning,  int restTimerDurationSeconds,  int restTimerRemainingSeconds,  bool isSaving,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveWorkoutState() when $default != null:
return $default(_that.session,_that.exercises,_that.sets,_that.elapsedSeconds,_that.isRestTimerRunning,_that.restTimerDurationSeconds,_that.restTimerRemainingSeconds,_that.isSaving,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WorkoutSession? session,  List<SessionExercise> exercises,  List<WorkoutSet> sets,  int elapsedSeconds,  bool isRestTimerRunning,  int restTimerDurationSeconds,  int restTimerRemainingSeconds,  bool isSaving,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ActiveWorkoutState():
return $default(_that.session,_that.exercises,_that.sets,_that.elapsedSeconds,_that.isRestTimerRunning,_that.restTimerDurationSeconds,_that.restTimerRemainingSeconds,_that.isSaving,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WorkoutSession? session,  List<SessionExercise> exercises,  List<WorkoutSet> sets,  int elapsedSeconds,  bool isRestTimerRunning,  int restTimerDurationSeconds,  int restTimerRemainingSeconds,  bool isSaving,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ActiveWorkoutState() when $default != null:
return $default(_that.session,_that.exercises,_that.sets,_that.elapsedSeconds,_that.isRestTimerRunning,_that.restTimerDurationSeconds,_that.restTimerRemainingSeconds,_that.isSaving,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ActiveWorkoutState extends ActiveWorkoutState {
  const _ActiveWorkoutState({required this.session,  List<SessionExercise> exercises = const <SessionExercise>[],  List<WorkoutSet> sets = const <WorkoutSet>[], this.elapsedSeconds = 0, this.isRestTimerRunning = false, this.restTimerDurationSeconds = 90, this.restTimerRemainingSeconds = 0, this.isSaving = false, this.errorMessage}): _exercises = exercises,_sets = sets,super._();
  

@override final  WorkoutSession? session;
 final  List<SessionExercise> _exercises;
@override@JsonKey() List<SessionExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

 final  List<WorkoutSet> _sets;
@override@JsonKey() List<WorkoutSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

@override@JsonKey() final  int elapsedSeconds;
@override@JsonKey() final  bool isRestTimerRunning;
@override@JsonKey() final  int restTimerDurationSeconds;
@override@JsonKey() final  int restTimerRemainingSeconds;
@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;

/// Create a copy of ActiveWorkoutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveWorkoutStateCopyWith<_ActiveWorkoutState> get copyWith => __$ActiveWorkoutStateCopyWithImpl<_ActiveWorkoutState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveWorkoutState&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other.exercises, _exercises)&&const DeepCollectionEquality().equals(other.sets, _sets)&&(identical(other.elapsedSeconds, elapsedSeconds) || other.elapsedSeconds == elapsedSeconds)&&(identical(other.isRestTimerRunning, isRestTimerRunning) || other.isRestTimerRunning == isRestTimerRunning)&&(identical(other.restTimerDurationSeconds, restTimerDurationSeconds) || other.restTimerDurationSeconds == restTimerDurationSeconds)&&(identical(other.restTimerRemainingSeconds, restTimerRemainingSeconds) || other.restTimerRemainingSeconds == restTimerRemainingSeconds)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,session,const DeepCollectionEquality().hash(_exercises),const DeepCollectionEquality().hash(_sets),elapsedSeconds,isRestTimerRunning,restTimerDurationSeconds,restTimerRemainingSeconds,isSaving,errorMessage);
}

@override
String toString() {
    return 'ActiveWorkoutState(session: $session, exercises: $exercises, sets: $sets, elapsedSeconds: $elapsedSeconds, isRestTimerRunning: $isRestTimerRunning, restTimerDurationSeconds: $restTimerDurationSeconds, restTimerRemainingSeconds: $restTimerRemainingSeconds, isSaving: $isSaving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ActiveWorkoutStateCopyWith<$Res> implements $ActiveWorkoutStateCopyWith<$Res> {
  factory _$ActiveWorkoutStateCopyWith(_ActiveWorkoutState value, $Res Function(_ActiveWorkoutState) _then) = __$ActiveWorkoutStateCopyWithImpl;
@override @useResult
$Res call({
 WorkoutSession? session, List<SessionExercise> exercises, List<WorkoutSet> sets, int elapsedSeconds, bool isRestTimerRunning, int restTimerDurationSeconds, int restTimerRemainingSeconds, bool isSaving, String? errorMessage
});


@override $WorkoutSessionCopyWith<$Res>? get session;

}
/// @nodoc
class __$ActiveWorkoutStateCopyWithImpl<$Res>
    implements _$ActiveWorkoutStateCopyWith<$Res> {
  __$ActiveWorkoutStateCopyWithImpl(this._self, this._then);

  final _ActiveWorkoutState _self;
  final $Res Function(_ActiveWorkoutState) _then;

/// Create a copy of ActiveWorkoutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = freezed,Object? exercises = null,Object? sets = null,Object? elapsedSeconds = null,Object? isRestTimerRunning = null,Object? restTimerDurationSeconds = null,Object? restTimerRemainingSeconds = null,Object? isSaving = null,Object? errorMessage = freezed,}) {
  return _then(_ActiveWorkoutState(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as WorkoutSession?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<WorkoutSet>,elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as int,isRestTimerRunning: null == isRestTimerRunning ? _self.isRestTimerRunning : isRestTimerRunning // ignore: cast_nullable_to_non_nullable
as bool,restTimerDurationSeconds: null == restTimerDurationSeconds ? _self.restTimerDurationSeconds : restTimerDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,restTimerRemainingSeconds: null == restTimerRemainingSeconds ? _self.restTimerRemainingSeconds : restTimerRemainingSeconds // ignore: cast_nullable_to_non_nullable
as int,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ActiveWorkoutState
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
