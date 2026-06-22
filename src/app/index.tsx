import { LinearGradient } from 'expo-linear-gradient';
import { ActivityIndicator, StyleSheet, View } from 'react-native';
import { OwlMark, Text } from '@/components';
import { colors, gradients } from '@/theme';

/**
 * Splash de arranque. El gating de navegación (en _layout.tsx) redirige a
 * login / onboarding / dashboard según el estado de sesión.
 */
export default function Index() {
  return (
    <LinearGradient colors={gradients.hero as unknown as [string, string]} style={styles.container}>
      <View style={styles.center}>
        <OwlMark size={88} />
        <Text variant="h1" color={colors.white} style={styles.brand}>
          QUHO
        </Text>
        <Text variant="bodyMedium" color={colors.tealLight} center style={styles.tag}>
          Tu asistente financiero personal
        </Text>
        <ActivityIndicator color={colors.white} style={styles.loader} />
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 8 },
  brand: { marginTop: 14, letterSpacing: 1 },
  tag: { marginTop: 4 },
  loader: { marginTop: 24 },
});
