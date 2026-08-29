import React from 'react';
import { TouchableOpacity, TouchableOpacityProps, StyleSheet, View } from 'react-native';
import { Typography } from './Typography';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';

interface GlassButtonProps extends TouchableOpacityProps {
  title: string;
  variant?: 'primary' | 'secondary' | 'ghost';
  leftIcon?: React.ReactNode;
}

export const GlassButton: React.FC<GlassButtonProps> = ({
  title,
  variant = 'primary',
  leftIcon,
  style,
  ...props
}) => {
  return (
    <TouchableOpacity
      activeOpacity={0.7}
      style={[
        styles.button,
        variant === 'primary' && styles.primary,
        variant === 'secondary' && styles.secondary,
        variant === 'ghost' && styles.ghost,
        style,
      ]}
      {...props}
    >
      <View style={styles.contentContainer}>
        {leftIcon && <View style={styles.iconWrapper}>{leftIcon}</View>}
        <Typography
          variant="body"
          style={[
            styles.text,
            variant === 'primary' && styles.textPrimary,
          ]}
        >
          {title.toUpperCase()}
        </Typography>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    height: 52,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: radii.md, // Soft pill/rectangle shape
    paddingHorizontal: spacing.xl,
  },
  primary: {
    backgroundColor: colors.primaryMuted, // rgba(0,240,255,0.15)
    borderWidth: 1,
    borderColor: 'rgba(0, 240, 255, 0.4)', // Glowing border
  },
  secondary: {
    backgroundColor: colors.glassBase,
    borderWidth: 1,
    borderColor: colors.glassBorder,
  },
  ghost: {
    backgroundColor: 'transparent',
  },
  contentContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconWrapper: {
    marginRight: spacing.sm,
  },
  text: {
    fontWeight: '600',
    letterSpacing: 1.5,
    color: colors.text, // default white
  },
  textPrimary: {
    color: colors.primary, // Glowing cyan text for primary
    textShadowColor: 'rgba(0, 240, 255, 0.5)',
    textShadowOffset: { width: 0, height: 0 },
    textShadowRadius: 8, // Real neon glow effect
  },
});
