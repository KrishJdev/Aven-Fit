import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/meal_type.dart';
import '../../domain/nutrition_log_entry.dart';

/// One meal section (WU-4.5, FEATURES.md §11.1/§11.2): a surface card
/// listing the meal's logged foods (name, serving, kcal, protein) with
/// inline quantity steppers, a per-meal kcal subtotal, and the "Add Food"
/// affordance → Food Database Search.
class MealSectionCard extends StatelessWidget {
  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.subtotalKcal,
    required this.onAddFood,
    required this.onQuantityStep,
    required this.onRemoveItem,
  });

  final MealType mealType;
  final List<NutritionLogEntry> entries;

  /// Sum of the bucket's denormalized kcal snapshots.
  final double subtotalKcal;
  final VoidCallback onAddFood;

  /// Inline stepper change: [delta] servings (±0.5) — the parent recomputes
  /// through the food's math and writes through (§11.2, <100ms recalc).
  final void Function(NutritionLogEntry entry, double delta) onQuantityStep;

  /// Remove tap — the parent owns the confirmation dialog (§11.2/L7).
  final void Function(NutritionLogEntry entry) onRemoveItem;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Container(
      key: ValueKey('meal_section_${mealType.name}'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: meal label + item count + kcal subtotal.
          Row(
            children: [
              Text(
                mealType.label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              if (entries.isNotEmpty)
                Text(
                  '${entries.length} item${entries.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              const Spacer(),
              Text(
                '${_fmtNum(subtotalKcal)} kcal',
                style: AppTheme.num(
                  13,
                  weight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (entries.isEmpty)
            Text(
              l10n.mealNothingLogged,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            )
          else
            for (final entry in entries) ...[
              _LoggedItemRow(
                entry: entry,
                onStep: (delta) => onQuantityStep(entry, delta),
                onRemove: () => onRemoveItem(entry),
              ),
              const SizedBox(height: AppTheme.spaceSm),
            ],

          const SizedBox(height: 6),
          _AddFoodButton(
            key: ValueKey('add_food_${mealType.name}'),
            onTap: onAddFood,
          ),
        ],
      ),
    );
  }
}

/// One logged item: name + serving line ("1.5 katori · 225 g · 9 g
/// protein"), inline ±0.5 steppers, kcal, and remove.
class _LoggedItemRow extends StatelessWidget {
  const _LoggedItemRow({
    required this.entry,
    required this.onStep,
    required this.onRemove,
  });

  final NutritionLogEntry entry;
  final ValueChanged<double> onStep;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    final grams = entry.food.scaleFor(
      quantityServings: item.quantityServings,
      servingUnit: item.servingUnitUsed,
    ).grams;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.food.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '${_fmtNum(item.quantityServings)} ${item.servingUnitUsed} · '
                '${_fmtNum(grams)} g · ${_fmtNum(item.calculatedProteinG)} g protein',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spaceSm),
        _StepButton(
          key: ValueKey('step_down_${item.id}'),
          icon: LucideIcons.minus,
          onTap: () => onStep(-0.5),
        ),
        SizedBox(
          width: 34,
          child: Text(
            _fmtNum(item.quantityServings),
            textAlign: TextAlign.center,
            style: AppTheme.num(13, color: AppTheme.textPrimary),
          ),
        ),
        _StepButton(
          key: ValueKey('step_up_${item.id}'),
          icon: LucideIcons.plus,
          onTap: () => onStep(0.5),
        ),
        const SizedBox(width: AppTheme.spaceXs),
        Text(
          _fmtNum(item.calculatedKcal),
          style: AppTheme.num(
            13,
            weight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
        GestureDetector(
          key: ValueKey('remove_item_${item.id}'),
          onTap: onRemove,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              LucideIcons.trash2,
              size: 15,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact ± stepper button.
class _StepButton extends StatelessWidget {
  const _StepButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceXs),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 12, color: AppTheme.textPrimary),
      ),
    );
  }
}

/// "Add Food" affordance → Food Database Search (§11.1).
class _AddFoodButton extends StatelessWidget {
  const _AddFoodButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.plus, size: 14, color: AppTheme.primary),
            const SizedBox(width: 6),
            Text(
              l10n.addFood,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats a macro number without a trailing ".0" (105 → "105",
/// 157.5 → "157.5").
String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
