import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';
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
        <Typography variant="h2" style={styles.exerciseName} color={theme.colors.primary}>
          {data.name.toUpperCase()}
        </Typography>
        <TouchableOpacity style={styles.optionsBtn}>
          <MoreHorizontal color={theme.colors.textMuted} size={24} />
        </TouchableOpacity>
      </View>

      {/* Table Headers */}
      <View style={styles.tableHeader}>
        <Typography variant="label" color={theme.colors.textSubtle} style={styles.thIndex}>SET</Typography>
        <Typography variant="label" color={theme.colors.textSubtle} style={styles.thPrev}>PREV</Typography>
        <Typography variant="label" color={theme.colors.textSubtle} style={styles.thInput}>KG</Typography>
        <Typography variant="label" color={theme.colors.textSubtle} style={styles.thInput}>REPS</Typography>
        <View style={styles.thStatus} />
      </View>

      {/* Rows */}
      {data.sets.map((set) => (
        <SetRow 
          key={set.id}
          data={set}
          onChange={onUpdateSet}
          onToggleStatus={onToggleSet}
        />
      ))}

      {/* Add Set Button */}
      <TouchableOpacity 
        style={styles.addSetBtn}
        onPress={() => onAddSet(data.id)}
      >
        <Plus color={theme.colors.textMuted} size={16} />
        <Typography variant="label" color={theme.colors.textMuted} style={styles.addSetText}>
          ADD SET
        </Typography>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: theme.spacing.xl,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: theme.spacing.md,
    paddingHorizontal: theme.spacing.screenHorizontal,
  },
  exerciseName: {
    letterSpacing: 1,
  },
  optionsBtn: {
    padding: theme.spacing.xs,
  },
  tableHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: theme.spacing.sm,
    paddingHorizontal: theme.spacing.screenHorizontal,
  },
  thIndex: {
    width: 32,
    textAlign: 'center',
    fontSize: 10,
  },
  thPrev: {
    flex: 1,
    textAlign: 'center',
    fontSize: 10,
  },
  thInput: {
    width: 72,
    textAlign: 'center',
    marginHorizontal: theme.spacing.xs,
    fontSize: 10,
  },
  thStatus: {
    width: 48,
  },
  addSetBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: theme.spacing.md,
    marginTop: theme.spacing.xs,
  },
  addSetText: {
    marginLeft: theme.spacing.xs,
  },
});
