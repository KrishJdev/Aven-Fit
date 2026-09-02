import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_flow_state.freezed.dart';

/// Lifecycle of one OTP verification attempt (§6.2 states — every one
/// is designed, never a blank screen, L6).
enum OtpStatus {
  /// Waiting for the code to be entered.
  idle,

  /// A verification request is in flight.
  verifying,

  /// The backend rejected the code (shake + clear + inline error).
  invalid,

  /// The code outlived its validity window — prompt a resend.
  expired,

  /// Verification succeeded; the screen navigates Home.
  success,
}

/// Immutable OTP-verification flow state (WU-5.2, FEATURES.md §6.2).
///
/// Both countdowns are epoch deadlines (L8): [nowEpochMs] is refreshed
/// by a 1s UI tick and every displayed value is recomputed from the
/// deadlines — zero accumulation drift.
@freezed
sealed class OtpFlowState with _$OtpFlowState {
  const factory OtpFlowState({
    required String phoneNumber,
    @Default('') String otp,
    @Default(OtpStatus.idle) OtpStatus status,
    String? errorMessage,

    /// Epoch ms before which resend is still cooling down.
    required int resendAtEpochMs,

    /// Epoch ms when the code stops being valid.
    required int expiresAtEpochMs,

    /// The tick clock — pure input to the derived getters below.
    required int nowEpochMs,
  }) = _OtpFlowState;

  const OtpFlowState._();

  bool get isComplete => otp.length == 6;

  bool get isVerifying => status == OtpStatus.verifying;

  /// Seconds until resend unlocks (0 when already unlocked).
  int get resendInSeconds {
    final remaining = resendAtEpochMs - nowEpochMs;
    return remaining <= 0 ? 0 : (remaining / 1000).ceil();
  }

  bool get canResend => resendInSeconds == 0;

  /// Seconds until the code expires (0 when already expired).
  int get expiresInSeconds {
    final remaining = expiresAtEpochMs - nowEpochMs;
    return remaining <= 0 ? 0 : (remaining / 1000).ceil();
  }

  bool get isExpired => expiresInSeconds == 0;

  /// MM:SS countdown display ("4:59") for the expiry line.
  String get expiresDisplay {
    final seconds = expiresInSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}
