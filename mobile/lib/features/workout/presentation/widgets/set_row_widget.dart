import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/ghost_set.dart';
import '../../domain/workout_set.dart';

/// Individual interactive set row with quick steppers, ghost prefill, and ✓ toggle.
///
/// Implements Law L1 (<3s set logging) and Law L7 (instant write-through).
class SetRowWidget extends StatelessWidget {
  const SetRowWidget({
    super.key,
    required this.set,
    this.ghost = const GhostSet(source: GhostSource.none),
    required this.onUpdateSet,
    required this.onToggleComplete,
    required this.onDeleteSet,
  });

  final WorkoutSet set;
  final GhostSet ghost;
  final ValueChanged<WorkoutSet> onUpdateSet;
  final VoidCallback onToggleComplete;
  final VoidCallback onDeleteSet;

  @override
  Widget build(BuildContext context) {
    final isDone = set.isCompleted;
    final isWarmup = set.type == SetType.warmup;
    final isDropset = set.type == SetType.dropSet;

    return Dismissible(
      key: Key('dismiss_${set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: AppTheme.burntOrange.withValues(alpha: 0.2),
        child: const Icon(LucideIcons.trash2, color: AppTheme.burntOrange, size: 20),
      ),
      confirmDismiss: (direction) async {
        if (!set.isCompleted) return true;
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF16191D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'DELETE COMPLETED SET?',
              style: AppTheme.num(
                16,
                weight: FontWeight.w700,
                color: AppTheme.burntOrange,
              ),
            ),
            content: const Text(
              'This set is marked as completed. Are you sure you want to delete it?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.burntOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('DELETE'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDeleteSet(),
      child: Container(
        color: isDone
            ? AppTheme.voltGreen.withValues(alpha: 0.08)
            : isWarmup
                ? AppTheme.burntOrange.withValues(alpha: 0.05)
                : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            // Set Number / Type Badge
            SizedBox(
              width: 36,
              child: GestureDetector(
                onTap: () => _showSetTypePicker(context),
                child: _buildSetBadge(isWarmup, isDropset),
              ),
            ),

            // PREV Performance Ghost
            Expanded(
              flex: 3,
              child: Text(
                ghost.prevSummary,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ),

            // KG Weight Stepper & Display
            Expanded(
              flex: 4,
              child: _buildKgField(context),
            ),

            const SizedBox(width: 4),

            // REPS Stepper & Display
            Expanded(
              flex: 4,
              child: _buildRepsField(context),
            ),

            const SizedBox(width: 8),

            // Complete ✓ Action Button
            SizedBox(
              width: 38,
              child: Center(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onToggleComplete();
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone ? AppTheme.voltGreen : const Color(0xFF22262B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDone ? AppTheme.voltGreen : AppTheme.glassBorder,
                      ),
                    ),
                    child: Icon(
                      LucideIcons.check,
                      size: 18,
                      color: isDone ? Colors.black : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetBadge(bool isWarmup, bool isDropset) {
    final Widget badge;
    if (isWarmup) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.burntOrange.withValues(alpha: 0.2),
          border: Border.all(color: AppTheme.burntOrange.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'W',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.burntOrange,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (isDropset) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.neonCyan.withValues(alpha: 0.2),
          border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'D',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.neonCyan,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      badge = Text(
        set.setNumber.toString(),
        textAlign: TextAlign.center,
        style: AppTheme.num(13, weight: FontWeight.w600, color: AppTheme.textSecondary),
      );
    }

    // PR badge (§8.1): a tiny volt-green flash when this set beat any
    // personal record (weight, e1RM, reps-at-weight, volume).
    if (!set.isPr) return badge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(height: 2),
        const _PrFlashBadge(),
      ],
    );
  }

  Widget _buildKgField(BuildContext context) {
    final weightStr = set.weightKg % 1 == 0
        ? set.weightKg.toInt().toString()
        : set.weightKg.toStringAsFixed(1);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        border: Border.all(color: AppTheme.glassBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepperButton(
            label: '−',
            onTap: () {
              final newWeight = (set.weightKg - 2.5).clamp(0.0, 999.0);
              onUpdateSet(set.copyWith(weightKg: newWeight));
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _editValueDialog(
                context,
                title: 'EDIT WEIGHT (KG)',
                initialValue: set.weightKg.toString(),
                onSubmitted: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed >= 0) {
                    onUpdateSet(set.copyWith(weightKg: parsed));
                  }
                },
              ),
              child: Text(
                weightStr,
                textAlign: TextAlign.center,
                style: AppTheme.num(13, weight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          _StepperButton(
            label: '+',
            onTap: () {
              final newWeight = (set.weightKg + 2.5).clamp(0.0, 999.0);
              onUpdateSet(set.copyWith(weightKg: newWeight));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRepsField(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        border: Border.all(color: AppTheme.glassBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepperButton(
            label: '−',
            onTap: () {
              final newReps = (set.reps - 1).clamp(0, 999);
              onUpdateSet(set.copyWith(reps: newReps));
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _editValueDialog(
                context,
                title: 'EDIT REPS',
                initialValue: set.reps.toString(),
                onSubmitted: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed >= 0) {
                    onUpdateSet(set.copyWith(reps: parsed));
                  }
                },
              ),
              child: Text(
                set.reps.toString(),
                textAlign: TextAlign.center,
                style: AppTheme.num(13, weight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          _StepperButton(
            label: '+',
            onTap: () {
              final newReps = (set.reps + 1).clamp(0, 999);
              onUpdateSet(set.copyWith(reps: newReps));
            },
          ),
        ],
      ),
    );
  }

  void _showSetTypePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.oledBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SET TYPE',
                style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(LucideIcons.checkCircle2, color: Colors.white),
                title: const Text('Normal Working Set', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onUpdateSet(set.copyWith(type: SetType.normal));
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.flame, color: AppTheme.burntOrange),
                title: const Text('Warm-up Set (Excluded from volume)',
                    style: TextStyle(color: AppTheme.burntOrange)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onUpdateSet(set.copyWith(type: SetType.warmup));
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.layers, color: AppTheme.neonCyan),
                title: const Text('Drop Set', style: TextStyle(color: AppTheme.neonCyan)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onUpdateSet(set.copyWith(type: SetType.dropSet));
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: AppTheme.burntOrange),
                title: const Text('Delete Set', style: TextStyle(color: AppTheme.burntOrange)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onDeleteSet();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editValueDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required ValueChanged<String> onSubmitted,
  }) {
    final textController = TextEditingController(text: initialValue);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16191D),
        title: Text(title, style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white)),
        content: TextField(
          controller: textController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              onSubmitted(textController.text);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.neonCyan, foregroundColor: Colors.black),
            child: const Text('APPLY'),
          ),
        ],
      ),
    );
  }
}

/// Tiny volt-green "PR" chip that pops in (scale + fade) the moment a set is
/// confirmed as a new personal record, with a single medium haptic buzz on
/// appearance — celebration stays haptic + visual only, never confetti-heavy
/// (FEATURES.md §8.1, L5).
class _PrFlashBadge extends StatefulWidget {
  const _PrFlashBadge();

  @override
  State<_PrFlashBadge> createState() => _PrFlashBadgeState();
}

class _PrFlashBadgeState extends State<_PrFlashBadge> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(
        scale: 0.6 + 0.4 * t,
        child: Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          color: AppTheme.voltGreen.withValues(alpha: 0.15),
          border: Border.all(color: AppTheme.voltGreen),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Text(
          'PR',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.voltGreen,
            fontSize: 8,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 22,
        height: 32,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
