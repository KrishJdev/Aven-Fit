import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import 'otp_flow_state.dart';
import 'otp_verification_controller.dart';
import 'widgets/otp_input_field.dart';

/// OTP verification (WU-5.2, FEATURES.md §6.2): 6-cell auto-submitting
/// input, 30s-enforced resend, change-number link, and a designed state
/// for verifying / invalid / expired / success (L6).
class OtpVerificationScreen extends ConsumerWidget {
  const OtpVerificationScreen({
    required this.phoneNumber,
    required this.expiresInSeconds,
    super.key,
  });

  final String phoneNumber;
  final int expiresInSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      otpVerificationControllerProvider(
        phoneNumber: phoneNumber,
        expiresInSeconds: expiresInSeconds,
      ),
    );
    final controller = ref.read(
      otpVerificationControllerProvider(
        phoneNumber: phoneNumber,
        expiresInSeconds: expiresInSeconds,
      ).notifier,
    );

    // Success → silently land on Home (§6.2). The guest→account data
    // link rides on the surviving guest UUID + the sync contract.
    ref.listen(
      otpVerificationControllerProvider(
        phoneNumber: phoneNumber,
        expiresInSeconds: expiresInSeconds,
      ).select((s) => s.status),
      (previous, next) {
        if (next == OtpStatus.success && context.mounted) {
          context.go('/home');
        }
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'VERIFY OTP',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'We sent a 6-digit code to',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                key: const ValueKey('otp_phone_display'),
                state.phoneNumber,
                textAlign: TextAlign.center,
                style: AppTheme.num(
                  18,
                  weight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const ValueKey('change_number'),
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.neonCyan,
                ),
                child: const Text(
                  'Change number',
                  style: TextStyle(fontSize: 13),
                ),
              ),

              const SizedBox(height: 24),
              OtpInputField(
                otp: state.otp,
                status: state.status,
                onChanged: controller.otpChanged,
                onSubmit: () {
                  // Auto-submit exactly once per filled code (§6.2).
                  unawaited(controller.verify());
                },
              ),

              // Designed attempt states (L6) — verifying / invalid /
              // expired, each with its own treatment, never blank.
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: KeyedSubtree(
                    key: const ValueKey('otp_status_area'),
                    child: switch (state.status) {
                      OtpStatus.verifying => const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.neonCyan,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'VERIFYING…',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      OtpStatus.invalid => _OtpNotice(
                          icon: LucideIcons.alertCircle,
                          color: AppTheme.burntOrange,
                          text: state.errorMessage ?? 'Invalid code. Try again.',
                        ),
                      OtpStatus.expired => _OtpNotice(
                          icon: LucideIcons.timerOff,
                          color: AppTheme.burntOrange,
                          text: state.errorMessage ??
                              'That code expired. Send a new one.',
                        ),
                      _ => state.errorMessage != null
                          ? _OtpNotice(
                              icon: LucideIcons.alertCircle,
                              color: AppTheme.burntOrange,
                              text: state.errorMessage!,
                            )
                          : const SizedBox.shrink(),
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend — cooldown-enforced countdown (§6.2 30s timer).
              TextButton(
                key: const ValueKey('otp_resend'),
                onPressed: state.canResend && !state.isVerifying
                    ? () => controller.resend()
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.neonCyan,
                ),
                child: Text(
                  state.canResend
                      ? 'RESEND CODE'
                      : 'RESEND CODE IN ${state.resendInSeconds}s',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: state.canResend
                        ? AppTheme.neonCyan
                        : AppTheme.textSecondary,
                  ),
                ),
              ),

              // OTP validity window — a neutral fact (L4).
              const SizedBox(height: 4),
              Text(
                key: const ValueKey('otp_expiry_display'),
                state.isExpired
                    ? 'Code expired — resend to continue.'
                    : 'Code expires in ${state.expiresDisplay}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: state.isExpired
                      ? AppTheme.burntOrange
                      : AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  key: const ValueKey('otp_verify_button'),
                  onPressed: state.isComplete && !state.isVerifying
                      ? () => controller.verify()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonCyan,
                    foregroundColor: AppTheme.oledBlack,
                    disabledBackgroundColor:
                        AppTheme.neonCyan.withValues(alpha: 0.35),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'VERIFY & CONTINUE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'No SMS permission needed — the code can also be typed '
                'in manually.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpNotice extends StatelessWidget {
  const _OtpNotice({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
