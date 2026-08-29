import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassButton, Badge, GlassCard } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft, Info, TrendingUp } from 'lucide-react-native';

export const ExerciseDetailScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        <Typography variant="hero" style={styles.title}>Barbell Bench Press</Typography>

        <View style={styles.badgesRow}>
          <Badge label="CHEST" variant="neutral" />
          <Badge label="BARBELL" variant="neutral" />
          <Badge label="COMPOUND" variant="accent" />
        </View>

        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Info color={colors.textMuted} size={16} />
            <Typography variant="microcopy" color={colors.textMuted}>INSTRUCTIONS</Typography>
          </View>
          <Typography variant="body" color={colors.text}>
            Lie on a flat bench. Grip the barbell with hands slightly wider than shoulder-width. Lower the bar to your mid-chest, then press back up until arms are extended.
          </Typography>
        </View>

        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <TrendingUp color={colors.textMuted} size={16} />
            <Typography variant="microcopy" color={colors.textMuted}>PERFORMANCE HISTORY</Typography>
          </View>
          
          <GlassCard style={styles.chartCard}>
            <Typography variant="body" color={colors.textSubtle}>
              Chart will appear here once you log this exercise.
            </Typography>
          </GlassCard>
        </View>

      </ScrollView>

      <View style={styles.footer}>
        <GlassButton title="ADD TO WORKOUT" variant="primary" style={{ flex: 1 }} />
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  header: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.sm,
  },
  backBtn: {
    padding: spacing.xs,
  },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingBottom: spacing.xxl 
  },
  title: {
    marginBottom: spacing.md,
  },
  badgesRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
    marginBottom: spacing.xl,
  },
  section: {
    marginBottom: spacing.xl,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
    marginBottom: spacing.md,
  },
  chartCard: {
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
  },
  footer: {
    padding: spacing.screenHorizontal,
    borderTopWidth: 1,
    borderTopColor: colors.glassBorder,
    backgroundColor: colors.background,
  }
});
