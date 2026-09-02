import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import 'login_controller.dart';

/// Login screen (WU-5.2, FEATURES.md §6.1): phone OTP as the primary
/// path, Google secondary, guest as a first-class exit (L2 — this
/// screen is opt-in navigation, never a gate).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();

  /// The NRI-friendly country codes (§6.1 — +91 default).
  static const _countryCodes = ['+91', '+1', '+44', '+61', '+971', '+65'];

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    _phoneFocus.unfocus();
    final result = await ref.read(loginControllerProvider.notifier).sendOtp();
    if (!mounted || result == null) {
      return;
    }
    // The verification screen carries the number + validity window.
    await context.push(
      '/auth/otp?phone=${Uri.encodeQueryComponent(result.phoneNumber)}'
      '&expires=${result.expiresInSeconds}',
    );
  }

  Future<void> _continueAsGuest() async {
    await ref.read(loginControllerProvider.notifier).continueAsGuest();
    if (!mounted) {
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);

    // One-shot designed notices (currently the Google deferral).
    ref.listen(loginControllerProvider.select((s) => s.infoMessage),
        (previous, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: const Color(0xFF1A1A1A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        ref.read(loginControllerProvider.notifier).clearInfoMessage();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'AVEN FIT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Train offline. Track everything.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // Phone input: country code + 10-digit Indian validation.
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.glassFill,
                  border: Border.all(
                    color: state.inlineError != null
                        ? AppTheme.burntOrange
                        : AppTheme.glassBorder,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        key: const ValueKey('country_code_selector'),
                        value: state.countryCode,
                        dropdownColor: const Color(0xFF1A1A1A),
                        icon: const Icon(
                          LucideIcons.chevronDown,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        items: _countryCodes
                            .map(
                              (code) => DropdownMenuItem<String>(
                                value: code,
                                child: Text(
                                  code,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (code) {
                          if (code != null) {
                            ref
                                .read(loginControllerProvider.notifier)
                                .setCountryCode(code);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(width: 1, height: 24, color: AppTheme.glassBorder),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const ValueKey('phone_field'),
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        enabled: !state.sendingOtp,
                        style: AppTheme.num(
                          17,
                          weight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: '98765 43210',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                        ),
                        onChanged: (value) => ref
                            .read(loginControllerProvider.notifier)
                            .setPhone(value),
                        onSubmitted: (_) => _sendOtp(),
                      ),
                    ),
                  ],
                ),
              ),

              // Inline validation (L6) — instant, never navigates.
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.topLeft,
                child: state.inlineError != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8, left: 2),
                        child: Text(
                          key: const ValueKey('phone_inline_error'),
                          state.inlineError!,
                          style: const TextStyle(
                            color: AppTheme.burntOrange,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Send OTP — the primary action (§6.1 Continue).
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  key: const ValueKey('send_otp_button'),
                  onPressed: state.sendingOtp ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonCyan,
                    foregroundColor: AppTheme.oledBlack,
                    disabledBackgroundColor:
                        AppTheme.neonCyan.withValues(alpha: 0.5),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: state.sendingOtp
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.oledBlack,
                          ),
                        )
                      : const Text(
                          'SEND OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),

              // Network/backend error with retry (§6.1 states).
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.topCenter,
                child: state.sendError != null
                    ? Container(
                        key: const ValueKey('send_error_banner'),
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.burntOrange.withValues(alpha: 0.12),
                          border: Border.all(color: AppTheme.burntOrange),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.wifiOff,
                              size: 16,
                              color: AppTheme.burntOrange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.sendError!,
                                style: const TextStyle(
                                  color: AppTheme.burntOrange,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            TextButton(
                              key: const ValueKey('retry_send'),
                              onPressed: _sendOtp,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: const Text(
                                'RETRY',
                                style: TextStyle(
                                  color: AppTheme.neonCyan,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),
              const _OrDivider(),
              const SizedBox(height: 12),

              // Google (secondary).
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  key: const ValueKey('google_button'),
                  onPressed: () => ref
                      .read(loginControllerProvider.notifier)
                      .signInWithGoogle(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.glassBorder),
                    foregroundColor: AppTheme.textPrimary,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'CONTINUE WITH GOOGLE',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Guest — prominent first-class exit (L2).
              SizedBox(
                height: 50,
                child: TextButton(
                  key: const ValueKey('guest_button'),
                  onPressed: _continueAsGuest,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.voltGreen,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'CONTINUE AS GUEST',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              // DPDP transparency (§6.1) — placeholder destinations for P0.
              const Text(
                'By continuing you agree to our Terms of Service and '
                'Privacy Policy. Your data stays on this device until '
                'you sign in.',
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppTheme.glassBorder, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.glassBorder, thickness: 1)),
      ],
    );
  }
}
