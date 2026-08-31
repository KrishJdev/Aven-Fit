// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_picker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExercisePickerState {

 String get searchQuery; String? get selectedMuscleGroupId; Equipment? get selectedEquipment; bool get favouritesOnly; bool get showRecentOnly; List<Exercise> get recentExercises; List<Exercise> get allExercises; List<MuscleGroup> get muscleGroups; bool get isSearching;
/// Create a copy of ExercisePickerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExercisePickerStateCopyWith<ExercisePickerState> get copyWith => _$ExercisePickerStateCopyWithImpl<ExercisePickerState>(this as ExercisePickerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExercisePickerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExercisePickerState&&(identical(other.searchQuery, _this.searchQuery) || other.searchQuery == _this.searchQuery)&&(identical(other.selectedMuscleGroupId, _this.selectedMuscleGroupId) || other.selectedMuscleGroupId == _this.selectedMuscleGroupId)&&(identical(other.selectedEquipment, _this.selectedEquipment) || other.selectedEquipment == _this.selectedEquipment)&&(identical(other.favouritesOnly, _this.favouritesOnly) || other.favouritesOnly == _this.favouritesOnly)&&(identical(other.showRecentOnly, _this.showRecentOnly) || other.showRecentOnly == _this.showRecentOnly)&&const DeepCollectionEquality().equals(other.recentExercises, _this.recentExercises)&&const DeepCollectionEquality().equals(other.allExercises, _this.allExercises)&&const DeepCollectionEquality().equals(other.muscleGroups, _this.muscleGroups)&&(identical(other.isSearching, _this.isSearching) || other.isSearching == _this.isSearching));
}


@override
int get hashCode {
  final _this = this as ExercisePickerState;
  return Object.hash(runtimeType,_this.searchQuery,_this.selectedMuscleGroupId,_this.selectedEquipment,_this.favouritesOnly,_this.showRecentOnly,const DeepCollectionEquality().hash(_this.recentExercises),const DeepCollectionEquality().hash(_this.allExercises),const DeepCollectionEquality().hash(_this.muscleGroups),_this.isSearching);
}

@override
String toString() {
  final _this = this as ExercisePickerState;
  return 'ExercisePickerState(searchQuery: ${_this.searchQuery}, selectedMuscleGroupId: ${_this.selectedMuscleGroupId}, selectedEquipment: ${_this.selectedEquipment}, favouritesOnly: ${_this.favouritesOnly}, showRecentOnly: ${_this.showRecentOnly}, recentExercises: ${_this.recentExercises}, allExercises: ${_this.allExercises}, muscleGroups: ${_this.muscleGroups}, isSearching: ${_this.isSearching})';
}


}

/// @nodoc
abstract mixin class $ExercisePickerStateCopyWith<$Res>  {
  factory $ExercisePickerStateCopyWith(ExercisePickerState value, $Res Function(ExercisePickerState) _then) = _$ExercisePickerStateCopyWithImpl;
@useResult
$Res call({
 String searchQuery, String? selectedMuscleGroupId, Equipment? selectedEquipment, bool favouritesOnly, bool showRecentOnly, List<Exercise> recentExercises, List<Exercise> allExercises, List<MuscleGroup> muscleGroups, bool isSearching
});




}
/// @nodoc
class _$ExercisePickerStateCopyWithImpl<$Res>
    implements $ExercisePickerStateCopyWith<$Res> {
  _$ExercisePickerStateCopyWithImpl(this._self, this._then);

  final ExercisePickerState _self;
  final $Res Function(ExercisePickerState) _then;

/// Create a copy of ExercisePickerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = null,Object? selectedMuscleGroupId = freezed,Object? selectedEquipment = freezed,Object? favouritesOnly = null,Object? showRecentOnly = null,Object? recentExercises = null,Object? allExercises = null,Object? muscleGroups = null,Object? isSearching = null,}) {
  return _then(ExercisePickerState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedMuscleGroupId: freezed == selectedMuscleGroupId ? _self.selectedMuscleGroupId : selectedMuscleGroupId // ignore: cast_nullable_to_non_nullable
as String?,selectedEquipment: freezed == selectedEquipment ? _self.selectedEquipment : selectedEquipment // ignore: cast_nullable_to_non_nullable
as Equipment?,favouritesOnly: null == favouritesOnly ? _self.favouritesOnly : favouritesOnly // ignore: cast_nullable_to_non_nullable
as bool,showRecentOnly: null == showRecentOnly ? _self.showRecentOnly : showRecentOnly // ignore: cast_nullable_to_non_nullable
as bool,recentExercises: null == recentExercises ? _self.recentExercises : recentExercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,allExercises: null == allExercises ? _self.allExercises : allExercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,muscleGroups: null == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<MuscleGroup>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExercisePickerState].
extension ExercisePickerStatePatterns on ExercisePickerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExercisePickerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExercisePickerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExercisePickerState value)  $default,){
final _that = this;
switch (_that) {
case _ExercisePickerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExercisePickerState value)?  $default,){
final _that = this;
switch (_that) {
case _ExercisePickerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchQuery,  String? selectedMuscleGroupId,  Equipment? selectedEquipment,  bool favouritesOnly,  bool showRecentOnly,  List<Exercise> recentExercises,  List<Exercise> allExercises,  List<MuscleGroup> muscleGroups,  bool isSearching)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExercisePickerState() when $default != null:
return $default(_that.searchQuery,_that.selectedMuscleGroupId,_that.selectedEquipment,_that.favouritesOnly,_that.showRecentOnly,_that.recentExercises,_that.allExercises,_that.muscleGroups,_that.isSearching);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchQuery,  String? selectedMuscleGroupId,  Equipment? selectedEquipment,  bool favouritesOnly,  bool showRecentOnly,  List<Exercise> recentExercises,  List<Exercise> allExercises,  List<MuscleGroup> muscleGroups,  bool isSearching)  $default,) {final _that = this;
switch (_that) {
case _ExercisePickerState():
return $default(_that.searchQuery,_that.selectedMuscleGroupId,_that.selectedEquipment,_that.favouritesOnly,_that.showRecentOnly,_that.recentExercises,_that.allExercises,_that.muscleGroups,_that.isSearching);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchQuery,  String? selectedMuscleGroupId,  Equipment? selectedEquipment,  bool favouritesOnly,  bool showRecentOnly,  List<Exercise> recentExercises,  List<Exercise> allExercises,  List<MuscleGroup> muscleGroups,  bool isSearching)?  $default,) {final _that = this;
switch (_that) {
case _ExercisePickerState() when $default != null:
return $default(_that.searchQuery,_that.selectedMuscleGroupId,_that.selectedEquipment,_that.favouritesOnly,_that.showRecentOnly,_that.recentExercises,_that.allExercises,_that.muscleGroups,_that.isSearching);case _:
  return null;

}
}

}

/// @nodoc


class _ExercisePickerState extends ExercisePickerState {
  const _ExercisePickerState({this.searchQuery = '', this.selectedMuscleGroupId, this.selectedEquipment, this.favouritesOnly = false, this.showRecentOnly = false,  List<Exercise> recentExercises = const <Exercise>[],  List<Exercise> allExercises = const <Exercise>[],  List<MuscleGroup> muscleGroups = const <MuscleGroup>[], this.isSearching = false}): _recentExercises = recentExercises,_allExercises = allExercises,_muscleGroups = muscleGroups,super._();
  

@override@JsonKey() final  String searchQuery;
@override final  String? selectedMuscleGroupId;
@override final  Equipment? selectedEquipment;
@override@JsonKey() final  bool favouritesOnly;
@override@JsonKey() final  bool showRecentOnly;
 final  List<Exercise> _recentExercises;
@override@JsonKey() List<Exercise> get recentExercises {
  if (_recentExercises is EqualUnmodifiableListView) return _recentExercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentExercises);
}

 final  List<Exercise> _allExercises;
@override@JsonKey() List<Exercise> get allExercises {
  if (_allExercises is EqualUnmodifiableListView) return _allExercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allExercises);
}

 final  List<MuscleGroup> _muscleGroups;
@override@JsonKey() List<MuscleGroup> get muscleGroups {
  if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscleGroups);
}

@override@JsonKey() final  bool isSearching;

/// Create a copy of ExercisePickerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExercisePickerStateCopyWith<_ExercisePickerState> get copyWith => __$ExercisePickerStateCopyWithImpl<_ExercisePickerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExercisePickerState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedMuscleGroupId, selectedMuscleGroupId) || other.selectedMuscleGroupId == selectedMuscleGroupId)&&(identical(other.selectedEquipment, selectedEquipment) || other.selectedEquipment == selectedEquipment)&&(identical(other.favouritesOnly, favouritesOnly) || other.favouritesOnly == favouritesOnly)&&(identical(other.showRecentOnly, showRecentOnly) || other.showRecentOnly == showRecentOnly)&&const DeepCollectionEquality().equals(other.recentExercises, _recentExercises)&&const DeepCollectionEquality().equals(other.allExercises, _allExercises)&&const DeepCollectionEquality().equals(other.muscleGroups, _muscleGroups)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchQuery,selectedMuscleGroupId,selectedEquipment,favouritesOnly,showRecentOnly,const DeepCollectionEquality().hash(_recentExercises),const DeepCollectionEquality().hash(_allExercises),const DeepCollectionEquality().hash(_muscleGroups),isSearching);
}

@override
String toString() {
    return 'ExercisePickerState(searchQuery: $searchQuery, selectedMuscleGroupId: $selectedMuscleGroupId, selectedEquipment: $selectedEquipment, favouritesOnly: $favouritesOnly, showRecentOnly: $showRecentOnly, recentExercises: $recentExercises, allExercises: $allExercises, muscleGroups: $muscleGroups, isSearching: $isSearching)';
}


}

/// @nodoc
abstract mixin class _$ExercisePickerStateCopyWith<$Res> implements $ExercisePickerStateCopyWith<$Res> {
  factory _$ExercisePickerStateCopyWith(_ExercisePickerState value, $Res Function(_ExercisePickerState) _then) = __$ExercisePickerStateCopyWithImpl;
@override @useResult
$Res call({
 String searchQuery, String? selectedMuscleGroupId, Equipment? selectedEquipment, bool favouritesOnly, bool showRecentOnly, List<Exercise> recentExercises, List<Exercise> allExercises, List<MuscleGroup> muscleGroups, bool isSearching
});




}
/// @nodoc
class __$ExercisePickerStateCopyWithImpl<$Res>
    implements _$ExercisePickerStateCopyWith<$Res> {
  __$ExercisePickerStateCopyWithImpl(this._self, this._then);

  final _ExercisePickerState _self;
  final $Res Function(_ExercisePickerState) _then;

/// Create a copy of ExercisePickerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = null,Object? selectedMuscleGroupId = freezed,Object? selectedEquipment = freezed,Object? favouritesOnly = null,Object? showRecentOnly = null,Object? recentExercises = null,Object? allExercises = null,Object? muscleGroups = null,Object? isSearching = null,}) {
  return _then(_ExercisePickerState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedMuscleGroupId: freezed == selectedMuscleGroupId ? _self.selectedMuscleGroupId : selectedMuscleGroupId // ignore: cast_nullable_to_non_nullable
as String?,selectedEquipment: freezed == selectedEquipment ? _self.selectedEquipment : selectedEquipment // ignore: cast_nullable_to_non_nullable
as Equipment?,favouritesOnly: null == favouritesOnly ? _self.favouritesOnly : favouritesOnly // ignore: cast_nullable_to_non_nullable
as bool,showRecentOnly: null == showRecentOnly ? _self.showRecentOnly : showRecentOnly // ignore: cast_nullable_to_non_nullable
as bool,recentExercises: null == recentExercises ? _self._recentExercises : recentExercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,allExercises: null == allExercises ? _self._allExercises : allExercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,muscleGroups: null == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<MuscleGroup>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
