import { MaterialIcons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, Pressable, StyleSheet, View } from 'react-native';
import { AuthScreen, Button, Text, TextField } from '@/components';
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
    <AuthScreen>
      <Pressable onPress={() => router.back()} hitSlop={8} style={styles.back}>
        <MaterialIcons name="arrow-back" size={24} color={colors.white} />
      </Pressable>

      <Text variant="h2" color={colors.white} style={styles.title}>
        Nueva contraseña
      </Text>
      <Text variant="caption" color="rgba(255,255,255,0.5)" style={styles.subtitle}>
        Ingresa el código que recibiste por correo y tu nueva contraseña.
      </Text>

      {localError || reset.isError ? (
        <View style={styles.errorBox}>
          <Text variant="bodySmall" color="#FCA5A5">
            {localError ?? reset.error?.message}
          </Text>
        </View>
      ) : null}

      <TextField
        tone="dark"
        label="Código de recuperación"
        placeholder="Pega aquí el código del correo"
        autoCapitalize="none"
        value={token}
        onChangeText={setToken}
      />
      <TextField
        tone="dark"
        label="Nueva contraseña"
        placeholder="••••••••"
        leftIcon="lock-outline"
        password
        value={password}
        onChangeText={setPassword}
      />
      <TextField
        tone="dark"
        label="Confirmar contraseña"
        placeholder="••••••••"
        leftIcon="lock-outline"
        password
        value={confirm}
        onChangeText={setConfirm}
      />

      <Button
        title="Actualizar contraseña"
        variant="accent"
        onPress={onSubmit}
        loading={reset.isPending}
        disabled={!token.trim() || !password || !confirm}
      />
    </AuthScreen>
  );
}

const styles = StyleSheet.create({
  back: { marginBottom: spacing.md, alignSelf: 'flex-start' },
  title: { textTransform: 'uppercase', letterSpacing: 1 },
  subtitle: { marginTop: spacing.xs, marginBottom: spacing.lg },
  errorBox: {
    backgroundColor: 'rgba(239,68,68,0.12)',
    borderColor: 'rgba(239,68,68,0.4)',
    borderWidth: 1,
    borderRadius: 8,
    padding: spacing.sm,
    marginBottom: spacing.md,
  },
});
