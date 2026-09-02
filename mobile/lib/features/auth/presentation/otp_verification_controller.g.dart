// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller for the OTP verification screen (WU-5.2,
/// FEATURES.md §6.2).
///
/// Auto-submit fires exactly once per filled code (the in-flight guard
/// rejects re-entry); an invalid code clears back to the designed
/// invalid state, an expired one prompts the resend.

@ProviderFor(OtpVerificationController)
final otpVerificationControllerProvider = OtpVerificationControllerFamily._();

/// Riverpod controller for the OTP verification screen (WU-5.2,
/// FEATURES.md §6.2).
///
/// Auto-submit fires exactly once per filled code (the in-flight guard
/// rejects re-entry); an invalid code clears back to the designed
/// invalid state, an expired one prompts the resend.
final class OtpVerificationControllerProvider
    extends $NotifierProvider<OtpVerificationController, OtpFlowState> {
  /// Riverpod controller for the OTP verification screen (WU-5.2,
  /// FEATURES.md §6.2).
  ///
  /// Auto-submit fires exactly once per filled code (the in-flight guard
  /// rejects re-entry); an invalid code clears back to the designed
  /// invalid state, an expired one prompts the resend.
  OtpVerificationControllerProvider._({
    required OtpVerificationControllerFamily super.from,
    required ({String phoneNumber, int expiresInSeconds}) super.argument,
  }) : super(
         retry: null,
         name: r'otpVerificationControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$otpVerificationControllerHash();

  @override
  String toString() {
    return r'otpVerificationControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  OtpVerificationController create() => OtpVerificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OtpFlowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OtpFlowState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OtpVerificationControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$otpVerificationControllerHash() =>
    r'e35b72dbce23160841ddea191a0a4ddd781616fe';

/// Riverpod controller for the OTP verification screen (WU-5.2,
/// FEATURES.md §6.2).
///
/// Auto-submit fires exactly once per filled code (the in-flight guard
/// rejects re-entry); an invalid code clears back to the designed
/// invalid state, an expired one prompts the resend.

final class OtpVerificationControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          OtpVerificationController,
          OtpFlowState,
          OtpFlowState,
          OtpFlowState,
          ({String phoneNumber, int expiresInSeconds})
        > {
  OtpVerificationControllerFamily._()
    : super(
        retry: null,
        name: r'otpVerificationControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod controller for the OTP verification screen (WU-5.2,
  /// FEATURES.md §6.2).
  ///
  /// Auto-submit fires exactly once per filled code (the in-flight guard
  /// rejects re-entry); an invalid code clears back to the designed
  /// invalid state, an expired one prompts the resend.

  OtpVerificationControllerProvider call({
    required String phoneNumber,
    required int expiresInSeconds,
  }) => OtpVerificationControllerProvider._(
    argument: (phoneNumber: phoneNumber, expiresInSeconds: expiresInSeconds),
    from: this,
  );

  @override
  String toString() => r'otpVerificationControllerProvider';
}

/// Riverpod controller for the OTP verification screen (WU-5.2,
/// FEATURES.md §6.2).
///
/// Auto-submit fires exactly once per filled code (the in-flight guard
/// rejects re-entry); an invalid code clears back to the designed
/// invalid state, an expired one prompts the resend.

abstract class _$OtpVerificationController extends $Notifier<OtpFlowState> {
  late final _$args = ref.$arg as ({String phoneNumber, int expiresInSeconds});
  String get phoneNumber => _$args.phoneNumber;
  int get expiresInSeconds => _$args.expiresInSeconds;

  OtpFlowState build({
    required String phoneNumber,
    required int expiresInSeconds,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OtpFlowState, OtpFlowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OtpFlowState, OtpFlowState>,
              OtpFlowState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(
        phoneNumber: _$args.phoneNumber,
        expiresInSeconds: _$args.expiresInSeconds,
      ),
    );
  }
}
