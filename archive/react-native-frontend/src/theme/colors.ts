export const colors = {
  // Midnight Glass Theme
  background: '#030305', // Deep space midnight
  
  // Translucent Surfaces (Glass)
  glassBase: 'rgba(255, 255, 255, 0.03)',
  glassHover: 'rgba(255, 255, 255, 0.08)',
  glassBorder: 'rgba(255, 255, 255, 0.12)',
  glassBorderHighlight: 'rgba(255, 255, 255, 0.25)',

  // Typography
  text: '#FFFFFF', // Pure white primary
  textMuted: 'rgba(255, 255, 255, 0.6)', // Frosted silver
  textSubtle: 'rgba(255, 255, 255, 0.35)', // Ghost text

  // Accents (Ice & Neon)
  primary: '#00F0FF', // Ice Blue / Cyan glow
  primaryMuted: 'rgba(0, 240, 255, 0.15)',
  
  // Semantics
  success: '#00FFA3', // Neon Emerald
  successMuted: 'rgba(0, 255, 163, 0.15)',
  
  error: '#FF2A55', // Neon Crimson
  errorMuted: 'rgba(255, 42, 85, 0.15)',
  
  warning: '#FFB300', // Neon Amber
  warningMuted: 'rgba(255, 179, 0, 0.15)',
  
  highlight: '#E2F835', // Keep Volt for PRs if we want, or use Cyan. Let's stick to Cyan for highlights to keep the cool theme.
};

export type Colors = typeof colors;
