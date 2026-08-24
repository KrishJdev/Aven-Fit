import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';

interface MacroProps {
  label: string;
  consumed: number;
  target: number;
  unit: string;
  isPrimary?: boolean;
}

const MacroBar: React.FC<MacroProps> = ({ label, consumed, target, unit, isPrimary }) => {
  const progress = Math.min((consumed / target) * 100, 100);
  const color = isPrimary ? theme.colors.primary : theme.colors.text;

  return (
    <View style={styles.macroContainer}>
      <View style={styles.macroHeader}>
        <Typography variant="label" color={theme.colors.textMuted}>{label}</Typography>
        <View style={styles.macroValues}>
          <Typography variant="tabular" style={styles.consumed}>{consumed}</Typography>
          <Typography variant="body" color={theme.colors.textSubtle}> / {target}{unit}</Typography>
        </View>
      </View>
      <View style={styles.track}>
        <View style={[styles.fill, { width: `${progress}%`, backgroundColor: color }]} />
      </View>
    </View>
  );
};

export const FuelSummary: React.FC = () => {
  // In a real implementation, this comes from the database/store
  return (
    <View style={styles.container}>
      <Typography variant="label" style={styles.sectionTitle}>TODAY'S FUEL</Typography>
      
      <View style={styles.card}>
        <MacroBar label="Calories" consumed={1450} target={2200} unit="kcal" isPrimary />
        <View style={styles.divider} />
        <MacroBar label="Protein" consumed={110} target={160} unit="g" />
        <View style={styles.divider} />
        <MacroBar label="Carbs" consumed={180} target={240} unit="g" />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: theme.spacing.xl,
  },
  sectionTitle: {
    marginBottom: theme.spacing.md,
    letterSpacing: 1,
  },
  card: {
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radii.md,
    padding: theme.spacing.lg,
    borderWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
  },
  macroContainer: {
    marginVertical: theme.spacing.xs,
  },
  macroHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginBottom: theme.spacing.sm,
  },
  macroValues: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  consumed: {
    fontSize: theme.typography.sizes.md,
  },
  track: {
    height: 4,
    backgroundColor: theme.colors.background,
    borderRadius: theme.radii.full,
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
    borderRadius: theme.radii.full,
  },
  divider: {
    height: 1,
    backgroundColor: theme.colors.surfaceHighlight,
    marginVertical: theme.spacing.md,
  }
});
