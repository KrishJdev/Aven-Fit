// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rest_timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RestTimerState {

 bool get isRunning; int get totalSeconds;/// Duration the countdown was started with — [restart] always restores
/// this, even after ±15s adjustments shrank or grew [totalSeconds].
 int get initialSeconds; int? get endsAtEpochMs; int get remainingSeconds; String? get sessionExerciseId; String? get exerciseName; bool get needsPermissionPrimer;
/// Create a copy of RestTimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestTimerStateCopyWith<RestTimerState> get copyWith => _$RestTimerStateCopyWithImpl<RestTimerState>(this as RestTimerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RestTimerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestTimerState&&(identical(other.isRunning, _this.isRunning) || other.isRunning == _this.isRunning)&&(identical(other.totalSeconds, _this.totalSeconds) || other.totalSeconds == _this.totalSeconds)&&(identical(other.initialSeconds, _this.initialSeconds) || other.initialSeconds == _this.initialSeconds)&&(identical(other.endsAtEpochMs, _this.endsAtEpochMs) || other.endsAtEpochMs == _this.endsAtEpochMs)&&(identical(other.remainingSeconds, _this.remainingSeconds) || other.remainingSeconds == _this.remainingSeconds)&&(identical(other.sessionExerciseId, _this.sessionExerciseId) || other.sessionExerciseId == _this.sessionExerciseId)&&(identical(other.exerciseName, _this.exerciseName) || other.exerciseName == _this.exerciseName)&&(identical(other.needsPermissionPrimer, _this.needsPermissionPrimer) || other.needsPermissionPrimer == _this.needsPermissionPrimer));
}


@override
int get hashCode {
  final _this = this as RestTimerState;
  return Object.hash(runtimeType,_this.isRunning,_this.totalSeconds,_this.initialSeconds,_this.endsAtEpochMs,_this.remainingSeconds,_this.sessionExerciseId,_this.exerciseName,_this.needsPermissionPrimer);
}

@override
String toString() {
  final _this = this as RestTimerState;
  return 'RestTimerState(isRunning: ${_this.isRunning}, totalSeconds: ${_this.totalSeconds}, initialSeconds: ${_this.initialSeconds}, endsAtEpochMs: ${_this.endsAtEpochMs}, remainingSeconds: ${_this.remainingSeconds}, sessionExerciseId: ${_this.sessionExerciseId}, exerciseName: ${_this.exerciseName}, needsPermissionPrimer: ${_this.needsPermissionPrimer})';
}


}

/// @nodoc
abstract mixin class $RestTimerStateCopyWith<$Res>  {
  factory $RestTimerStateCopyWith(RestTimerState value, $Res Function(RestTimerState) _then) = _$RestTimerStateCopyWithImpl;
@useResult
$Res call({
 bool isRunning, int totalSeconds, int initialSeconds, int? endsAtEpochMs, int remainingSeconds, String? sessionExerciseId, String? exerciseName, bool needsPermissionPrimer
});




}
/// @nodoc
class _$RestTimerStateCopyWithImpl<$Res>
    implements $RestTimerStateCopyWith<$Res> {
  _$RestTimerStateCopyWithImpl(this._self, this._then);

  final RestTimerState _self;
  final $Res Function(RestTimerState) _then;

/// Create a copy of RestTimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRunning = null,Object? totalSeconds = null,Object? initialSeconds = null,Object? endsAtEpochMs = freezed,Object? remainingSeconds = null,Object? sessionExerciseId = freezed,Object? exerciseName = freezed,Object? needsPermissionPrimer = null,}) {
  return _then(RestTimerState(
isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,initialSeconds: null == initialSeconds ? _self.initialSeconds : initialSeconds // ignore: cast_nullable_to_non_nullable
as int,endsAtEpochMs: freezed == endsAtEpochMs ? _self.endsAtEpochMs : endsAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,remainingSeconds: null == remainingSeconds ? _self.remainingSeconds : remainingSeconds // ignore: cast_nullable_to_non_nullable
as int,sessionExerciseId: freezed == sessionExerciseId ? _self.sessionExerciseId : sessionExerciseId // ignore: cast_nullable_to_non_nullable
as String?,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,needsPermissionPrimer: null == needsPermissionPrimer ? _self.needsPermissionPrimer : needsPermissionPrimer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RestTimerState].
extension RestTimerStatePatterns on RestTimerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestTimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestTimerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestTimerState value)  $default,){
final _that = this;
switch (_that) {
case _RestTimerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestTimerState value)?  $default,){
final _that = this;
switch (_that) {
case _RestTimerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRunning,  int totalSeconds,  int initialSeconds,  int? endsAtEpochMs,  int remainingSeconds,  String? sessionExerciseId,  String? exerciseName,  bool needsPermissionPrimer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestTimerState() when $default != null:
return $default(_that.isRunning,_that.totalSeconds,_that.initialSeconds,_that.endsAtEpochMs,_that.remainingSeconds,_that.sessionExerciseId,_that.exerciseName,_that.needsPermissionPrimer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRunning,  int totalSeconds,  int initialSeconds,  int? endsAtEpochMs,  int remainingSeconds,  String? sessionExerciseId,  String? exerciseName,  bool needsPermissionPrimer)  $default,) {final _that = this;
switch (_that) {
case _RestTimerState():
return $default(_that.isRunning,_that.totalSeconds,_that.initialSeconds,_that.endsAtEpochMs,_that.remainingSeconds,_that.sessionExerciseId,_that.exerciseName,_that.needsPermissionPrimer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRunning,  int totalSeconds,  int initialSeconds,  int? endsAtEpochMs,  int remainingSeconds,  String? sessionExerciseId,  String? exerciseName,  bool needsPermissionPrimer)?  $default,) {final _that = this;
switch (_that) {
case _RestTimerState() when $default != null:
return $default(_that.isRunning,_that.totalSeconds,_that.initialSeconds,_that.endsAtEpochMs,_that.remainingSeconds,_that.sessionExerciseId,_that.exerciseName,_that.needsPermissionPrimer);case _:
  return null;

}
}

}

/// @nodoc


class _RestTimerState extends RestTimerState {
  const _RestTimerState({this.isRunning = false, this.totalSeconds = 0, this.initialSeconds = 0, this.endsAtEpochMs, this.remainingSeconds = 0, this.sessionExerciseId, this.exerciseName, this.needsPermissionPrimer = false}): super._();
  

@override@JsonKey() final  bool isRunning;
@override@JsonKey() final  int totalSeconds;
/// Duration the countdown was started with — [restart] always restores
/// this, even after ±15s adjustments shrank or grew [totalSeconds].
@override@JsonKey() final  int initialSeconds;
@override final  int? endsAtEpochMs;
@override@JsonKey() final  int remainingSeconds;
@override final  String? sessionExerciseId;
@override final  String? exerciseName;
@override@JsonKey() final  bool needsPermissionPrimer;

/// Create a copy of RestTimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestTimerStateCopyWith<_RestTimerState> get copyWith => __$RestTimerStateCopyWithImpl<_RestTimerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestTimerState&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds)&&(identical(other.initialSeconds, initialSeconds) || other.initialSeconds == initialSeconds)&&(identical(other.endsAtEpochMs, endsAtEpochMs) || other.endsAtEpochMs == endsAtEpochMs)&&(identical(other.remainingSeconds, remainingSeconds) || other.remainingSeconds == remainingSeconds)&&(identical(other.sessionExerciseId, sessionExerciseId) || other.sessionExerciseId == sessionExerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.needsPermissionPrimer, needsPermissionPrimer) || other.needsPermissionPrimer == needsPermissionPrimer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isRunning,totalSeconds,initialSeconds,endsAtEpochMs,remainingSeconds,sessionExerciseId,exerciseName,needsPermissionPrimer);
}

@override
String toString() {
    return 'RestTimerState(isRunning: $isRunning, totalSeconds: $totalSeconds, initialSeconds: $initialSeconds, endsAtEpochMs: $endsAtEpochMs, remainingSeconds: $remainingSeconds, sessionExerciseId: $sessionExerciseId, exerciseName: $exerciseName, needsPermissionPrimer: $needsPermissionPrimer)';
}


}

/// @nodoc
abstract mixin class _$RestTimerStateCopyWith<$Res> implements $RestTimerStateCopyWith<$Res> {
  factory _$RestTimerStateCopyWith(_RestTimerState value, $Res Function(_RestTimerState) _then) = __$RestTimerStateCopyWithImpl;
@override @useResult
$Res call({
 bool isRunning, int totalSeconds, int initialSeconds, int? endsAtEpochMs, int remainingSeconds, String? sessionExerciseId, String? exerciseName, bool needsPermissionPrimer
});




}
/// @nodoc
class __$RestTimerStateCopyWithImpl<$Res>
    implements _$RestTimerStateCopyWith<$Res> {
  __$RestTimerStateCopyWithImpl(this._self, this._then);

  final _RestTimerState _self;
  final $Res Function(_RestTimerState) _then;

/// Create a copy of RestTimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRunning = null,Object? totalSeconds = null,Object? initialSeconds = null,Object? endsAtEpochMs = freezed,Object? remainingSeconds = null,Object? sessionExerciseId = freezed,Object? exerciseName = freezed,Object? needsPermissionPrimer = null,}) {
  return _then(_RestTimerState(
isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,initialSeconds: null == initialSeconds ? _self.initialSeconds : initialSeconds // ignore: cast_nullable_to_non_nullable
as int,endsAtEpochMs: freezed == endsAtEpochMs ? _self.endsAtEpochMs : endsAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,remainingSeconds: null == remainingSeconds ? _self.remainingSeconds : remainingSeconds // ignore: cast_nullable_to_non_nullable
as int,sessionExerciseId: freezed == sessionExerciseId ? _self.sessionExerciseId : sessionExerciseId // ignore: cast_nullable_to_non_nullable
as String?,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,needsPermissionPrimer: null == needsPermissionPrimer ? _self.needsPermissionPrimer : needsPermissionPrimer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
