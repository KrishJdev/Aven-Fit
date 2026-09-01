// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NutritionDashboardState {

 DateTime get day; List<NutritionLogEntry> get entries; DailyNutritionTotals? get totals; NutritionGoals? get goals;
/// Create a copy of NutritionDashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionDashboardStateCopyWith<NutritionDashboardState> get copyWith => _$NutritionDashboardStateCopyWithImpl<NutritionDashboardState>(this as NutritionDashboardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NutritionDashboardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionDashboardState&&(identical(other.day, _this.day) || other.day == _this.day)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.totals, _this.totals) || other.totals == _this.totals)&&(identical(other.goals, _this.goals) || other.goals == _this.goals));
}


@override
int get hashCode {
  final _this = this as NutritionDashboardState;
  return Object.hash(runtimeType,_this.day,const DeepCollectionEquality().hash(_this.entries),_this.totals,_this.goals);
}

@override
String toString() {
  final _this = this as NutritionDashboardState;
  return 'NutritionDashboardState(day: ${_this.day}, entries: ${_this.entries}, totals: ${_this.totals}, goals: ${_this.goals})';
}


}

/// @nodoc
abstract mixin class $NutritionDashboardStateCopyWith<$Res>  {
  factory $NutritionDashboardStateCopyWith(NutritionDashboardState value, $Res Function(NutritionDashboardState) _then) = _$NutritionDashboardStateCopyWithImpl;
@useResult
$Res call({
 DateTime day, List<NutritionLogEntry> entries, DailyNutritionTotals? totals, NutritionGoals? goals
});


$NutritionGoalsCopyWith<$Res>? get goals;

}
/// @nodoc
class _$NutritionDashboardStateCopyWithImpl<$Res>
    implements $NutritionDashboardStateCopyWith<$Res> {
  _$NutritionDashboardStateCopyWithImpl(this._self, this._then);

  final NutritionDashboardState _self;
  final $Res Function(NutritionDashboardState) _then;

/// Create a copy of NutritionDashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? entries = null,Object? totals = freezed,Object? goals = freezed,}) {
  return _then(NutritionDashboardState(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<NutritionLogEntry>,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as DailyNutritionTotals?,goals: freezed == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as NutritionGoals?,
  ));
}
/// Create a copy of NutritionDashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionGoalsCopyWith<$Res>? get goals {
    if (_self.goals == null) {
    return null;
  }

  return $NutritionGoalsCopyWith<$Res>(_self.goals!, (value) {
    return _then(_self.copyWith(goals: value));
  });
}
}


/// Adds pattern-matching-related methods to [NutritionDashboardState].
extension NutritionDashboardStatePatterns on NutritionDashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionDashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionDashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionDashboardState value)  $default,){
final _that = this;
switch (_that) {
case _NutritionDashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionDashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionDashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime day,  List<NutritionLogEntry> entries,  DailyNutritionTotals? totals,  NutritionGoals? goals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionDashboardState() when $default != null:
return $default(_that.day,_that.entries,_that.totals,_that.goals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime day,  List<NutritionLogEntry> entries,  DailyNutritionTotals? totals,  NutritionGoals? goals)  $default,) {final _that = this;
switch (_that) {
case _NutritionDashboardState():
return $default(_that.day,_that.entries,_that.totals,_that.goals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime day,  List<NutritionLogEntry> entries,  DailyNutritionTotals? totals,  NutritionGoals? goals)?  $default,) {final _that = this;
switch (_that) {
case _NutritionDashboardState() when $default != null:
return $default(_that.day,_that.entries,_that.totals,_that.goals);case _:
  return null;

}
}

}

/// @nodoc


class _NutritionDashboardState extends NutritionDashboardState {
  const _NutritionDashboardState({required this.day,  List<NutritionLogEntry> entries = const <NutritionLogEntry>[], this.totals, this.goals}): _entries = entries,super._();
  

@override final  DateTime day;
 final  List<NutritionLogEntry> _entries;
@override@JsonKey() List<NutritionLogEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  DailyNutritionTotals? totals;
@override final  NutritionGoals? goals;

/// Create a copy of NutritionDashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionDashboardStateCopyWith<_NutritionDashboardState> get copyWith => __$NutritionDashboardStateCopyWithImpl<_NutritionDashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionDashboardState&&(identical(other.day, day) || other.day == day)&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.goals, goals) || other.goals == goals));
}


@override
int get hashCode {
    return Object.hash(runtimeType,day,const DeepCollectionEquality().hash(_entries),totals,goals);
}

@override
String toString() {
    return 'NutritionDashboardState(day: $day, entries: $entries, totals: $totals, goals: $goals)';
}


}

/// @nodoc
abstract mixin class _$NutritionDashboardStateCopyWith<$Res> implements $NutritionDashboardStateCopyWith<$Res> {
  factory _$NutritionDashboardStateCopyWith(_NutritionDashboardState value, $Res Function(_NutritionDashboardState) _then) = __$NutritionDashboardStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime day, List<NutritionLogEntry> entries, DailyNutritionTotals? totals, NutritionGoals? goals
});


@override $NutritionGoalsCopyWith<$Res>? get goals;

}
/// @nodoc
class __$NutritionDashboardStateCopyWithImpl<$Res>
    implements _$NutritionDashboardStateCopyWith<$Res> {
  __$NutritionDashboardStateCopyWithImpl(this._self, this._then);

  final _NutritionDashboardState _self;
  final $Res Function(_NutritionDashboardState) _then;

/// Create a copy of NutritionDashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? entries = null,Object? totals = freezed,Object? goals = freezed,}) {
  return _then(_NutritionDashboardState(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<NutritionLogEntry>,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as DailyNutritionTotals?,goals: freezed == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as NutritionGoals?,
  ));
}

/// Create a copy of NutritionDashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionGoalsCopyWith<$Res>? get goals {
    if (_self.goals == null) {
    return null;
  }

  return $NutritionGoalsCopyWith<$Res>(_self.goals!, (value) {
    return _then(_self.copyWith(goals: value));
  });
}
}

// dart format on
