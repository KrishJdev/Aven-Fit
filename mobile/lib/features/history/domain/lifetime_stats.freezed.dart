// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lifetime_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LifetimeStats {

 int get workoutCount; int get completedSetCount; double get totalVolumeKg; DateTime? get firstSessionAt;
/// Create a copy of LifetimeStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LifetimeStatsCopyWith<LifetimeStats> get copyWith => _$LifetimeStatsCopyWithImpl<LifetimeStats>(this as LifetimeStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LifetimeStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LifetimeStats&&(identical(other.workoutCount, _this.workoutCount) || other.workoutCount == _this.workoutCount)&&(identical(other.completedSetCount, _this.completedSetCount) || other.completedSetCount == _this.completedSetCount)&&(identical(other.totalVolumeKg, _this.totalVolumeKg) || other.totalVolumeKg == _this.totalVolumeKg)&&(identical(other.firstSessionAt, _this.firstSessionAt) || other.firstSessionAt == _this.firstSessionAt));
}


@override
int get hashCode {
  final _this = this as LifetimeStats;
  return Object.hash(runtimeType,_this.workoutCount,_this.completedSetCount,_this.totalVolumeKg,_this.firstSessionAt);
}

@override
String toString() {
  final _this = this as LifetimeStats;
  return 'LifetimeStats(workoutCount: ${_this.workoutCount}, completedSetCount: ${_this.completedSetCount}, totalVolumeKg: ${_this.totalVolumeKg}, firstSessionAt: ${_this.firstSessionAt})';
}


}

/// @nodoc
abstract mixin class $LifetimeStatsCopyWith<$Res>  {
  factory $LifetimeStatsCopyWith(LifetimeStats value, $Res Function(LifetimeStats) _then) = _$LifetimeStatsCopyWithImpl;
@useResult
$Res call({
 int workoutCount, int completedSetCount, double totalVolumeKg, DateTime? firstSessionAt
});




}
/// @nodoc
class _$LifetimeStatsCopyWithImpl<$Res>
    implements $LifetimeStatsCopyWith<$Res> {
  _$LifetimeStatsCopyWithImpl(this._self, this._then);

  final LifetimeStats _self;
  final $Res Function(LifetimeStats) _then;

/// Create a copy of LifetimeStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workoutCount = null,Object? completedSetCount = null,Object? totalVolumeKg = null,Object? firstSessionAt = freezed,}) {
  return _then(LifetimeStats(
workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,completedSetCount: null == completedSetCount ? _self.completedSetCount : completedSetCount // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,firstSessionAt: freezed == firstSessionAt ? _self.firstSessionAt : firstSessionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LifetimeStats].
extension LifetimeStatsPatterns on LifetimeStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LifetimeStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LifetimeStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LifetimeStats value)  $default,){
final _that = this;
switch (_that) {
case _LifetimeStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LifetimeStats value)?  $default,){
final _that = this;
switch (_that) {
case _LifetimeStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int workoutCount,  int completedSetCount,  double totalVolumeKg,  DateTime? firstSessionAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LifetimeStats() when $default != null:
return $default(_that.workoutCount,_that.completedSetCount,_that.totalVolumeKg,_that.firstSessionAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int workoutCount,  int completedSetCount,  double totalVolumeKg,  DateTime? firstSessionAt)  $default,) {final _that = this;
switch (_that) {
case _LifetimeStats():
return $default(_that.workoutCount,_that.completedSetCount,_that.totalVolumeKg,_that.firstSessionAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int workoutCount,  int completedSetCount,  double totalVolumeKg,  DateTime? firstSessionAt)?  $default,) {final _that = this;
switch (_that) {
case _LifetimeStats() when $default != null:
return $default(_that.workoutCount,_that.completedSetCount,_that.totalVolumeKg,_that.firstSessionAt);case _:
  return null;

}
}

}

/// @nodoc


class _LifetimeStats extends LifetimeStats {
  const _LifetimeStats({this.workoutCount = 0, this.completedSetCount = 0, this.totalVolumeKg = 0.0, this.firstSessionAt}): super._();
  

@override@JsonKey() final  int workoutCount;
@override@JsonKey() final  int completedSetCount;
@override@JsonKey() final  double totalVolumeKg;
@override final  DateTime? firstSessionAt;

/// Create a copy of LifetimeStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LifetimeStatsCopyWith<_LifetimeStats> get copyWith => __$LifetimeStatsCopyWithImpl<_LifetimeStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LifetimeStats&&(identical(other.workoutCount, workoutCount) || other.workoutCount == workoutCount)&&(identical(other.completedSetCount, completedSetCount) || other.completedSetCount == completedSetCount)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg)&&(identical(other.firstSessionAt, firstSessionAt) || other.firstSessionAt == firstSessionAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,workoutCount,completedSetCount,totalVolumeKg,firstSessionAt);
}

@override
String toString() {
    return 'LifetimeStats(workoutCount: $workoutCount, completedSetCount: $completedSetCount, totalVolumeKg: $totalVolumeKg, firstSessionAt: $firstSessionAt)';
}


}

/// @nodoc
abstract mixin class _$LifetimeStatsCopyWith<$Res> implements $LifetimeStatsCopyWith<$Res> {
  factory _$LifetimeStatsCopyWith(_LifetimeStats value, $Res Function(_LifetimeStats) _then) = __$LifetimeStatsCopyWithImpl;
@override @useResult
$Res call({
 int workoutCount, int completedSetCount, double totalVolumeKg, DateTime? firstSessionAt
});




}
/// @nodoc
class __$LifetimeStatsCopyWithImpl<$Res>
    implements _$LifetimeStatsCopyWith<$Res> {
  __$LifetimeStatsCopyWithImpl(this._self, this._then);

  final _LifetimeStats _self;
  final $Res Function(_LifetimeStats) _then;

/// Create a copy of LifetimeStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workoutCount = null,Object? completedSetCount = null,Object? totalVolumeKg = null,Object? firstSessionAt = freezed,}) {
  return _then(_LifetimeStats(
workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,completedSetCount: null == completedSetCount ? _self.completedSetCount : completedSetCount // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,firstSessionAt: freezed == firstSessionAt ? _self.firstSessionAt : firstSessionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
