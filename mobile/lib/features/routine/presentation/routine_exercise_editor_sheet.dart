import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/routine_exercise.dart';
import '../domain/routine_set.dart';

/// Modal bottom sheet allowing users to customize target sets, weight, reps,
/// rest intervals, and cues for a routine exercise.
///
/// Implements Law L2 (instant offline update) and Law L6 (inline validated bounds).
class RoutineExerciseEditorSheet extends StatefulWidget {
  const RoutineExerciseEditorSheet({
    super.key,
    required this.exercise,
    required this.onSave,
  });

  final RoutineExercise exercise;
  final ValueChanged<RoutineExercise> onSave;

  static Future<RoutineExercise?> show(
    BuildContext context, {
    required RoutineExercise exercise,
  }) {
    return showModalBottomSheet<RoutineExercise>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => RoutineExerciseEditorSheet(
        exercise: exercise,
        onSave: (updated) => Navigator.of(ctx).pop(updated),
      ),
    );
  }

  @override
  State<RoutineExerciseEditorSheet> createState() =>
      _RoutineExerciseEditorSheetState();
}

class _RoutineExerciseEditorSheetState
    extends State<RoutineExerciseEditorSheet> {
  late int _setsCount;
  late int _restSeconds;
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final TextEditingController _rpeController;
  late final TextEditingController _notesController;

  static const List<int> _quickRestTimes = [30, 60, 90, 120, 180];

  @override
  void initState() {
    super.initState();
    _setsCount = widget.exercise.setsCount > 0 ? widget.exercise.setsCount : 3;
    _restSeconds = widget.exercise.restSeconds;

    final initialWeight = widget.exercise.targetWeightKg ??
        (widget.exercise.sets.isNotEmpty
            ? widget.exercise.sets.first.targetWeightKg
            : null);
    _weightController = TextEditingController(
      text: (initialWeight != null && initialWeight > 0)
          ? initialWeight.toStringAsFixed(initialWeight.truncateToDouble() == initialWeight ? 0 : 1)
          : '',
    );

    final initialReps = widget.exercise.targetReps ??
        (widget.exercise.sets.isNotEmpty
            ? widget.exercise.sets.first.targetReps
            : 10);
    _repsController = TextEditingController(
      text: (initialReps != null && initialReps > 0) ? initialReps.toString() : '10',
    );

    final initialRpe = widget.exercise.targetRpe ??
        (widget.exercise.sets.isNotEmpty
            ? widget.exercise.sets.first.targetRpe
            : null);
    _rpeController = TextEditingController(
      text: initialRpe != null ? initialRpe.toString() : '',
    );

    _notesController = TextEditingController(text: widget.exercise.notes ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _rpeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final weight = double.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim()) ?? 10;
    final rpe = double.tryParse(_rpeController.text.trim());
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : null;

    final updatedSets = List.generate(
      _setsCount,
      (i) => RoutineSet(
        id: 'rs_${DateTime.now().microsecondsSinceEpoch}_$i',
        routineExerciseId: widget.exercise.id,
        position: i + 1,
        targetWeightKg: weight ?? 0.0,
        targetReps: reps,
        targetRpe: rpe,
      ),
    );

    final updatedExercise = widget.exercise.copyWith(
      targetSetsCount: _setsCount,
      targetWeightKg: weight ?? 0.0,
      targetReps: reps,
      targetRpe: rpe,
      restSeconds: _restSeconds,
      notes: notes,
      sets: updatedSets,
    );

    widget.onSave(updatedExercise);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final exName = widget.exercise.exerciseName ??
        widget.exercise.exercise?.name ??
        l10n.exerciseTargetsTitle;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1.5),
          left: BorderSide(color: AppTheme.border, width: 1),
          right: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppTheme.spaceXl,
        left: AppTheme.spaceXl,
        right: AppTheme.spaceXl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spaceXxl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),
            // Sets Count Selector
            _buildSectionHeader(l10n.plannedSetsLabel),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              children: [
                _buildStepperButton(
                  icon: LucideIcons.minus,
                  onTap: () {
                    if (_setsCount > 1) {
                      setState(() => _setsCount--);
                    }
                  },
                ),
                const SizedBox(width: AppTheme.spaceLg),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl, vertical: AppTheme.spaceSm),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$_setsCount SETS',
                    style: AppTheme.num(
                      16,
                      weight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceLg),
                _buildStepperButton(
                  icon: LucideIcons.plus,
                  onTap: () {
                    if (_setsCount < 20) {
                      setState(() => _setsCount++);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXl),
            // Target Weight & Reps
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(l10n.targetWeightKgLabel),
                      const SizedBox(height: AppTheme.spaceSm),
                      _buildNumberField(
                        controller: _weightController,
                        hintText: '0.0',
                        isDecimal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(l10n.targetRepsLabel),
                      const SizedBox(height: AppTheme.spaceSm),
                      _buildNumberField(
                        controller: _repsController,
                        hintText: '10',
                        isDecimal: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXl),
            // Rest Timer
            _buildSectionHeader(l10n.restDurationLabel),
            const SizedBox(height: AppTheme.spaceSm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickRestTimes.map((secs) {
                final isSelected = _restSeconds == secs;
                return ChoiceChip(
                  label: Text('${secs}s'),
                  selected: isSelected,
                  selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                  backgroundColor: AppTheme.surface,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _restSeconds = secs);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            // Target RPE (optional)
            _buildSectionHeader(l10n.targetRpeLabel),
            const SizedBox(height: AppTheme.spaceSm),
            _buildNumberField(
              controller: _rpeController,
              hintText: l10n.rpeHint,
              isDecimal: true,
            ),
            const SizedBox(height: AppTheme.spaceXl),
            // Notes
            _buildSectionHeader(l10n.notesCuesLabel),
            const SizedBox(height: AppTheme.spaceSm),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: l10n.notesHint,
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
                fillColor: AppTheme.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                contentPadding: const EdgeInsets.all(AppTheme.spaceMd),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXxl),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  l10n.confirmTargets,
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hintText,
    required bool isDecimal,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        if (isDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      style: AppTheme.num(15, color: AppTheme.textPrimary, weight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.textSecondary.withValues(alpha: 0.4),
          fontSize: 13,
        ),
        fillColor: AppTheme.surface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: 10),
      ),
    );
  }
}
