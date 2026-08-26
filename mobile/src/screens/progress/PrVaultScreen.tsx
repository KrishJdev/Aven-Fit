import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, Badge } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft, Trophy } from 'lucide-react-native';

const MOCK_PRS = [
  { id: '1', name: 'Barbell Bench Press', date: '25 Aug', maxWeight: '100 kg', maxReps: '100 kg × 6', est1rm: '120.5 kg' },
  { id: '2', name: 'Squat', date: '24 Aug', maxWeight: '140 kg', maxReps: '140 kg × 5', est1rm: '163.3 kg' },
  { id: '3', name: 'Deadlift', date: '22 Aug', maxWeight: '180 kg', maxReps: '160 kg × 8', est1rm: '205.4 kg' },
];

export const PrVaultScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">PR Vault</Typography>
        <View style={{ width: 28 }} />
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        
        <View style={styles.heroSection}>
          <Trophy color={colors.highlight} size={48} style={styles.trophyIcon} />
          <Typography variant="hero">12 Records</Typography>
          <Typography variant="body" color={colors.textMuted}>Lifetime personal records achieved</Typography>
        </View>

        <View style={styles.list}>
          {MOCK_PRS.map((pr) => (
            <View key={pr.id} style={styles.prRow}>
              <View style={styles.prHeader}>
                <Typography variant="body" style={{ fontWeight: '700' }}>{pr.name}</Typography>
                <Typography variant="microcopy" color={colors.textMuted}>{pr.date}</Typography>
              </View>

              <View style={styles.statsGrid}>
                <View style={styles.statBox}>
                  <Typography variant="microcopy" color={colors.textMuted}>MAX WEIGHT</Typography>
                  <Typography variant="body" tabular color={colors.text}>{pr.maxWeight}</Typography>
                </View>
                <View style={styles.statBox}>
                  <Typography variant="microcopy" color={colors.textMuted}>MAX REPS</Typography>
                  <Typography variant="body" tabular color={colors.text}>{pr.maxReps}</Typography>
                </View>
                <View style={[styles.statBox, { borderRightWidth: 0 }]}>
                  <Typography variant="microcopy" color={colors.highlight}>EST. 1RM</Typography>
                  <Typography variant="body" tabular color={colors.highlight} style={{fontWeight: '700'}}>{pr.est1rm}</Typography>
                </View>
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
    paddingTop: spacing.xl,
    paddingBottom: spacing.xxl 
  },
  heroSection: {
    alignItems: 'center',
    marginBottom: spacing.xxl,
  },
  trophyIcon: {
    marginBottom: spacing.md,
  },
  list: {
  },
  prRow: {
    marginBottom: spacing.xl,
    backgroundColor: colors.glassBase,
    borderWidth: 1,
    borderColor: colors.glassBorder,
  },
  prHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  statsGrid: {
    flexDirection: 'row',
  },
  statBox: {
    flex: 1,
    padding: spacing.md,
    borderRightWidth: 1,
    borderRightColor: colors.glassBorder,
    gap: spacing.xs,
  }
});
