import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';
import { Plus } from 'lucide-react-native';

export interface FoodItem {
  id: string;
  name: string;
  serving: string;
  calories: number;
  protein: number;
}

interface MealSectionProps {
  title: string;
  items: FoodItem[];
  onAddFood: () => void;
}

export const MealSection: React.FC<MealSectionProps> = ({ title, items, onAddFood }) => {
  const totalCalories = items.reduce((sum, item) => sum + item.calories, 0);

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Typography variant="h2">{title}</Typography>
        <Typography variant="tabular" color={theme.colors.textMuted}>
          {totalCalories} kcal
        </Typography>
      </View>

      {/* Food Items */}
      <View style={styles.itemsContainer}>
        {items.map((item, index) => (
          <View key={item.id}>
            <View style={styles.foodRow}>
              <View style={styles.foodInfo}>
                <Typography variant="body">{item.name}</Typography>
                <Typography variant="label" color={theme.colors.textSubtle}>
                  {item.serving} • {item.protein}g protein
                </Typography>
              </View>
              <Typography variant="tabular">{item.calories}</Typography>
            </View>
            {index < items.length - 1 && <View style={styles.divider} />}
          </View>
        ))}

        {/* Empty State / Add Action */}
        <TouchableOpacity 
          style={[
            styles.addAction, 
            items.length > 0 && { borderTopWidth: 1, borderTopColor: theme.colors.surfaceHighlight }
          ]} 
          onPress={onAddFood} 
          activeOpacity={0.7}
        >
          <Plus color={theme.colors.primary} size={20} />
          <Typography variant="label" color={theme.colors.primary} style={styles.addText}>
            ADD FOOD
          </Typography>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: theme.spacing.xl,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginBottom: theme.spacing.md,
    paddingHorizontal: theme.spacing.screenHorizontal,
  },
  itemsContainer: {
    backgroundColor: theme.colors.surface,
    borderWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
    borderLeftWidth: 0,
    borderRightWidth: 0,
  },
  foodRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.screenHorizontal,
  },
  foodInfo: {
    flex: 1,
    paddingRight: theme.spacing.md,
  },
  divider: {
    height: 1,
    backgroundColor: theme.colors.surfaceHighlight,
    marginLeft: theme.spacing.screenHorizontal,
  },
  addAction: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.screenHorizontal,
  },
  addText: {
    marginLeft: theme.spacing.sm,
  },
});
