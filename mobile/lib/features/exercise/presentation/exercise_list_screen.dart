import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../domain/exercise.dart';
import 'exercise_list_controller.dart';
import 'exercise_search_delegate.dart';

/// Full-screen Exercise Directory with search, category/equipment/muscle group filter chips,
/// and favourite toggling.
///
/// Implements Law L1 (<300ms query latency), Law L2 (offline catalog), and Law L6 (designed empty states).
class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({
    super.key,
    this.onExerciseSelected,
  });

  /// Optional callback for in-session exercise picking mode.
  final ValueChanged<Exercise>? onExerciseSelected;

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
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
    final stateAsync = ref.watch(exerciseListControllerProvider);
    final controller = ref.read(exerciseListControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.oledBlack,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'EXERCISE DIRECTORY',
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
                  border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${state.exercises.length}',
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
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppTheme.neonCyan),
            tooltip: 'Create Custom Exercise',
            onPressed: () => context.push('/exercises/new'),
          ),
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: ExerciseSearchBar(
                  controller: _searchController,
                  onChanged: (val) => controller.setSearchQuery(val),
                  onClear: () {
                    _searchController.clear();
                    controller.setSearchQuery('');
                  },
                ),
              ),

              // Filter Chips Bar
              ExerciseFilterChipsBar(
                muscleGroups: state.muscleGroups,
                selectedMuscleGroupId: state.selectedMuscleGroupId,
                onSelectMuscleGroup: controller.selectMuscleGroup,
                selectedEquipment: state.selectedEquipment,
                onSelectEquipment: controller.selectEquipment,
                favouritesOnly: state.favouritesOnly,
                onToggleFavourites: controller.toggleFavouritesOnly,
              ),

              const Divider(
                color: AppTheme.glassBorder,
                height: 1,
              ),

              // Exercise List / Empty State
              Expanded(
                child: state.exercises.isEmpty
                    ? _EmptyStateView(
                        hasFilters: state.hasActiveFilters,
                        onClearFilters: () {
                          _searchController.clear();
                          controller.clearFilters();
                        },
                      )
                    : ListView.builder(
                        itemCount: state.exercises.length,
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemBuilder: (context, index) {
                          final exercise = state.exercises[index];
                          return ExerciseListTile(
                            exercise: exercise,
                            onTap: () {
                              if (widget.onExerciseSelected != null) {
                                widget.onExerciseSelected!(exercise);
                              } else {
                                context.push('/exercises/${exercise.id}');
                              }
                            },
                            onToggleFavourite: () =>
                                controller.toggleFavourite(exercise.id),
                          );
                        },
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
                'Failed to load exercises: $err',
                style: const TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.refresh(exerciseListControllerProvider),
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
                  ? 'No exercises match the selected filters.'
                  : 'No exercises found in local library.',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search query or removing active muscle/equipment filters.',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'CLEAR ALL FILTERS',
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
