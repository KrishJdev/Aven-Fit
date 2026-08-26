import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, TextInput } from 'react-native';
import { Typography, GlassButton } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft } from 'lucide-react-native';

export const FoodItemDetailScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">Add Food</Typography>
        <View style={{ width: 28 }} />
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        
        <View style={styles.foodHeader}>
          <Typography variant="hero">Roti / Chapati</Typography>
          <Typography variant="body" color={colors.textMuted}>Generic</Typography>
        </View>

        <View style={styles.macroGrid}>
          <View style={styles.macroBox}>
            <Typography variant="microcopy" color={colors.textMuted}>CALORIES</Typography>
            <Typography variant="title" tabular>104</Typography>
          </View>
          <View style={styles.macroBox}>
            <Typography variant="microcopy" color={colors.textMuted}>PROTEIN</Typography>
            <Typography variant="title" tabular>3.0g</Typography>
          </View>
          <View style={styles.macroBox}>
            <Typography variant="microcopy" color={colors.textMuted}>CARBS</Typography>
            <Typography variant="title" tabular>22.0g</Typography>
          </View>
          <View style={[styles.macroBox, { borderRightWidth: 0 }]}>
            <Typography variant="microcopy" color={colors.textMuted}>FAT</Typography>
            <Typography variant="title" tabular>0.5g</Typography>
          </View>
        </View>

        <View style={styles.adjusterSection}>
          <View style={styles.inputCol}>
            <Typography variant="microcopy" color={colors.textMuted}>NUMBER OF SERVINGS</Typography>
            <TextInput
              style={styles.input}
              keyboardType="decimal-pad"
              defaultValue="1"
            />
          </View>
          <View style={styles.inputCol}>
            <Typography variant="microcopy" color={colors.textMuted}>SERVING SIZE</Typography>
            <TouchableOpacity style={styles.dropdown}>
              <Typography variant="body" color={colors.text}>1 medium (30g)</Typography>
              <Typography variant="body" color={colors.textMuted}>▼</Typography>
            </TouchableOpacity>
          </View>
        </View>

      </ScrollView>

      <View style={styles.footer}>
        <GlassButton title="LOG FOOD" variant="primary" style={{ flex: 1 }} />
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
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.xl,
    paddingBottom: spacing.xxl 
  },
  foodHeader: {
    marginBottom: spacing.xxl,
  },
  macroGrid: {
    flexDirection: 'row',
    borderWidth: 1,
    borderColor: colors.glassBorder,
    marginBottom: spacing.xxl,
    backgroundColor: '#131316',
  },
  macroBox: {
    flex: 1,
    padding: spacing.sm,
    borderRightWidth: 1,
    borderRightColor: colors.glassBorder,
    alignItems: 'center',
    gap: spacing.xs,
  },
  adjusterSection: {
    flexDirection: 'row',
    gap: spacing.md,
  },
  inputCol: {
    flex: 1,
    gap: spacing.sm,
  },
  input: {
    height: 48,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    backgroundColor: colors.glassBase,
    color: colors.text,
    paddingHorizontal: spacing.md,
    fontSize: 16,
    fontVariant: ['tabular-nums'],
  },
  dropdown: {
    height: 48,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    backgroundColor: colors.glassBase,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.md,
  },
  footer: {
    padding: spacing.screenHorizontal,
    borderTopWidth: 1,
    borderTopColor: colors.glassBorder,
    backgroundColor: colors.background,
  }
});
