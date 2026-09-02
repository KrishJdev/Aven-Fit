// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 WorkoutSession? get activeSession; StreakInfo? get streak; WeeklyGlance? get weeklyGlance; List<WorkoutHistoryItem> get recentWorkouts; Routine? get suggestedRoutine; NutritionGoals? get goals; DailyNutritionTotals? get todayTotals;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HomeState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.activeSession, _this.activeSession) || other.activeSession == _this.activeSession)&&(identical(other.streak, _this.streak) || other.streak == _this.streak)&&(identical(other.weeklyGlance, _this.weeklyGlance) || other.weeklyGlance == _this.weeklyGlance)&&const DeepCollectionEquality().equals(other.recentWorkouts, _this.recentWorkouts)&&(identical(other.suggestedRoutine, _this.suggestedRoutine) || other.suggestedRoutine == _this.suggestedRoutine)&&(identical(other.goals, _this.goals) || other.goals == _this.goals)&&(identical(other.todayTotals, _this.todayTotals) || other.todayTotals == _this.todayTotals));
}


@override
int get hashCode {
  final _this = this as HomeState;
  return Object.hash(runtimeType,_this.activeSession,_this.streak,_this.weeklyGlance,const DeepCollectionEquality().hash(_this.recentWorkouts),_this.suggestedRoutine,_this.goals,_this.todayTotals);
}

@override
String toString() {
  final _this = this as HomeState;
  return 'HomeState(activeSession: ${_this.activeSession}, streak: ${_this.streak}, weeklyGlance: ${_this.weeklyGlance}, recentWorkouts: ${_this.recentWorkouts}, suggestedRoutine: ${_this.suggestedRoutine}, goals: ${_this.goals}, todayTotals: ${_this.todayTotals})';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 WorkoutSession? activeSession, StreakInfo? streak, WeeklyGlance? weeklyGlance, List<WorkoutHistoryItem> recentWorkouts, Routine? suggestedRoutine, NutritionGoals? goals, DailyNutritionTotals? todayTotals
});


$WorkoutSessionCopyWith<$Res>? get activeSession;$StreakInfoCopyWith<$Res>? get streak;$RoutineCopyWith<$Res>? get suggestedRoutine;$NutritionGoalsCopyWith<$Res>? get goals;

}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeSession = freezed,Object? streak = freezed,Object? weeklyGlance = freezed,Object? recentWorkouts = null,Object? suggestedRoutine = freezed,Object? goals = freezed,Object? todayTotals = freezed,}) {
  return _then(HomeState(
activeSession: freezed == activeSession ? _self.activeSession : activeSession // ignore: cast_nullable_to_non_nullable
as WorkoutSession?,streak: freezed == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakInfo?,weeklyGlance: freezed == weeklyGlance ? _self.weeklyGlance : weeklyGlance // ignore: cast_nullable_to_non_nullable
as WeeklyGlance?,recentWorkouts: null == recentWorkouts ? _self.recentWorkouts : recentWorkouts // ignore: cast_nullable_to_non_nullable
as List<WorkoutHistoryItem>,suggestedRoutine: freezed == suggestedRoutine ? _self.suggestedRoutine : suggestedRoutine // ignore: cast_nullable_to_non_nullable
as Routine?,goals: freezed == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as NutritionGoals?,todayTotals: freezed == todayTotals ? _self.todayTotals : todayTotals // ignore: cast_nullable_to_non_nullable
as DailyNutritionTotals?,
  ));
}
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<$Res>? get activeSession {
    if (_self.activeSession == null) {
    return null;
  }

  return $WorkoutSessionCopyWith<$Res>(_self.activeSession!, (value) {
    return _then(_self.copyWith(activeSession: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakInfoCopyWith<$Res>? get streak {
    if (_self.streak == null) {
    return null;
  }

  return $StreakInfoCopyWith<$Res>(_self.streak!, (value) {
    return _then(_self.copyWith(streak: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineCopyWith<$Res>? get suggestedRoutine {
    if (_self.suggestedRoutine == null) {
    return null;
  }

  return $RoutineCopyWith<$Res>(_self.suggestedRoutine!, (value) {
    return _then(_self.copyWith(suggestedRoutine: value));
  });
}/// Create a copy of HomeState
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


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WorkoutSession? activeSession,  StreakInfo? streak,  WeeklyGlance? weeklyGlance,  List<WorkoutHistoryItem> recentWorkouts,  Routine? suggestedRoutine,  NutritionGoals? goals,  DailyNutritionTotals? todayTotals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.activeSession,_that.streak,_that.weeklyGlance,_that.recentWorkouts,_that.suggestedRoutine,_that.goals,_that.todayTotals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WorkoutSession? activeSession,  StreakInfo? streak,  WeeklyGlance? weeklyGlance,  List<WorkoutHistoryItem> recentWorkouts,  Routine? suggestedRoutine,  NutritionGoals? goals,  DailyNutritionTotals? todayTotals)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.activeSession,_that.streak,_that.weeklyGlance,_that.recentWorkouts,_that.suggestedRoutine,_that.goals,_that.todayTotals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WorkoutSession? activeSession,  StreakInfo? streak,  WeeklyGlance? weeklyGlance,  List<WorkoutHistoryItem> recentWorkouts,  Routine? suggestedRoutine,  NutritionGoals? goals,  DailyNutritionTotals? todayTotals)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.activeSession,_that.streak,_that.weeklyGlance,_that.recentWorkouts,_that.suggestedRoutine,_that.goals,_that.todayTotals);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState extends HomeState {
  const _HomeState({this.activeSession, this.streak, this.weeklyGlance,  List<WorkoutHistoryItem> recentWorkouts = const <WorkoutHistoryItem>[], this.suggestedRoutine, this.goals, this.todayTotals}): _recentWorkouts = recentWorkouts,super._();
  

@override final  WorkoutSession? activeSession;
@override final  StreakInfo? streak;
@override final  WeeklyGlance? weeklyGlance;
 final  List<WorkoutHistoryItem> _recentWorkouts;
@override@JsonKey() List<WorkoutHistoryItem> get recentWorkouts {
  if (_recentWorkouts is EqualUnmodifiableListView) return _recentWorkouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentWorkouts);
}

@override final  Routine? suggestedRoutine;
@override final  NutritionGoals? goals;
@override final  DailyNutritionTotals? todayTotals;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.activeSession, activeSession) || other.activeSession == activeSession)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.weeklyGlance, weeklyGlance) || other.weeklyGlance == weeklyGlance)&&const DeepCollectionEquality().equals(other.recentWorkouts, _recentWorkouts)&&(identical(other.suggestedRoutine, suggestedRoutine) || other.suggestedRoutine == suggestedRoutine)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.todayTotals, todayTotals) || other.todayTotals == todayTotals));
}


@override
int get hashCode {
    return Object.hash(runtimeType,activeSession,streak,weeklyGlance,const DeepCollectionEquality().hash(_recentWorkouts),suggestedRoutine,goals,todayTotals);
}

@override
String toString() {
    return 'HomeState(activeSession: $activeSession, streak: $streak, weeklyGlance: $weeklyGlance, recentWorkouts: $recentWorkouts, suggestedRoutine: $suggestedRoutine, goals: $goals, todayTotals: $todayTotals)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 WorkoutSession? activeSession, StreakInfo? streak, WeeklyGlance? weeklyGlance, List<WorkoutHistoryItem> recentWorkouts, Routine? suggestedRoutine, NutritionGoals? goals, DailyNutritionTotals? todayTotals
});


@override $WorkoutSessionCopyWith<$Res>? get activeSession;@override $StreakInfoCopyWith<$Res>? get streak;@override $RoutineCopyWith<$Res>? get suggestedRoutine;@override $NutritionGoalsCopyWith<$Res>? get goals;

}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeSession = freezed,Object? streak = freezed,Object? weeklyGlance = freezed,Object? recentWorkouts = null,Object? suggestedRoutine = freezed,Object? goals = freezed,Object? todayTotals = freezed,}) {
  return _then(_HomeState(
activeSession: freezed == activeSession ? _self.activeSession : activeSession // ignore: cast_nullable_to_non_nullable
as WorkoutSession?,streak: freezed == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakInfo?,weeklyGlance: freezed == weeklyGlance ? _self.weeklyGlance : weeklyGlance // ignore: cast_nullable_to_non_nullable
as WeeklyGlance?,recentWorkouts: null == recentWorkouts ? _self._recentWorkouts : recentWorkouts // ignore: cast_nullable_to_non_nullable
as List<WorkoutHistoryItem>,suggestedRoutine: freezed == suggestedRoutine ? _self.suggestedRoutine : suggestedRoutine // ignore: cast_nullable_to_non_nullable
as Routine?,goals: freezed == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as NutritionGoals?,todayTotals: freezed == todayTotals ? _self.todayTotals : todayTotals // ignore: cast_nullable_to_non_nullable
as DailyNutritionTotals?,
  ));
}

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<$Res>? get activeSession {
    if (_self.activeSession == null) {
    return null;
  }

  return $WorkoutSessionCopyWith<$Res>(_self.activeSession!, (value) {
    return _then(_self.copyWith(activeSession: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakInfoCopyWith<$Res>? get streak {
    if (_self.streak == null) {
    return null;
  }

  return $StreakInfoCopyWith<$Res>(_self.streak!, (value) {
    return _then(_self.copyWith(streak: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineCopyWith<$Res>? get suggestedRoutine {
    if (_self.suggestedRoutine == null) {
    return null;
  }

  return $RoutineCopyWith<$Res>(_self.suggestedRoutine!, (value) {
    return _then(_self.copyWith(suggestedRoutine: value));
  });
}/// Create a copy of HomeState
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
