// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_flow_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OtpFlowState {

 String get phoneNumber; String get otp; OtpStatus get status; String? get errorMessage;/// Epoch ms before which resend is still cooling down.
 int get resendAtEpochMs;/// Epoch ms when the code stops being valid.
 int get expiresAtEpochMs;/// The tick clock — pure input to the derived getters below.
 int get nowEpochMs;
/// Create a copy of OtpFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpFlowStateCopyWith<OtpFlowState> get copyWith => _$OtpFlowStateCopyWithImpl<OtpFlowState>(this as OtpFlowState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OtpFlowState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpFlowState&&(identical(other.phoneNumber, _this.phoneNumber) || other.phoneNumber == _this.phoneNumber)&&(identical(other.otp, _this.otp) || other.otp == _this.otp)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.resendAtEpochMs, _this.resendAtEpochMs) || other.resendAtEpochMs == _this.resendAtEpochMs)&&(identical(other.expiresAtEpochMs, _this.expiresAtEpochMs) || other.expiresAtEpochMs == _this.expiresAtEpochMs)&&(identical(other.nowEpochMs, _this.nowEpochMs) || other.nowEpochMs == _this.nowEpochMs));
}


@override
int get hashCode {
  final _this = this as OtpFlowState;
  return Object.hash(runtimeType,_this.phoneNumber,_this.otp,_this.status,_this.errorMessage,_this.resendAtEpochMs,_this.expiresAtEpochMs,_this.nowEpochMs);
}

@override
String toString() {
  final _this = this as OtpFlowState;
  return 'OtpFlowState(phoneNumber: ${_this.phoneNumber}, otp: ${_this.otp}, status: ${_this.status}, errorMessage: ${_this.errorMessage}, resendAtEpochMs: ${_this.resendAtEpochMs}, expiresAtEpochMs: ${_this.expiresAtEpochMs}, nowEpochMs: ${_this.nowEpochMs})';
}


}

/// @nodoc
abstract mixin class $OtpFlowStateCopyWith<$Res>  {
  factory $OtpFlowStateCopyWith(OtpFlowState value, $Res Function(OtpFlowState) _then) = _$OtpFlowStateCopyWithImpl;
@useResult
$Res call({
 String phoneNumber, String otp, OtpStatus status, String? errorMessage, int resendAtEpochMs, int expiresAtEpochMs, int nowEpochMs
});




}
/// @nodoc
class _$OtpFlowStateCopyWithImpl<$Res>
    implements $OtpFlowStateCopyWith<$Res> {
  _$OtpFlowStateCopyWithImpl(this._self, this._then);

  final OtpFlowState _self;
  final $Res Function(OtpFlowState) _then;

/// Create a copy of OtpFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneNumber = null,Object? otp = null,Object? status = null,Object? errorMessage = freezed,Object? resendAtEpochMs = null,Object? expiresAtEpochMs = null,Object? nowEpochMs = null,}) {
  return _then(OtpFlowState(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OtpStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,resendAtEpochMs: null == resendAtEpochMs ? _self.resendAtEpochMs : resendAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,expiresAtEpochMs: null == expiresAtEpochMs ? _self.expiresAtEpochMs : expiresAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,nowEpochMs: null == nowEpochMs ? _self.nowEpochMs : nowEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpFlowState].
extension OtpFlowStatePatterns on OtpFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpFlowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpFlowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpFlowState value)  $default,){
final _that = this;
switch (_that) {
case _OtpFlowState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpFlowState value)?  $default,){
final _that = this;
switch (_that) {
case _OtpFlowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String phoneNumber,  String otp,  OtpStatus status,  String? errorMessage,  int resendAtEpochMs,  int expiresAtEpochMs,  int nowEpochMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpFlowState() when $default != null:
return $default(_that.phoneNumber,_that.otp,_that.status,_that.errorMessage,_that.resendAtEpochMs,_that.expiresAtEpochMs,_that.nowEpochMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String phoneNumber,  String otp,  OtpStatus status,  String? errorMessage,  int resendAtEpochMs,  int expiresAtEpochMs,  int nowEpochMs)  $default,) {final _that = this;
switch (_that) {
case _OtpFlowState():
return $default(_that.phoneNumber,_that.otp,_that.status,_that.errorMessage,_that.resendAtEpochMs,_that.expiresAtEpochMs,_that.nowEpochMs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String phoneNumber,  String otp,  OtpStatus status,  String? errorMessage,  int resendAtEpochMs,  int expiresAtEpochMs,  int nowEpochMs)?  $default,) {final _that = this;
switch (_that) {
case _OtpFlowState() when $default != null:
return $default(_that.phoneNumber,_that.otp,_that.status,_that.errorMessage,_that.resendAtEpochMs,_that.expiresAtEpochMs,_that.nowEpochMs);case _:
  return null;

}
}

}

/// @nodoc


class _OtpFlowState extends OtpFlowState {
  const _OtpFlowState({required this.phoneNumber, this.otp = '', this.status = OtpStatus.idle, this.errorMessage, required this.resendAtEpochMs, required this.expiresAtEpochMs, required this.nowEpochMs}): super._();
  

@override final  String phoneNumber;
@override@JsonKey() final  String otp;
@override@JsonKey() final  OtpStatus status;
@override final  String? errorMessage;
/// Epoch ms before which resend is still cooling down.
@override final  int resendAtEpochMs;
/// Epoch ms when the code stops being valid.
@override final  int expiresAtEpochMs;
/// The tick clock — pure input to the derived getters below.
@override final  int nowEpochMs;

/// Create a copy of OtpFlowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpFlowStateCopyWith<_OtpFlowState> get copyWith => __$OtpFlowStateCopyWithImpl<_OtpFlowState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpFlowState&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.resendAtEpochMs, resendAtEpochMs) || other.resendAtEpochMs == resendAtEpochMs)&&(identical(other.expiresAtEpochMs, expiresAtEpochMs) || other.expiresAtEpochMs == expiresAtEpochMs)&&(identical(other.nowEpochMs, nowEpochMs) || other.nowEpochMs == nowEpochMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phoneNumber,otp,status,errorMessage,resendAtEpochMs,expiresAtEpochMs,nowEpochMs);
}

@override
String toString() {
    return 'OtpFlowState(phoneNumber: $phoneNumber, otp: $otp, status: $status, errorMessage: $errorMessage, resendAtEpochMs: $resendAtEpochMs, expiresAtEpochMs: $expiresAtEpochMs, nowEpochMs: $nowEpochMs)';
}


}

/// @nodoc
abstract mixin class _$OtpFlowStateCopyWith<$Res> implements $OtpFlowStateCopyWith<$Res> {
  factory _$OtpFlowStateCopyWith(_OtpFlowState value, $Res Function(_OtpFlowState) _then) = __$OtpFlowStateCopyWithImpl;
@override @useResult
$Res call({
 String phoneNumber, String otp, OtpStatus status, String? errorMessage, int resendAtEpochMs, int expiresAtEpochMs, int nowEpochMs
});




}
/// @nodoc
class __$OtpFlowStateCopyWithImpl<$Res>
    implements _$OtpFlowStateCopyWith<$Res> {
  __$OtpFlowStateCopyWithImpl(this._self, this._then);

  final _OtpFlowState _self;
  final $Res Function(_OtpFlowState) _then;

/// Create a copy of OtpFlowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneNumber = null,Object? otp = null,Object? status = null,Object? errorMessage = freezed,Object? resendAtEpochMs = null,Object? expiresAtEpochMs = null,Object? nowEpochMs = null,}) {
  return _then(_OtpFlowState(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OtpStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,resendAtEpochMs: null == resendAtEpochMs ? _self.resendAtEpochMs : resendAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,expiresAtEpochMs: null == expiresAtEpochMs ? _self.expiresAtEpochMs : expiresAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,nowEpochMs: null == nowEpochMs ? _self.nowEpochMs : nowEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
