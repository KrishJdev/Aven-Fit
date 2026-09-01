// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FoodSearchState {

 String get searchQuery; bool get vegOnly; bool get satvikOnly; List<FoodItem> get foods;
/// Create a copy of FoodSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodSearchStateCopyWith<FoodSearchState> get copyWith => _$FoodSearchStateCopyWithImpl<FoodSearchState>(this as FoodSearchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FoodSearchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodSearchState&&(identical(other.searchQuery, _this.searchQuery) || other.searchQuery == _this.searchQuery)&&(identical(other.vegOnly, _this.vegOnly) || other.vegOnly == _this.vegOnly)&&(identical(other.satvikOnly, _this.satvikOnly) || other.satvikOnly == _this.satvikOnly)&&const DeepCollectionEquality().equals(other.foods, _this.foods));
}


@override
int get hashCode {
  final _this = this as FoodSearchState;
  return Object.hash(runtimeType,_this.searchQuery,_this.vegOnly,_this.satvikOnly,const DeepCollectionEquality().hash(_this.foods));
}

@override
String toString() {
  final _this = this as FoodSearchState;
  return 'FoodSearchState(searchQuery: ${_this.searchQuery}, vegOnly: ${_this.vegOnly}, satvikOnly: ${_this.satvikOnly}, foods: ${_this.foods})';
}


}

/// @nodoc
abstract mixin class $FoodSearchStateCopyWith<$Res>  {
  factory $FoodSearchStateCopyWith(FoodSearchState value, $Res Function(FoodSearchState) _then) = _$FoodSearchStateCopyWithImpl;
@useResult
$Res call({
 String searchQuery, bool vegOnly, bool satvikOnly, List<FoodItem> foods
});




}
/// @nodoc
class _$FoodSearchStateCopyWithImpl<$Res>
    implements $FoodSearchStateCopyWith<$Res> {
  _$FoodSearchStateCopyWithImpl(this._self, this._then);

  final FoodSearchState _self;
  final $Res Function(FoodSearchState) _then;

/// Create a copy of FoodSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = null,Object? vegOnly = null,Object? satvikOnly = null,Object? foods = null,}) {
  return _then(FoodSearchState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,vegOnly: null == vegOnly ? _self.vegOnly : vegOnly // ignore: cast_nullable_to_non_nullable
as bool,satvikOnly: null == satvikOnly ? _self.satvikOnly : satvikOnly // ignore: cast_nullable_to_non_nullable
as bool,foods: null == foods ? _self.foods : foods // ignore: cast_nullable_to_non_nullable
as List<FoodItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodSearchState].
extension FoodSearchStatePatterns on FoodSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodSearchState value)  $default,){
final _that = this;
switch (_that) {
case _FoodSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _FoodSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchQuery,  bool vegOnly,  bool satvikOnly,  List<FoodItem> foods)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodSearchState() when $default != null:
return $default(_that.searchQuery,_that.vegOnly,_that.satvikOnly,_that.foods);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchQuery,  bool vegOnly,  bool satvikOnly,  List<FoodItem> foods)  $default,) {final _that = this;
switch (_that) {
case _FoodSearchState():
return $default(_that.searchQuery,_that.vegOnly,_that.satvikOnly,_that.foods);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchQuery,  bool vegOnly,  bool satvikOnly,  List<FoodItem> foods)?  $default,) {final _that = this;
switch (_that) {
case _FoodSearchState() when $default != null:
return $default(_that.searchQuery,_that.vegOnly,_that.satvikOnly,_that.foods);case _:
  return null;

}
}

}

/// @nodoc


class _FoodSearchState extends FoodSearchState {
  const _FoodSearchState({this.searchQuery = '', this.vegOnly = false, this.satvikOnly = false,  List<FoodItem> foods = const <FoodItem>[]}): _foods = foods,super._();
  

@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  bool vegOnly;
@override@JsonKey() final  bool satvikOnly;
 final  List<FoodItem> _foods;
@override@JsonKey() List<FoodItem> get foods {
  if (_foods is EqualUnmodifiableListView) return _foods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_foods);
}


/// Create a copy of FoodSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodSearchStateCopyWith<_FoodSearchState> get copyWith => __$FoodSearchStateCopyWithImpl<_FoodSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodSearchState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.vegOnly, vegOnly) || other.vegOnly == vegOnly)&&(identical(other.satvikOnly, satvikOnly) || other.satvikOnly == satvikOnly)&&const DeepCollectionEquality().equals(other.foods, _foods));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchQuery,vegOnly,satvikOnly,const DeepCollectionEquality().hash(_foods));
}

@override
String toString() {
    return 'FoodSearchState(searchQuery: $searchQuery, vegOnly: $vegOnly, satvikOnly: $satvikOnly, foods: $foods)';
}


}

/// @nodoc
abstract mixin class _$FoodSearchStateCopyWith<$Res> implements $FoodSearchStateCopyWith<$Res> {
  factory _$FoodSearchStateCopyWith(_FoodSearchState value, $Res Function(_FoodSearchState) _then) = __$FoodSearchStateCopyWithImpl;
@override @useResult
$Res call({
 String searchQuery, bool vegOnly, bool satvikOnly, List<FoodItem> foods
});




}
/// @nodoc
class __$FoodSearchStateCopyWithImpl<$Res>
    implements _$FoodSearchStateCopyWith<$Res> {
  __$FoodSearchStateCopyWithImpl(this._self, this._then);

  final _FoodSearchState _self;
  final $Res Function(_FoodSearchState) _then;

/// Create a copy of FoodSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = null,Object? vegOnly = null,Object? satvikOnly = null,Object? foods = null,}) {
  return _then(_FoodSearchState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,vegOnly: null == vegOnly ? _self.vegOnly : vegOnly // ignore: cast_nullable_to_non_nullable
as bool,satvikOnly: null == satvikOnly ? _self.satvikOnly : satvikOnly // ignore: cast_nullable_to_non_nullable
as bool,foods: null == foods ? _self._foods : foods // ignore: cast_nullable_to_non_nullable
as List<FoodItem>,
  ));
}


}

// dart format on
