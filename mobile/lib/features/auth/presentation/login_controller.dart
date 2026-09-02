import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import 'login_state.dart';

part 'login_controller.g.dart';

/// Riverpod controller for the login flow (WU-5.2, FEATURES.md §6.1).
///
/// Guest is a first-class outcome (L2): "Continue as guest" bypasses the
/// network entirely. An invalid phone never reaches the repository and
/// never navigates (L6); network errors surface with the backend's
/// message and a retry.
@riverpod
class LoginController extends _$LoginController {
  @override
  LoginState build() => const LoginState();

  void setPhone(String raw) {
    final digits = LoginState.normalizePhone(raw);
    state = state.copyWith(
      phone: digits,
      // Editing clears the stale inline error — errors are per-submit.
      inlineError: null,
    );
  }

  void setCountryCode(String code) {
    state = state.copyWith(countryCode: code, inlineError: null);
  }

  void clearInfoMessage() {
    state = state.copyWith(infoMessage: null);
  }

  /// Designed notice for the deferred Google native SDK (see
  /// [kGoogleSignInSetupMessage]); the repository's `loginWithGoogle`
  /// path is fully wired for when credentials land.
  void signInWithGoogle() {
    state = state.copyWith(infoMessage: kGoogleSignInSetupMessage);
  }

  /// Validates, requests the OTP and returns the verification arguments
  /// the OTP screen needs — or null when the flow must not advance
  /// (invalid input or a failed request, L6).
  Future<({String phoneNumber, int expiresInSeconds})?> sendOtp() async {
    final error = validatePhone(state.countryCode, state.phone);
    if (error != null) {
      state = state.copyWith(inlineError: error);
      return null;
    }

    state = state.copyWith(sendingOtp: true, sendError: null);
    try {
      final expiresInSeconds =
          await ref.read(authRepositoryProvider).requestOtp(state.fullPhone);
      if (!ref.mounted) {
        return null;
      }
      state = state.copyWith(sendingOtp: false);
      return (
        phoneNumber: state.fullPhone,
        expiresInSeconds: expiresInSeconds,
      );
    } on AuthException catch (error) {
      if (!ref.mounted) {
        return null;
      }
      state = state.copyWith(sendingOtp: false, sendError: error.message);
      return null;
    } catch (_) {
      if (!ref.mounted) {
        return null;
      }
      state = state.copyWith(sendingOtp: false, sendError: 'Something went wrong. Try again.');
      return null;
    }
  }

  /// Enters guest mode (L2 — works with the network fully down; the
  /// repository generates the stable local identity).
  Future<void> continueAsGuest() async {
    await ref.read(authRepositoryProvider).continueAsGuest();
  }
}
