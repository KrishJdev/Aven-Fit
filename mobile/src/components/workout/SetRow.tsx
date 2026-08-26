import React from 'react';
import { View, StyleSheet, TextInput, TouchableOpacity } from 'react-native';
import { Typography } from '../ui/Typography';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';
import { Check } from 'lucide-react-native';

export interface SetData {
  id: string;
  index: number;
  previousString: string;
  kg: string;
  reps: string;
  isCompleted: boolean;
}

interface SetRowProps {
  data: SetData;
  onUpdate: (field: 'kg' | 'reps', value: string) => void;
  onToggle: () => void;
}

export const SetRow: React.FC<SetRowProps> = ({ data, onUpdate, onToggle }) => {
  const isDone = data.isCompleted;

  return (
    <View style={[styles.row, isDone && styles.rowCompleted]}>
      {/* Set Index */}
      <View style={styles.indexCol}>
        <View style={[styles.indexBadge, isDone && styles.indexBadgeCompleted]}>
          <Typography variant="microcopy" color={isDone ? colors.background : colors.textMuted}>
            {data.index}
          </Typography>
        </View>
      </View>

      {/* Previous Data */}
      <View style={styles.prevCol}>
        <Typography variant="body" color={colors.textSubtle} tabular>
          {data.previousString}
        </Typography>
      </View>

      {/* Inputs (KG & Reps) */}
      <View style={styles.inputWrap}>
        <TextInput
          style={[styles.input, isDone && styles.inputCompleted]}
          keyboardType="decimal-pad"
          value={data.kg}
          onChangeText={(val) => onUpdate('kg', val)}
          placeholder="-"
          placeholderTextColor={colors.textSubtle}
          editable={!isDone}
        />
      </View>
      
      <View style={styles.inputWrap}>
        <TextInput
          style={[styles.input, isDone && styles.inputCompleted]}
          keyboardType="number-pad"
          value={data.reps}
          onChangeText={(val) => onUpdate('reps', val)}
          placeholder="-"
          placeholderTextColor={colors.textSubtle}
          editable={!isDone}
        />
      </View>

      {/* Check Button */}
      <TouchableOpacity 
        style={[styles.checkBtn, isDone && styles.checkBtnCompleted]} 
        onPress={onToggle}
        activeOpacity={0.7}
      >
        <Check color={isDone ? colors.background : colors.textMuted} size={20} />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.sm,
    backgroundColor: 'transparent',
    borderRadius: radii.sm,
    marginBottom: spacing.xs,
  },
  rowCompleted: {
    backgroundColor: 'rgba(0, 255, 163, 0.05)', // Faint neon emerald
  },
  indexCol: { width: 32, alignItems: 'center' },
  indexBadge: {
    width: 24,
    height: 24,
    borderRadius: radii.sm,
    backgroundColor: colors.glassBase,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: colors.glassBorder,
  },
  indexBadgeCompleted: {
    backgroundColor: colors.success,
    borderColor: colors.success,
  },
  prevCol: { flex: 1, alignItems: 'center' },
  inputWrap: {
    width: 64,
    marginHorizontal: spacing.xs,
  },
  input: {
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: radii.sm,
    color: colors.text,
    fontSize: 16,
    fontVariant: ['tabular-nums'],
    textAlign: 'center',
    height: 40,
    fontWeight: '500',
  },
  inputCompleted: {
    backgroundColor: 'transparent',
    borderColor: 'transparent',
    color: colors.success,
  },
  checkBtn: {
    width: 44,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: radii.sm,
    backgroundColor: colors.glassBase,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    marginLeft: spacing.xs,
  },
  checkBtnCompleted: {
    backgroundColor: colors.success,
    borderColor: colors.success,
  }
});
