import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';

interface MacroTargetProps {
  label: string;
  consumed: number;
  target: number;
  unit?: string;
  color?: string;
}

export const MacroTarget: React.FC<MacroTargetProps> = ({ 
  label, 
  consumed, 
  target, 
  unit = 'g',
  color = theme.colors.primary 
}) => {
  const progress = Math.min((consumed / target) * 100, 100);

  return (
    <View style={styles.container}>
      <Typography variant="label" color={theme.colors.textMuted} style={styles.label}>
        {label}
      </Typography>
      
      <View style={styles.track}>
        <View style={[styles.fill, { height: `${progress}%`, backgroundColor: color }]} />
      </View>
      
      <View style={styles.stats}>
        <Typography variant="tabular" style={styles.consumed}>{consumed}</Typography>
        <Typography variant="label" color={theme.colors.textSubtle} style={styles.target}>
          / {target}{unit}
        </Typography>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    width: 64,
  },
  label: {
    marginBottom: theme.spacing.sm,
  },
  track: {
    width: 6,
    height: 80,
    backgroundColor: theme.colors.glassBorder,
    borderRadius: theme.radii.full,
    justifyContent: 'flex-end',
    marginBottom: theme.spacing.sm,
    overflow: 'hidden',
  },
  fill: {
    width: '100%',
    borderRadius: theme.radii.full,
  },
  stats: {
    alignItems: 'center',
  },
  consumed: {
    fontSize: 14,
    marginBottom: 2,
  },
  target: {
    fontSize: 10,
  }
});
