import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Designed error state (WU-X.4, Law L6): what failed, why, and a RETRY
/// recovery path — an error is never a dead end.
///
/// [onRetry] re-executes the failing async read (typically
/// `ref.invalidate(provider)`); local reads recover instantly, and the
/// user is never left staring at a broken screen (L2).
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    required this.error,
    this.onRetry,
    super.key,
  });

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.triangleAlert,
              size: 40,
              color: AppTheme.burntOrange,
            ),
            const SizedBox(height: 14),
            Text(
              'SOMETHING WENT WRONG',
              style: AppTheme.num(
                14,
                weight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                key: const ValueKey('error_state_retry'),
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.neonCyan),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: AppTheme.neonCyan,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
