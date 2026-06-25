import { ReactNode } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { colors, spacing } from '@/theme';
import { Text } from './Text';

/** Título editorial de pantalla: MAYÚSCULAS + tracking, con subtítulo y acción opcional. */
export function ScreenHeader({
  title,
  subtitle,
  right,
}: {
  title: string;
  subtitle?: string;
  right?: ReactNode;
}) {
  return (
    <View style={styles.screen}>
      <View style={styles.flex}>
        <Text variant="h2" style={styles.title}>
          {title}
        </Text>
        {subtitle ? (
          <Text variant="caption" color={colors.gray500} style={styles.sub}>
            {subtitle}
          </Text>
        ) : null}
      </View>
      {right ?? null}
    </View>
  );
}

/** Encabezado de sección: etiqueta en MAYÚSCULAS + acción opcional (teal). */
export function SectionHeader({
  title,
  actionLabel,
  onAction,
}: {
  title: string;
  actionLabel?: string;
  onAction?: () => void;
}) {
  return (
    <View style={styles.section}>
      <Text variant="h5" style={styles.sectionLabel}>
        {title}
      </Text>
      {actionLabel && onAction ? (
        <Pressable onPress={onAction} hitSlop={8}>
          <Text variant="caption" color={colors.teal} style={styles.action}>
            {actionLabel}
          </Text>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    gap: spacing.sm,
  },
  flex: { flex: 1 },
  title: { textTransform: 'uppercase', letterSpacing: 0.5 },
  sub: { marginTop: 2, textTransform: 'uppercase', letterSpacing: 1 },
  section: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
  },
  sectionLabel: { textTransform: 'uppercase', letterSpacing: 1 },
  action: { textTransform: 'uppercase', letterSpacing: 1 },
});
