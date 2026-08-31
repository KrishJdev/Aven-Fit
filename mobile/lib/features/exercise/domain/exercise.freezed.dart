// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {

 String get id; String get name; String? get description; ExerciseCategory get category; Equipment get equipment; bool get isCustom; bool get isFavourite; bool get isTimeBased; bool get isCardio; String? get primaryMuscle; List<String> get secondaryMuscles; List<ExerciseMuscleRef> get muscleRefs; String? get createdById; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseCopyWith<Exercise> get copyWith => _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Exercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.equipment, _this.equipment) || other.equipment == _this.equipment)&&(identical(other.isCustom, _this.isCustom) || other.isCustom == _this.isCustom)&&(identical(other.isFavourite, _this.isFavourite) || other.isFavourite == _this.isFavourite)&&(identical(other.isTimeBased, _this.isTimeBased) || other.isTimeBased == _this.isTimeBased)&&(identical(other.isCardio, _this.isCardio) || other.isCardio == _this.isCardio)&&(identical(other.primaryMuscle, _this.primaryMuscle) || other.primaryMuscle == _this.primaryMuscle)&&const DeepCollectionEquality().equals(other.secondaryMuscles, _this.secondaryMuscles)&&const DeepCollectionEquality().equals(other.muscleRefs, _this.muscleRefs)&&(identical(other.createdById, _this.createdById) || other.createdById == _this.createdById)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Exercise;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.category,_this.equipment,_this.isCustom,_this.isFavourite,_this.isTimeBased,_this.isCardio,_this.primaryMuscle,const DeepCollectionEquality().hash(_this.secondaryMuscles),const DeepCollectionEquality().hash(_this.muscleRefs),_this.createdById,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Exercise;
  return 'Exercise(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, category: ${_this.category}, equipment: ${_this.equipment}, isCustom: ${_this.isCustom}, isFavourite: ${_this.isFavourite}, isTimeBased: ${_this.isTimeBased}, isCardio: ${_this.isCardio}, primaryMuscle: ${_this.primaryMuscle}, secondaryMuscles: ${_this.secondaryMuscles}, muscleRefs: ${_this.muscleRefs}, createdById: ${_this.createdById}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res>  {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) = _$ExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, ExerciseCategory category, Equipment equipment, bool isCustom, bool isFavourite, bool isTimeBased, bool isCardio, String? primaryMuscle, List<String> secondaryMuscles, List<ExerciseMuscleRef> muscleRefs, String? createdById, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ExerciseCopyWithImpl<$Res>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? category = null,Object? equipment = null,Object? isCustom = null,Object? isFavourite = null,Object? isTimeBased = null,Object? isCardio = null,Object? primaryMuscle = freezed,Object? secondaryMuscles = null,Object? muscleRefs = null,Object? createdById = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as Equipment,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,isTimeBased: null == isTimeBased ? _self.isTimeBased : isTimeBased // ignore: cast_nullable_to_non_nullable
as bool,isCardio: null == isCardio ? _self.isCardio : isCardio // ignore: cast_nullable_to_non_nullable
as bool,primaryMuscle: freezed == primaryMuscle ? _self.primaryMuscle : primaryMuscle // ignore: cast_nullable_to_non_nullable
as String?,secondaryMuscles: null == secondaryMuscles ? _self.secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,muscleRefs: null == muscleRefs ? _self.muscleRefs : muscleRefs // ignore: cast_nullable_to_non_nullable
as List<ExerciseMuscleRef>,createdById: freezed == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exercise value)  $default,){
final _that = this;
switch (_that) {
case _Exercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exercise value)?  $default,){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  ExerciseCategory category,  Equipment equipment,  bool isCustom,  bool isFavourite,  bool isTimeBased,  bool isCardio,  String? primaryMuscle,  List<String> secondaryMuscles,  List<ExerciseMuscleRef> muscleRefs,  String? createdById,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.equipment,_that.isCustom,_that.isFavourite,_that.isTimeBased,_that.isCardio,_that.primaryMuscle,_that.secondaryMuscles,_that.muscleRefs,_that.createdById,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  ExerciseCategory category,  Equipment equipment,  bool isCustom,  bool isFavourite,  bool isTimeBased,  bool isCardio,  String? primaryMuscle,  List<String> secondaryMuscles,  List<ExerciseMuscleRef> muscleRefs,  String? createdById,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Exercise():
return $default(_that.id,_that.name,_that.description,_that.category,_that.equipment,_that.isCustom,_that.isFavourite,_that.isTimeBased,_that.isCardio,_that.primaryMuscle,_that.secondaryMuscles,_that.muscleRefs,_that.createdById,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  ExerciseCategory category,  Equipment equipment,  bool isCustom,  bool isFavourite,  bool isTimeBased,  bool isCardio,  String? primaryMuscle,  List<String> secondaryMuscles,  List<ExerciseMuscleRef> muscleRefs,  String? createdById,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.equipment,_that.isCustom,_that.isFavourite,_that.isTimeBased,_that.isCardio,_that.primaryMuscle,_that.secondaryMuscles,_that.muscleRefs,_that.createdById,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Exercise extends Exercise {
  const _Exercise({required this.id, required this.name, this.description, this.category = ExerciseCategory.other, this.equipment = Equipment.none, this.isCustom = false, this.isFavourite = false, this.isTimeBased = false, this.isCardio = false, this.primaryMuscle,  List<String> secondaryMuscles = const <String>[],  List<ExerciseMuscleRef> muscleRefs = const <ExerciseMuscleRef>[], this.createdById, this.createdAt, this.updatedAt}): _secondaryMuscles = secondaryMuscles,_muscleRefs = muscleRefs,super._();
  factory _Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  ExerciseCategory category;
@override@JsonKey() final  Equipment equipment;
@override@JsonKey() final  bool isCustom;
@override@JsonKey() final  bool isFavourite;
@override@JsonKey() final  bool isTimeBased;
@override@JsonKey() final  bool isCardio;
@override final  String? primaryMuscle;
 final  List<String> _secondaryMuscles;
@override@JsonKey() List<String> get secondaryMuscles {
  if (_secondaryMuscles is EqualUnmodifiableListView) return _secondaryMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryMuscles);
}

 final  List<ExerciseMuscleRef> _muscleRefs;
@override@JsonKey() List<ExerciseMuscleRef> get muscleRefs {
  if (_muscleRefs is EqualUnmodifiableListView) return _muscleRefs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscleRefs);
}

@override final  String? createdById;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseCopyWith<_Exercise> get copyWith => __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.isFavourite, isFavourite) || other.isFavourite == isFavourite)&&(identical(other.isTimeBased, isTimeBased) || other.isTimeBased == isTimeBased)&&(identical(other.isCardio, isCardio) || other.isCardio == isCardio)&&(identical(other.primaryMuscle, primaryMuscle) || other.primaryMuscle == primaryMuscle)&&const DeepCollectionEquality().equals(other.secondaryMuscles, _secondaryMuscles)&&const DeepCollectionEquality().equals(other.muscleRefs, _muscleRefs)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,category,equipment,isCustom,isFavourite,isTimeBased,isCardio,primaryMuscle,const DeepCollectionEquality().hash(_secondaryMuscles),const DeepCollectionEquality().hash(_muscleRefs),createdById,createdAt,updatedAt);
}

@override
String toString() {
    return 'Exercise(id: $id, name: $name, description: $description, category: $category, equipment: $equipment, isCustom: $isCustom, isFavourite: $isFavourite, isTimeBased: $isTimeBased, isCardio: $isCardio, primaryMuscle: $primaryMuscle, secondaryMuscles: $secondaryMuscles, muscleRefs: $muscleRefs, createdById: $createdById, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res> implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) = __$ExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, ExerciseCategory category, Equipment equipment, bool isCustom, bool isFavourite, bool isTimeBased, bool isCardio, String? primaryMuscle, List<String> secondaryMuscles, List<ExerciseMuscleRef> muscleRefs, String? createdById, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ExerciseCopyWithImpl<$Res>
    implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? category = null,Object? equipment = null,Object? isCustom = null,Object? isFavourite = null,Object? isTimeBased = null,Object? isCardio = null,Object? primaryMuscle = freezed,Object? secondaryMuscles = null,Object? muscleRefs = null,Object? createdById = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as Equipment,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,isTimeBased: null == isTimeBased ? _self.isTimeBased : isTimeBased // ignore: cast_nullable_to_non_nullable
as bool,isCardio: null == isCardio ? _self.isCardio : isCardio // ignore: cast_nullable_to_non_nullable
as bool,primaryMuscle: freezed == primaryMuscle ? _self.primaryMuscle : primaryMuscle // ignore: cast_nullable_to_non_nullable
as String?,secondaryMuscles: null == secondaryMuscles ? _self._secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,muscleRefs: null == muscleRefs ? _self._muscleRefs : muscleRefs // ignore: cast_nullable_to_non_nullable
as List<ExerciseMuscleRef>,createdById: freezed == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
