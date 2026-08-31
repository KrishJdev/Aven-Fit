// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pr_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PRRecord {

 String get id; String get exerciseId; RecordType get recordType; double get value;/// Weight key for [RecordType.maxRepsAtWeight] records; null otherwise.
 double? get weightKg; DateTime get achievedAt; String? get sessionId; String? get setId; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PRRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PRRecordCopyWith<PRRecord> get copyWith => _$PRRecordCopyWithImpl<PRRecord>(this as PRRecord, _$identity);

  /// Serializes this PRRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PRRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PRRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.recordType, _this.recordType) || other.recordType == _this.recordType)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.achievedAt, _this.achievedAt) || other.achievedAt == _this.achievedAt)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.setId, _this.setId) || other.setId == _this.setId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PRRecord;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.recordType,_this.value,_this.weightKg,_this.achievedAt,_this.sessionId,_this.setId,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as PRRecord;
  return 'PRRecord(id: ${_this.id}, exerciseId: ${_this.exerciseId}, recordType: ${_this.recordType}, value: ${_this.value}, weightKg: ${_this.weightKg}, achievedAt: ${_this.achievedAt}, sessionId: ${_this.sessionId}, setId: ${_this.setId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $PRRecordCopyWith<$Res>  {
  factory $PRRecordCopyWith(PRRecord value, $Res Function(PRRecord) _then) = _$PRRecordCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, RecordType recordType, double value, double? weightKg, DateTime achievedAt, String? sessionId, String? setId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PRRecordCopyWithImpl<$Res>
    implements $PRRecordCopyWith<$Res> {
  _$PRRecordCopyWithImpl(this._self, this._then);

  final PRRecord _self;
  final $Res Function(PRRecord) _then;

/// Create a copy of PRRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? recordType = null,Object? value = null,Object? weightKg = freezed,Object? achievedAt = null,Object? sessionId = freezed,Object? setId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(PRRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,recordType: null == recordType ? _self.recordType : recordType // ignore: cast_nullable_to_non_nullable
as RecordType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,setId: freezed == setId ? _self.setId : setId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PRRecord].
extension PRRecordPatterns on PRRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PRRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PRRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PRRecord value)  $default,){
final _that = this;
switch (_that) {
case _PRRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PRRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PRRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  RecordType recordType,  double value,  double? weightKg,  DateTime achievedAt,  String? sessionId,  String? setId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PRRecord() when $default != null:
return $default(_that.id,_that.exerciseId,_that.recordType,_that.value,_that.weightKg,_that.achievedAt,_that.sessionId,_that.setId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  RecordType recordType,  double value,  double? weightKg,  DateTime achievedAt,  String? sessionId,  String? setId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PRRecord():
return $default(_that.id,_that.exerciseId,_that.recordType,_that.value,_that.weightKg,_that.achievedAt,_that.sessionId,_that.setId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  RecordType recordType,  double value,  double? weightKg,  DateTime achievedAt,  String? sessionId,  String? setId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PRRecord() when $default != null:
return $default(_that.id,_that.exerciseId,_that.recordType,_that.value,_that.weightKg,_that.achievedAt,_that.sessionId,_that.setId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PRRecord implements PRRecord {
  const _PRRecord({required this.id, required this.exerciseId, required this.recordType, required this.value, this.weightKg, required this.achievedAt, this.sessionId, this.setId, this.createdAt, this.updatedAt});
  factory _PRRecord.fromJson(Map<String, dynamic> json) => _$PRRecordFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  RecordType recordType;
@override final  double value;
/// Weight key for [RecordType.maxRepsAtWeight] records; null otherwise.
@override final  double? weightKg;
@override final  DateTime achievedAt;
@override final  String? sessionId;
@override final  String? setId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PRRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PRRecordCopyWith<_PRRecord> get copyWith => __$PRRecordCopyWithImpl<_PRRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PRRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PRRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.recordType, recordType) || other.recordType == recordType)&&(identical(other.value, value) || other.value == value)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.setId, setId) || other.setId == setId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,recordType,value,weightKg,achievedAt,sessionId,setId,createdAt,updatedAt);
}

@override
String toString() {
    return 'PRRecord(id: $id, exerciseId: $exerciseId, recordType: $recordType, value: $value, weightKg: $weightKg, achievedAt: $achievedAt, sessionId: $sessionId, setId: $setId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PRRecordCopyWith<$Res> implements $PRRecordCopyWith<$Res> {
  factory _$PRRecordCopyWith(_PRRecord value, $Res Function(_PRRecord) _then) = __$PRRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, RecordType recordType, double value, double? weightKg, DateTime achievedAt, String? sessionId, String? setId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PRRecordCopyWithImpl<$Res>
    implements _$PRRecordCopyWith<$Res> {
  __$PRRecordCopyWithImpl(this._self, this._then);

  final _PRRecord _self;
  final $Res Function(_PRRecord) _then;

/// Create a copy of PRRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? recordType = null,Object? value = null,Object? weightKg = freezed,Object? achievedAt = null,Object? sessionId = freezed,Object? setId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PRRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,recordType: null == recordType ? _self.recordType : recordType // ignore: cast_nullable_to_non_nullable
as RecordType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,setId: freezed == setId ? _self.setId : setId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
