import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassCard, Badge } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft, Info } from 'lucide-react-native';

const MOCK_HISTORY = [
  { id: '1', date: '25 Aug 2026', oneRm: '120.5 kg', weight: '100 kg', reps: '6' },
  { id: '2', date: '18 Aug 2026', oneRm: '115.0 kg', weight: '95 kg', reps: '7' },
];

export const Exercise1RMChartScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">1RM Progression</Typography>
        <View style={{ width: 28 }} />
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        <View style={styles.exerciseInfo}>
          <Typography variant="hero">Bench Press</Typography>
          <Typography variant="body" color={colors.textMuted} style={styles.subtitle}>
            Estimated 1-Rep Max (Brzycki Formula)
          </Typography>
        </View>

        <GlassCard style={styles.chartCard}>
          <Typography variant="body" color={colors.textSubtle}>
            Strength trend line chart goes here.
          </Typography>
        </GlassCard>

        <View style={styles.historyList}>
          <Typography variant="microcopy" color={colors.textMuted} style={styles.listTitle}>
            HISTORY LOG
          </Typography>

          {MOCK_HISTORY.map((entry) => (
            <View key={entry.id} style={styles.historyRow}>
              <View>
                <Typography variant="body" style={styles.date}>{entry.date}</Typography>
                <Typography variant="microcopy" color={colors.textMuted}>
                  {entry.weight} × {entry.reps} REPS
                </Typography>
              </View>
              <View style={styles.weightCol}>
                <Typography variant="title" tabular color={colors.highlight}>{entry.oneRm}</Typography>
                <Typography variant="microcopy" color={colors.textMuted}>EST. 1RM</Typography>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>

    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  backBtn: { padding: spacing.xs },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.lg,
    paddingBottom: spacing.xxl 
  },
  exerciseInfo: {
    marginBottom: spacing.xl,
  },
  subtitle: {
    marginTop: spacing.xs,
  },
  chartCard: {
    height: 250,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.xl,
    backgroundColor: '#131316',
  },
  listTitle: {
    marginBottom: spacing.md,
  },
  historyList: {
  },
  historyRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  date: {
    color: colors.text,
    marginBottom: spacing.xs,
  },
  weightCol: {
    alignItems: 'flex-end',
  }
});
