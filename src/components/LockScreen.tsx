import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useCallback, useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuthStore } from '@/store/authStore';
import { colors, gradients, spacing } from '@/theme';
import { Button } from './Button';
import { Text } from './Text';

export function LockScreen() {
  const unlock = useAuthStore((s) => s.unlock);
  const signOut = useAuthStore((s) => s.signOut);
  const [authenticating, setAuthenticating] = useState(false);

  const authenticate = useCallback(async () => {
    setAuthenticating(true);
    try {
      const LocalAuthentication = await import('expo-local-authentication');
      const result = await LocalAuthentication.authenticateAsync({
        promptMessage: 'Desbloquea QUHO',
        cancelLabel: 'Cancelar',
      });
      if (result.success) unlock();
    } catch {
      // si el módulo no está disponible, no bloquear permanentemente
      unlock();
    } finally {
      setAuthenticating(false);
    }
  }, [unlock]);

  useEffect(() => {
    authenticate();
  }, [authenticate]);

  return (
    <LinearGradient colors={gradients.hero as unknown as [string, string]} style={styles.flex}>
      <SafeAreaView style={styles.flex}>
        <View style={styles.content}>
          <View style={styles.iconCircle}>
            <MaterialIcons name="lock" size={40} color={colors.white} />
          </View>
          <Text variant="h2" color={colors.white} center>
            QUHO está bloqueado
          </Text>
          <Text variant="bodyMedium" color={colors.tealLight} center style={styles.subtitle}>
            Usa tu huella o rostro para continuar
          </Text>
        </View>
        <View style={styles.footer}>
          <Button title="Desbloquear" icon="fingerprint" onPress={authenticate} loading={authenticating} />
          <Button title="Cerrar sesión" variant="ghost" onPress={signOut} style={styles.signout} />
        </View>
      </SafeAreaView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing.xs, padding: spacing.lg },
  iconCircle: {
    width: 88,
    height: 88,
    borderRadius: 44,
    backgroundColor: '#FFFFFF22',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.md,
  },
  subtitle: { marginTop: spacing.xs },
  footer: { padding: spacing.lg, gap: spacing.xs },
  signout: { marginTop: spacing.xs },
});
