import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_state.dart';
import '../../history/domain/lifetime_stats.dart';
import 'profile_controller.dart';

/// Profile screen (WU-5.3, FEATURES.md §12.1/§5.4): identity header with
/// the guest upgrade banner ("Local profile — sign in to back up"), the
/// lifetime stats grid recomputed from local history, quick links, and
/// the sign-in / sign-out actions. Everything renders from local SQLite
/// plus the auth union — zero network (L2); the banner never blocks any
/// flow (L4/L6).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final auth = state.auth;

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'PROFILE',
          style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _IdentityHeader(auth: auth),
          // Guest upgrade banner (§5.4/§12.1): informative, never a wall.
          // A broken auth store renders like Guest (L2).
          if (auth is AuthGuest || auth is AuthError) ...[
            const SizedBox(height: 12),
            const _GuestUpgradeBanner(),
          ],
          const SizedBox(height: 12),
          _LifetimeStatsGrid(stats: state.stats),
          const SizedBox(height: 12),
          const _QuickLinks(),
          if (auth is AuthAuthenticated) ...[
            const SizedBox(height: 12),
            _SignOutTile(onConfirm: () async {
              await ref.read(profileControllerProvider.notifier).signOut();
            }),
          ],
        ],
      ),
    );
  }
}

/// Identity card: avatar circle (initial when we have a name), display
/// name and status line. Exhaustive over the sealed auth union.
class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.auth});

  final AuthState auth;

  ({String name, String subtitle, String? initial}) get _identity =>
      switch (auth) {
        AuthLoading() => const (
            name: 'Loading…',
            subtitle: '',
            initial: null,
          ),
        AuthGuest() => const (
            name: 'Guest',
            subtitle: 'Local profile',
            initial: null,
          ),
        AuthAuthenticated(:final displayName, :final phoneNumber) =>
          _authenticatedIdentity(displayName, phoneNumber),
        AuthError() => const (
            name: 'Guest',
            subtitle: 'Local profile',
            initial: null,
          ),
      };

  /// Account identity: display name first, phone fallback, then the
  /// neutral "Athlete" (never a blank identity, L6).
  static ({String name, String subtitle, String? initial})
      _authenticatedIdentity(String? displayName, String? phoneNumber) {
    if (displayName != null && displayName.isNotEmpty) {
      return (
        name: displayName,
        subtitle: 'Signed in',
        initial: displayName[0].toUpperCase(),
      );
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      return (name: phoneNumber, subtitle: 'Signed in', initial: null);
    }
    return (name: 'Athlete', subtitle: 'Signed in', initial: null);
  }

  @override
  Widget build(BuildContext context) {
    final identity = _identity;

    return Container(
      key: const ValueKey('profile_identity_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.glassFill,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: identity.initial != null
                ? Text(
                    identity.initial!,
                    style: AppTheme.num(22, weight: FontWeight.w700,
                        color: AppTheme.neonCyan),
                  )
                : const Icon(
                    LucideIcons.userRound,
                    size: 26,
                    color: AppTheme.textSecondary,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key: const ValueKey('profile_identity_name'),
                  identity.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (identity.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    identity.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Local profile — sign in to back up" (§5.4): one-tap sign-in to the
/// opt-in login screen. Never blocks any flow (L4/L6).
class _GuestUpgradeBanner extends StatelessWidget {
  const _GuestUpgradeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('profile_upgrade_banner'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.neonCyan.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.neonCyan),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.shieldCheck, size: 20, color: AppTheme.neonCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOCAL PROFILE',
                  style: AppTheme.num(11, weight: FontWeight.w700,
                      color: AppTheme.neonCyan),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Sign in to back up your data and sync across devices.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              key: const ValueKey('profile_sign_in_button'),
              onPressed: () => context.push('/auth/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonCyan,
                foregroundColor: AppTheme.oledBlack,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text(
                'SIGN IN',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lifetime stats grid (§12.1): total workouts, working volume (warm-ups
/// excluded, L1), confirmed sets, and the "member since" anchor. Derived
/// from history on every read — never stored (L7/L8).
class _LifetimeStatsGrid extends StatelessWidget {
  const _LifetimeStatsGrid({required this.stats});

  final LifetimeStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('profile_stats_grid'),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'WORKOUTS',
                value: '${stats.workoutCount}',
                valueKey: 'profile_stat_workouts',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCell(
                label: 'WORKING VOLUME (KG)',
                value: stats.volumeDisplay,
                valueKey: 'profile_stat_volume',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCell(
                label: 'SETS LOGGED',
                value: '${stats.completedSetCount}',
                valueKey: 'profile_stat_sets',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCell(
                label: 'MEMBER SINCE',
                value: stats.memberSinceDisplay,
                valueKey: 'profile_stat_since',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Single glass stat cell — tabular numerals so stacked columns align.
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.num(10, weight: FontWeight.w700,
                color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            key: ValueKey(valueKey),
            value,
            style: AppTheme.num(18, weight: FontWeight.w600,
                color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Quick links (§12.1): Settings and Data Export are P1 placeholders
/// (designed neutral notices, L6); About shows a static dialog.
class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('profile_snackbar'),
          content: Text(message),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(),
        title: Text(
          'AVEN FIT',
          style: AppTheme.num(18, weight: FontWeight.w700,
              color: AppTheme.neonCyan),
        ),
        content: const Text(
          'Offline-first gym & nutrition tracker. Your data lives on this '
          'device — no account needed, no cloud required.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('profile_quick_links'),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          _LinkRow(
            key: const ValueKey('profile_link_settings'),
            icon: LucideIcons.settings,
            label: 'SETTINGS',
            onTap: () =>
                _showNotice(context, 'Settings is coming in a future update.'),
          ),
          const Divider(height: 1, color: AppTheme.glassBorder),
          _LinkRow(
            key: const ValueKey('profile_link_export'),
            icon: LucideIcons.download,
            label: 'DATA EXPORT',
            onTap: () => _showNotice(
                context, 'Data export is coming in a future update.'),
          ),
          const Divider(height: 1, color: AppTheme.glassBorder),
          _LinkRow(
            key: const ValueKey('profile_link_about'),
            icon: LucideIcons.info,
            label: 'ABOUT',
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }
}

/// Single glass quick-link row.
class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16,
                color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Sign-out row (authenticated only). The confirmation dialog is the UI
/// concern (L7 — data never silently vanishes): local history survives
/// sign-out and the guest UUID links it back on the next sign-in (§5.4).
class _SignOutTile extends StatelessWidget {
  const _SignOutTile({required this.onConfirm});

  final Future<void> Function() onConfirm;

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(),
        title: Text(
          'SIGN OUT?',
          style: AppTheme.num(16, weight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Your workouts, routines and nutrition history stay safely on '
          'this device. You can sign in again anytime to pick up where '
          'you left off.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            key: const ValueKey('profile_sign_out_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            key: const ValueKey('profile_sign_out_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.burntOrange),
            child: const Text(
              'SIGN OUT',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: InkWell(
        key: const ValueKey('profile_sign_out_button'),
        onTap: () => _confirmAndSignOut(context),
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(LucideIcons.logOut, size: 18, color: AppTheme.burntOrange),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'SIGN OUT',
                  style: TextStyle(
                    color: AppTheme.burntOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
