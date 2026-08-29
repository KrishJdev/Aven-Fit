import React from 'react';
import { ScrollView, View, StyleSheet } from 'react-native';
import { Screen } from '@/components/common/Screen';
import { Typography } from '@/components/common/Typography';
import { MacroTarget } from '@/components/nutrition/MacroTarget';
import { MealSection, FoodItem } from '@/components/nutrition/MealSection';
import { theme } from '@/theme';
import { Flame } from 'lucide-react-native';

const MOCK_LUNCH: FoodItem[] = [
  { id: '1', name: 'Paneer Tikka', serving: '1 Katori (150g)', calories: 340, protein: 18 },
  { id: '2', name: 'Roti (Whole Wheat)', serving: '2 medium', calories: 240, protein: 6 },
  { id: '3', name: 'Dal Makhani', serving: '1 Katori', calories: 280, protein: 9 },
];

export const NutritionScreen = () => {
  const handleAddFood = (mealType: string) => {
    // Navigates to FoodSearchScreen
    console.log(`Add to ${mealType}`);
  };

  return (
    <Screen safeArea edges={['top', 'left', 'right']} style={styles.screen}>
      <ScrollView 
        style={styles.container} 
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
      >
        {/* Editorial Header */}
        <View style={styles.header}>
          <Typography variant="h1" style={styles.title}>NUTRITION</Typography>
          
          <View style={styles.dashboard}>
            {/* Calories Remaining (Primary focus) */}
            <View style={styles.calContainer}>
              <View style={styles.calRow}>
                <Flame color={theme.colors.primary} size={20} />
                <Typography variant="label" color={theme.colors.textMuted} style={styles.calLabel}>
                  REMAINING
                </Typography>
              </View>
              <Typography variant="display" style={styles.calValue}>
                1,340
              </Typography>
              <Typography variant="body" color={theme.colors.textSubtle}>
                Goal: 2,200 kcal
              </Typography>
            </View>

            {/* Macros (Vertical Targets) */}
            <View style={styles.macrosContainer}>
              <MacroTarget label="PRO" consumed={33} target={160} color={theme.colors.primary} />
              <MacroTarget label="CARB" consumed={95} target={240} color={theme.colors.highlight} />
              <MacroTarget label="FAT" consumed={35} target={65} color={theme.colors.text} />
            </View>
          </View>
        </View>

        {/* Meals */}
        <MealSection 
          title="Breakfast" 
          items={[]} 
          onAddFood={() => handleAddFood('Breakfast')} 
        />
        
        <MealSection 
          title="Lunch" 
          items={MOCK_LUNCH} 
          onAddFood={() => handleAddFood('Lunch')} 
        />
        
        <MealSection 
          title="Dinner" 
          items={[]} 
          onAddFood={() => handleAddFood('Dinner')} 
        />
        
        <MealSection 
          title="Snacks" 
          items={[]} 
          onAddFood={() => handleAddFood('Snacks')} 
        />

      </ScrollView>
    </Screen>
  );
};

const styles = StyleSheet.create({
  screen: {
    backgroundColor: theme.colors.background,
  },
  container: {
    flex: 1,
  },
  content: {
    paddingTop: theme.spacing.lg,
    paddingBottom: 100, // Tab bar padding
  },
  header: {
    paddingHorizontal: theme.spacing.screenHorizontal,
    marginBottom: theme.spacing.xxl,
  },
  title: {
    letterSpacing: 2,
    marginBottom: theme.spacing.xl,
  },
  dashboard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  calContainer: {
    flex: 1,
  },
  calRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: theme.spacing.xs,
  },
  calLabel: {
    marginLeft: theme.spacing.xs,
    letterSpacing: 1,
  },
  calValue: {
    marginBottom: theme.spacing.xs,
  },
  macrosContainer: {
    flexDirection: 'row',
    gap: theme.spacing.md,
  }
});
