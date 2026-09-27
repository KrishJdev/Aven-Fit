import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// A tappable card representing a single discrete entity (design system
/// §11): a workout session, a routine, a food item, a PR record. The card
/// communicates "this is one thing" and is the whole tap target unless it
/// carries multiple independent actions (rare — pass [onTap] null then).
///
/// Solid [AppTheme.surface] fill, [AppTheme.radiusMd], no border by default
/// (§11.5) — the fill distinguishes it from the black background. Cards sit
/// on the background; nothing nests on a card (§11.5).
class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.selected = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.surfaceActive : AppTheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusMd)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusMd)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppTheme.spaceMd),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppTheme.spaceXxs),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppTheme.spaceSm),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: AppTheme.spaceSm),
                const Icon(
                  LucideIcons.chevronRight,
                  size: AppTheme.iconAction,
                  color: AppTheme.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
