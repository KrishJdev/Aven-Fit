import React from 'react';
import { Text, TextProps } from 'react-native';
import { theme } from '@/theme';

type TypographyVariant = keyof typeof theme.typography.variants;

interface TypographyProps extends TextProps {
  variant?: TypographyVariant;
  color?: string;
  align?: 'auto' | 'left' | 'right' | 'center' | 'justify';
}

export const Typography: React.FC<TypographyProps> = ({
  variant = 'body',
  color = theme.colors.text,
  align = 'left',
  style,
  children,
  ...props
}) => {
  const variantStyle = theme.typography.variants[variant];

  // We cast variantStyle as any to avoid RN FontVariant strict typing mismatches 
  // since standard string array works at runtime.
  return (
    <Text
      style={[
        variantStyle as any,
        { color, textAlign: align, fontFamily: theme.typography.primary },
        style,
      ]}
      {...props}
    >
      {children}
    </Text>
  );
};
