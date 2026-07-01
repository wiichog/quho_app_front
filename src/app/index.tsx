import { ActivityIndicator, StyleSheet, View } from 'react-native';
import { MarkDot, Text } from '@/components';
import { colors } from '@/theme';

/** Fondo lavanda del splash nativo (app.json → expo-splash-screen) para una
 *  transición sin salto entre el splash nativo y este splash JS. */
const SPLASH_BG = '#F4EFFF';

/**
 * Splash de arranque. Reproduce la marca editorial (anillo + punto morado) del
 * splash/ícono nativo. El gating de navegación (en _layout.tsx) redirige a
 * login / onboarding / dashboard según el estado de sesión.
 */
export default function Index() {
  return (
    <View style={styles.container}>
      <View style={styles.center}>
        <MarkDot size={88} />
        <Text variant="h1" color={colors.gray900} style={styles.brand}>
          QUHO
        </Text>
        <Text variant="bodyMedium" color={colors.gray500} center style={styles.tag}>
          Tu asistente financiero personal
        </Text>
        <ActivityIndicator color={colors.purple} style={styles.loader} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: SPLASH_BG },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 8 },
  brand: { marginTop: 14, letterSpacing: 1 },
  tag: { marginTop: 4 },
  loader: { marginTop: 24 },
});
