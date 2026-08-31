import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/exercise.dart';
import '../domain/muscle_group.dart';

/// Reusable search bar widget for exercise filtering across directory and session picker.
class ExerciseSearchBar extends StatelessWidget {
  const ExerciseSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search exercises (e.g. bench, squat)...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

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
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
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

/// Reusable horizontal filter chips bar for muscle groups, equipment, and favourites.
class ExerciseFilterChipsBar extends StatelessWidget {
  const ExerciseFilterChipsBar({
    super.key,
    required this.muscleGroups,
    required this.selectedMuscleGroupId,
    required this.onSelectMuscleGroup,
    required this.selectedEquipment,
    required this.onSelectEquipment,
    required this.favouritesOnly,
    required this.onToggleFavourites,
  });

  final List<MuscleGroup> muscleGroups;
  final String? selectedMuscleGroupId;
  final ValueChanged<String?> onSelectMuscleGroup;
  final Equipment? selectedEquipment;
  final ValueChanged<Equipment?> onSelectEquipment;
  final bool favouritesOnly;
  final VoidCallback onToggleFavourites;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Favourites Chip
          _FilterChip(
            label: '★ Favourites',
            isSelected: favouritesOnly,
            onTap: onToggleFavourites,
            activeColor: AppTheme.voltGreen,
          ),
          const SizedBox(width: 8),

          // Muscle Groups Chips
          ...muscleGroups.map((mg) {
            final isSelected = selectedMuscleGroupId == mg.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: mg.name,
                isSelected: isSelected,
                onTap: () => onSelectMuscleGroup(mg.id),
                activeColor: AppTheme.neonCyan,
              ),
            );
          }),

          // Equipment Chips
          ...Equipment.values.where((e) => e != Equipment.none && e != Equipment.other).map((eq) {
            final isSelected = selectedEquipment == eq;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: _formatEquipment(eq),
                isSelected: isSelected,
                onTap: () => onSelectEquipment(eq),
                activeColor: AppTheme.neonCyan,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatEquipment(Equipment eq) {
    switch (eq) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.machine:
        return 'Machine';
      case Equipment.cable:
        return 'Cable';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.band:
        return 'Band';
      case Equipment.smithMachine:
        return 'Smith Machine';
      default:
        return eq.name;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
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
          ),
        ),
      ),
    );
  }
}

/// Reusable exercise list tile with Sharp Glassmorphism design tokens.
class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (exercise.primaryMuscle != null)
                          _Badge(
                            label: exercise.primaryMuscle!,
                            color: AppTheme.neonCyan,
                          ),
                        if (exercise.equipment != Equipment.none)
                          _Badge(
                            label: exercise.equipment.name.toUpperCase(),
                            color: AppTheme.textSecondary,
                          ),
                        if (exercise.isCustom)
                          const _Badge(
                            label: 'CUSTOM',
                            color: AppTheme.voltGreen,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  exercise.isFavourite ? LucideIcons.star : LucideIcons.star,
                  size: 20,
                  color: exercise.isFavourite
                      ? AppTheme.voltGreen
                      : AppTheme.textSecondary.withValues(alpha: 0.4),
                ),
                onPressed: onToggleFavourite,
              ),
            ],
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
