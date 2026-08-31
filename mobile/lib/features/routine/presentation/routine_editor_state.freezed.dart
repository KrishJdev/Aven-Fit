// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutineEditorState {

 String? get routineId; String get name; String get description; List<RoutineExercise> get exercises; bool get isSaving; bool get isSaved; String? get errorMessage;
/// Create a copy of RoutineEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineEditorStateCopyWith<RoutineEditorState> get copyWith => _$RoutineEditorStateCopyWithImpl<RoutineEditorState>(this as RoutineEditorState, _$identity);

  /// Serializes this RoutineEditorState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoutineEditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineEditorState&&(identical(other.routineId, _this.routineId) || other.routineId == _this.routineId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.isSaved, _this.isSaved) || other.isSaved == _this.isSaved)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoutineEditorState;
  return Object.hash(runtimeType,_this.routineId,_this.name,_this.description,const DeepCollectionEquality().hash(_this.exercises),_this.isSaving,_this.isSaved,_this.errorMessage);
}

@override
String toString() {
  final _this = this as RoutineEditorState;
  return 'RoutineEditorState(routineId: ${_this.routineId}, name: ${_this.name}, description: ${_this.description}, exercises: ${_this.exercises}, isSaving: ${_this.isSaving}, isSaved: ${_this.isSaved}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $RoutineEditorStateCopyWith<$Res>  {
  factory $RoutineEditorStateCopyWith(RoutineEditorState value, $Res Function(RoutineEditorState) _then) = _$RoutineEditorStateCopyWithImpl;
@useResult
$Res call({
 String? routineId, String name, String description, List<RoutineExercise> exercises, bool isSaving, bool isSaved, String? errorMessage
});




}
/// @nodoc
class _$RoutineEditorStateCopyWithImpl<$Res>
    implements $RoutineEditorStateCopyWith<$Res> {
  _$RoutineEditorStateCopyWithImpl(this._self, this._then);

  final RoutineEditorState _self;
  final $Res Function(RoutineEditorState) _then;

/// Create a copy of RoutineEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = freezed,Object? name = null,Object? description = null,Object? exercises = null,Object? isSaving = null,Object? isSaved = null,Object? errorMessage = freezed,}) {
  return _then(RoutineEditorState(
routineId: freezed == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<RoutineExercise>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineEditorState].
extension RoutineEditorStatePatterns on RoutineEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineEditorState value)  $default,){
final _that = this;
switch (_that) {
case _RoutineEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? routineId,  String name,  String description,  List<RoutineExercise> exercises,  bool isSaving,  bool isSaved,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineEditorState() when $default != null:
return $default(_that.routineId,_that.name,_that.description,_that.exercises,_that.isSaving,_that.isSaved,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? routineId,  String name,  String description,  List<RoutineExercise> exercises,  bool isSaving,  bool isSaved,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _RoutineEditorState():
return $default(_that.routineId,_that.name,_that.description,_that.exercises,_that.isSaving,_that.isSaved,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? routineId,  String name,  String description,  List<RoutineExercise> exercises,  bool isSaving,  bool isSaved,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _RoutineEditorState() when $default != null:
return $default(_that.routineId,_that.name,_that.description,_that.exercises,_that.isSaving,_that.isSaved,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineEditorState extends RoutineEditorState {
  const _RoutineEditorState({this.routineId, this.name = '', this.description = '',  List<RoutineExercise> exercises = const <RoutineExercise>[], this.isSaving = false, this.isSaved = false, this.errorMessage}): _exercises = exercises,super._();
  factory _RoutineEditorState.fromJson(Map<String, dynamic> json) => _$RoutineEditorStateFromJson(json);

@override final  String? routineId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
 final  List<RoutineExercise> _exercises;
@override@JsonKey() List<RoutineExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isSaved;
@override final  String? errorMessage;

/// Create a copy of RoutineEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineEditorStateCopyWith<_RoutineEditorState> get copyWith => __$RoutineEditorStateCopyWithImpl<_RoutineEditorState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineEditorStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineEditorState&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.exercises, _exercises)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,routineId,name,description,const DeepCollectionEquality().hash(_exercises),isSaving,isSaved,errorMessage);
}

@override
String toString() {
    return 'RoutineEditorState(routineId: $routineId, name: $name, description: $description, exercises: $exercises, isSaving: $isSaving, isSaved: $isSaved, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$RoutineEditorStateCopyWith<$Res> implements $RoutineEditorStateCopyWith<$Res> {
  factory _$RoutineEditorStateCopyWith(_RoutineEditorState value, $Res Function(_RoutineEditorState) _then) = __$RoutineEditorStateCopyWithImpl;
@override @useResult
$Res call({
 String? routineId, String name, String description, List<RoutineExercise> exercises, bool isSaving, bool isSaved, String? errorMessage
});




}
/// @nodoc
class __$RoutineEditorStateCopyWithImpl<$Res>
    implements _$RoutineEditorStateCopyWith<$Res> {
  __$RoutineEditorStateCopyWithImpl(this._self, this._then);

  final _RoutineEditorState _self;
  final $Res Function(_RoutineEditorState) _then;

/// Create a copy of RoutineEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = freezed,Object? name = null,Object? description = null,Object? exercises = null,Object? isSaving = null,Object? isSaved = null,Object? errorMessage = freezed,}) {
  return _then(_RoutineEditorState(
routineId: freezed == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<RoutineExercise>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
