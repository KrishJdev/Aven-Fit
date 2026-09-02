import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../../exercise/domain/exercise.dart';
import '../../exercise/domain/muscle_group.dart';
import '../../exercise/presentation/exercise_search_delegate.dart';
import 'active_workout_controller.dart';
import 'exercise_picker_controller.dart';
import 'exercise_picker_state.dart';

/// Full-screen modal picker for selecting exercises to add to an active workout session.
///
/// Implements Law L1 (<300ms search latency), Law L2 (100% offline), and Law L6 (designed empty states).
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({
    super.key,
    this.onExerciseSelected,
  });

  final ValueChanged<Exercise>? onExerciseSelected;

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(exercisePickerControllerProvider);
    final controller = ref.read(exercisePickerControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'ADD EXERCISE',
          style: AppTheme.num(18, weight: FontWeight.w700, color: AppTheme.neonCyan),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/exercises/new'),
            icon: const Icon(LucideIcons.plus, size: 16, color: AppTheme.voltGreen),
            label: Text(
              'CUSTOM',
              style: AppTheme.num(13, weight: FontWeight.w700, color: AppTheme.voltGreen),
            ),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(
          child: SingleChildScrollView(
            child: LoadingStateWidget(),
          ),
        ),
        error: (err, stack) => _buildErrorState(err, controller),
        data: (state) => _buildPickerContent(context, state, controller),
      ),
    );
  }

  Widget _buildPickerContent(
    BuildContext context,
    ExercisePickerState state,
    ExercisePickerController controller,
  ) {
    final exercises = state.filteredExercises;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: ExerciseSearchBar(
            controller: _searchController,
            onChanged: controller.updateSearchQuery,
            onClear: () {
              _searchController.clear();
              controller.updateSearchQuery('');
            },
            hintText: 'Search exercise library or muscles...',
          ),
        ),

        // Filter Chips Bar (Recent, Favourites, Muscles, Equipment)
        _buildFilterChips(state, controller),

        // Header Count Badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.showRecentOnly
                    ? 'RECENT EXERCISES (${exercises.length})'
                    : 'AVAILABLE EXERCISES (${exercises.length})',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              if (state.hasActiveFilters)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    controller.clearFilters();
                  },
                  child: Text(
                    'RESET',
                    style: AppTheme.num(11, weight: FontWeight.w700, color: AppTheme.burntOrange),
                  ),
                ),
            ],
          ),
        ),

        const Divider(color: AppTheme.glassBorder, height: 1),

        // Exercise List or Designed Empty State
        Expanded(
          child: exercises.isEmpty
              ? _buildEmptyState(context, state, controller)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ExerciseListTile(
                      exercise: exercise,
                      onTap: () => _handleSelectExercise(context, exercise),
                      onToggleFavourite: () =>
                          controller.toggleFavourite(exercise.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    ExercisePickerState state,
    ExercisePickerController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Recent Filter Chip
          if (state.recentExercises.isNotEmpty) ...[
            _PickerChip(
              label: '⚡ Recent (${state.recentExercises.length})',
              isSelected: state.showRecentOnly,
              onTap: controller.toggleRecentOnly,
              activeColor: AppTheme.neonCyan,
            ),
            const SizedBox(width: 8),
          ],

          // Favourites Chip
          _PickerChip(
            label: '★ Favourites',
            isSelected: state.favouritesOnly,
            onTap: controller.toggleFavouritesOnly,
            activeColor: AppTheme.voltGreen,
          ),
          const SizedBox(width: 8),

          // Muscle Group Chips
          ...state.muscleGroups.map((mg) {
            final isSelected = state.selectedMuscleGroupId == mg.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _PickerChip(
                label: mg.name,
                isSelected: isSelected,
                onTap: () => controller.setMuscleGroup(mg.id),
                activeColor: AppTheme.neonCyan,
              ),
            );
          }),

          // Equipment Chips
          ...Equipment.values
              .where((e) => e != Equipment.none && e != Equipment.other)
              .map((eq) {
            final isSelected = state.selectedEquipment == eq;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _PickerChip(
                label: eq.name.toUpperCase(),
                isSelected: isSelected,
                onTap: () => controller.setEquipment(eq),
                activeColor: AppTheme.neonCyan,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ExercisePickerState state,
    ExercisePickerController controller,
  ) {
    final hasQuery = state.searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.dumbbell, size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              hasQuery
                  ? 'NO EXERCISE FOUND FOR "${state.searchQuery}"'
                  : 'NO EXERCISES MATCH FILTERS',
              textAlign: TextAlign.center,
              style: AppTheme.num(16, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a custom exercise with your specific muscles and equipment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.hasActiveFilters) ...[
                  OutlinedButton(
                    onPressed: () {
                      _searchController.clear();
                      controller.clearFilters();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.glassBorder),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('CLEAR FILTERS'),
                  ),
                  const SizedBox(width: 12),
                ],
                FilledButton.icon(
                  onPressed: () => context.push('/exercises/new'),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('CREATE CUSTOM'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.voltGreen,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, ExercisePickerController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.triangleAlert, size: 48, color: AppTheme.burntOrange),
            const SizedBox(height: 16),
            Text(
              'COULD NOT LOAD EXERCISES',
              style: AppTheme.num(18, weight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => ref.invalidate(exercisePickerControllerProvider),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSelectExercise(
    BuildContext context,
    Exercise exercise,
  ) async {
    if (widget.onExerciseSelected != null) {
      widget.onExerciseSelected!(exercise);
    } else {
      // Direct add to active session if available
      final activeState = ref.read(activeWorkoutControllerProvider).value;
      if (activeState != null && activeState.hasActiveSession) {
        await ref
            .read(activeWorkoutControllerProvider.notifier)
            .addExercise(exercise.id);
      }
    }

    if (!context.mounted) return;
    Navigator.of(context).pop(exercise);
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({
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
          borderRadius: BorderRadius.circular(4),
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
