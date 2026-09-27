import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../domain/muscle_group.dart';
import 'create_custom_exercise_controller.dart';

/// Screen enabling users to create custom exercises with primary/secondary muscle targets
/// and equipment mapping.
///
/// Implements Law L2 (offline creation), Law L6 (inline validation & error states), and Law L7 (write-through persistence).
class CreateCustomExerciseScreen extends ConsumerStatefulWidget {
  const CreateCustomExerciseScreen({super.key});

  @override
  ConsumerState<CreateCustomExerciseScreen> createState() =>
      _CreateCustomExerciseScreenState();
}

class _CreateCustomExerciseScreenState
    extends ConsumerState<CreateCustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();

  String? _selectedPrimaryMuscleId;
  final Set<String> _selectedSecondaryMuscleIds = {};
  Equipment _selectedEquipment = Equipment.barbell;
  ExerciseCategory _selectedCategory = ExerciseCategory.barbell;
  bool _isTimeBased = false;
  bool _isCardio = false;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final musclesAsync =
        ref.watch(createCustomExerciseControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.createCustomExerciseTitle,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: musclesAsync.when(
        data: (muscleGroups) {
          // Initialize default primary muscle if none selected yet
          if (_selectedPrimaryMuscleId == null && muscleGroups.isNotEmpty) {
            _selectedPrimaryMuscleId = muscleGroups.first.id;
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spaceMd),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.15),
                        border: Border.all(color: AppTheme.warning),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.alertCircle,
                            size: 18,
                            color: AppTheme.warning,
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppTheme.warning,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                  ],

                  // Exercise Name
                  _SectionHeader(title: l10n.exerciseNameLabel),
                  const SizedBox(height: AppTheme.spaceSm),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _inputDecoration(
                      hintText: l10n.exerciseNameHint,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return l10n.exerciseNameRequired;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppTheme.spaceXl),

                  // Primary Muscle Group
                  _SectionHeader(title: l10n.primaryMuscleDriverLabel),
                  const SizedBox(height: AppTheme.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPrimaryMuscleId,
                        dropdownColor: AppTheme.surfaceActive,
                        isExpanded: true,
                        icon: const Icon(
                          LucideIcons.chevronDown,
                          color: AppTheme.textSecondary,
                        ),
                        items: muscleGroups.map((mg) {
                          return DropdownMenuItem<String>(
                            value: mg.id,
                            child: Text(
                              mg.name,
                              style: const TextStyle(color: AppTheme.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPrimaryMuscleId = val;
                              _selectedSecondaryMuscleIds.remove(val);
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceXl),

                  // Secondary Muscle Groups (Optional)
                  _SectionHeader(title: l10n.secondaryMusclesLabel),
                  const SizedBox(height: AppTheme.spaceSm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: muscleGroups
                        .where((mg) => mg.id != _selectedPrimaryMuscleId)
                        .map((mg) {
                      final isSelected =
                          _selectedSecondaryMuscleIds.contains(mg.id);
                      return FilterChip(
                        label: Text(mg.name),
                        selected: isSelected,
                        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.primary,
                        backgroundColor: AppTheme.surface,
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.border,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        shape: const RoundedRectangleBorder(),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSecondaryMuscleIds.add(mg.id);
                            } else {
                              _selectedSecondaryMuscleIds.remove(mg.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppTheme.spaceXl),

                  // Equipment & Category
                  Row(
                    children: [
                      // Equipment Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(title: l10n.equipmentLabel),
                            const SizedBox(height: AppTheme.spaceSm),
                            _buildDropdownContainer(
                              child: DropdownButton<Equipment>(
                                value: _selectedEquipment,
                                dropdownColor: AppTheme.surfaceActive,
                                isExpanded: true,
                                icon: const Icon(
                                  LucideIcons.chevronDown,
                                  color: AppTheme.textSecondary,
                                ),
                                items: Equipment.values.map((eq) {
                                  return DropdownMenuItem<Equipment>(
                                    value: eq,
                                    child: Text(
                                      _formatEquipment(eq),
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedEquipment = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceMd),

                      // Category Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(title: l10n.categoryLabel),
                            const SizedBox(height: AppTheme.spaceSm),
                            _buildDropdownContainer(
                              child: DropdownButton<ExerciseCategory>(
                                value: _selectedCategory,
                                dropdownColor: AppTheme.surfaceActive,
                                isExpanded: true,
                                icon: const Icon(
                                  LucideIcons.chevronDown,
                                  color: AppTheme.textSecondary,
                                ),
                                items: ExerciseCategory.values.map((cat) {
                                  return DropdownMenuItem<ExerciseCategory>(
                                    value: cat,
                                    child: Text(
                                      cat.name.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCategory = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spaceXl),

                  // Instructions / Notes
                  _SectionHeader(title: l10n.instructionsFormLabel),
                  const SizedBox(height: AppTheme.spaceSm),
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _inputDecoration(
                      hintText: l10n.instructionsFormHint,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceXl),

                  // Tracking Modes (Time-based / Cardio)
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.timeBasedLabel,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          ),
                          value: _isTimeBased,
                          activeColor: AppTheme.primary,
                          checkColor: AppTheme.background,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() => _isTimeBased = val ?? false);
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.cardioLabel,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          ),
                          value: _isCardio,
                          activeColor: AppTheme.primary,
                          checkColor: AppTheme.background,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() => _isCardio = val ?? false);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spaceXxl),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.background,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.background,
                              ),
                            )
                          : Text(
                              l10n.saveCustomExercise,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
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
              ref.invalidate(createCustomExerciseControllerProvider),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppTheme.surface,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.border),
        borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.primary),
        borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.warning),
        borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.warning),
        borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
      ),
    );
  }

  String _formatEquipment(Equipment eq) {
    switch (eq) {
      case Equipment.smithMachine:
        return 'Smith Machine';
      default:
        return eq.name[0].toUpperCase() + eq.name.substring(1);
    }
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPrimaryMuscleId == null) {
      setState(() => _errorMessage = l10nOf(context).primaryMuscleRequired);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final controller =
          ref.read(createCustomExerciseControllerProvider.notifier);
      final created = await controller.createExercise(
        name: _nameController.text,
        description: _instructionsController.text,
        primaryMuscleGroupId: _selectedPrimaryMuscleId!,
        secondaryMuscleGroupIds: _selectedSecondaryMuscleIds.toList(),
        equipment: _selectedEquipment,
        category: _selectedCategory,
        isTimeBased: _isTimeBased,
        isCardio: _isCardio,
      );

      if (mounted) {
        context.pushReplacement('/exercises/${created.id}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is ArgumentError ? e.message.toString() : e.toString();
        _isSaving = false;
      });
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
