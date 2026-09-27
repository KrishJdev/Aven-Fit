import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable designed empty state (WU-X.4, Law L6): icon + title +
/// optional explainer + optional action button — a list is never blank.
///
/// Adherence-neutral by design (L4): the copy states the fact and, when
/// an action exists, offers it once — no nags. v2 design system: solid
/// [AppTheme.surface] fill, [AppTheme.radiusMd], no border (§11.5).
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl, vertical: AppTheme.spaceXxl),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusMd)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTheme.iconEmpty, color: AppTheme.textMuted),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textMuted),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppTheme.spaceMd),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              ),
              child: Text(
                actionLabel!.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
