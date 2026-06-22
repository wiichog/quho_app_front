import { useEffect, useRef } from 'react';
import { Animated, DimensionValue, StyleSheet, View, ViewStyle } from 'react-native';
import { colors, radius as themeRadius, spacing } from '@/theme';
import { Card } from './Card';

/** Bloque animado (pulso) para estados de carga. */
export function Skeleton({
  width = '100%',
  height = 16,
  radius = 8,
  style,
}: {
  width?: DimensionValue;
  height?: number;
  radius?: number;
  style?: ViewStyle;
}) {
  const opacity = useRef(new Animated.Value(0.5)).current;

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(opacity, { toValue: 1, duration: 700, useNativeDriver: true }),
        Animated.timing(opacity, { toValue: 0.5, duration: 700, useNativeDriver: true }),
      ]),
    );
    loop.start();
    return () => loop.stop();
  }, [opacity]);

  return (
    <Animated.View
      style={[{ width, height, borderRadius: radius, backgroundColor: colors.gray200, opacity }, style]}
    />
  );
}

/** Lista de filas estilo "movimiento" para pantallas de listado. */
export function ListSkeleton({ rows = 6 }: { rows?: number }) {
  return (
    <View style={styles.list}>
      {Array.from({ length: rows }).map((_, i) => (
        <View key={i} style={styles.row}>
          <Skeleton width={42} height={42} radius={21} />
          <View style={styles.rowMid}>
            <Skeleton width="60%" height={14} />
            <Skeleton width="40%" height={11} />
          </View>
          <Skeleton width={60} height={14} />
        </View>
      ))}
    </View>
  );
}

/** Esqueleto del dashboard (hero + tarjeta). */
export function DashboardSkeleton() {
  return (
    <View style={styles.dash}>
      <Skeleton width={140} height={26} />
      <Skeleton height={150} radius={themeRadius.lg} style={{ marginTop: spacing.md }} />
      <View style={styles.actions}>
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} width={56} height={56} radius={16} />
        ))}
      </View>
      <Card>
        <ListSkeleton rows={3} />
      </Card>
    </View>
  );
}

const styles = StyleSheet.create({
  list: { gap: spacing.md },
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  rowMid: { flex: 1, gap: 6 },
  dash: { gap: spacing.xs },
  actions: { flexDirection: 'row', justifyContent: 'space-between', marginVertical: spacing.lg },
});
