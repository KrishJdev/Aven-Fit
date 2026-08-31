// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseMuscleRef {

 String? get muscleGroupId; String get name; MuscleRole get role;
/// Create a copy of ExerciseMuscleRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseMuscleRefCopyWith<ExerciseMuscleRef> get copyWith => _$ExerciseMuscleRefCopyWithImpl<ExerciseMuscleRef>(this as ExerciseMuscleRef, _$identity);

  /// Serializes this ExerciseMuscleRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseMuscleRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseMuscleRef&&(identical(other.muscleGroupId, _this.muscleGroupId) || other.muscleGroupId == _this.muscleGroupId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.role, _this.role) || other.role == _this.role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseMuscleRef;
  return Object.hash(runtimeType,_this.muscleGroupId,_this.name,_this.role);
}

@override
String toString() {
  final _this = this as ExerciseMuscleRef;
  return 'ExerciseMuscleRef(muscleGroupId: ${_this.muscleGroupId}, name: ${_this.name}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $ExerciseMuscleRefCopyWith<$Res>  {
  factory $ExerciseMuscleRefCopyWith(ExerciseMuscleRef value, $Res Function(ExerciseMuscleRef) _then) = _$ExerciseMuscleRefCopyWithImpl;
@useResult
$Res call({
 String? muscleGroupId, String name, MuscleRole role
});




}
/// @nodoc
class _$ExerciseMuscleRefCopyWithImpl<$Res>
    implements $ExerciseMuscleRefCopyWith<$Res> {
  _$ExerciseMuscleRefCopyWithImpl(this._self, this._then);

  final ExerciseMuscleRef _self;
  final $Res Function(ExerciseMuscleRef) _then;

/// Create a copy of ExerciseMuscleRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? muscleGroupId = freezed,Object? name = null,Object? role = null,}) {
  return _then(ExerciseMuscleRef(
muscleGroupId: freezed == muscleGroupId ? _self.muscleGroupId : muscleGroupId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MuscleRole,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseMuscleRef].
extension ExerciseMuscleRefPatterns on ExerciseMuscleRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseMuscleRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseMuscleRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseMuscleRef value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseMuscleRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseMuscleRef value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseMuscleRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? muscleGroupId,  String name,  MuscleRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseMuscleRef() when $default != null:
return $default(_that.muscleGroupId,_that.name,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? muscleGroupId,  String name,  MuscleRole role)  $default,) {final _that = this;
switch (_that) {
case _ExerciseMuscleRef():
return $default(_that.muscleGroupId,_that.name,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? muscleGroupId,  String name,  MuscleRole role)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseMuscleRef() when $default != null:
return $default(_that.muscleGroupId,_that.name,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseMuscleRef implements ExerciseMuscleRef {
  const _ExerciseMuscleRef({this.muscleGroupId, required this.name, this.role = MuscleRole.primary});
  factory _ExerciseMuscleRef.fromJson(Map<String, dynamic> json) => _$ExerciseMuscleRefFromJson(json);

@override final  String? muscleGroupId;
@override final  String name;
@override@JsonKey() final  MuscleRole role;

/// Create a copy of ExerciseMuscleRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseMuscleRefCopyWith<_ExerciseMuscleRef> get copyWith => __$ExerciseMuscleRefCopyWithImpl<_ExerciseMuscleRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseMuscleRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseMuscleRef&&(identical(other.muscleGroupId, muscleGroupId) || other.muscleGroupId == muscleGroupId)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,muscleGroupId,name,role);
}

@override
String toString() {
    return 'ExerciseMuscleRef(muscleGroupId: $muscleGroupId, name: $name, role: $role)';
}


}

/// @nodoc
abstract mixin class _$ExerciseMuscleRefCopyWith<$Res> implements $ExerciseMuscleRefCopyWith<$Res> {
  factory _$ExerciseMuscleRefCopyWith(_ExerciseMuscleRef value, $Res Function(_ExerciseMuscleRef) _then) = __$ExerciseMuscleRefCopyWithImpl;
@override @useResult
$Res call({
 String? muscleGroupId, String name, MuscleRole role
});




}
/// @nodoc
class __$ExerciseMuscleRefCopyWithImpl<$Res>
    implements _$ExerciseMuscleRefCopyWith<$Res> {
  __$ExerciseMuscleRefCopyWithImpl(this._self, this._then);

  final _ExerciseMuscleRef _self;
  final $Res Function(_ExerciseMuscleRef) _then;

/// Create a copy of ExerciseMuscleRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? muscleGroupId = freezed,Object? name = null,Object? role = null,}) {
  return _then(_ExerciseMuscleRef(
muscleGroupId: freezed == muscleGroupId ? _self.muscleGroupId : muscleGroupId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MuscleRole,
  ));
}


}


/// @nodoc
mixin _$MuscleGroup {

 String get id; String get name; int get displayOrder; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of MuscleGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleGroupCopyWith<MuscleGroup> get copyWith => _$MuscleGroupCopyWithImpl<MuscleGroup>(this as MuscleGroup, _$identity);

  /// Serializes this MuscleGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MuscleGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleGroup&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.displayOrder, _this.displayOrder) || other.displayOrder == _this.displayOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MuscleGroup;
  return Object.hash(runtimeType,_this.id,_this.name,_this.displayOrder,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as MuscleGroup;
  return 'MuscleGroup(id: ${_this.id}, name: ${_this.name}, displayOrder: ${_this.displayOrder}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MuscleGroupCopyWith<$Res>  {
  factory $MuscleGroupCopyWith(MuscleGroup value, $Res Function(MuscleGroup) _then) = _$MuscleGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, int displayOrder, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$MuscleGroupCopyWithImpl<$Res>
    implements $MuscleGroupCopyWith<$Res> {
  _$MuscleGroupCopyWithImpl(this._self, this._then);

  final MuscleGroup _self;
  final $Res Function(MuscleGroup) _then;

/// Create a copy of MuscleGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? displayOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(MuscleGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleGroup].
extension MuscleGroupPatterns on MuscleGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleGroup value)  $default,){
final _that = this;
switch (_that) {
case _MuscleGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleGroup value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int displayOrder,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleGroup() when $default != null:
return $default(_that.id,_that.name,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int displayOrder,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MuscleGroup():
return $default(_that.id,_that.name,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int displayOrder,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MuscleGroup() when $default != null:
return $default(_that.id,_that.name,_that.displayOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleGroup implements MuscleGroup {
  const _MuscleGroup({required this.id, required this.name, this.displayOrder = 0, this.createdAt, this.updatedAt});
  factory _MuscleGroup.fromJson(Map<String, dynamic> json) => _$MuscleGroupFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  int displayOrder;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of MuscleGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleGroupCopyWith<_MuscleGroup> get copyWith => __$MuscleGroupCopyWithImpl<_MuscleGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleGroupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,displayOrder,createdAt,updatedAt);
}

@override
String toString() {
    return 'MuscleGroup(id: $id, name: $name, displayOrder: $displayOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MuscleGroupCopyWith<$Res> implements $MuscleGroupCopyWith<$Res> {
  factory _$MuscleGroupCopyWith(_MuscleGroup value, $Res Function(_MuscleGroup) _then) = __$MuscleGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int displayOrder, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$MuscleGroupCopyWithImpl<$Res>
    implements _$MuscleGroupCopyWith<$Res> {
  __$MuscleGroupCopyWithImpl(this._self, this._then);

  final _MuscleGroup _self;
  final $Res Function(_MuscleGroup) _then;

/// Create a copy of MuscleGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? displayOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MuscleGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
