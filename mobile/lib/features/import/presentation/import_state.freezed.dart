// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportState {

 ImportStatus get status; String? get fileName; ParsedCsvSummary? get summary; Map<String, ExerciseMatchResult> get matchResults; ImportResult? get result; String? get errorMessage;
/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportStateCopyWith<ImportState> get copyWith => _$ImportStateCopyWithImpl<ImportState>(this as ImportState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ImportState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&const DeepCollectionEquality().equals(other.matchResults, _this.matchResults)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as ImportState;
  return Object.hash(runtimeType,_this.status,_this.fileName,_this.summary,const DeepCollectionEquality().hash(_this.matchResults),_this.result,_this.errorMessage);
}

@override
String toString() {
  final _this = this as ImportState;
  return 'ImportState(status: ${_this.status}, fileName: ${_this.fileName}, summary: ${_this.summary}, matchResults: ${_this.matchResults}, result: ${_this.result}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $ImportStateCopyWith<$Res>  {
  factory $ImportStateCopyWith(ImportState value, $Res Function(ImportState) _then) = _$ImportStateCopyWithImpl;
@useResult
$Res call({
 ImportStatus status, String? fileName, ParsedCsvSummary? summary, Map<String, ExerciseMatchResult> matchResults, ImportResult? result, String? errorMessage
});




}
/// @nodoc
class _$ImportStateCopyWithImpl<$Res>
    implements $ImportStateCopyWith<$Res> {
  _$ImportStateCopyWithImpl(this._self, this._then);

  final ImportState _self;
  final $Res Function(ImportState) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? fileName = freezed,Object? summary = freezed,Object? matchResults = null,Object? result = freezed,Object? errorMessage = freezed,}) {
  return _then(ImportState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ImportStatus,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ParsedCsvSummary?,matchResults: null == matchResults ? _self.matchResults : matchResults // ignore: cast_nullable_to_non_nullable
as Map<String, ExerciseMatchResult>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ImportResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportState].
extension ImportStatePatterns on ImportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportState value)  $default,){
final _that = this;
switch (_that) {
case _ImportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportState value)?  $default,){
final _that = this;
switch (_that) {
case _ImportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ImportStatus status,  String? fileName,  ParsedCsvSummary? summary,  Map<String, ExerciseMatchResult> matchResults,  ImportResult? result,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportState() when $default != null:
return $default(_that.status,_that.fileName,_that.summary,_that.matchResults,_that.result,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ImportStatus status,  String? fileName,  ParsedCsvSummary? summary,  Map<String, ExerciseMatchResult> matchResults,  ImportResult? result,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ImportState():
return $default(_that.status,_that.fileName,_that.summary,_that.matchResults,_that.result,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ImportStatus status,  String? fileName,  ParsedCsvSummary? summary,  Map<String, ExerciseMatchResult> matchResults,  ImportResult? result,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ImportState() when $default != null:
return $default(_that.status,_that.fileName,_that.summary,_that.matchResults,_that.result,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ImportState extends ImportState {
  const _ImportState({this.status = ImportStatus.idle, this.fileName, this.summary,  Map<String, ExerciseMatchResult> matchResults = const <String, ExerciseMatchResult>{}, this.result, this.errorMessage}): _matchResults = matchResults,super._();
  

@override@JsonKey() final  ImportStatus status;
@override final  String? fileName;
@override final  ParsedCsvSummary? summary;
 final  Map<String, ExerciseMatchResult> _matchResults;
@override@JsonKey() Map<String, ExerciseMatchResult> get matchResults {
  if (_matchResults is EqualUnmodifiableMapView) return _matchResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_matchResults);
}

@override final  ImportResult? result;
@override final  String? errorMessage;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportStateCopyWith<_ImportState> get copyWith => __$ImportStateCopyWithImpl<_ImportState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportState&&(identical(other.status, status) || other.status == status)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.matchResults, _matchResults)&&(identical(other.result, result) || other.result == result)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,fileName,summary,const DeepCollectionEquality().hash(_matchResults),result,errorMessage);
}

@override
String toString() {
    return 'ImportState(status: $status, fileName: $fileName, summary: $summary, matchResults: $matchResults, result: $result, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ImportStateCopyWith<$Res> implements $ImportStateCopyWith<$Res> {
  factory _$ImportStateCopyWith(_ImportState value, $Res Function(_ImportState) _then) = __$ImportStateCopyWithImpl;
@override @useResult
$Res call({
 ImportStatus status, String? fileName, ParsedCsvSummary? summary, Map<String, ExerciseMatchResult> matchResults, ImportResult? result, String? errorMessage
});




}
/// @nodoc
class __$ImportStateCopyWithImpl<$Res>
    implements _$ImportStateCopyWith<$Res> {
  __$ImportStateCopyWithImpl(this._self, this._then);

  final _ImportState _self;
  final $Res Function(_ImportState) _then;

/// Create a copy of ImportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? fileName = freezed,Object? summary = freezed,Object? matchResults = null,Object? result = freezed,Object? errorMessage = freezed,}) {
  return _then(_ImportState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ImportStatus,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ParsedCsvSummary?,matchResults: null == matchResults ? _self._matchResults : matchResults // ignore: cast_nullable_to_non_nullable
as Map<String, ExerciseMatchResult>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ImportResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
