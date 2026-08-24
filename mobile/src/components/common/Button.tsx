import React from 'react';
import { 
  TouchableOpacity, 
  TouchableOpacityProps, 
  StyleSheet, 
  ActivityIndicator,
  View
} from 'react-native';
import { Typography } from './Typography';
import { theme } from '@/theme';
import * as Haptics from 'react-native-haptic-feedback';

interface ButtonProps extends TouchableOpacityProps {
  title: string;
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  isLoading?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  title,
  variant = 'primary',
  isLoading = false,
  style,
  onPress,
  disabled,
  ...props
}) => {
  const handlePress = (e: any) => {
    Haptics.trigger('impactLight');
    onPress?.(e);
  };

  const isPrimary = variant === 'primary';
  const isOutline = variant === 'outline';
  
  return (
    <TouchableOpacity
      activeOpacity={0.8}
      onPress={handlePress}
      disabled={disabled || isLoading}
      style={[
        styles.container,
        isPrimary && styles.primary,
        variant === 'secondary' && styles.secondary,
        isOutline && styles.outline,
        (disabled || isLoading) && styles.disabled,
        style,
      ]}
      {...props}
    >
      {isLoading ? (
        <ActivityIndicator color={isPrimary ? theme.colors.background : theme.colors.primary} />
      ) : (
        <Typography 
          variant="label" 
          color={isPrimary ? theme.colors.background : theme.colors.text}
          style={isOutline ? { color: theme.colors.text } : undefined}
        >
          {title}
        </Typography>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    height: 56,
    borderRadius: theme.radii.sm, // Sharp, premium radius
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: theme.spacing.lg,
  },
  primary: {
    backgroundColor: theme.colors.primary,
  },
  secondary: {
    backgroundColor: theme.colors.surfaceHighlight,
  },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
  },
  disabled: {
    opacity: 0.5,
  },
});
