import React from 'react';
import { View, StyleSheet, ViewProps } from 'react-native';
import { Typography } from './Typography';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';

interface BadgeProps extends ViewProps {
  label: string;
  variant?: 'positive' | 'negative' | 'neutral' | 'accent';
}

export const Badge: React.FC<BadgeProps> = ({
  label,
  variant = 'neutral',
  style,
  ...props
}) => {
  let backgroundColor = colors.glassBorder;
  let textColor = colors.text;

  if (variant === 'positive') {
    backgroundColor = '#003300';
    textColor = colors.highlight; // Volt Green
  } else if (variant === 'negative') {
    backgroundColor = colors.errorMuted;
    textColor = colors.primary; // Burnt Orange
  } else if (variant === 'accent') {
    backgroundColor = colors.primaryMuted;
    textColor = colors.primary;
  }

  return (
    <View style={[styles.container, { backgroundColor }, style]} {...props}>
      <Typography variant="microcopy" color={textColor}>
        {label}
      </Typography>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: radii.sm, // 0px
    alignSelf: 'flex-start',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
