import { MaterialIcons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Text, TextField } from '@/components';
import { useConfirmPasswordReset } from '@/features/auth/hooks';
import { colors, spacing } from '@/theme';
import { passwordSchema } from '@/utils/validators';

export default function ResetPasswordScreen() {
  const router = useRouter();
  const { token: tokenParam } = useLocalSearchParams<{ token?: string }>();
  const reset = useConfirmPasswordReset();

  const [token, setToken] = useState(tokenParam ?? '');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [localError, setLocalError] = useState<string | null>(null);

  const onSubmit = () => {
    setLocalError(null);
    const pwd = passwordSchema.safeParse(password);
    if (!pwd.success) {
      setLocalError(pwd.error.issues[0].message);
      return;
    }
    if (password !== confirm) {
      setLocalError('Las contraseñas no coinciden');
      return;
    }
    reset.mutate(
      { token: token.trim(), newPassword: password },
      {
        onSuccess: () => {
          Alert.alert('Listo', 'Tu contraseña fue actualizada. Inicia sesión.');
          router.replace('/(auth)/login');
        },
      },
    );
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.content}>
        <Pressable onPress={() => router.back()} hitSlop={8} style={styles.back}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>

        <Text variant="h2">Nueva contraseña</Text>
        <Text variant="bodyMedium" color={colors.gray500} style={styles.subtitle}>
          Ingresa el código que recibiste por correo y tu nueva contraseña.
        </Text>

        {localError || reset.isError ? (
          <View style={styles.errorBox}>
            <Text variant="bodySmall" color={colors.red}>
              {localError ?? reset.error?.message}
            </Text>
          </View>
        ) : null}

        <TextField
          label="Código de recuperación"
          placeholder="Pega aquí el código del correo"
          autoCapitalize="none"
          value={token}
          onChangeText={setToken}
        />
        <TextField
          label="Nueva contraseña"
          placeholder="••••••••"
          leftIcon="lock-outline"
          password
          value={password}
          onChangeText={setPassword}
        />
        <TextField
          label="Confirmar contraseña"
          placeholder="••••••••"
          leftIcon="lock-outline"
          password
          value={confirm}
          onChangeText={setConfirm}
        />

        <Button
          title="Actualizar contraseña"
          onPress={onSubmit}
          loading={reset.isPending}
          disabled={!token.trim() || !password || !confirm}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  content: { flex: 1, padding: spacing.lg, justifyContent: 'center' },
  back: { position: 'absolute', top: spacing.lg, left: spacing.lg },
  subtitle: { marginTop: spacing.xs, marginBottom: spacing.lg },
  errorBox: { backgroundColor: colors.redPale, borderRadius: 12, padding: spacing.sm, marginBottom: spacing.md },
});
