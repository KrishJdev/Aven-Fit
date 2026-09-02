import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// Resend-cooldown before a second OTP request (FEATURES.md §6.2 — the
/// 30s timer is enforced client-side regardless of OTP validity).
const int kOtpResendCooldownSeconds = 30;

/// Fallback OTP validity when the backend response lacks one.
const int kDefaultOtpExpirySeconds = 300;

/// Google Sign-In native SDK status (WU-5.2): the button and the
/// repository path (`loginWithGoogle(idToken)`) exist, but the native
/// SDK needs Google Cloud credentials (OAuth client / SHA-1) that are
/// not provisioned yet — the tap surfaces a designed notice instead of
/// a guaranteed runtime failure.
const String kGoogleSignInSetupMessage =
    'Google sign-in is being configured for this build. '
    'Use your phone number or continue as guest for now.';

/// Validation is instant and inline (§6.1): an invalid phone never
/// navigates. 10 digits for Indian numbers (primary), 10–15 for other
/// country codes (NRI users) — mirroring the backend's
/// `^\+?[0-9]{10,15}$` pattern. Null means valid.
String? validatePhone(String countryCode, String digits) {
  if (digits.isEmpty) {
    return 'Enter your phone number.';
  }
  if (countryCode == '+91') {
    if (digits.length != 10) {
      return 'Indian numbers are exactly 10 digits.';
    }
    return null;
  }
  if (digits.length < 10 || digits.length > 15) {
    return 'Phone numbers are 10–15 digits.';
  }
  return null;
}

/// Immutable login-screen flow state (WU-5.2, FEATURES.md §6.1).
@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState({
    @Default('+91') String countryCode,
    @Default('') String phone,
    String? inlineError,
    @Default(false) bool sendingOtp,
    String? sendError,

    /// One-shot designed notice (currently the Google setup deferral).
    String? infoMessage,
  }) = _LoginState;

  const LoginState._();

  /// Digits-only view of the entered phone (what [validatePhone] sees),
  /// capped at the backend's 15-digit maximum.
  static String normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.length > 15 ? digits.substring(0, 15) : digits;
  }

  /// The full E.164-style number sent to the backend.
  String get fullPhone => '$countryCode$phone';
}
