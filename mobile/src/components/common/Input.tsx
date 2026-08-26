import React, { useState } from 'react';
import { 
  TextInput, 
  TextInputProps, 
  View, 
  StyleSheet 
} from 'react-native';
import { Typography } from './Typography';
import { theme } from '@/theme';

interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
}

export const Input: React.FC<InputProps> = ({
  label,
  error,
  style,
  onFocus,
  onBlur,
  ...props
}) => {
  const [isFocused, setIsFocused] = useState(false);

  const handleFocus = (e: any) => {
    setIsFocused(true);
    onFocus?.(e);
  };

  const handleBlur = (e: any) => {
    setIsFocused(false);
    onBlur?.(e);
  };

  return (
    <View style={styles.container}>
      {label && (
        <Typography variant="label" color={theme.colors.textMuted} style={styles.label}>
          {label}
        </Typography>
      )}
      <TextInput
        style={[
          styles.input,
          isFocused && styles.inputFocused,
          error && styles.inputError,
          style,
        ]}
        placeholderTextColor={theme.colors.textSubtle}
        onFocus={handleFocus}
        onBlur={handleBlur}
        {...props}
      />
      {error && (
        <Typography variant="body" color={theme.colors.error} style={styles.errorText}>
          {error}
        </Typography>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: theme.spacing.md,
  },
  label: {
    marginBottom: theme.spacing.sm,
  },
  input: {
    height: 56,
    backgroundColor: theme.colors.glassBase,
    borderWidth: 1,
    borderColor: theme.colors.glassBorder,
    borderRadius: theme.radii.sm,
    color: theme.colors.text,
    paddingHorizontal: theme.spacing.md,
    fontSize: theme.typography.sizes.md,
    fontFamily: theme.typography.primary,
  },
  inputFocused: {
    borderColor: theme.colors.primary,
    backgroundColor: theme.colors.background,
  },
  inputError: {
    borderColor: theme.colors.error,
  },
  errorText: {
    marginTop: theme.spacing.xs,
    fontSize: theme.typography.sizes.sm,
  },
});
