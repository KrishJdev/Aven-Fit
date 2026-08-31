import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';

/// Modal bottom sheet for previewing and inserting a warm-up pyramid ladder.
///
/// Implements FEATURES.md §8.1 and Law L1 (instant warm-up generation).
class WarmupPyramidSheet extends StatefulWidget {
  const WarmupPyramidSheet({
    super.key,
    required this.workingWeightKg,
    required this.onGenerate,
  });

  final double workingWeightKg;
  final ValueChanged<double> onGenerate;

  @override
  State<WarmupPyramidSheet> createState() => _WarmupPyramidSheetState();
}

class _WarmupPyramidSheetState extends State<WarmupPyramidSheet> {
  late double _workingWeight;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _workingWeight = widget.workingWeightKg > 0 ? widget.workingWeightKg : 80.0;
    _weightController = TextEditingController(
      text: _workingWeight % 1 == 0
          ? _workingWeight.toInt().toString()
          : _workingWeight.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  List<({String step, double weight, int reps, String note})> _computeLadder() {
    final w = _workingWeight;
    final ladder = <({String step, double weight, int reps, String note})>[];

    if (w >= 40.0) {
      ladder.add((step: '1', weight: 20.0, reps: 10, note: 'Empty bar'));
      ladder.add((
        step: '2',
        weight: ((w * 0.5) / 2.5).round() * 2.5,
        reps: 5,
        note: '50% Load',
      ));
      ladder.add((
        step: '3',
        weight: ((w * 0.7) / 2.5).round() * 2.5,
        reps: 3,
        note: '70% Load',
      ));
      ladder.add((
        step: '4',
        weight: ((w * 0.85) / 2.5).round() * 2.5,
        reps: 1,
        note: '85% Potentiation',
      ));
    } else {
      ladder.add((
        step: '1',
        weight: ((w * 0.5) / 2.5).round() * 2.5,
        reps: 8,
        note: '50% Load',
      ));
      ladder.add((
        step: '2',
        weight: ((w * 0.75) / 2.5).round() * 2.5,
        reps: 4,
        note: '75% Load',
      ));
    }

    return ladder;
  }

  @override
  Widget build(BuildContext context) {
    final ladder = _computeLadder();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.flame, color: AppTheme.burntOrange, size: 22),
                const SizedBox(width: 8),
                Text(
                  'WARM-UP PYRAMID',
                  style: AppTheme.num(18, weight: FontWeight.w700, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: AppTheme.textSecondary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Auto-generates progressive warm-up sets. Excluded from working volume & PRs.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Target Working Weight Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.glassFill,
                border: Border.all(color: AppTheme.glassBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    'TARGET WORKING LOAD:',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: AppTheme.num(16, weight: FontWeight.w700, color: AppTheme.neonCyan),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        suffixText: ' kg',
                        suffixStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setState(() {
                            _workingWeight = parsed;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ladder Preview Table
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16191D),
                border: Border.all(color: AppTheme.glassBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ...ladder.map((step) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.burntOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'W${step.step}',
                                style: const TextStyle(
                                  color: AppTheme.burntOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${step.weight} kg × ${step.reps}',
                              style: AppTheme.num(14, weight: FontWeight.w700, color: Colors.white),
                            ),
                            const Spacer(),
                            Text(
                              step.note,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Insert Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: () {
                  widget.onGenerate(_workingWeight);
                  Navigator.of(context).pop();
                },
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('INSERT WARM-UP SETS'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.burntOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
