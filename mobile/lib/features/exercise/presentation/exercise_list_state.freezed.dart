// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExerciseListState {

 String get searchQuery; String? get selectedMuscleGroupId; Equipment? get selectedEquipment; ExerciseCategory? get selectedCategory; bool get favouritesOnly; List<MuscleGroup> get muscleGroups; List<Exercise> get exercises; bool get isSeeding; String? get errorMessage;
/// Create a copy of ExerciseListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseListStateCopyWith<ExerciseListState> get copyWith => _$ExerciseListStateCopyWithImpl<ExerciseListState>(this as ExerciseListState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExerciseListState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseListState&&(identical(other.searchQuery, _this.searchQuery) || other.searchQuery == _this.searchQuery)&&(identical(other.selectedMuscleGroupId, _this.selectedMuscleGroupId) || other.selectedMuscleGroupId == _this.selectedMuscleGroupId)&&(identical(other.selectedEquipment, _this.selectedEquipment) || other.selectedEquipment == _this.selectedEquipment)&&(identical(other.selectedCategory, _this.selectedCategory) || other.selectedCategory == _this.selectedCategory)&&(identical(other.favouritesOnly, _this.favouritesOnly) || other.favouritesOnly == _this.favouritesOnly)&&const DeepCollectionEquality().equals(other.muscleGroups, _this.muscleGroups)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises)&&(identical(other.isSeeding, _this.isSeeding) || other.isSeeding == _this.isSeeding)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as ExerciseListState;
  return Object.hash(runtimeType,_this.searchQuery,_this.selectedMuscleGroupId,_this.selectedEquipment,_this.selectedCategory,_this.favouritesOnly,const DeepCollectionEquality().hash(_this.muscleGroups),const DeepCollectionEquality().hash(_this.exercises),_this.isSeeding,_this.errorMessage);
}

@override
String toString() {
  final _this = this as ExerciseListState;
  return 'ExerciseListState(searchQuery: ${_this.searchQuery}, selectedMuscleGroupId: ${_this.selectedMuscleGroupId}, selectedEquipment: ${_this.selectedEquipment}, selectedCategory: ${_this.selectedCategory}, favouritesOnly: ${_this.favouritesOnly}, muscleGroups: ${_this.muscleGroups}, exercises: ${_this.exercises}, isSeeding: ${_this.isSeeding}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $ExerciseListStateCopyWith<$Res>  {
  factory $ExerciseListStateCopyWith(ExerciseListState value, $Res Function(ExerciseListState) _then) = _$ExerciseListStateCopyWithImpl;
@useResult
$Res call({
 String searchQuery, String? selectedMuscleGroupId, Equipment? selectedEquipment, ExerciseCategory? selectedCategory, bool favouritesOnly, List<MuscleGroup> muscleGroups, List<Exercise> exercises, bool isSeeding, String? errorMessage
});




}
/// @nodoc
class _$ExerciseListStateCopyWithImpl<$Res>
    implements $ExerciseListStateCopyWith<$Res> {
  _$ExerciseListStateCopyWithImpl(this._self, this._then);

  final ExerciseListState _self;
  final $Res Function(ExerciseListState) _then;

/// Create a copy of ExerciseListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = null,Object? selectedMuscleGroupId = freezed,Object? selectedEquipment = freezed,Object? selectedCategory = freezed,Object? favouritesOnly = null,Object? muscleGroups = null,Object? exercises = null,Object? isSeeding = null,Object? errorMessage = freezed,}) {
  return _then(ExerciseListState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedMuscleGroupId: freezed == selectedMuscleGroupId ? _self.selectedMuscleGroupId : selectedMuscleGroupId // ignore: cast_nullable_to_non_nullable
as String?,selectedEquipment: freezed == selectedEquipment ? _self.selectedEquipment : selectedEquipment // ignore: cast_nullable_to_non_nullable
as Equipment?,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as ExerciseCategory?,favouritesOnly: null == favouritesOnly ? _self.favouritesOnly : favouritesOnly // ignore: cast_nullable_to_non_nullable
as bool,muscleGroups: null == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<MuscleGroup>,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,isSeeding: null == isSeeding ? _self.isSeeding : isSeeding // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseListState].
extension ExerciseListStatePatterns on ExerciseListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseListState value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseListState value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchQuery,  String? selectedMuscleGroupId,  Equipment? selectedEquipment,  ExerciseCategory? selectedCategory,  bool favouritesOnly,  List<MuscleGroup> muscleGroups,  List<Exercise> exercises,  bool isSeeding,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseListState() when $default != null:
return $default(_that.searchQuery,_that.selectedMuscleGroupId,_that.selectedEquipment,_that.selectedCategory,_that.favouritesOnly,_that.muscleGroups,_that.exercises,_that.isSeeding,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchQuery,  String? selectedMuscleGroupId,  Equipment? selectedEquipment,  ExerciseCategory? selectedCategory,  bool favouritesOnly,  List<MuscleGroup> muscleGroups,  List<Exercise> exercises,  bool isSeeding,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ExerciseListState():
return $default(_that.searchQuery,_that.selectedMuscleGroupId,_that.selectedEquipment,_that.selectedCategory,_that.favouritesOnly,_that.muscleGroups,_that.exercises,_that.isSeeding,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchQuery,  String? selectedMuscleGroupId,  Equipment? selectedEquipment,  ExerciseCategory? selectedCategory,  bool favouritesOnly,  List<MuscleGroup> muscleGroups,  List<Exercise> exercises,  bool isSeeding,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseListState() when $default != null:
return $default(_that.searchQuery,_that.selectedMuscleGroupId,_that.selectedEquipment,_that.selectedCategory,_that.favouritesOnly,_that.muscleGroups,_that.exercises,_that.isSeeding,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseListState extends ExerciseListState {
  const _ExerciseListState({this.searchQuery = '', this.selectedMuscleGroupId, this.selectedEquipment, this.selectedCategory, this.favouritesOnly = false,  List<MuscleGroup> muscleGroups = const <MuscleGroup>[],  List<Exercise> exercises = const <Exercise>[], this.isSeeding = false, this.errorMessage}): _muscleGroups = muscleGroups,_exercises = exercises,super._();
  

@override@JsonKey() final  String searchQuery;
@override final  String? selectedMuscleGroupId;
@override final  Equipment? selectedEquipment;
@override final  ExerciseCategory? selectedCategory;
@override@JsonKey() final  bool favouritesOnly;
 final  List<MuscleGroup> _muscleGroups;
@override@JsonKey() List<MuscleGroup> get muscleGroups {
  if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscleGroups);
}

 final  List<Exercise> _exercises;
@override@JsonKey() List<Exercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@JsonKey() final  bool isSeeding;
@override final  String? errorMessage;

/// Create a copy of ExerciseListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseListStateCopyWith<_ExerciseListState> get copyWith => __$ExerciseListStateCopyWithImpl<_ExerciseListState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseListState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedMuscleGroupId, selectedMuscleGroupId) || other.selectedMuscleGroupId == selectedMuscleGroupId)&&(identical(other.selectedEquipment, selectedEquipment) || other.selectedEquipment == selectedEquipment)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.favouritesOnly, favouritesOnly) || other.favouritesOnly == favouritesOnly)&&const DeepCollectionEquality().equals(other.muscleGroups, _muscleGroups)&&const DeepCollectionEquality().equals(other.exercises, _exercises)&&(identical(other.isSeeding, isSeeding) || other.isSeeding == isSeeding)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchQuery,selectedMuscleGroupId,selectedEquipment,selectedCategory,favouritesOnly,const DeepCollectionEquality().hash(_muscleGroups),const DeepCollectionEquality().hash(_exercises),isSeeding,errorMessage);
}

@override
String toString() {
    return 'ExerciseListState(searchQuery: $searchQuery, selectedMuscleGroupId: $selectedMuscleGroupId, selectedEquipment: $selectedEquipment, selectedCategory: $selectedCategory, favouritesOnly: $favouritesOnly, muscleGroups: $muscleGroups, exercises: $exercises, isSeeding: $isSeeding, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ExerciseListStateCopyWith<$Res> implements $ExerciseListStateCopyWith<$Res> {
  factory _$ExerciseListStateCopyWith(_ExerciseListState value, $Res Function(_ExerciseListState) _then) = __$ExerciseListStateCopyWithImpl;
@override @useResult
$Res call({
 String searchQuery, String? selectedMuscleGroupId, Equipment? selectedEquipment, ExerciseCategory? selectedCategory, bool favouritesOnly, List<MuscleGroup> muscleGroups, List<Exercise> exercises, bool isSeeding, String? errorMessage
});




}
/// @nodoc
class __$ExerciseListStateCopyWithImpl<$Res>
    implements _$ExerciseListStateCopyWith<$Res> {
  __$ExerciseListStateCopyWithImpl(this._self, this._then);

  final _ExerciseListState _self;
  final $Res Function(_ExerciseListState) _then;

/// Create a copy of ExerciseListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = null,Object? selectedMuscleGroupId = freezed,Object? selectedEquipment = freezed,Object? selectedCategory = freezed,Object? favouritesOnly = null,Object? muscleGroups = null,Object? exercises = null,Object? isSeeding = null,Object? errorMessage = freezed,}) {
  return _then(_ExerciseListState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedMuscleGroupId: freezed == selectedMuscleGroupId ? _self.selectedMuscleGroupId : selectedMuscleGroupId // ignore: cast_nullable_to_non_nullable
as String?,selectedEquipment: freezed == selectedEquipment ? _self.selectedEquipment : selectedEquipment // ignore: cast_nullable_to_non_nullable
as Equipment?,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as ExerciseCategory?,favouritesOnly: null == favouritesOnly ? _self.favouritesOnly : favouritesOnly // ignore: cast_nullable_to_non_nullable
as bool,muscleGroups: null == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<MuscleGroup>,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,isSeeding: null == isSeeding ? _self.isSeeding : isSeeding // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
