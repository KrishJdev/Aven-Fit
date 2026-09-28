import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
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
    final l10n = l10nOf(context);

    // One-shot designed notices (currently the Google deferral).
    ref.listen(loginControllerProvider.select((s) => s.infoMessage),
        (previous, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: AppTheme.surfaceActive,
              behavior: SnackBarBehavior.floating,
            ),
          );
        ref.read(loginControllerProvider.notifier).clearInfoMessage();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXxl, vertical: AppTheme.spaceXxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spaceXxl),
              Text(
                l10n.authWordmark,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                l10n.authLoginSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // Phone input: country code + 10-digit Indian validation.
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(
                    color: state.inlineError != null
                        ? AppTheme.warning
                        : AppTheme.border,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
                child: Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        key: const ValueKey('country_code_selector'),
                        value: state.countryCode,
                        dropdownColor: AppTheme.surfaceActive,
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
                    const SizedBox(width: AppTheme.spaceXs),
                    Container(width: 1, height: 24, color: AppTheme.border),
                    const SizedBox(width: AppTheme.spaceMd),
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
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: l10n.authPhoneHint,
                          hintStyle: const TextStyle(color: AppTheme.textSecondary),
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
                        padding: const EdgeInsets.only(top: AppTheme.spaceSm, left: AppTheme.spaceXxs),
                        child: Text(
                          key: const ValueKey('phone_inline_error'),
                          state.inlineError!,
                          style: const TextStyle(
                            color: AppTheme.warning,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Send OTP — the primary action (§6.1 Continue).
              const SizedBox(height: AppTheme.spaceLg),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  key: const ValueKey('send_otp_button'),
                  onPressed: state.sendingOtp ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.background,
                    disabledBackgroundColor:
                        AppTheme.primary.withValues(alpha: 0.5),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: state.sendingOtp
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.background,
                          ),
                        )
                      : Text(
                          l10n.authSendOtp,
                          style: const TextStyle(
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
                        margin: const EdgeInsets.only(top: AppTheme.spaceMd),
                        padding: const EdgeInsets.all(AppTheme.spaceMd),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.12),
                          border: Border.all(color: AppTheme.warning),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.wifiOff,
                              size: 16,
                              color: AppTheme.warning,
                            ),
                            const SizedBox(width: AppTheme.spaceSm),
                            Expanded(
                              child: Text(
                                state.sendError!,
                                style: const TextStyle(
                                  color: AppTheme.warning,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            TextButton(
                              key: const ValueKey('retry_send'),
                              onPressed: _sendOtp,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceSm,
                                ),
                              ),
                              child: Text(
                                l10n.retry,
                                style: const TextStyle(
                                  color: AppTheme.primary,
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

              const SizedBox(height: AppTheme.spaceMd),
              _OrDivider(),
              const SizedBox(height: AppTheme.spaceMd),

              // Google (secondary).
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  key: const ValueKey('google_button'),
                  onPressed: () => ref
                      .read(loginControllerProvider.notifier)
                      .signInWithGoogle(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border),
                    foregroundColor: AppTheme.textPrimary,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(
                    l10n.authContinueWithGoogle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Guest — prominent first-class exit (L2).
              SizedBox(
                height: 50,
                child: TextButton(
                  key: const ValueKey('guest_button'),
                  onPressed: _continueAsGuest,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondary,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(
                    l10n.authContinueAsGuest,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spaceXxxl),
              // DPDP transparency (§6.1) — placeholder destinations for P0.
              Text(
                l10n.authDpdpNotice,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
    final l10n = l10nOf(context);
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
          child: Text(
            l10n.authOrDivider,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
      ],
    );
  }
}
