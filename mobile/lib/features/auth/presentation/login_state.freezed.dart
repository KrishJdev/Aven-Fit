// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {

 String get countryCode; String get phone; String? get inlineError; bool get sendingOtp; String? get sendError;/// One-shot designed notice (currently the Google setup deferral).
 String? get infoMessage;
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStateCopyWith<LoginState> get copyWith => _$LoginStateCopyWithImpl<LoginState>(this as LoginState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LoginState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState&&(identical(other.countryCode, _this.countryCode) || other.countryCode == _this.countryCode)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.inlineError, _this.inlineError) || other.inlineError == _this.inlineError)&&(identical(other.sendingOtp, _this.sendingOtp) || other.sendingOtp == _this.sendingOtp)&&(identical(other.sendError, _this.sendError) || other.sendError == _this.sendError)&&(identical(other.infoMessage, _this.infoMessage) || other.infoMessage == _this.infoMessage));
}


@override
int get hashCode {
  final _this = this as LoginState;
  return Object.hash(runtimeType,_this.countryCode,_this.phone,_this.inlineError,_this.sendingOtp,_this.sendError,_this.infoMessage);
}

@override
String toString() {
  final _this = this as LoginState;
  return 'LoginState(countryCode: ${_this.countryCode}, phone: ${_this.phone}, inlineError: ${_this.inlineError}, sendingOtp: ${_this.sendingOtp}, sendError: ${_this.sendError}, infoMessage: ${_this.infoMessage})';
}


}

/// @nodoc
abstract mixin class $LoginStateCopyWith<$Res>  {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) _then) = _$LoginStateCopyWithImpl;
@useResult
$Res call({
 String countryCode, String phone, String? inlineError, bool sendingOtp, String? sendError, String? infoMessage
});




}
/// @nodoc
class _$LoginStateCopyWithImpl<$Res>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._self, this._then);

  final LoginState _self;
  final $Res Function(LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? countryCode = null,Object? phone = null,Object? inlineError = freezed,Object? sendingOtp = null,Object? sendError = freezed,Object? infoMessage = freezed,}) {
  return _then(LoginState(
countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,inlineError: freezed == inlineError ? _self.inlineError : inlineError // ignore: cast_nullable_to_non_nullable
as String?,sendingOtp: null == sendingOtp ? _self.sendingOtp : sendingOtp // ignore: cast_nullable_to_non_nullable
as bool,sendError: freezed == sendError ? _self.sendError : sendError // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginState value)  $default,){
final _that = this;
switch (_that) {
case _LoginState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String countryCode,  String phone,  String? inlineError,  bool sendingOtp,  String? sendError,  String? infoMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.countryCode,_that.phone,_that.inlineError,_that.sendingOtp,_that.sendError,_that.infoMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String countryCode,  String phone,  String? inlineError,  bool sendingOtp,  String? sendError,  String? infoMessage)  $default,) {final _that = this;
switch (_that) {
case _LoginState():
return $default(_that.countryCode,_that.phone,_that.inlineError,_that.sendingOtp,_that.sendError,_that.infoMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String countryCode,  String phone,  String? inlineError,  bool sendingOtp,  String? sendError,  String? infoMessage)?  $default,) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.countryCode,_that.phone,_that.inlineError,_that.sendingOtp,_that.sendError,_that.infoMessage);case _:
  return null;

}
}

}

/// @nodoc


class _LoginState extends LoginState {
  const _LoginState({this.countryCode = '+91', this.phone = '', this.inlineError, this.sendingOtp = false, this.sendError, this.infoMessage}): super._();
  

@override@JsonKey() final  String countryCode;
@override@JsonKey() final  String phone;
@override final  String? inlineError;
@override@JsonKey() final  bool sendingOtp;
@override final  String? sendError;
/// One-shot designed notice (currently the Google setup deferral).
@override final  String? infoMessage;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginStateCopyWith<_LoginState> get copyWith => __$LoginStateCopyWithImpl<_LoginState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginState&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.inlineError, inlineError) || other.inlineError == inlineError)&&(identical(other.sendingOtp, sendingOtp) || other.sendingOtp == sendingOtp)&&(identical(other.sendError, sendError) || other.sendError == sendError)&&(identical(other.infoMessage, infoMessage) || other.infoMessage == infoMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,countryCode,phone,inlineError,sendingOtp,sendError,infoMessage);
}

@override
String toString() {
    return 'LoginState(countryCode: $countryCode, phone: $phone, inlineError: $inlineError, sendingOtp: $sendingOtp, sendError: $sendError, infoMessage: $infoMessage)';
}


}

/// @nodoc
abstract mixin class _$LoginStateCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory _$LoginStateCopyWith(_LoginState value, $Res Function(_LoginState) _then) = __$LoginStateCopyWithImpl;
@override @useResult
$Res call({
 String countryCode, String phone, String? inlineError, bool sendingOtp, String? sendError, String? infoMessage
});




}
/// @nodoc
class __$LoginStateCopyWithImpl<$Res>
    implements _$LoginStateCopyWith<$Res> {
  __$LoginStateCopyWithImpl(this._self, this._then);

  final _LoginState _self;
  final $Res Function(_LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? countryCode = null,Object? phone = null,Object? inlineError = freezed,Object? sendingOtp = null,Object? sendError = freezed,Object? infoMessage = freezed,}) {
  return _then(_LoginState(
countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,inlineError: freezed == inlineError ? _self.inlineError : inlineError // ignore: cast_nullable_to_non_nullable
as String?,sendingOtp: null == sendingOtp ? _self.sendingOtp : sendingOtp // ignore: cast_nullable_to_non_nullable
as bool,sendError: freezed == sendError ? _self.sendError : sendError // ignore: cast_nullable_to_non_nullable
as String?,infoMessage: freezed == infoMessage ? _self.infoMessage : infoMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
