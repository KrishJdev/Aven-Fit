import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
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
      color: const Color(0xFF11222C),
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.timer, size: 18, color: AppTheme.neonCyan),
              const SizedBox(width: 8),
              Text(
                'REST TIMER:',
                style: AppTheme.num(12, weight: FontWeight.w600, color: AppTheme.neonCyan),
              ),
              const SizedBox(width: 6),
              Text(
                restState.remainingDisplay,
                style: AppTheme.num(15, weight: FontWeight.w700, color: Colors.white),
              ),
              if (restState.exerciseName != null) ...[
                const SizedBox(width: 8),
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
                icon: const Icon(LucideIcons.rotateCcw, size: 16, color: AppTheme.textSecondary),
                tooltip: 'Restart rest',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: restNotifier.cancel,
                icon: const Icon(LucideIcons.x, size: 16, color: AppTheme.textSecondary),
                tooltip: 'Skip rest',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: restState.progressFraction,
              minHeight: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonCyan),
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        label,
        style: AppTheme.num(12, weight: FontWeight.w700, color: AppTheme.neonCyan),
      ),
    );
  }
}
