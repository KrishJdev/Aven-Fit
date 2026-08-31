// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ghost_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GhostSet {

 double? get weightKg; int? get reps; double? get rpe; SetType get setType; GhostSource get source;
/// Create a copy of GhostSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GhostSetCopyWith<GhostSet> get copyWith => _$GhostSetCopyWithImpl<GhostSet>(this as GhostSet, _$identity);

  /// Serializes this GhostSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GhostSet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GhostSet&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.rpe, _this.rpe) || other.rpe == _this.rpe)&&(identical(other.setType, _this.setType) || other.setType == _this.setType)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GhostSet;
  return Object.hash(runtimeType,_this.weightKg,_this.reps,_this.rpe,_this.setType,_this.source);
}

@override
String toString() {
  final _this = this as GhostSet;
  return 'GhostSet(weightKg: ${_this.weightKg}, reps: ${_this.reps}, rpe: ${_this.rpe}, setType: ${_this.setType}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $GhostSetCopyWith<$Res>  {
  factory $GhostSetCopyWith(GhostSet value, $Res Function(GhostSet) _then) = _$GhostSetCopyWithImpl;
@useResult
$Res call({
 double? weightKg, int? reps, double? rpe, SetType setType, GhostSource source
});




}
/// @nodoc
class _$GhostSetCopyWithImpl<$Res>
    implements $GhostSetCopyWith<$Res> {
  _$GhostSetCopyWithImpl(this._self, this._then);

  final GhostSet _self;
  final $Res Function(GhostSet) _then;

/// Create a copy of GhostSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weightKg = freezed,Object? reps = freezed,Object? rpe = freezed,Object? setType = null,Object? source = null,}) {
  return _then(GhostSet(
weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as double?,setType: null == setType ? _self.setType : setType // ignore: cast_nullable_to_non_nullable
as SetType,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as GhostSource,
  ));
}

}


/// Adds pattern-matching-related methods to [GhostSet].
extension GhostSetPatterns on GhostSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GhostSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GhostSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GhostSet value)  $default,){
final _that = this;
switch (_that) {
case _GhostSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GhostSet value)?  $default,){
final _that = this;
switch (_that) {
case _GhostSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? weightKg,  int? reps,  double? rpe,  SetType setType,  GhostSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GhostSet() when $default != null:
return $default(_that.weightKg,_that.reps,_that.rpe,_that.setType,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? weightKg,  int? reps,  double? rpe,  SetType setType,  GhostSource source)  $default,) {final _that = this;
switch (_that) {
case _GhostSet():
return $default(_that.weightKg,_that.reps,_that.rpe,_that.setType,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? weightKg,  int? reps,  double? rpe,  SetType setType,  GhostSource source)?  $default,) {final _that = this;
switch (_that) {
case _GhostSet() when $default != null:
return $default(_that.weightKg,_that.reps,_that.rpe,_that.setType,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GhostSet extends GhostSet {
  const _GhostSet({this.weightKg, this.reps, this.rpe, this.setType = SetType.normal, this.source = GhostSource.none}): super._();
  factory _GhostSet.fromJson(Map<String, dynamic> json) => _$GhostSetFromJson(json);

@override final  double? weightKg;
@override final  int? reps;
@override final  double? rpe;
@override@JsonKey() final  SetType setType;
@override@JsonKey() final  GhostSource source;

/// Create a copy of GhostSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GhostSetCopyWith<_GhostSet> get copyWith => __$GhostSetCopyWithImpl<_GhostSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GhostSetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GhostSet&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.setType, setType) || other.setType == setType)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,weightKg,reps,rpe,setType,source);
}

@override
String toString() {
    return 'GhostSet(weightKg: $weightKg, reps: $reps, rpe: $rpe, setType: $setType, source: $source)';
}


}

/// @nodoc
abstract mixin class _$GhostSetCopyWith<$Res> implements $GhostSetCopyWith<$Res> {
  factory _$GhostSetCopyWith(_GhostSet value, $Res Function(_GhostSet) _then) = __$GhostSetCopyWithImpl;
@override @useResult
$Res call({
 double? weightKg, int? reps, double? rpe, SetType setType, GhostSource source
});




}
/// @nodoc
class __$GhostSetCopyWithImpl<$Res>
    implements _$GhostSetCopyWith<$Res> {
  __$GhostSetCopyWithImpl(this._self, this._then);

  final _GhostSet _self;
  final $Res Function(_GhostSet) _then;

/// Create a copy of GhostSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weightKg = freezed,Object? reps = freezed,Object? rpe = freezed,Object? setType = null,Object? source = null,}) {
  return _then(_GhostSet(
weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as double?,setType: null == setType ? _self.setType : setType // ignore: cast_nullable_to_non_nullable
as SetType,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as GhostSource,
  ));
}


}

// dart format on
