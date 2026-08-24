import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';

const DAYS = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

export const MomentumChart: React.FC = () => {
  // Mock data representing a typical week's consistency
  const activeDays = [true, false, true, true, false, false, false];

  return (
    <View style={styles.container}>
      <Typography variant="label" style={styles.sectionTitle}>MOMENTUM</Typography>
      
      <View style={styles.card}>
        <View style={styles.header}>
          <Typography variant="h2">3 Day Streak</Typography>
          <Typography variant="body" color={theme.colors.textMuted}>This Week</Typography>
        </View>

        <View style={styles.grid}>
          {DAYS.map((day, index) => {
            const isActive = activeDays[index];
            return (
              <View key={index} style={styles.dayCol}>
                <View style={[styles.dot, isActive && styles.dotActive]} />
                <Typography 
                  variant="label" 
                  color={isActive ? theme.colors.text : theme.colors.textSubtle}
                  style={styles.dayLabel}
                >
                  {day}
                </Typography>
              </View>
            );
          })}
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: theme.spacing.xl,
    marginBottom: theme.spacing.xxl,
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
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginBottom: theme.spacing.lg,
  },
  grid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: theme.spacing.xs,
  },
  dayCol: {
    alignItems: 'center',
  },
  dot: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: theme.colors.background,
    marginBottom: theme.spacing.sm,
    borderWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
  },
  dotActive: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },
  dayLabel: {
    fontSize: 12,
  },
});
