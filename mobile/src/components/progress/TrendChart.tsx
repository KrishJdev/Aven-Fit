import React from 'react';
import { View, StyleSheet } from 'react-native';
import Svg, { Path, Circle, Defs, LinearGradient, Stop } from 'react-native-svg';
import { theme } from '@/theme';
import { Typography } from '../common/Typography';

export interface DataPoint {
  label: string;
  value: number;
}

interface TrendChartProps {
  title: string;
  data: DataPoint[];
  height?: number;
}

export const TrendChart: React.FC<TrendChartProps> = ({ title, data, height = 180 }) => {
  if (!data || data.length === 0) return null;

  const PADDING = 20;
  const graphWidth = 300; // Will be responsive in a real layout, hardcoded for SVGs viewBox usually
  const graphHeight = height - PADDING * 2;
  
  const maxValue = Math.max(...data.map(d => d.value));
  const minValue = Math.min(...data.map(d => d.value));
  const range = maxValue - minValue || 1;

  // Generate Path
  const pointCoordinates = data.map((d, index) => {
    const x = (index / (data.length - 1)) * graphWidth;
    const y = graphHeight - ((d.value - minValue) / range) * graphHeight;
    return { x, y, value: d.value };
  });

  const pathData = pointCoordinates.reduce((acc, point, index) => {
    return `${acc} ${index === 0 ? 'M' : 'L'} ${point.x},${point.y}`;
  }, '');

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Typography variant="label" color={theme.colors.textMuted}>{title}</Typography>
        <Typography variant="h2">{data[data.length - 1].value}</Typography>
      </View>

      <View style={[styles.chartContainer, { height }]}>
        <Svg width="100%" height="100%" viewBox={`0 -10 ${graphWidth} ${height + 20}`}>
          <Defs>
            <LinearGradient id="grad" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0" stopColor={theme.colors.primary} stopOpacity="0.3" />
              <Stop offset="1" stopColor={theme.colors.primary} stopOpacity="0" />
            </LinearGradient>
          </Defs>
          
          {/* Subtle Grid Lines */}
          <Path d={`M 0,0 L ${graphWidth},0`} stroke={theme.colors.glassBorder} strokeWidth="1" strokeDasharray="4,4" />
          <Path d={`M 0,${graphHeight/2} L ${graphWidth},${graphHeight/2}`} stroke={theme.colors.glassBorder} strokeWidth="1" strokeDasharray="4,4" />
          <Path d={`M 0,${graphHeight} L ${graphWidth},${graphHeight}`} stroke={theme.colors.glassBorder} strokeWidth="1" strokeDasharray="4,4" />

          {/* Area Fill */}
          <Path 
            d={`${pathData} L ${graphWidth},${graphHeight} L 0,${graphHeight} Z`} 
            fill="url(#grad)" 
          />

          {/* Line */}
          <Path 
            d={pathData} 
            fill="none" 
            stroke={theme.colors.primary} 
            strokeWidth="3" 
            strokeLinecap="round"
            strokeLinejoin="round"
          />

          {/* Data Points */}
          {pointCoordinates.map((p, i) => (
            <Circle key={i} cx={p.x} cy={p.y} r="4" fill={theme.colors.background} stroke={theme.colors.primary} strokeWidth="2" />
          ))}
        </Svg>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: theme.colors.glassBase,
    borderRadius: theme.radii.md,
    padding: theme.spacing.lg,
    borderWidth: 1,
    borderColor: theme.colors.glassBorder,
    marginBottom: theme.spacing.xl,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginBottom: theme.spacing.lg,
  },
  chartContainer: {
    width: '100%',
  },
});
