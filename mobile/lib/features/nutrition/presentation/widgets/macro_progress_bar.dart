import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Adherence-neutral macro bar (WU-4.5, FEATURES.md §11.1): a flat cyan
/// fill on a grey track — zero radius, no gradients, **no red/green
/// judgment colors, no over-target alarm anywhere** (L4). Over-target
/// consumption simply clamps the fill at full width; the value text keeps
/// showing the fact.
class MacroProgressBar extends StatelessWidget {
  const MacroProgressBar({
    super.key,
    required this.label,
    required this.consumed,
    this.target,
    this.emphasized = false,
  });

  final String label;

  /// Grams consumed so far.
  final double consumed;

  /// Daily target in grams. Null or non-positive means "unset" — the bar
  /// is omitted and only the consumed grams render (a percentage of
  /// nothing would be a fake verdict, L4/L6).
  final double? target;

  /// Protein is the #1 macro for this audience (§11.1/§11.9): the
  /// emphasized bar renders first-class — taller track, stronger label.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final hasTarget = target != null && target! > 0;
    final labelStyle = emphasized
        ? const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          )
        : const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 0.8,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: labelStyle),
            const Spacer(),
            Text(
              hasTarget
                  ? '${_fmtNum(consumed)} / ${_fmtNum(target!)} g'
                  : '${_fmtNum(consumed)} g',
              style: AppTheme.num(
                12,
                weight: FontWeight.w600,
                color: emphasized ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        if (hasTarget) ...[
          const SizedBox(height: 6),
          Container(
            height: emphasized ? 8 : 5,
            width: double.infinity,
            color: AppTheme.glassBorder,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (consumed / target!).clamp(0.0, 1.0).toDouble(),
              child: const ColoredBox(color: AppTheme.neonCyan),
            ),
          ),
        ],
      ],
    );
  }
}

/// Formats a macro number without a trailing ".0" (105 → "105",
/// 157.5 → "157.5").
String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
