import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassCard, Badge } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';
import { LineChart, Dumbbell, User, Trophy, TrendingUp } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';

export const ProgressDashboardScreen = () => {
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        <View style={styles.header}>
          <Typography variant="microcopy" color={colors.primary}>ANALYTICS</Typography>
          <Typography variant="hero">Progress</Typography>
        </View>

        {/* PR Vault */}
        <TouchableOpacity 
          activeOpacity={0.8}
          onPress={() => navigation.navigate('PrVault')}
          style={styles.heroSection}
        >
          <GlassCard style={styles.prCard}>
            <Trophy color={colors.primary} size={32} />
            <View style={styles.prText}>
              <Typography variant="title">12 PRs Hit</Typography>
              <Typography variant="microcopy" color={colors.textMuted}>VIEW TROPHY ROOM</Typography>
            </View>
          </GlassCard>
        </TouchableOpacity>

        {/* Body Weight */}
        <View style={styles.section}>
          <TouchableOpacity 
            style={styles.sectionHeader}
            onPress={() => navigation.navigate('BodyWeightHistory')}
          >
            <View style={styles.sectionTitleRow}>
              <User color={colors.primary} size={18} />
              <Typography variant="body" style={{fontWeight: '600'}}>Body Weight</Typography>
            </View>
            <Typography variant="microcopy" color={colors.textSubtle}>VIEW LOG</Typography>
          </TouchableOpacity>
          
          <TouchableOpacity activeOpacity={0.9} onPress={() => navigation.navigate('BodyWeightHistory')}>
            <GlassCard style={styles.chartCard}>
              <View style={styles.statRow}>
                <Typography variant="hero" tabular>78.0</Typography>
                <Typography variant="body" color={colors.textMuted} style={{marginBottom: 6}}>kg</Typography>
              </View>
              <View style={styles.chartPlaceholder}>
                <TrendingUp color={colors.textSubtle} size={24} />
                <Typography variant="microcopy" color={colors.textSubtle} style={{marginTop: spacing.sm}}>
                  CHART DATA UNAVAILABLE
                </Typography>
              </View>
            </GlassCard>
          </TouchableOpacity>
        </View>

        {/* Strength */}
        <View style={styles.section}>
          <TouchableOpacity 
            style={styles.sectionHeader}
            onPress={() => navigation.navigate('Exercise1RMChart', { exerciseId: '1' })}
          >
            <View style={styles.sectionTitleRow}>
              <Dumbbell color={colors.primary} size={18} />
              <Typography variant="body" style={{fontWeight: '600'}}>Strength 1RM</Typography>
            </View>
            <Typography variant="microcopy" color={colors.textSubtle}>VIEW TREND</Typography>
          </TouchableOpacity>

          <TouchableOpacity activeOpacity={0.9} onPress={() => navigation.navigate('ExerciseDirectory')}>
            <GlassCard style={styles.dropdownCard}>
              <Typography variant="body" color={colors.text}>Alternating Dumbbell Curl</Typography>
              <Typography variant="microcopy" color={colors.primary}>CHANGE</Typography>
            </GlassCard>
          </TouchableOpacity>
          
          <TouchableOpacity activeOpacity={0.9} onPress={() => navigation.navigate('Exercise1RMChart', { exerciseId: '1' })}>
            <GlassCard style={styles.chartCard}>
              <View style={styles.statRow}>
                <Typography variant="hero" tabular>10.0</Typography>
                <Typography variant="body" color={colors.textMuted} style={{marginBottom: 6}}>kg</Typography>
              </View>
              <View style={styles.chartPlaceholder}>
                <TrendingUp color={colors.textSubtle} size={24} />
                <Typography variant="microcopy" color={colors.textSubtle} style={{marginTop: spacing.sm}}>
                  CHART DATA UNAVAILABLE
                </Typography>
              </View>
            </GlassCard>
          </TouchableOpacity>
        </View>

      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.xxl,
    paddingBottom: spacing.xxl 
  },
  header: {
    marginBottom: spacing.xxl,
    alignItems: 'center',
  },
  heroSection: {
    marginBottom: spacing.xxl,
  },
  prCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.lg,
    padding: spacing.lg,
    backgroundColor: 'rgba(0, 240, 255, 0.05)',
    borderColor: 'rgba(0, 240, 255, 0.2)',
  },
  prText: {
    gap: spacing.xs,
  },
  section: {
    marginBottom: spacing.xxl,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  sectionTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  dropdownCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    marginBottom: spacing.md,
  },
  chartCard: {
    padding: spacing.lg,
  },
  statRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: spacing.xs,
    marginBottom: spacing.xl,
  },
  chartPlaceholder: {
    height: 120,
    justifyContent: 'center',
    alignItems: 'center',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.glassBorder,
  }
});
