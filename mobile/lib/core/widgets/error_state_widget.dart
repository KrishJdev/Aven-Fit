import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Designed error state (WU-X.4, Law L6): what failed, why, and a RETRY
/// recovery path — an error is never a dead end.
///
/// [onRetry] re-executes the failing async read (typically
/// `ref.invalidate(provider)`); local reads recover instantly, and the
/// user is never left staring at a broken screen (L2). v2 tokens: warning
/// icon, [AppTheme.surfaceElevated] scrim, [AppTheme.radiusSm] retry.
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
        padding: const EdgeInsets.all(AppTheme.spaceXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.triangleAlert,
              size: AppTheme.iconEmpty,
              color: AppTheme.warning,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              l10nOf(context).somethingWentWrong,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spaceXl),
              OutlinedButton(
                key: const ValueKey('error_state_retry'),
                onPressed: onRetry,
                child: Text(
                  l10nOf(context).retry,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
