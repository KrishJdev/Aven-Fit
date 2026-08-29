import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Typography, GlassCard } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft } from 'lucide-react-native';

export const MuscleVolumeDistributionScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">Muscle Volume</Typography>
        <View style={{ width: 28 }} />
      </View>
      
      <View style={styles.container}>
        <GlassCard style={styles.chartCard}>
          <Typography variant="body" color={colors.textSubtle}>
            Muscle Heatmap Graphic
          </Typography>
        </GlassCard>
      </View>
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
  container: { 
    flex: 1,
    padding: spacing.screenHorizontal, 
    paddingTop: spacing.lg,
  },
  chartCard: {
    height: 300,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#131316',
  }
});
