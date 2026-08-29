import { Platform } from 'react-native';

export const typography = {
  // Using system fonts optimized for readability and data density.
  // SF Pro on iOS, Roboto on Android, but configured strictly.
  primary: Platform.select({ ios: 'System', android: 'sans-serif' }),
  mono: Platform.select({ ios: 'Menlo', android: 'monospace' }),

  weights: {
    regular: '400' as const,
    medium: '500' as const,
    semibold: '600' as const,
    bold: '700' as const,
  },

  sizes: {
    xs: 12,
    sm: 14,
    md: 16, // Body default
    lg: 18,
    xl: 20,
    xxl: 24,
    display: 32,
    displayLg: 48,
  },

  // Specific text styles combining size, weight, and layout features
  // Tabular numbers are critical for workout tables so digits don't jump
  variants: {
    display: {
      fontSize: 32,
      fontWeight: '700' as const,
      letterSpacing: -1,
    },
    h1: {
      fontSize: 24,
      fontWeight: '700' as const,
      letterSpacing: -0.5,
    },
    h2: {
      fontSize: 20,
      fontWeight: '600' as const,
      letterSpacing: -0.5,
    },
    body: {
      fontSize: 16,
      fontWeight: '400' as const,
      letterSpacing: 0,
    },
    label: {
      fontSize: 14,
      fontWeight: '500' as const,
      letterSpacing: 0.5,
      textTransform: 'uppercase' as const,
    },
    tabular: {
      fontSize: 18,
      fontWeight: '600' as const,
      fontVariant: ['tabular-nums'],
    },
  },
};
