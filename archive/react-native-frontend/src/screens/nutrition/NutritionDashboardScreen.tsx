import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassCard } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';
import { ChevronLeft, ChevronRight, Calendar, Plus, Flame } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';

const MEALS = ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'];

export const NutritionDashboardScreen = () => {
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        <View style={styles.header}>
          <Typography variant="microcopy" color={colors.primary}>NUTRITION</Typography>
          <Typography variant="hero">Diet Log</Typography>
        </View>

        <View style={styles.dateSelector}>
          <TouchableOpacity style={styles.iconBtn}><ChevronLeft color={colors.text} size={24} /></TouchableOpacity>
          <View style={styles.dateCenter}>
            <Calendar color={colors.textMuted} size={16} />
            <Typography variant="body" style={{fontWeight: '600'}}>Today</Typography>
          </View>
          <TouchableOpacity style={styles.iconBtn}><ChevronRight color={colors.text} size={24} /></TouchableOpacity>
        </View>

        <GlassCard style={styles.macroRingCard}>
          <View style={styles.macroHeader}>
            <Flame color={colors.primary} size={20} />
            <Typography variant="title">2,450 / 3,000</Typography>
          </View>
          <Typography variant="microcopy" color={colors.textMuted} style={{marginBottom: spacing.xl}}>
            KCAL CONSUMED
          </Typography>

          <View style={styles.macroBars}>
            <View style={styles.macroCol}>
              <Typography variant="microcopy" color={colors.textSubtle}>PROTEIN</Typography>
              <Typography variant="body" tabular>150g</Typography>
            </View>
            <View style={styles.macroCol}>
              <Typography variant="microcopy" color={colors.textSubtle}>CARBS</Typography>
              <Typography variant="body" tabular>200g</Typography>
            </View>
            <View style={styles.macroCol}>
              <Typography variant="microcopy" color={colors.textSubtle}>FAT</Typography>
              <Typography variant="body" tabular>65g</Typography>
            </View>
          </View>
        </GlassCard>

        <View style={styles.mealsList}>
          {MEALS.map((meal) => (
            <TouchableOpacity 
              key={meal} 
              onPress={() => navigation.navigate('MealLoggingOverview', { mealType: meal })}
              activeOpacity={0.8}
            >
              <GlassCard style={styles.mealCard}>
                <View style={styles.mealHeader}>
                  <Typography variant="body" style={{fontWeight: '600', letterSpacing: 1}}>{meal}</Typography>
                  <TouchableOpacity 
                    style={styles.addBtn}
                    onPress={() => navigation.navigate('FoodDatabaseSearch')}
                  >
                    <Plus color={colors.primary} size={20} />
                  </TouchableOpacity>
                </View>
                <Typography variant="microcopy" color={colors.textSubtle}>
                  NO FOODS LOGGED
                </Typography>
              </GlassCard>
            </TouchableOpacity>
          ))}
        </View>

      </ScrollView>

      {/* Floating Action Button */}
      <TouchableOpacity 
        style={styles.fab}
        activeOpacity={0.9}
        onPress={() => navigation.navigate('FoodDatabaseSearch')}
      >
        <Plus color={colors.background} size={24} />
        <Typography variant="body" style={{fontWeight: '700', color: colors.background, letterSpacing: 1}}>LOG FOOD</Typography>
      </TouchableOpacity>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.xxl,
    paddingBottom: 100 
  },
  header: {
    marginBottom: spacing.xxl,
    alignItems: 'center',
  },
  dateSelector: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  dateCenter: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  iconBtn: { padding: spacing.xs },
  macroRingCard: {
    padding: spacing.xl,
    alignItems: 'center',
    marginBottom: spacing.xxl,
    backgroundColor: 'rgba(0, 240, 255, 0.02)',
  },
  macroHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    marginBottom: spacing.xs,
  },
  macroBars: {
    flexDirection: 'row',
    width: '100%',
    justifyContent: 'space-between',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.glassBorder,
    paddingTop: spacing.lg,
  },
  macroCol: {
    alignItems: 'center',
    gap: spacing.xs,
  },
  mealsList: {
    gap: spacing.md,
  },
  mealCard: {
    padding: spacing.lg,
  },
  mealHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  addBtn: {
    padding: spacing.xs,
    backgroundColor: colors.primaryMuted,
    borderRadius: radii.sm,
  },
  fab: {
    position: 'absolute',
    bottom: spacing.xxl,
    alignSelf: 'center',
    backgroundColor: colors.primary,
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.xl,
    borderRadius: radii.full,
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 12,
    elevation: 8,
  }
});
