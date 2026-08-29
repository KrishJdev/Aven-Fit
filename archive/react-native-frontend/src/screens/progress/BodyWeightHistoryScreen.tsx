import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassButton, GlassCard, Badge } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft, Plus } from 'lucide-react-native';

const MOCK_HISTORY = [
  { id: '1', date: '25 Aug 2026', weight: '78.0 kg', change: '0.0 kg', trend: 'neutral' },
  { id: '2', date: '20 Aug 2026', weight: '78.0 kg', change: '-0.2 kg', trend: 'positive' },
  { id: '3', date: '15 Aug 2026', weight: '78.2 kg', change: '-0.5 kg', trend: 'positive' },
  { id: '4', date: '10 Aug 2026', weight: '78.7 kg', change: '+0.1 kg', trend: 'negative' },
];

export const BodyWeightHistoryScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">Body Weight</Typography>
        <TouchableOpacity style={styles.addBtn}>
          <Plus color={colors.text} size={24} />
        </TouchableOpacity>
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        <GlassCard style={styles.chartCard}>
          <Typography variant="body" color={colors.textSubtle}>
            Full screen chart goes here.
          </Typography>
        </GlassCard>

        <View style={styles.historyList}>
          <Typography variant="microcopy" color={colors.textMuted} style={styles.listTitle}>
            HISTORY LOG
          </Typography>

          {MOCK_HISTORY.map((entry) => (
            <View key={entry.id} style={styles.historyRow}>
              <Typography variant="body" style={styles.date}>{entry.date}</Typography>
              <View style={styles.weightCol}>
                <Typography variant="title" tabular>{entry.weight}</Typography>
                <Badge 
                  label={entry.change} 
                  variant={entry.trend as 'positive' | 'negative' | 'neutral'} 
                />
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
  addBtn: { padding: spacing.xs },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.lg,
    paddingBottom: spacing.xxl 
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
    // 
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
    color: colors.textMuted,
  },
  weightCol: {
    alignItems: 'flex-end',
    gap: spacing.xs,
  }
});
