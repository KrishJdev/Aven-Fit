import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// ALL-CAPS section label with an optional trailing action (design system
/// §10.7). `xl` above, `md` below — never an icon unless disambiguating
/// peer sections in a list (not supported here; keep it text-only per §9.3).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.label,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    super.key,
  });

  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional test key for the trailing action — lets callers preserve
  /// `find.byKey` contracts (e.g. Home's VIEW ALL, Progress's VIEW ALL)
  /// when adopting this widget.
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spaceXl, bottom: AppTheme.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              key: actionKey,
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: AppTheme.spaceSm),
                child: Text(
                  actionLabel!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
