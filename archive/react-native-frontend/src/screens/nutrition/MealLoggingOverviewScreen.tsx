import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassButton } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft, Plus, MoreVertical } from 'lucide-react-native';

const MOCK_FOODS = [
  { id: '1', name: 'Oats with Milk', serving: '1 bowl', calories: '350 kcal', protein: '12g' },
  { id: '2', name: 'Banana', serving: '1 medium', calories: '105 kcal', protein: '1g' },
];

export const MealLoggingOverviewScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">Breakfast</Typography>
        <TouchableOpacity style={styles.optionsBtn}>
          <MoreVertical color={colors.text} size={24} />
        </TouchableOpacity>
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        
        <View style={styles.summaryCard}>
          <Typography variant="hero" tabular>455 kcal</Typography>
          <View style={styles.macroRow}>
            <Typography variant="microcopy" color={colors.textMuted}>PROTEIN: 13g</Typography>
            <Typography variant="microcopy" color={colors.textMuted}>CARBS: 75g</Typography>
            <Typography variant="microcopy" color={colors.textMuted}>FAT: 10g</Typography>
          </View>
        </View>

        <View style={styles.list}>
          {MOCK_FOODS.map((food) => (
            <View key={food.id} style={styles.foodRow}>
              <View style={styles.foodInfo}>
                <Typography variant="body" style={{ fontWeight: '700' }}>{food.name}</Typography>
                <Typography variant="microcopy" color={colors.textMuted}>{food.serving}</Typography>
              </View>
              <View style={styles.foodStats}>
                <Typography variant="body" tabular>{food.calories}</Typography>
                <Typography variant="microcopy" color={colors.textMuted}>P: {food.protein}</Typography>
              </View>
            </View>
          ))}
        </View>

        <GlassButton 
          title="+ ADD FOOD" 
          variant="secondary" 
          style={styles.addFoodBtn} 
        />
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
  optionsBtn: { padding: spacing.xs },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.xl,
    paddingBottom: spacing.xxl 
  },
  summaryCard: {
    backgroundColor: '#131316',
    borderWidth: 1,
    borderColor: colors.glassBorder,
    padding: spacing.lg,
    marginBottom: spacing.xl,
  },
  macroRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: spacing.md,
    borderTopWidth: 1,
    borderTopColor: colors.glassBorder,
    paddingTop: spacing.md,
  },
  list: {
    marginBottom: spacing.md,
  },
  foodRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  foodInfo: {
    flex: 1,
  },
  foodStats: {
    alignItems: 'flex-end',
  },
  addFoodBtn: {
    marginTop: spacing.xl,
  }
});
