import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final musclesAsync =
        ref.watch(createCustomExerciseControllerProvider);

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
          'CREATE CUSTOM EXERCISE',
          style: TextStyle(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.burntOrange.withValues(alpha: 0.15),
                        border: Border.all(color: AppTheme.burntOrange),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.alertCircle,
                            size: 18,
                            color: AppTheme.burntOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppTheme.burntOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Exercise Name
                  _SectionHeader(title: 'EXERCISE NAME *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _inputDecoration(
                      hintText: 'e.g. Landmine Press, Swiss Bar Bench',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter an exercise name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Primary Muscle Group
                  _SectionHeader(title: 'PRIMARY MUSCLE DRIVER *'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.glassFill,
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPrimaryMuscleId,
                        dropdownColor: const Color(0xFF1A1A1A),
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

                  const SizedBox(height: 20),

                  // Secondary Muscle Groups (Optional)
                  _SectionHeader(title: 'SECONDARY MUSCLES / STABILIZERS (OPTIONAL)'),
                  const SizedBox(height: 8),
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
                        selectedColor: AppTheme.neonCyan.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.neonCyan,
                        backgroundColor: AppTheme.glassFill,
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.neonCyan
                              : AppTheme.glassBorder,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.neonCyan
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

                  const SizedBox(height: 20),

                  // Equipment & Category
                  Row(
                    children: [
                      // Equipment Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(title: 'EQUIPMENT *'),
                            const SizedBox(height: 8),
                            _buildDropdownContainer(
                              child: DropdownButton<Equipment>(
                                value: _selectedEquipment,
                                dropdownColor: const Color(0xFF1A1A1A),
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
                      const SizedBox(width: 12),

                      // Category Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(title: 'CATEGORY *'),
                            const SizedBox(height: 8),
                            _buildDropdownContainer(
                              child: DropdownButton<ExerciseCategory>(
                                value: _selectedCategory,
                                dropdownColor: const Color(0xFF1A1A1A),
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

                  const SizedBox(height: 20),

                  // Instructions / Notes
                  _SectionHeader(title: 'INSTRUCTIONS / FORM NOTES (OPTIONAL)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _inputDecoration(
                      hintText: 'Cues, setup notes, bench angle, attachments...',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tracking Modes (Time-based / Cardio)
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Time-based',
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          ),
                          value: _isTimeBased,
                          activeColor: AppTheme.neonCyan,
                          checkColor: AppTheme.oledBlack,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() => _isTimeBased = val ?? false);
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Cardio',
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          ),
                          value: _isCardio,
                          activeColor: AppTheme.neonCyan,
                          checkColor: AppTheme.oledBlack,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() => _isCardio = val ?? false);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonCyan,
                        foregroundColor: AppTheme.oledBlack,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.oledBlack,
                              ),
                            )
                          : const Text(
                              'SAVE CUSTOM EXERCISE',
                              style: TextStyle(
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
        color: AppTheme.glassFill,
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppTheme.glassFill,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.glassBorder),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.neonCyan),
        borderRadius: BorderRadius.zero,
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.burntOrange),
        borderRadius: BorderRadius.zero,
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.burntOrange),
        borderRadius: BorderRadius.zero,
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
      setState(() => _errorMessage = 'Please select a primary muscle group.');
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
