import 'package:aven_fit/core/l10n/l10n.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../rest_timer_controller.dart';

/// Slim rest-timer bar rendered under the session header (FEATURES.md
/// §8.1/§8.3) — never blocks content. Shows the epoch-derived remaining time,
/// ±15s adjustments, restart, and one-tap dismiss.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restState = ref.watch(restTimerControllerProvider);
    final restNotifier = ref.read(restTimerControllerProvider.notifier);

    return Container(
      width: double.infinity,
      color: AppTheme.surfaceElevated,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceLg,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.timer, size: AppTheme.iconSection, color: AppTheme.primary),
              const SizedBox(width: AppTheme.spaceSm),
              Text(
                l10nOf(context).restTimerLabel,
                style: AppTheme.num(12, weight: FontWeight.w600, color: AppTheme.primary),
              ),
              const SizedBox(width: AppTheme.spaceXs + 2),
              Text(
                restState.remainingDisplay,
                style: AppTheme.num(15, weight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              if (restState.exerciseName != null) ...[
                const SizedBox(width: AppTheme.spaceSm),
                Flexible(
                  child: Text(
                    restState.exerciseName!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ),
              ],
              const Spacer(),
              _RestAdjustButton(
                label: '-15s',
                onPressed: () => restNotifier.addTime(-15),
              ),
              _RestAdjustButton(
                label: '+15s',
                onPressed: () => restNotifier.addTime(15),
              ),
              IconButton(
                onPressed: restNotifier.restart,
                icon: const Icon(LucideIcons.rotateCcw, size: AppTheme.iconSmall, color: AppTheme.textSecondary),
                tooltip: l10nOf(context).restartRestTooltip,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: restNotifier.cancel,
                icon: const Icon(LucideIcons.x, size: AppTheme.iconSmall, color: AppTheme.textSecondary),
                tooltip: l10nOf(context).skipRestTooltip,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXs),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusFull)),
            child: LinearProgressIndicator(
              value: restState.progressFraction,
              minHeight: 3,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestAdjustButton extends StatelessWidget {
  const _RestAdjustButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        label,
        style: AppTheme.num(12, weight: FontWeight.w700, color: AppTheme.primary),
      ),
    );
  }
}
