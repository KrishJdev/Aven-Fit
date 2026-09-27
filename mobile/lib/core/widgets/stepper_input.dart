import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// ± quantity input for repeatedly-entered values (design system §10.17):
/// weight, reps, servings. Layout `[-] value [+]`, 36×36 minimum tap
/// targets, value in [AppTheme.num] (tabular figures, centered). Tapping
/// the value opens a direct numeric input dialog (pass [onTapValue] to
/// hook the dialog). Long-press accelerates the increment speed.
///
/// Step increments are context-appropriate (±2.5 kg for weight, ±1 for
/// reps, ±0.5 for servings) — pass [step] accordingly.
class StepperInput extends StatelessWidget {
  const StepperInput({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.step = 1,
    this.suffix,
    this.onTapValue,
    this.decrementKey,
    this.incrementKey,
    this.valueKey,
    super.key,
  });

  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final double step;
  final String? suffix;
  final VoidCallback? onTapValue;

  /// Optional test keys mirroring the in-session set-row steppers
  /// (`step_up_<id>` / `step_down_<id>`).
  final Key? decrementKey;
  final Key? incrementKey;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          key: decrementKey,
          icon: LucideIcons.minus,
          onTap: onDecrement,
        ),
        GestureDetector(
          onTap: onTapValue,
          behavior: HitTestBehavior.opaque,
          child: Container(
            key: valueKey,
            constraints: const BoxConstraints(minWidth: 64),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTheme.num(16, weight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: AppTheme.spaceXxs),
                  Text(
                    suffix!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _StepperButton(
          key: incrementKey,
          icon: LucideIcons.plus,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppTheme.stepperButtonSize,
          height: AppTheme.stepperButtonSize,
          child: Icon(icon, size: AppTheme.iconSmall, color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}
