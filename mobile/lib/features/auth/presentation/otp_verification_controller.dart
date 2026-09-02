import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import 'login_state.dart';
import 'otp_flow_state.dart';

part 'otp_verification_controller.g.dart';

/// Riverpod controller for the OTP verification screen (WU-5.2,
/// FEATURES.md §6.2).
///
/// Auto-submit fires exactly once per filled code (the in-flight guard
/// rejects re-entry); an invalid code clears back to the designed
/// invalid state, an expired one prompts the resend.
@riverpod
class OtpVerificationController extends _$OtpVerificationController {
  /// Injectable clock for deterministic tests (the rest-timer pattern);
  /// production uses wall time.
  DateTime Function() clock = DateTime.now;

  @override
  OtpFlowState build({
    required String phoneNumber,
    required int expiresInSeconds,
  }) {
    final now = clock().millisecondsSinceEpoch;
    // The 1s tick exists only to refresh UI values — every displayed
    // number is recomputed from the epoch deadlines (L8).
    final tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(nowEpochMs: clock().millisecondsSinceEpoch);
    });
    ref.onDispose(tick.cancel);

    return OtpFlowState(
      phoneNumber: phoneNumber,
      resendAtEpochMs: now + kOtpResendCooldownSeconds * 1000,
      expiresAtEpochMs: now + expiresInSeconds * 1000,
      nowEpochMs: now,
    );
  }

  /// Digits only, capped at 6 — editing resets an error state so the
  /// cells start clean (L6).
  void otpChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final otp =
        digits.length > 6 ? digits.substring(0, 6) : digits;
    state = state.copyWith(
      otp: otp,
      status: state.status == OtpStatus.verifying
          ? OtpStatus.verifying
          : OtpStatus.idle,
      errorMessage: null,
    );
  }

  /// Clears the cells (invalid path — shake + clear + error, §6.2).
  void clearOtp() {
    state = state.copyWith(otp: '', status: OtpStatus.idle);
  }

  /// Verifies the entered code. Returns the resulting state; the screen
  /// navigates Home on [OtpStatus.success].
  ///
  /// Guarded against re-entry so auto-submit can only fire exactly once
  /// per code (§6.2).
  Future<OtpFlowState> verify() async {
    if (state.status == OtpStatus.verifying || !state.isComplete) {
      return state;
    }
    state = state.copyWith(status: OtpStatus.verifying, errorMessage: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .loginWithOtp(state.phoneNumber, state.otp);
      if (!ref.mounted) {
        return state;
      }
      return state = state.copyWith(status: OtpStatus.success);
    } on AuthException catch (error) {
      if (!ref.mounted) {
        return state;
      }
      // Expiry is judged against fresh clock time, not the last UI tick
      // (L8) — a rejection past the validity window reads as "expired"
      // (the designed prompt is a resend, not a blame — L4/L6).
      final nowMs = clock().millisecondsSinceEpoch;
      final expired = nowMs >= state.expiresAtEpochMs;
      return state = state.copyWith(
        status: expired ? OtpStatus.expired : OtpStatus.invalid,
        otp: '',
        errorMessage: error.message,
        nowEpochMs: nowMs,
      );
    } catch (_) {
      if (!ref.mounted) {
        return state;
      }
      return state = state.copyWith(
        status: OtpStatus.invalid,
        otp: '',
        errorMessage: 'Something went wrong. Try again.',
      );
    }
  }

  /// Requests a fresh code once the cooldown has elapsed (fresh clock
  /// guard, not the last UI tick). Resets the deadlines and the entry.
  Future<void> resend() async {
    final now = clock().millisecondsSinceEpoch;
    if (now < state.resendAtEpochMs || state.isVerifying) {
      return;
    }
    final nextResendAt = now + kOtpResendCooldownSeconds * 1000;
    state = state.copyWith(
      otp: '',
      status: OtpStatus.idle,
      errorMessage: null,
      resendAtEpochMs: nextResendAt,
      nowEpochMs: now,
    );
    try {
      final expiresInSeconds = await ref
          .read(authRepositoryProvider)
          .requestOtp(state.phoneNumber);
      if (!ref.mounted) {
        return;
      }
      final settled = clock().millisecondsSinceEpoch;
      state = state.copyWith(
        expiresAtEpochMs: settled + expiresInSeconds * 1000,
        nowEpochMs: settled,
      );
    } on AuthException catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(errorMessage: 'Could not resend. Check your connection.');
    }
  }
}
