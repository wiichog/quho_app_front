import { MaterialIcons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { AuthScreen, Button, Text, TextField } from '@/components';
import { useVerifyEmail } from '@/features/auth/hooks';
import { colors, spacing } from '@/theme';

export default function VerifyEmailScreen() {
  const router = useRouter();
  const { email } = useLocalSearchParams<{ email?: string }>();
  const verify = useVerifyEmail();
  const [token, setToken] = useState('');

  const onVerify = () => {
    verify.mutate(token.trim(), {
      onSuccess: () => router.replace({ pathname: '/(auth)/login' }),
    });
  };

  return (
    <AuthScreen>
      <Pressable onPress={() => router.back()} hitSlop={8} style={styles.back}>
        <MaterialIcons name="arrow-back" size={24} color={colors.white} />
      </Pressable>

      <View style={styles.iconCircle}>
        <MaterialIcons name="mark-email-read" size={36} color={colors.purple} />
      </View>

      <Text variant="h2" color={colors.white} center style={styles.title}>
        Verifica tu email
      </Text>
      <Text variant="caption" color="rgba(255,255,255,0.5)" center style={styles.subtitle}>
        Enviamos un código de verificación a{'\n'}
        <Text variant="caption" color={colors.white}>
          {email ?? 'tu correo'}
        </Text>
      </Text>

      {verify.isError ? (
        <View style={styles.errorBox}>
          <Text variant="bodySmall" color="#FCA5A5">
            {verify.error?.message}
          </Text>
        </View>
      ) : null}

      <TextField
        tone="dark"
        label="Código de verificación"
        placeholder="Pega aquí el código del correo"
        autoCapitalize="none"
        value={token}
        onChangeText={setToken}
      />

      <Button
        title="Verificar"
        variant="accent"
        onPress={onVerify}
        loading={verify.isPending}
        disabled={token.trim().length === 0}
      />
    </AuthScreen>
  );
}

const styles = StyleSheet.create({
  back: { marginBottom: spacing.md, alignSelf: 'flex-start' },
  iconCircle: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(94,14,215,0.15)',
    borderWidth: 1,
    borderColor: 'rgba(94,14,215,0.5)',
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'center',
    marginBottom: spacing.lg,
  },
  title: { textTransform: 'uppercase', letterSpacing: 1 },
  subtitle: { marginTop: spacing.xs, marginBottom: spacing.xl },
  errorBox: {
    backgroundColor: 'rgba(239,68,68,0.12)',
    borderColor: 'rgba(239,68,68,0.4)',
    borderWidth: 1,
    borderRadius: 8,
    padding: spacing.sm,
    marginBottom: spacing.md,
  },
});
