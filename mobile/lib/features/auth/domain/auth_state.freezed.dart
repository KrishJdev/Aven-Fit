// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthLoading value)?  loading,TResult Function( AuthGuest value)?  guest,TResult Function( AuthAuthenticated value)?  authenticated,TResult Function( AuthError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthLoading() when loading != null:
return loading(_that);case AuthGuest() when guest != null:
return guest(_that);case AuthAuthenticated() when authenticated != null:
return authenticated(_that);case AuthError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthLoading value)  loading,required TResult Function( AuthGuest value)  guest,required TResult Function( AuthAuthenticated value)  authenticated,required TResult Function( AuthError value)  error,}){
final _that = this;
switch (_that) {
case AuthLoading():
return loading(_that);case AuthGuest():
return guest(_that);case AuthAuthenticated():
return authenticated(_that);case AuthError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthLoading value)?  loading,TResult? Function( AuthGuest value)?  guest,TResult? Function( AuthAuthenticated value)?  authenticated,TResult? Function( AuthError value)?  error,}){
final _that = this;
switch (_that) {
case AuthLoading() when loading != null:
return loading(_that);case AuthGuest() when guest != null:
return guest(_that);case AuthAuthenticated() when authenticated != null:
return authenticated(_that);case AuthError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( String clientUuid)?  guest,TResult Function( String userId,  String accessToken,  String refreshToken,  String? displayName,  String? phoneNumber)?  authenticated,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthLoading() when loading != null:
return loading();case AuthGuest() when guest != null:
return guest(_that.clientUuid);case AuthAuthenticated() when authenticated != null:
return authenticated(_that.userId,_that.accessToken,_that.refreshToken,_that.displayName,_that.phoneNumber);case AuthError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( String clientUuid)  guest,required TResult Function( String userId,  String accessToken,  String refreshToken,  String? displayName,  String? phoneNumber)  authenticated,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case AuthLoading():
return loading();case AuthGuest():
return guest(_that.clientUuid);case AuthAuthenticated():
return authenticated(_that.userId,_that.accessToken,_that.refreshToken,_that.displayName,_that.phoneNumber);case AuthError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( String clientUuid)?  guest,TResult? Function( String userId,  String accessToken,  String refreshToken,  String? displayName,  String? phoneNumber)?  authenticated,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case AuthLoading() when loading != null:
return loading();case AuthGuest() when guest != null:
return guest(_that.clientUuid);case AuthAuthenticated() when authenticated != null:
return authenticated(_that.userId,_that.accessToken,_that.refreshToken,_that.displayName,_that.phoneNumber);case AuthError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AuthLoading implements AuthState {
  const AuthLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthState.loading()';
}


}




/// @nodoc


class AuthGuest implements AuthState {
  const AuthGuest({required this.clientUuid});
  

 final  String clientUuid;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthGuestCopyWith<AuthGuest> get copyWith => _$AuthGuestCopyWithImpl<AuthGuest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthGuest&&(identical(other.clientUuid, clientUuid) || other.clientUuid == clientUuid));
}


@override
int get hashCode {
    return Object.hash(runtimeType,clientUuid);
}

@override
String toString() {
    return 'AuthState.guest(clientUuid: $clientUuid)';
}


}

/// @nodoc
abstract mixin class $AuthGuestCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthGuestCopyWith(AuthGuest value, $Res Function(AuthGuest) _then) = _$AuthGuestCopyWithImpl;
@useResult
$Res call({
 String clientUuid
});




}
/// @nodoc
class _$AuthGuestCopyWithImpl<$Res>
    implements $AuthGuestCopyWith<$Res> {
  _$AuthGuestCopyWithImpl(this._self, this._then);

  final AuthGuest _self;
  final $Res Function(AuthGuest) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? clientUuid = null,}) {
  return _then(AuthGuest(
clientUuid: null == clientUuid ? _self.clientUuid : clientUuid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthAuthenticated implements AuthState {
  const AuthAuthenticated({required this.userId, required this.accessToken, required this.refreshToken, this.displayName, this.phoneNumber});
  

 final  String userId;
 final  String accessToken;
 final  String refreshToken;
 final  String? displayName;
 final  String? phoneNumber;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAuthenticatedCopyWith<AuthAuthenticated> get copyWith => _$AuthAuthenticatedCopyWithImpl<AuthAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAuthenticated&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,accessToken,refreshToken,displayName,phoneNumber);
}

@override
String toString() {
    return 'AuthState.authenticated(userId: $userId, accessToken: $accessToken, refreshToken: $refreshToken, displayName: $displayName, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class $AuthAuthenticatedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthAuthenticatedCopyWith(AuthAuthenticated value, $Res Function(AuthAuthenticated) _then) = _$AuthAuthenticatedCopyWithImpl;
@useResult
$Res call({
 String userId, String accessToken, String refreshToken, String? displayName, String? phoneNumber
});




}
/// @nodoc
class _$AuthAuthenticatedCopyWithImpl<$Res>
    implements $AuthAuthenticatedCopyWith<$Res> {
  _$AuthAuthenticatedCopyWithImpl(this._self, this._then);

  final AuthAuthenticated _self;
  final $Res Function(AuthAuthenticated) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? accessToken = null,Object? refreshToken = null,Object? displayName = freezed,Object? phoneNumber = freezed,}) {
  return _then(AuthAuthenticated(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class AuthError implements AuthState {
  const AuthError({required this.message});
  

 final  String message;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthErrorCopyWith<AuthError> get copyWith => _$AuthErrorCopyWithImpl<AuthError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AuthState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthErrorCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthErrorCopyWith(AuthError value, $Res Function(AuthError) _then) = _$AuthErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AuthErrorCopyWithImpl<$Res>
    implements $AuthErrorCopyWith<$Res> {
  _$AuthErrorCopyWithImpl(this._self, this._then);

  final AuthError _self;
  final $Res Function(AuthError) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AuthError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
