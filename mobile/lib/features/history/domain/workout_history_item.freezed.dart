// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_history_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutHistoryItem {

 String get id; String get name;/// When the workout was completed (falls back to its start time).
 DateTime get date; int get durationSeconds; int get exerciseCount; int get totalSetsCount; double get totalVolumeKg; int get prCount;
/// Create a copy of WorkoutHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutHistoryItemCopyWith<WorkoutHistoryItem> get copyWith => _$WorkoutHistoryItemCopyWithImpl<WorkoutHistoryItem>(this as WorkoutHistoryItem, _$identity);

  /// Serializes this WorkoutHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkoutHistoryItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutHistoryItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.exerciseCount, _this.exerciseCount) || other.exerciseCount == _this.exerciseCount)&&(identical(other.totalSetsCount, _this.totalSetsCount) || other.totalSetsCount == _this.totalSetsCount)&&(identical(other.totalVolumeKg, _this.totalVolumeKg) || other.totalVolumeKg == _this.totalVolumeKg)&&(identical(other.prCount, _this.prCount) || other.prCount == _this.prCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkoutHistoryItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.date,_this.durationSeconds,_this.exerciseCount,_this.totalSetsCount,_this.totalVolumeKg,_this.prCount);
}

@override
String toString() {
  final _this = this as WorkoutHistoryItem;
  return 'WorkoutHistoryItem(id: ${_this.id}, name: ${_this.name}, date: ${_this.date}, durationSeconds: ${_this.durationSeconds}, exerciseCount: ${_this.exerciseCount}, totalSetsCount: ${_this.totalSetsCount}, totalVolumeKg: ${_this.totalVolumeKg}, prCount: ${_this.prCount})';
}


}

/// @nodoc
abstract mixin class $WorkoutHistoryItemCopyWith<$Res>  {
  factory $WorkoutHistoryItemCopyWith(WorkoutHistoryItem value, $Res Function(WorkoutHistoryItem) _then) = _$WorkoutHistoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime date, int durationSeconds, int exerciseCount, int totalSetsCount, double totalVolumeKg, int prCount
});




}
/// @nodoc
class _$WorkoutHistoryItemCopyWithImpl<$Res>
    implements $WorkoutHistoryItemCopyWith<$Res> {
  _$WorkoutHistoryItemCopyWithImpl(this._self, this._then);

  final WorkoutHistoryItem _self;
  final $Res Function(WorkoutHistoryItem) _then;

/// Create a copy of WorkoutHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? date = null,Object? durationSeconds = null,Object? exerciseCount = null,Object? totalSetsCount = null,Object? totalVolumeKg = null,Object? prCount = null,}) {
  return _then(WorkoutHistoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,totalSetsCount: null == totalSetsCount ? _self.totalSetsCount : totalSetsCount // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,prCount: null == prCount ? _self.prCount : prCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutHistoryItem].
extension WorkoutHistoryItemPatterns on WorkoutHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime date,  int durationSeconds,  int exerciseCount,  int totalSetsCount,  double totalVolumeKg,  int prCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutHistoryItem() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.durationSeconds,_that.exerciseCount,_that.totalSetsCount,_that.totalVolumeKg,_that.prCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime date,  int durationSeconds,  int exerciseCount,  int totalSetsCount,  double totalVolumeKg,  int prCount)  $default,) {final _that = this;
switch (_that) {
case _WorkoutHistoryItem():
return $default(_that.id,_that.name,_that.date,_that.durationSeconds,_that.exerciseCount,_that.totalSetsCount,_that.totalVolumeKg,_that.prCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime date,  int durationSeconds,  int exerciseCount,  int totalSetsCount,  double totalVolumeKg,  int prCount)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutHistoryItem() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.durationSeconds,_that.exerciseCount,_that.totalSetsCount,_that.totalVolumeKg,_that.prCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutHistoryItem extends WorkoutHistoryItem {
  const _WorkoutHistoryItem({required this.id, this.name = 'Workout', required this.date, this.durationSeconds = 0, this.exerciseCount = 0, this.totalSetsCount = 0, this.totalVolumeKg = 0.0, this.prCount = 0}): super._();
  factory _WorkoutHistoryItem.fromJson(Map<String, dynamic> json) => _$WorkoutHistoryItemFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
/// When the workout was completed (falls back to its start time).
@override final  DateTime date;
@override@JsonKey() final  int durationSeconds;
@override@JsonKey() final  int exerciseCount;
@override@JsonKey() final  int totalSetsCount;
@override@JsonKey() final  double totalVolumeKg;
@override@JsonKey() final  int prCount;

/// Create a copy of WorkoutHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutHistoryItemCopyWith<_WorkoutHistoryItem> get copyWith => __$WorkoutHistoryItemCopyWithImpl<_WorkoutHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.totalSetsCount, totalSetsCount) || other.totalSetsCount == totalSetsCount)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg)&&(identical(other.prCount, prCount) || other.prCount == prCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,date,durationSeconds,exerciseCount,totalSetsCount,totalVolumeKg,prCount);
}

@override
String toString() {
    return 'WorkoutHistoryItem(id: $id, name: $name, date: $date, durationSeconds: $durationSeconds, exerciseCount: $exerciseCount, totalSetsCount: $totalSetsCount, totalVolumeKg: $totalVolumeKg, prCount: $prCount)';
}


}

/// @nodoc
abstract mixin class _$WorkoutHistoryItemCopyWith<$Res> implements $WorkoutHistoryItemCopyWith<$Res> {
  factory _$WorkoutHistoryItemCopyWith(_WorkoutHistoryItem value, $Res Function(_WorkoutHistoryItem) _then) = __$WorkoutHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime date, int durationSeconds, int exerciseCount, int totalSetsCount, double totalVolumeKg, int prCount
});




}
/// @nodoc
class __$WorkoutHistoryItemCopyWithImpl<$Res>
    implements _$WorkoutHistoryItemCopyWith<$Res> {
  __$WorkoutHistoryItemCopyWithImpl(this._self, this._then);

  final _WorkoutHistoryItem _self;
  final $Res Function(_WorkoutHistoryItem) _then;

/// Create a copy of WorkoutHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? date = null,Object? durationSeconds = null,Object? exerciseCount = null,Object? totalSetsCount = null,Object? totalVolumeKg = null,Object? prCount = null,}) {
  return _then(_WorkoutHistoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,totalSetsCount: null == totalSetsCount ? _self.totalSetsCount : totalSetsCount // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,prCount: null == prCount ? _self.prCount : prCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
