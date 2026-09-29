import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/import_models.dart';
import 'import_controller.dart';
import 'import_state.dart';

/// Screen for importing workout history from Strong or Hevy CSV exports (FEATURES.md §12.4, J4 journey).
///
/// Implements full offline flow with all L6 designed states:
/// - Idle: onboarding hero, steps explanation, file picker trigger
/// - Parsing: loading spinner while parsing and matching
/// - Preview: summary metrics card, exercise mapping review tabs, commit/cancel actions
/// - Importing: progress indicator during transactional commit & PR calculation
/// - Success: stats highlight, idempotency check, "VIEW PROGRESS" navigation
/// - Error: warning icon, error details, retry action
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  int _selectedMappingTab = 0; // 0: Auto-mapped, 1: Needs review, 2: Custom

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importControllerProvider);
    final l10n = l10nOf(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () {
            ref.read(importControllerProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Text(
          l10n.importTitle,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: switch (state.status) {
          ImportStatus.idle => _buildIdleView(context, l10n),
          ImportStatus.parsing => _buildParsingView(context, l10n),
          ImportStatus.preview => _buildPreviewView(context, state, l10n),
          ImportStatus.importing => _buildImportingView(context, l10n),
          ImportStatus.success => _buildSuccessView(context, state, l10n),
          ImportStatus.error => _buildErrorView(context, state, l10n),
        },
      ),
    );
  }

  Widget _buildIdleView(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTheme.spaceMd),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.primaryMuted),
              ),
              child: const Icon(
                LucideIcons.fileSpreadsheet,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            l10n.importHeadline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            l10n.importSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXl),
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Column(
              children: [
                _buildStepRow(
                  icon: LucideIcons.fileUp,
                  text: l10n.importStep1,
                  number: '1',
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _buildStepRow(
                  icon: LucideIcons.gitCompare,
                  text: l10n.importStep2,
                  number: '2',
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _buildStepRow(
                  icon: LucideIcons.zap,
                  text: l10n.importStep3,
                  number: '3',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceXxl),
          FilledButton.icon(
            key: const ValueKey('import_select_file_button'),
            onPressed: () =>
                ref.read(importControllerProvider.notifier).pickAndParseFile(),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            icon: const Icon(LucideIcons.folderOpen, size: 20),
            label: Text(
              l10n.importSelectFile,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            l10n.importSupportedNotice,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required IconData icon,
    required String text,
    required String number,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.surfaceActive,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Text(
            number,
            style: AppTheme.num(
              13,
              weight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13.5,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParsingView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            l10n.importAnalyzing,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView(
    BuildContext context,
    ImportState state,
    AppLocalizations l10n,
  ) {
    final summary = state.summary!;
    final earliest = state.earliestDate;
    final latest = state.latestDate;
    final dateRange = earliest != null && latest != null
        ? '${_formatDate(earliest)} – ${_formatDate(latest)}'
        : '—';

    final highMatches = state.highConfidenceMatches;
    final mediumMatches = state.mediumConfidenceMatches;
    final lowMatches = state.lowConfidenceMatches;

    final currentMatches = switch (_selectedMappingTab) {
      0 => highMatches,
      1 => mediumMatches,
      _ => lowMatches,
    };

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            children: [
              // Summary card
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.importSummaryTitle,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceActive,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            summary.source.name.toUpperCase(),
                            style: AppTheme.num(
                              11,
                              weight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${summary.workouts.length}',
                                style: AppTheme.num(
                                  20,
                                  weight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                l10n.importWorkoutsLabel,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${summary.totalSets}',
                                style: AppTheme.num(
                                  20,
                                  weight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                l10n.importSetsLabel,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    const Divider(color: AppTheme.divider, height: 1),
                    const SizedBox(height: AppTheme.spaceSm),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: AppTheme.spaceSm),
                        Text(
                          dateRange,
                          style: AppTheme.num(
                            12,
                            weight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceXl),

              // Mapping Review Section
              Text(
                l10n.importExerciseMappingTitle,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // Tabs
              Row(
                children: [
                  _buildTabChip(
                    label: '${l10n.importAutoMappedLabel} (${highMatches.length})',
                    isSelected: _selectedMappingTab == 0,
                    activeColor: AppTheme.secondary,
                    onTap: () => setState(() => _selectedMappingTab = 0),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  _buildTabChip(
                    label: '${l10n.importReviewLabel} (${mediumMatches.length})',
                    isSelected: _selectedMappingTab == 1,
                    activeColor: AppTheme.primary,
                    onTap: () => setState(() => _selectedMappingTab = 1),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  _buildTabChip(
                    label: '${l10n.importCustomLabel} (${lowMatches.length})',
                    isSelected: _selectedMappingTab == 2,
                    activeColor: AppTheme.textSecondary,
                    onTap: () => setState(() => _selectedMappingTab = 2),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),

              if (_selectedMappingTab == 2 && lowMatches.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceActive,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.info,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: AppTheme.spaceSm),
                      Expanded(
                        child: Text(
                          l10n.importCustomNotice,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
              ],

              // Match list
              if (currentMatches.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceXl),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Text(
                    'No exercises in this category.',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                ...currentMatches.map((match) => _buildMatchTile(match)),
            ],
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceElevated,
            border: Border(
              top: BorderSide(color: AppTheme.divider),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  key: const ValueKey('import_cancel_button'),
                  onPressed: () =>
                      ref.read(importControllerProvider.notifier).reset(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: Text(
                    l10n.importCancelButton,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                flex: 2,
                child: FilledButton(
                  key: const ValueKey('import_commit_button'),
                  onPressed: () =>
                      ref.read(importControllerProvider.notifier).startImport(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: Text(
                    l10n.importStartButton(summary.workouts.length),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surfaceActive : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchTile(ExerciseMatchResult match) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.originalName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (match.matchedName != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.arrowRight,
                        size: 12,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match.matchedName!,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          if (match.confidence == MatchConfidence.high)
            const Icon(LucideIcons.check, size: 16, color: AppTheme.secondary)
          else if (match.confidence == MatchConfidence.medium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceActive,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                'SUGGESTION',
                style: AppTheme.num(
                  10,
                  weight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceActive,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                'NEW CUSTOM',
                style: AppTheme.num(
                  10,
                  weight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImportingView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.secondary),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            l10n.importingProgress,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            l10n.importCalculatingPrs,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    ImportState state,
    AppLocalizations l10n,
  ) {
    final result = state.result;
    final isSkip = result?.wasIdempotentSkip ?? false;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: isSkip ? AppTheme.primary : AppTheme.secondary,
                ),
              ),
              child: Icon(
                isSkip ? LucideIcons.info : LucideIcons.checkCheck,
                size: 40,
                color: isSkip ? AppTheme.primary : AppTheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            isSkip
                ? l10n.importAlreadyImportedTitle
                : l10n.importSuccessTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            isSkip
                ? l10n.importAlreadyImportedMessage(result?.workoutsSkipped ?? 0)
                : l10n.importSuccessSummary(
                    result?.workoutsImported ?? 0,
                    result?.setsImported ?? 0,
                    result?.prCount ?? 0,
                  ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSkip ? AppTheme.textSecondary : AppTheme.secondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          if (result != null && !isSkip) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Column(
                children: [
                  if (result.exercisesCreated > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.plus,
                            size: 14,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Text(
                            l10n.importCustomCreatedCount(
                                result.exercisesCreated),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (result.workoutsSkipped > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.skipForward,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Text(
                            l10n.importDuplicatesSkippedCount(
                                result.workoutsSkipped),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const Spacer(),
          FilledButton(
            key: const ValueKey('import_view_progress_button'),
            onPressed: () {
              ref.read(importControllerProvider.notifier).reset();
              context.go('/progress');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            child: Text(
              l10n.importViewProgress,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          OutlinedButton(
            key: const ValueKey('import_done_button'),
            onPressed: () {
              ref.read(importControllerProvider.notifier).reset();
              context.pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            child: Text(
              l10n.importDone,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    ImportState state,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.triangleAlert,
              size: 48,
              color: AppTheme.warning,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              l10n.importErrorTitle,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              state.errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            FilledButton(
              key: const ValueKey('import_retry_button'),
              onPressed: () =>
                  ref.read(importControllerProvider.notifier).reset(),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: Text(
                l10n.importSelectAnother,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
