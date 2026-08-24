import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';
import { Play, ArrowRight } from 'lucide-react-native';
import * as Haptics from 'react-native-haptic-feedback';

interface ActionCardProps {
  title: string;
  subtitle: string;
  onPress: () => void;
}

export const ActionCard: React.FC<ActionCardProps> = ({ title, subtitle, onPress }) => {
  const handlePress = () => {
    Haptics.trigger('impactMedium');
    onPress();
  };

  return (
    <TouchableOpacity 
      activeOpacity={0.9} 
      onPress={handlePress}
      style={styles.container}
    >
      <View style={styles.content}>
        <Typography variant="label" color={theme.colors.primary} style={styles.label}>
          NEXT UP
        </Typography>
        <Typography variant="h2" style={styles.title}>
          {title}
        </Typography>
        <Typography variant="body" color={theme.colors.textMuted}>
          {subtitle}
        </Typography>
      </View>
      
      <View style={styles.iconContainer}>
        <ArrowRight color={theme.colors.background} size={24} />
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radii.md,
    padding: theme.spacing.lg,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
  },
  content: {
    flex: 1,
  },
  label: {
    marginBottom: theme.spacing.sm,
  },
  title: {
    marginBottom: theme.spacing.xs,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: theme.colors.text,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: theme.spacing.md,
  },
});
