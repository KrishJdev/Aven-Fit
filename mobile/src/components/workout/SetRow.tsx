import React, { useState } from 'react';
import { View, StyleSheet, TextInput, TouchableOpacity } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';
import { Check } from 'lucide-react-native';
import * as Haptics from 'react-native-haptic-feedback';

export interface SetData {
  id: string;
  index: number;
  previousString: string; // e.g. "60 × 10"
  kg: string;
  reps: string;
  isCompleted: boolean;
}

interface SetRowProps {
  data: SetData;
  onChange: (id: string, field: 'kg' | 'reps', value: string) => void;
  onToggleStatus: (id: string) => void;
}

export const SetRow: React.FC<SetRowProps> = ({ data, onChange, onToggleStatus }) => {
  const [focusedField, setFocusedField] = useState<'kg' | 'reps' | null>(null);

  const handleToggle = () => {
    if (!data.isCompleted) {
      Haptics.trigger('impactHeavy'); // Satisfying click for finishing a set
    } else {
      Haptics.trigger('impactLight');
    }
    onToggleStatus(data.id);
  };

  const isCompleted = data.isCompleted;

  return (
    <View style={[styles.container, isCompleted && styles.containerCompleted]}>
      {/* Set Number */}
      <View style={styles.colIndex}>
        <Typography 
          variant="tabular" 
          color={isCompleted ? theme.colors.textMuted : theme.colors.text}
        >
          {String(data.index).padStart(2, '0')}
        </Typography>
      </View>

      {/* Previous Data */}
      <View style={styles.colPrev}>
        <Typography variant="body" color={theme.colors.textSubtle}>
          {data.previousString || '—'}
        </Typography>
      </View>

      {/* KG Input */}
      <View style={styles.colInput}>
        <TextInput
          style={[
            styles.input,
            focusedField === 'kg' && styles.inputFocused,
            isCompleted && styles.inputCompleted,
          ]}
          keyboardType="decimal-pad"
          value={data.kg}
          onChangeText={(val) => onChange(data.id, 'kg', val)}
          onFocus={() => setFocusedField('kg')}
          onBlur={() => setFocusedField(null)}
          editable={!isCompleted}
          selectTextOnFocus
          placeholder="—"
          placeholderTextColor={theme.colors.textSubtle}
        />
      </View>

      {/* REPS Input */}
      <View style={styles.colInput}>
        <TextInput
          style={[
            styles.input,
            focusedField === 'reps' && styles.inputFocused,
            isCompleted && styles.inputCompleted,
          ]}
          keyboardType="number-pad"
          value={data.reps}
          onChangeText={(val) => onChange(data.id, 'reps', val)}
          onFocus={() => setFocusedField('reps')}
          onBlur={() => setFocusedField(null)}
          editable={!isCompleted}
          selectTextOnFocus
          placeholder="—"
          placeholderTextColor={theme.colors.textSubtle}
        />
      </View>

      {/* Status Toggle */}
      <View style={styles.colStatus}>
        <TouchableOpacity 
          activeOpacity={0.8} 
          onPress={handleToggle}
          style={[styles.checkButton, isCompleted && styles.checkButtonActive]}
        >
          {isCompleted && <Check color={theme.colors.background} size={16} strokeWidth={3} />}
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: theme.spacing.sm,
    backgroundColor: theme.colors.background,
  },
  containerCompleted: {
    backgroundColor: theme.colors.surfaceHighlight, // Subtle highlight when done
  },
  colIndex: {
    width: 32,
    alignItems: 'center',
  },
  colPrev: {
    flex: 1,
    alignItems: 'center',
  },
  colInput: {
    width: 72,
    alignItems: 'center',
    marginHorizontal: theme.spacing.xs,
  },
  colStatus: {
    width: 48,
    alignItems: 'center',
  },
  input: {
    width: '100%',
    height: 36,
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radii.sm,
    color: theme.colors.text,
    textAlign: 'center',
    fontSize: theme.typography.sizes.lg,
    fontFamily: theme.typography.primary,
    fontVariant: ['tabular-nums'],
    fontWeight: '600',
  },
  inputFocused: {
    backgroundColor: theme.colors.surfaceHighlight,
    borderColor: theme.colors.primary,
    borderWidth: 1,
  },
  inputCompleted: {
    backgroundColor: 'transparent',
    color: theme.colors.success, // Turns green when logged
  },
  checkButton: {
    width: 28,
    height: 28,
    borderRadius: 4,
    backgroundColor: theme.colors.surface,
    borderWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkButtonActive: {
    backgroundColor: theme.colors.success,
    borderColor: theme.colors.success,
  },
});
