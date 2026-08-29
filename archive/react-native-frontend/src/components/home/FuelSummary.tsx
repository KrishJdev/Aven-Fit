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
        <Typography variant="label" color={theme.colors.textMuted} style={styles.macroLabel}>{label}</Typography>
        <View style={styles.macroValues}>
          <Typography variant="tabular" style={styles.consumed}>{consumed}</Typography>
          <Typography variant="tabular" color={theme.colors.textSubtle} style={styles.target}> / {target}{unit}</Typography>
        </View>
      </View>
      <View style={styles.track}>
        <View style={[styles.fill, { width: `${progress}%`, backgroundColor: color }]} />
      </View>
    </View>
  );
};

export const FuelSummary: React.FC = () => {
  return (
    <View style={styles.container}>
      <View style={styles.headerRow}>
        <Typography variant="label" style={styles.sectionTitle} color={theme.colors.textSubtle}>FUEL</Typography>
        <Typography variant="label" style={styles.sectionTitle} color={theme.colors.textSubtle}>INTAKE</Typography>
      </View>
      
      <View style={styles.metricsWrapper}>
        <MacroBar label="KCAL" consumed={1450} target={2200} unit="" isPrimary />
        <MacroBar label="PRO" consumed={110} target={160} unit="G" />
        <MacroBar label="CRB" consumed={180} target={240} unit="G" />
        <MacroBar label="FAT" consumed={45} target={70} unit="G" />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: theme.spacing.xl,
    paddingVertical: theme.spacing.lg,
  },
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderBottomWidth: 1,
    borderColor: theme.colors.glassBorder,
    paddingBottom: theme.spacing.sm,
    marginBottom: theme.spacing.md,
  },
  sectionTitle: {
    letterSpacing: 2,
    fontSize: 10,
  },
  metricsWrapper: {
    gap: theme.spacing.md,
  },
  macroContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  macroHeader: {
    width: 140,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingRight: theme.spacing.md,
  },
  macroLabel: {
    letterSpacing: 1.5,
    fontSize: 11,
  },
  macroValues: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  consumed: {
    fontSize: 14,
    fontWeight: '700',
  },
  target: {
    fontSize: 12,
  },
  track: {
    flex: 1,
    height: 4,
    backgroundColor: theme.colors.glassBorder,
  },
  fill: {
    height: '100%',
  },
});
