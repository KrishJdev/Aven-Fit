import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/food_item.dart';
import 'food_search_controller.dart';

/// Full-screen Food Database Search over the bundled Indian catalog
/// (WU-4.4, FEATURES.md §11.3): debounced search, FSSAI veg indicator on
/// every tile, household serving display ("1 katori · 150 g · 105 kcal").
///
/// Implements Law L1 (<300ms query latency), Law L2 (100% offline catalog),
/// and Law L6 (designed empty states with a filter-escape affordance).
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({
    super.key,
    this.mealHint,
  });

  /// Optional meal bucket the flow started from (the dashboard's meal
  /// sections pass it, WU-4.5) — forwarded to the detail screen so the
  /// item logs into the right meal.
  final String? mealHint;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(foodSearchControllerProvider);
    final controller = ref.read(foodSearchControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const Text(
              'FOOD DATABASE',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            stateAsync.when(
              data: (state) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.neonCyan.withValues(alpha: 0.15),
                  border:
                      Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${state.foods.length}',
                  style: AppTheme.num(
                    12,
                    weight: FontWeight.w700,
                    color: AppTheme.neonCyan,
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: stateAsync.when(
        data: (state) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: _SearchBar(
                  controller: _searchController,
                  onChanged: controller.setSearchQuery,
                  onClear: () {
                    _searchController.clear();
                    controller.setSearchQuery('');
                  },
                ),
              ),

              // Filter Chips (FSSAI veg + §11.10 satvik)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'VEG ONLY',
                      isSelected: state.vegOnly,
                      onTap: controller.toggleVegOnly,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'SATVIK',
                      isSelected: state.satvikOnly,
                      onTap: controller.toggleSatvikOnly,
                      activeColor: AppTheme.voltGreen,
                    ),
                  ],
                ),
              ),

              const Divider(color: AppTheme.glassBorder, height: 1),

              // Food List / Empty State
              Expanded(
                child: state.foods.isEmpty
                    ? _EmptyStateView(
                        hasFilters: state.hasActiveFilters,
                        onClearFilters: () {
                          _searchController.clear();
                          controller.clearFilters();
                        },
                      )
                    : ListView.builder(
                        itemCount: state.foods.length,
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemBuilder: (context, index) {
                          final food = state.foods[index];
                          return _FoodTile(
                            food: food,
                            onTap: () => context.push(
                              widget.mealHint == null
                                  ? '/foods/${food.id}'
                                  : '/foods/${food.id}?meal=${widget.mealHint}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.neonCyan,
            strokeWidth: 2,
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                color: AppTheme.burntOrange,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load foods: $err',
                style: const TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.refresh(foodSearchControllerProvider),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.neonCyan),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(color: AppTheme.neonCyan),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search bar for the food database (mirrors the exercise search bar).
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        border: Border.all(color: AppTheme.glassBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(
            LucideIcons.search,
            size: 18,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search foods (e.g. dal, paneer, roti)...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  LucideIcons.x,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One food result tile: FSSAI veg mark, name, household serving line
/// ("1 katori · 150 g · 105 kcal"), and kcal badge.
class _FoodTile extends StatelessWidget {
  const _FoodTile({
    required this.food,
    required this.onTap,
  });

  final FoodItem food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              VegMark(isVeg: food.isVeg),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _servingLine(food),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (food.isSatvik || food.isCustom) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (food.isSatvik)
                            const _Badge(
                              label: 'SATVIK',
                              color: AppTheme.voltGreen,
                            ),
                          if (food.isCustom)
                            const _Badge(
                              label: 'CUSTOM',
                              color: AppTheme.textSecondary,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_fmtNum(food.caloriesKcal)} kcal',
                style: AppTheme.num(
                  13,
                  weight: FontWeight.w700,
                  color: AppTheme.neonCyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The standard-serving line. Entries whose household unit IS grams
  /// skip the redundant "1 g" prefix.
  String _servingLine(FoodItem food) {
    if (food.householdServingUnit.trim().toLowerCase() == 'g') {
      return '${_fmtNum(food.servingSizeG)} g serving';
    }
    return '1 ${food.householdServingUnit} · ${_fmtNum(food.servingSizeG)} g';
  }
}

/// FSSAI veg/non-veg mark (§11.3): green dot for veg, brown-red triangle
/// for non-veg — rendered from data, never guessed (L10).
class VegMark extends StatelessWidget {
  const VegMark({
    super.key,
    required this.isVeg,
    this.size = 16,
  });

  final bool isVeg;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppTheme.voltGreen : AppTheme.burntOrange;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(2.5),
      child: isVeg
          ? Container(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          : CustomPaint(painter: _TrianglePainter(color)),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor = AppTheme.neonCyan,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : AppTheme.glassFill,
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView({
    required this.hasFilters,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.searchX,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No foods match your search.'
                  : 'The food catalog is empty.',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a shorter query — "dal", "paneer", "roti" — or clear the veg/satvik filters.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.neonCyan),
                  shape: const RoundedRectangleBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'CLEAR FILTERS',
                  style: TextStyle(
                    color: AppTheme.neonCyan,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
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
