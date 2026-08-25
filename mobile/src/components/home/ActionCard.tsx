import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';
import { ArrowRight } from 'lucide-react-native';
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
      activeOpacity={0.8} 
      onPress={handlePress}
      style={styles.container}
    >
      <View style={styles.topRow}>
        <View style={styles.badge}>
          <Typography variant="label" color={theme.colors.background} style={styles.badgeText}>
            NEXT UP
          </Typography>
        </View>
        <ArrowRight color={theme.colors.primary} size={24} strokeWidth={1.5} />
      </View>
      
      <View style={styles.bottomRow}>
        <Typography variant="h1" style={styles.title} numberOfLines={1}>
          {title.toUpperCase()}
        </Typography>
        <Typography variant="body" color={theme.colors.textMuted} style={styles.subtitle}>
          {subtitle.toUpperCase()}
        </Typography>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'transparent',
    paddingVertical: theme.spacing.xl,
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
    marginVertical: theme.spacing.md,
  },
  topRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: theme.spacing.lg,
  },
  badge: {
    backgroundColor: theme.colors.primary,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  badgeText: {
    letterSpacing: 2,
    fontSize: 10,
    fontWeight: '700',
  },
  bottomRow: {
    flexDirection: 'column',
  },
  title: {
    fontSize: 40,
    lineHeight: 44,
    letterSpacing: -1,
    marginBottom: 4,
  },
  subtitle: {
    letterSpacing: 1,
    fontSize: 12,
  },
});
