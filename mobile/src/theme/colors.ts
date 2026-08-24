export const colors = {
  // Core Backgrounds
  background: '#09090B', // Zinc 950 - Absolute deep background
  surface: '#18181B', // Zinc 900 - Cards/Elevated areas
  surfaceHighlight: '#27272A', // Zinc 800 - Borders/Hover states

  // Typography
  text: '#FAFAFA', // Zinc 50 - Primary text
  textMuted: '#A1A1AA', // Zinc 400 - Secondary text, labels
  textSubtle: '#52525B', // Zinc 600 - Disabled/very low emphasis

  // Brand Signature
  // Aven Fit identity: premium athletic Burnt Orange/Rust
  primary: '#E85D04', 
  primaryMuted: '#9D3D00',

  // Semantics
  success: '#10B981', // Emerald 500 - Completed sets, goals reached
  successMuted: '#064E3B', // Emerald 900
  
  error: '#EF4444', // Red 500 - Errors, destructive actions
  errorMuted: '#7F1D1D', // Red 900
  
  warning: '#F59E0B', // Amber 500 - Rest timers, warnings
  warningMuted: '#78350F', // Amber 900

  // Specifically for PRs / Highlights
  highlight: '#E2F835', // Volt Green - strictly for Personal Records and extreme highlights
};

export type Colors = typeof colors;
