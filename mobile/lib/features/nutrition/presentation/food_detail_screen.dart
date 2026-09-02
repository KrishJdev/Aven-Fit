import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../domain/meal_type.dart';
import 'food_detail_controller.dart';
import 'food_search_screen.dart';

/// Food Item Detail (WU-4.4, FEATURES.md §11.4): full nutrition panel,
/// serving-size selector (household unit + grams), quantity stepper with
/// <100ms macro recalculation, meal selection, and write-through logging.
///
/// Implements Law L1 (instant recalc), L2 (offline), L6 ("—" placeholders
/// for unknown sub-values), L7 (write-through log).
class FoodDetailScreen extends ConsumerStatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.foodId,
    this.mealHint,
  });

  final String foodId;

  /// Optional preselected meal bucket (the dashboard passes the section
  /// the flow started from, e.g. `?meal=lunch`).
  final String? mealHint;

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  bool _mealHintApplied = false;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(foodDetailControllerProvider(widget.foodId));
    final controller =
        ref.read(foodDetailControllerProvider(widget.foodId).notifier);

    // Apply the meal hint once, after the food has loaded (post-frame so
    // the provider state is never mutated during build).
    final data = detailAsync.value;
    if (data != null && !_mealHintApplied && widget.mealHint != null) {
      _mealHintApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.selectMeal(MealType.fromName(widget.mealHint!));
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'FOOD DETAIL',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: detailAsync.when(
        data: (state) {
          if (state == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.searchX,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FOOD NOT FOUND',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.neonCyan),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text(
                      'BACK TO SEARCH',
                      style: TextStyle(color: AppTheme.neonCyan),
                    ),
                  ),
                ],
              ),
            );
          }

          final macros = state.macros;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          VegMark(isVeg: state.food.isVeg),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.food.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.food.brand != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          state.food.brand!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Serving selector
                      _GlassCard(
                        title: 'SERVING',
                        icon: LucideIcons.salad,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'UNIT',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (state.unitOptions.length > 1)
                                  DropdownButton<String>(
                                    value: state.unit,
                                    dropdownColor: AppTheme.oledBlack,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                    ),
                                    underline: Container(
                                      height: 1,
                                      color: AppTheme.glassBorder,
                                    ),
                                    items: state.unitOptions
                                        .map(
                                          (unit) => DropdownMenuItem(
                                            value: unit,
                                            child: Text(_unitLabel(unit)),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (unit) {
                                      if (unit != null) {
                                        controller.selectUnit(unit);
                                      }
                                    },
                                  )
                                else
                                  Text(
                                    _unitLabel(state.unit),
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  '≈ ${_fmtNum(macros.grams)} g',
                                  style: AppTheme.num(
                                    13,
                                    weight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final preset in const [0.5, 1.0, 1.5, 2.0])
                                  _QuantityChip(
                                    label: _fmtNum(preset),
                                    isSelected: state.quantity == preset,
                                    onTap: () => controller.setQuantity(preset),
                                  ),
                                _QuantityChip(
                                  label: 'CUSTOM',
                                  isSelected: !_isPreset(state.quantity),
                                  onTap: () =>
                                      _showCustomQuantityDialog(controller),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nutrition panel
                      _GlassCard(
                        title: 'NUTRITION',
                        icon: LucideIcons.layers,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _fmtNum(macros.kcal),
                                  style: AppTheme.num(
                                    32,
                                    weight: FontWeight.w700,
                                    color: AppTheme.neonCyan,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'kcal',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _MacroRow(
                                label: 'PROTEIN', grams: macros.proteinG),
                            _MacroRow(label: 'CARBS', grams: macros.carbsG),
                            _MacroRow(label: 'FAT', grams: macros.fatG),
                            _MacroRow(
                              label: 'FIBER',
                              grams: macros.fiberG,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Meal selector
                      _GlassCard(
                        title: 'ADD TO MEAL',
                        icon: LucideIcons.bookOpen,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final meal in const [
                              MealType.breakfast,
                              MealType.lunch,
                              MealType.dinner,
                              MealType.snack,
                            ])
                              _QuantityChip(
                                label: meal.label,
                                isSelected: state.mealType == meal,
                                onTap: () => controller.selectMeal(meal),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Sticky log action
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: state.isLogging
                        ? const OutlinedButton(
                            onPressed: null,
                            style: ButtonStyle(
                              side: WidgetStatePropertyAll(
                                BorderSide(color: AppTheme.glassBorder),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(),
                              ),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                            child: Text(
                              'LOGGING…',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: () => _log(context, controller),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppTheme.voltGreen,
                              ),
                              shape: const RoundedRectangleBorder(),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'LOG TO ${state.mealType.label}',
                              style: const TextStyle(
                                color: AppTheme.voltGreen,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: SingleChildScrollView(
            child: LoadingStateWidget(),
          ),
        ),
        error: (err, _) => ErrorStateWidget(
          error: err,
          onRetry: () =>
              ref.invalidate(foodDetailControllerProvider(widget.foodId)),
        ),
      ),
    );
  }

  bool _isPreset(double quantity) =>
      const [0.5, 1.0, 1.5, 2.0].any((p) => p == quantity);

  String _unitLabel(String unit) =>
      unit.trim().toLowerCase() == 'g' ? 'grams (g)' : '1 $unit';

  Future<void> _log(
    BuildContext context,
    FoodDetailController controller,
  ) async {
    final item = await controller.log();
    if (item != null && context.mounted) {
      context.pop();
    }
  }

  Future<void> _showCustomQuantityDialog(
    FoodDetailController controller,
  ) async {
    final current = ref.read(foodDetailControllerProvider(widget.foodId)).value;
    if (current == null) return;

    final fieldController =
        TextEditingController(text: _fmtNum(current.quantity));
    final parsed = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.oledBlack,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppTheme.glassBorder),
        ),
        title: Text(
          'Custom quantity (${_unitLabel(current.unit)})',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: fieldController,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. 1.5',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.neonCyan),
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () {
              final value =
                  double.tryParse(fieldController.text.trim().replaceAll(',', '.'));
              Navigator.of(ctx).pop(value);
            },
            child: const Text(
              'APPLY',
              style: TextStyle(
                color: AppTheme.neonCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (parsed != null) {
      controller.setQuantity(parsed);
    }
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        border: Border.all(color: AppTheme.glassBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.neonCyan),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _QuantityChip extends StatelessWidget {
  const _QuantityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.neonCyan.withValues(alpha: 0.15)
              : AppTheme.glassFill,
          border: Border.all(
            color: isSelected ? AppTheme.neonCyan : AppTheme.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.neonCyan : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// One macro row. Unknown sub-values render "—" — never zeros, never
/// errors (FEATURES.md §11.4, L6).
class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.grams,
  });

  final String label;
  final double? grams;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              14,
              weight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats a macro number without a trailing ".0" (105 → "105",
/// 157.5 → "157.5").
String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
