// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeekStats {

 int get workoutCount; int get completedSetCount; double get volumeKg;
/// Create a copy of WeekStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekStatsCopyWith<WeekStats> get copyWith => _$WeekStatsCopyWithImpl<WeekStats>(this as WeekStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WeekStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekStats&&(identical(other.workoutCount, _this.workoutCount) || other.workoutCount == _this.workoutCount)&&(identical(other.completedSetCount, _this.completedSetCount) || other.completedSetCount == _this.completedSetCount)&&(identical(other.volumeKg, _this.volumeKg) || other.volumeKg == _this.volumeKg));
}


@override
int get hashCode {
  final _this = this as WeekStats;
  return Object.hash(runtimeType,_this.workoutCount,_this.completedSetCount,_this.volumeKg);
}

@override
String toString() {
  final _this = this as WeekStats;
  return 'WeekStats(workoutCount: ${_this.workoutCount}, completedSetCount: ${_this.completedSetCount}, volumeKg: ${_this.volumeKg})';
}


}

/// @nodoc
abstract mixin class $WeekStatsCopyWith<$Res>  {
  factory $WeekStatsCopyWith(WeekStats value, $Res Function(WeekStats) _then) = _$WeekStatsCopyWithImpl;
@useResult
$Res call({
 int workoutCount, int completedSetCount, double volumeKg
});




}
/// @nodoc
class _$WeekStatsCopyWithImpl<$Res>
    implements $WeekStatsCopyWith<$Res> {
  _$WeekStatsCopyWithImpl(this._self, this._then);

  final WeekStats _self;
  final $Res Function(WeekStats) _then;

/// Create a copy of WeekStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workoutCount = null,Object? completedSetCount = null,Object? volumeKg = null,}) {
  return _then(WeekStats(
workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,completedSetCount: null == completedSetCount ? _self.completedSetCount : completedSetCount // ignore: cast_nullable_to_non_nullable
as int,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WeekStats].
extension WeekStatsPatterns on WeekStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekStats value)  $default,){
final _that = this;
switch (_that) {
case _WeekStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekStats value)?  $default,){
final _that = this;
switch (_that) {
case _WeekStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int workoutCount,  int completedSetCount,  double volumeKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekStats() when $default != null:
return $default(_that.workoutCount,_that.completedSetCount,_that.volumeKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int workoutCount,  int completedSetCount,  double volumeKg)  $default,) {final _that = this;
switch (_that) {
case _WeekStats():
return $default(_that.workoutCount,_that.completedSetCount,_that.volumeKg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int workoutCount,  int completedSetCount,  double volumeKg)?  $default,) {final _that = this;
switch (_that) {
case _WeekStats() when $default != null:
return $default(_that.workoutCount,_that.completedSetCount,_that.volumeKg);case _:
  return null;

}
}

}

/// @nodoc


class _WeekStats extends WeekStats {
  const _WeekStats({this.workoutCount = 0, this.completedSetCount = 0, this.volumeKg = 0.0}): super._();
  

@override@JsonKey() final  int workoutCount;
@override@JsonKey() final  int completedSetCount;
@override@JsonKey() final  double volumeKg;

/// Create a copy of WeekStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekStatsCopyWith<_WeekStats> get copyWith => __$WeekStatsCopyWithImpl<_WeekStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekStats&&(identical(other.workoutCount, workoutCount) || other.workoutCount == workoutCount)&&(identical(other.completedSetCount, completedSetCount) || other.completedSetCount == completedSetCount)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg));
}


@override
int get hashCode {
    return Object.hash(runtimeType,workoutCount,completedSetCount,volumeKg);
}

@override
String toString() {
    return 'WeekStats(workoutCount: $workoutCount, completedSetCount: $completedSetCount, volumeKg: $volumeKg)';
}


}

/// @nodoc
abstract mixin class _$WeekStatsCopyWith<$Res> implements $WeekStatsCopyWith<$Res> {
  factory _$WeekStatsCopyWith(_WeekStats value, $Res Function(_WeekStats) _then) = __$WeekStatsCopyWithImpl;
@override @useResult
$Res call({
 int workoutCount, int completedSetCount, double volumeKg
});




}
/// @nodoc
class __$WeekStatsCopyWithImpl<$Res>
    implements _$WeekStatsCopyWith<$Res> {
  __$WeekStatsCopyWithImpl(this._self, this._then);

  final _WeekStats _self;
  final $Res Function(_WeekStats) _then;

/// Create a copy of WeekStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workoutCount = null,Object? completedSetCount = null,Object? volumeKg = null,}) {
  return _then(_WeekStats(
workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,completedSetCount: null == completedSetCount ? _self.completedSetCount : completedSetCount // ignore: cast_nullable_to_non_nullable
as int,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
