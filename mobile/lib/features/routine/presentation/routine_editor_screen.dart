import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../../exercise/presentation/exercise_list_screen.dart';
import '../domain/routine_exercise.dart';
import 'routine_editor_controller.dart';
import 'routine_editor_state.dart';
import 'routine_exercise_editor_sheet.dart';

/// Full-screen builder and editor for custom workout routines and splits.
///
/// Implements Law L2 (offline fast write-through), Law L3 (unlimited routines),
/// Law L6 (inline validation errors), and Law L7 (safe non-destructive edits and reordering).
class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({
    super.key,
    this.routineId,
  });

  final String? routineId;

  @override
  ConsumerState<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  bool _initializedControllers = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _syncControllers(RoutineEditorState state) {
    if (!_initializedControllers && state.name.isNotEmpty) {
      _nameController.text = state.name;
      _descController.text = state.description;
      _initializedControllers = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync =
        ref.watch(routineEditorControllerProvider(widget.routineId));
    final controller =
        ref.read(routineEditorControllerProvider(widget.routineId).notifier);

    return stateAsync.when(
      data: (state) {
        _syncControllers(state);

        return Scaffold(
          backgroundColor: AppTheme.oledBlack,
          appBar: AppBar(
            backgroundColor: AppTheme.oledBlack,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft,
                  color: AppTheme.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              state.isNew ? 'NEW ROUTINE' : 'EDIT ROUTINE',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: state.isSaving ? null : () => _handleSave(context),
                child: state.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.neonCyan,
                        ),
                      )
                    : const Text(
                        'SAVE',
                        style: TextStyle(
                          color: AppTheme.neonCyan,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(color: AppTheme.glassBorder, height: 1),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                if (state.errorMessage != null) ...[
                  _buildErrorBanner(state.errorMessage!),
                  const SizedBox(height: 16),
                ],
                _buildMetadataSection(controller, state),
                const SizedBox(height: 20),
                _buildSummaryBadges(state),
                const SizedBox(height: 24),
                _buildExercisesHeader(context, controller, state),
                const SizedBox(height: 12),
                _buildExercisesList(context, controller, state),
                const SizedBox(height: 16),
                _buildAddExerciseButton(context, controller),
              ],
            ),
          ),
          bottomSheet: _buildStickySaveBar(context, state),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppTheme.oledBlack,
        body: Center(
          child: SingleChildScrollView(
            child: LoadingStateWidget(),
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppTheme.oledBlack,
        body: ErrorStateWidget(
          error: err,
          onRetry: () => ref
              .invalidate(routineEditorControllerProvider(widget.routineId)),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.burntOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.burntOrange.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: AppTheme.burntOrange,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.burntOrange,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(
    RoutineEditorController controller,
    RoutineEditorState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ROUTINE DETAILS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            onChanged: controller.updateName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Routine Name *',
              labelStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
              hintText: 'e.g. Upper Body Hypertrophy',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                fontSize: 14,
              ),
              fillColor: const Color(0xFF141416),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.neonCyan),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            onChanged: controller.updateDescription,
            maxLines: 2,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              labelStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
              hintText: 'e.g. 4-week strength block focusing on bench and OHP',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                fontSize: 13,
              ),
              fillColor: const Color(0xFF141416),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.neonCyan),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadges(RoutineEditorState state) {
    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard(
            label: 'EXERCISES',
            value: '${state.exercises.length}',
            color: AppTheme.neonCyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            label: 'TOTAL SETS',
            value: '${state.totalSets}',
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            label: 'EST. TIME',
            value: '${state.estimatedDurationMinutes} MIN',
            color: AppTheme.voltGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.num(
              15,
              weight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesHeader(
    BuildContext context,
    RoutineEditorController controller,
    RoutineEditorState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'EXERCISES',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppTheme.textPrimary,
          ),
        ),
        if (state.exercises.isNotEmpty)
          Text(
            'Drag handle to reorder',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildExercisesList(
    BuildContext context,
    RoutineEditorController controller,
    RoutineEditorState state,
  ) {
    if (state.exercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.glassFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.dumbbell,
              size: 32,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'No exercises added yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap below to browse the catalog and add exercises to your routine.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.exercises.length,
      // ignore: deprecated_member_use
      onReorder: controller.reorderExercises,
      itemBuilder: (context, index) {
        final ex = state.exercises[index];
        return _buildExerciseCard(
          key: ValueKey(ex.id.isNotEmpty ? ex.id : 'ex_idx_$index'),
          context: context,
          index: index,
          exercise: ex,
          controller: controller,
        );
      },
    );
  }

  Widget _buildExerciseCard({
    required Key key,
    required BuildContext context,
    required int index,
    required RoutineExercise exercise,
    required RoutineEditorController controller,
  }) {
    final exName =
        exercise.exerciseName ?? exercise.exercise?.name ?? 'Exercise';

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: InkWell(
        onTap: () async {
          final updated = await RoutineExerciseEditorSheet.show(
            context,
            exercise: exercise,
          );
          if (updated != null) {
            controller.updateExercise(index, updated);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Position Index
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.neonCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTheme.num(
                    12,
                    weight: FontWeight.w800,
                    color: AppTheme.neonCyan,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Exercise Info & Targets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.setsCount} sets · ${exercise.targetSummary} · ${exercise.restSeconds}s rest',
                      style: AppTheme.num(
                        11,
                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Edit targets icon
              const Icon(
                LucideIcons.settings2,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              // Delete button (Law L7)
              IconButton(
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: AppTheme.burntOrange,
                ),
                onPressed: () => _confirmRemoveExercise(context, index, exName, controller),
                visualDensity: VisualDensity.compact,
              ),
              // Reorder drag handle
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Icon(
                    LucideIcons.gripVertical,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton(
    BuildContext context,
    RoutineEditorController controller,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _openExercisePicker(context, controller),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.neonCyan,
        side: const BorderSide(color: AppTheme.neonCyan, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(LucideIcons.plus, size: 18),
      label: const Text(
        'ADD EXERCISE',
        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildStickySaveBar(
    BuildContext context,
    RoutineEditorState state,
  ) {
    return Container(
      color: const Color(0xFF101012),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: state.isSaving ? null : () => _handleSave(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonCyan,
              foregroundColor: AppTheme.oledBlack,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: state.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.oledBlack,
                    ),
                  )
                : Text(
                    state.isNew ? 'CREATE ROUTINE' : 'SAVE CHANGES',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _openExercisePicker(
    BuildContext context,
    RoutineEditorController controller,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExerciseListScreen(
          onExerciseSelected: (exercise) {
            controller.addExercise(exercise);
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  void _confirmRemoveExercise(
    BuildContext context,
    int index,
    String exerciseName,
    RoutineEditorController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141416),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppTheme.glassBorder),
        ),
        title: const Text(
          'Remove Exercise?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Remove "$exerciseName" from this routine?',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.burntOrange,
              foregroundColor: AppTheme.textPrimary,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.removeExercise(index);
            },
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    final controller =
        ref.read(routineEditorControllerProvider(widget.routineId).notifier);
    final success = await controller.saveRoutine();
    if (success && context.mounted) {
      context.pop();
    }
  }
}
