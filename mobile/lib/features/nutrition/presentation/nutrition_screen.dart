import 'package:aven_fit/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../domain/logged_meal_item.dart' show LoggedMealItem;
import '../domain/nutrition_log_entry.dart';
import 'nutrition_dashboard_controller.dart';
import 'nutrition_dashboard_state.dart';
import 'widgets/macro_progress_bar.dart';
import 'widgets/meal_section_card.dart';

/// Nutrition Dashboard (WU-4.5, FEATURES.md §11.1): day navigation,
/// calories-remaining card (hidden entirely without goals — L4),
/// adherence-neutral macro bars (flat cyan-on-grey, protein first — L4),
/// four meal sections with inline quantity steppers, and the daily totals
/// summary. 100% offline from reactive SQLite streams (L2/L8).
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionDashboardControllerProvider);
    final controller = ref.read(nutritionDashboardControllerProvider.notifier);
    final dayController = ref.read(selectedNutritionDayProvider.notifier);

    final today = LoggedMealItem.normalizeDay(DateTime.now());
    final isToday = state.day == today;
    final l10n = l10nOf(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceMd, AppTheme.spaceLg, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.nutritionTitle,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            // Day navigation (§11.1): ← Today → ; the future is unreachable.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm, vertical: AppTheme.spaceXs),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('day_prev'),
                    icon: const Icon(
                      LucideIcons.chevronLeft,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                    onPressed: dayController.previousDay,
                  ),
                  Expanded(
                    child: Text(
                      _dayLabel(state.day, today, l10n),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('day_next'),
                    icon: Icon(
                      LucideIcons.chevronRight,
                      color: isToday
                          ? AppTheme.border
                          : AppTheme.textPrimary,
                      size: 20,
                    ),
                    onPressed: isToday ? null : dayController.nextDay,
                  ),
                ],
              ),
            ),

            const Divider(color: AppTheme.border, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceMd, AppTheme.spaceLg, AppTheme.spaceXxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calories remaining vs goal — hidden entirely when no
                    // goals are set, never a nag (L4).
                    if (state.hasCalorieGoal) ...[
                      _CaloriesCard(state: state),
                      const SizedBox(height: AppTheme.spaceLg),
                    ],

                    // Four meal sections (§11.1).
                    for (final bucket in state.mealEntries.entries) ...[
                      MealSectionCard(
                        mealType: bucket.key,
                        entries: bucket.value,
                        subtotalKcal: state.mealKcal(bucket.key),
                        onAddFood: () => context
                            .push('/foods?meal=${bucket.key.name}'),
                        onQuantityStep: (entry, delta) {
                          final next =
                              (entry.item.quantityServings + delta)
                                  .clamp(0.5, 10000)
                                  .toDouble();
                          controller.updateItemQuantity(entry.item.id, next);
                        },
                        onRemoveItem: (entry) =>
                            _confirmRemove(context, ref, entry),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                    ],

                    // Daily totals summary (§11.1).
                    _DailyTotalsCard(state: state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Remove requires confirmation — data never silently vanishes
  /// (§11.2, L7 spirit).
  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    NutritionLogEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: l10nOf(context).removeItemTitle,
        message: l10nOf(context).removeItemMessage(entry.food.name),
        confirmLabel: l10nOf(context).removeItemConfirm,
        cancelLabel: l10nOf(context).dialogCancel,
        style: ConfirmStyle.destructive,
        onConfirm: () {},
      ),
    );

    if (confirmed == true) {
      await ref
          .read(nutritionDashboardControllerProvider.notifier)
          .removeItem(entry.item.id);
    }
  }
}

/// Calories remaining vs goal — the primary visual (§11.1): big remaining
/// figure, consumed/target fact line, and the macro bars with protein
/// first-class. Over-target days show the delta neutrally — never red
/// (L4).
class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({required this.state});

  final NutritionDashboardState state;

  @override
  Widget build(BuildContext context) {
    final goals = state.goals!;
    final totals = state.totals;
    final remaining = state.caloriesRemaining;
    final overTarget = remaining < 0;
    final l10n = l10nOf(context);

    return Container(
      key: const ValueKey('calories_remaining_card'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overTarget ? l10n.caloriesOverTarget : l10n.caloriesRemaining,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtNum(remaining.abs()),
                style: AppTheme.num(
                  32,
                  weight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  l10n.kcalUnit,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${_fmtNum(state.consumedKcal)} of ${_fmtNum(goals.targetCalories)}',
                  style: AppTheme.num(
                    13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),
          // Protein first-class (§11.1/§11.9), then carbs and fat. Bars
          // render only for set targets — a percentage of nothing would be
          // a fake verdict (L4/L6).
          MacroProgressBar(
            label: l10n.proteinLabel,
            consumed: totals?.proteinG ?? 0,
            target: goals.targetProteinG,
            emphasized: true,
          ),
          const SizedBox(height: 10),
          MacroProgressBar(
            label: l10n.carbsLabel,
            consumed: totals?.carbsG ?? 0,
            target: goals.targetCarbsG,
          ),
          const SizedBox(height: 10),
          MacroProgressBar(
            label: l10n.fatLabel,
            consumed: totals?.fatG ?? 0,
            target: goals.targetFatG,
          ),
        ],
      ),
    );
  }
}

/// Daily totals summary — the day's facts at the bottom (§11.1). Unknown
/// fiber renders "—" — never a silent zero (L6).
class _DailyTotalsCard extends StatelessWidget {
  const _DailyTotalsCard({required this.state});

  final NutritionDashboardState state;

  @override
  Widget build(BuildContext context) {
    final totals = state.totals;
    final l10n = l10nOf(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.dailyTotalsLabel,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (totals != null && totals.itemCount > 0)
                Text(
                  '${totals.itemCount} item${totals.itemCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtNum(totals?.kcal ?? 0),
                style: AppTheme.num(
                  28,
                  weight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
                child: Text(
                  l10n.kcalUnit,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _TotalsRow(label: l10n.proteinLabel, grams: totals?.proteinG ?? 0),
          _TotalsRow(label: l10n.carbsLabel, grams: totals?.carbsG ?? 0),
          _TotalsRow(label: l10n.fatLabel, grams: totals?.fatG ?? 0),
          _TotalsRow(label: l10n.fiberLabel, grams: totals?.fiberG),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.label, required this.grams});

  final String label;
  final double? grams;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            grams == null ? '—' : '${_fmtNum(grams!)} g',
            style: AppTheme.num(
              13,
              weight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Day navigation label: TODAY / YESTERDAY / a short date. Manual
/// formatting — no new deps (the history feed pattern).
String _dayLabel(DateTime day, DateTime today, AppLocalizations l10n) {
  if (day == today) return l10n.dateToday;
  if (day == today.subtract(const Duration(days: 1))) return l10n.dateYesterday;
  const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  const months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  return '${weekdays[day.weekday - 1]}, ${day.day} ${months[day.month - 1]}';
}

/// Formats a macro number without a trailing ".0" (105 → "105",
/// 157.5 → "157.5").
String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
