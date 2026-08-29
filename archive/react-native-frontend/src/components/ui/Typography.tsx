import React from 'react';
import { Text, TextProps, StyleSheet } from 'react-native';
import { colors } from '../../theme/colors';

interface TypographyProps extends TextProps {
  variant?: 'hero' | 'header' | 'title' | 'body' | 'microcopy';
  color?: string;
  tabular?: boolean;
}

export const Typography: React.FC<TypographyProps> = ({
  variant = 'body',
  color = colors.text,
  tabular = false,
  style,
  children,
  ...props
}) => {
  return (
    <Text
      style={[
        styles[variant],
        { color },
        tabular && { fontVariant: ['tabular-nums'] },
        style,
      ]}
      {...props}
    >
      {children}
    </Text>
  );
};

const styles = StyleSheet.create({
  hero: {
    fontSize: 40,
    fontWeight: '300', // Thin, elegant
    letterSpacing: -1,
    lineHeight: 48,
  },
  header: {
    fontSize: 24,
    fontWeight: '400',
    letterSpacing: -0.5,
    lineHeight: 32,
  },
  title: {
    fontSize: 18,
    fontWeight: '500',
    letterSpacing: 0,
    lineHeight: 24,
  },
  body: {
    fontSize: 14,
    fontWeight: '400',
    lineHeight: 20,
    opacity: 0.9, // Slightly sheer
  },
  microcopy: {
    fontSize: 11,
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: 2,
    lineHeight: 16,
    opacity: 0.8,
  },
});
