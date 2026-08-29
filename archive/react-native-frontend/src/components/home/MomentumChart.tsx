import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';

const DAYS = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

export const MomentumChart: React.FC = () => {
  // Mock data: height of the bar represents intensity or just binary completed
  const activity = [1, 0, 0.8, 1, 0, 0, 0];

  return (
    <View style={styles.container}>
      <View style={styles.headerRow}>
        <Typography variant="label" style={styles.sectionTitle} color={theme.colors.textSubtle}>MOMENTUM</Typography>
        <Typography variant="tabular" style={styles.streakText}>3 DAY STREAK</Typography>
      </View>
      
      <View style={styles.grid}>
        {DAYS.map((day, index) => {
          const val = activity[index];
          const isActive = val > 0;
          return (
            <View key={index} style={styles.dayCol}>
              <View style={styles.barTrack}>
                <View style={[
                  styles.barFill, 
                  { height: `${val * 100}%`, backgroundColor: isActive ? theme.colors.text : 'transparent' }
                ]} />
              </View>
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
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: theme.spacing.xl,
    marginBottom: theme.spacing.xxl,
  },
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    borderBottomWidth: 1,
    borderColor: theme.colors.glassBorder,
    paddingBottom: theme.spacing.sm,
    marginBottom: theme.spacing.lg,
  },
  sectionTitle: {
    letterSpacing: 2,
    fontSize: 10,
  },
  streakText: {
    fontSize: 12,
    color: theme.colors.primary,
  },
  grid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  dayCol: {
    alignItems: 'center',
    width: 32,
  },
  barTrack: {
    width: 6,
    height: 48,
    backgroundColor: theme.colors.glassBorder,
    justifyContent: 'flex-end',
    marginBottom: theme.spacing.md,
  },
  barFill: {
    width: '100%',
  },
  dayLabel: {
    fontSize: 10,
    letterSpacing: 1,
  },
});
