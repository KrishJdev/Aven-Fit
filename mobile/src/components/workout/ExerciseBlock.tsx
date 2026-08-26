import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Typography } from '../ui/Typography';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';
import { SetRow, SetData } from './SetRow';
import { MoreHorizontal, Plus } from 'lucide-react-native';

export interface ExerciseBlockData {
  id: string;
  name: string;
  sets: SetData[];
}

interface ExerciseBlockProps {
  data: ExerciseBlockData;
  onUpdateSet: (setId: string, field: 'kg' | 'reps', value: string) => void;
  onToggleSet: (setId: string) => void;
  onAddSet: (exerciseId: string) => void;
}

export const ExerciseBlock: React.FC<ExerciseBlockProps> = ({ 
  data, 
  onUpdateSet, 
  onToggleSet, 
  onAddSet 
}) => {
  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Typography variant="title" style={styles.exerciseName}>{data.name}</Typography>
        <TouchableOpacity style={styles.menuBtn}>
          <MoreHorizontal color={colors.textMuted} size={24} />
        </TouchableOpacity>
      </View>

      {/* Column Labels */}
      <View style={styles.colLabels}>
        <View style={styles.indexCol}><Typography variant="microcopy" color={colors.textSubtle}>SET</Typography></View>
        <View style={styles.prevCol}><Typography variant="microcopy" color={colors.textSubtle}>PREV</Typography></View>
        <View style={styles.inputCol}><Typography variant="microcopy" color={colors.textSubtle}>KG</Typography></View>
        <View style={styles.inputCol}><Typography variant="microcopy" color={colors.textSubtle}>REPS</Typography></View>
        <View style={styles.checkCol}><Typography variant="microcopy" color={colors.textSubtle}>DONE</Typography></View>
      </View>

      {/* Sets */}
      <View style={styles.setsWrapper}>
        {data.sets.map((set) => (
          <SetRow 
            key={set.id} 
            data={set} 
            onUpdate={(field, val) => onUpdateSet(set.id, field, val)}
            onToggle={() => onToggleSet(set.id)}
          />
        ))}
      </View>

      {/* Add Set Button */}
      <TouchableOpacity 
        style={styles.addSetBtn}
        onPress={() => onAddSet(data.id)}
        activeOpacity={0.7}
      >
        <Plus color={colors.primary} size={16} />
        <Typography variant="body" color={colors.primary} style={{fontWeight: '600'}}>ADD SET</Typography>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: spacing.xxl,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.md,
    paddingHorizontal: spacing.sm,
  },
  exerciseName: {
    color: colors.primary, // Make the exercise name pop with the accent color
    fontWeight: '600',
  },
  menuBtn: {
    padding: spacing.xs,
  },
  colLabels: {
    flexDirection: 'row',
    paddingHorizontal: spacing.sm,
    marginBottom: spacing.sm,
  },
  indexCol: { width: 32, alignItems: 'center' },
  prevCol: { flex: 1, alignItems: 'center' },
  inputCol: { width: 64, alignItems: 'center', marginHorizontal: spacing.xs },
  checkCol: { width: 44, alignItems: 'center', marginLeft: spacing.xs },
  setsWrapper: {
    backgroundColor: 'rgba(255, 255, 255, 0.02)',
    borderRadius: radii.md,
    paddingVertical: spacing.xs,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: colors.glassBorder,
    marginBottom: spacing.sm,
  },
  addSetBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: spacing.md,
    gap: spacing.xs,
  }
});
