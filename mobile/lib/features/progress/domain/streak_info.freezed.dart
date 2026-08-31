// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StreakInfo {

 int get weeklyGoalDays; int get workoutsThisWeek; int get currentStreakWeeks;
/// Create a copy of StreakInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakInfoCopyWith<StreakInfo> get copyWith => _$StreakInfoCopyWithImpl<StreakInfo>(this as StreakInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StreakInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakInfo&&(identical(other.weeklyGoalDays, _this.weeklyGoalDays) || other.weeklyGoalDays == _this.weeklyGoalDays)&&(identical(other.workoutsThisWeek, _this.workoutsThisWeek) || other.workoutsThisWeek == _this.workoutsThisWeek)&&(identical(other.currentStreakWeeks, _this.currentStreakWeeks) || other.currentStreakWeeks == _this.currentStreakWeeks));
}


@override
int get hashCode {
  final _this = this as StreakInfo;
  return Object.hash(runtimeType,_this.weeklyGoalDays,_this.workoutsThisWeek,_this.currentStreakWeeks);
}

@override
String toString() {
  final _this = this as StreakInfo;
  return 'StreakInfo(weeklyGoalDays: ${_this.weeklyGoalDays}, workoutsThisWeek: ${_this.workoutsThisWeek}, currentStreakWeeks: ${_this.currentStreakWeeks})';
}


}

/// @nodoc
abstract mixin class $StreakInfoCopyWith<$Res>  {
  factory $StreakInfoCopyWith(StreakInfo value, $Res Function(StreakInfo) _then) = _$StreakInfoCopyWithImpl;
@useResult
$Res call({
 int weeklyGoalDays, int workoutsThisWeek, int currentStreakWeeks
});




}
/// @nodoc
class _$StreakInfoCopyWithImpl<$Res>
    implements $StreakInfoCopyWith<$Res> {
  _$StreakInfoCopyWithImpl(this._self, this._then);

  final StreakInfo _self;
  final $Res Function(StreakInfo) _then;

/// Create a copy of StreakInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weeklyGoalDays = null,Object? workoutsThisWeek = null,Object? currentStreakWeeks = null,}) {
  return _then(StreakInfo(
weeklyGoalDays: null == weeklyGoalDays ? _self.weeklyGoalDays : weeklyGoalDays // ignore: cast_nullable_to_non_nullable
as int,workoutsThisWeek: null == workoutsThisWeek ? _self.workoutsThisWeek : workoutsThisWeek // ignore: cast_nullable_to_non_nullable
as int,currentStreakWeeks: null == currentStreakWeeks ? _self.currentStreakWeeks : currentStreakWeeks // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakInfo].
extension StreakInfoPatterns on StreakInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakInfo value)  $default,){
final _that = this;
switch (_that) {
case _StreakInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakInfo value)?  $default,){
final _that = this;
switch (_that) {
case _StreakInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int weeklyGoalDays,  int workoutsThisWeek,  int currentStreakWeeks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakInfo() when $default != null:
return $default(_that.weeklyGoalDays,_that.workoutsThisWeek,_that.currentStreakWeeks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int weeklyGoalDays,  int workoutsThisWeek,  int currentStreakWeeks)  $default,) {final _that = this;
switch (_that) {
case _StreakInfo():
return $default(_that.weeklyGoalDays,_that.workoutsThisWeek,_that.currentStreakWeeks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int weeklyGoalDays,  int workoutsThisWeek,  int currentStreakWeeks)?  $default,) {final _that = this;
switch (_that) {
case _StreakInfo() when $default != null:
return $default(_that.weeklyGoalDays,_that.workoutsThisWeek,_that.currentStreakWeeks);case _:
  return null;

}
}

}

/// @nodoc


class _StreakInfo extends StreakInfo {
  const _StreakInfo({this.weeklyGoalDays = kDefaultWeeklyGoal, this.workoutsThisWeek = 0, this.currentStreakWeeks = 0}): super._();
  

@override@JsonKey() final  int weeklyGoalDays;
@override@JsonKey() final  int workoutsThisWeek;
@override@JsonKey() final  int currentStreakWeeks;

/// Create a copy of StreakInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakInfoCopyWith<_StreakInfo> get copyWith => __$StreakInfoCopyWithImpl<_StreakInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakInfo&&(identical(other.weeklyGoalDays, weeklyGoalDays) || other.weeklyGoalDays == weeklyGoalDays)&&(identical(other.workoutsThisWeek, workoutsThisWeek) || other.workoutsThisWeek == workoutsThisWeek)&&(identical(other.currentStreakWeeks, currentStreakWeeks) || other.currentStreakWeeks == currentStreakWeeks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,weeklyGoalDays,workoutsThisWeek,currentStreakWeeks);
}

@override
String toString() {
    return 'StreakInfo(weeklyGoalDays: $weeklyGoalDays, workoutsThisWeek: $workoutsThisWeek, currentStreakWeeks: $currentStreakWeeks)';
}


}

/// @nodoc
abstract mixin class _$StreakInfoCopyWith<$Res> implements $StreakInfoCopyWith<$Res> {
  factory _$StreakInfoCopyWith(_StreakInfo value, $Res Function(_StreakInfo) _then) = __$StreakInfoCopyWithImpl;
@override @useResult
$Res call({
 int weeklyGoalDays, int workoutsThisWeek, int currentStreakWeeks
});




}
/// @nodoc
class __$StreakInfoCopyWithImpl<$Res>
    implements _$StreakInfoCopyWith<$Res> {
  __$StreakInfoCopyWithImpl(this._self, this._then);

  final _StreakInfo _self;
  final $Res Function(_StreakInfo) _then;

/// Create a copy of StreakInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weeklyGoalDays = null,Object? workoutsThisWeek = null,Object? currentStreakWeeks = null,}) {
  return _then(_StreakInfo(
weeklyGoalDays: null == weeklyGoalDays ? _self.weeklyGoalDays : weeklyGoalDays // ignore: cast_nullable_to_non_nullable
as int,workoutsThisWeek: null == workoutsThisWeek ? _self.workoutsThisWeek : workoutsThisWeek // ignore: cast_nullable_to_non_nullable
as int,currentStreakWeeks: null == currentStreakWeeks ? _self.currentStreakWeeks : currentStreakWeeks // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
