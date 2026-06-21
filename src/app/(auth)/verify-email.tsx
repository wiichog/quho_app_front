import { MaterialIcons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Text, TextField } from '@/components';
import { useVerifyEmail } from '@/features/auth/hooks';
import { colors, spacing } from '@/theme';

export default function VerifyEmailScreen() {
  const router = useRouter();
  const { email } = useLocalSearchParams<{ email?: string }>();
  const verify = useVerifyEmail();
  const [token, setToken] = useState('');

  const onVerify = () => {
    verify.mutate(token.trim(), {
      onSuccess: () =>
        router.replace({ pathname: '/(auth)/login' }),
    });
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.content}>
        <Pressable onPress={() => router.back()} hitSlop={8} style={styles.back}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>

        <View style={styles.iconCircle}>
          <MaterialIcons name="mark-email-read" size={36} color={colors.teal} />
        </View>

        <Text variant="h2" center>
          Verifica tu email
        </Text>
        <Text variant="bodyMedium" color={colors.gray500} center style={styles.subtitle}>
          Enviamos un código de verificación a{'\n'}
          <Text variant="bodyMedium" color={colors.gray700}>
            {email ?? 'tu correo'}
          </Text>
        </Text>

        {verify.isError ? (
          <View style={styles.errorBox}>
            <Text variant="bodySmall" color={colors.red}>
              {verify.error?.message}
            </Text>
          </View>
        ) : null}

        <TextField
          label="Código de verificación"
          placeholder="Pega aquí el código del correo"
          autoCapitalize="none"
          value={token}
          onChangeText={setToken}
        />

        <Button
          title="Verificar"
          onPress={onVerify}
          loading={verify.isPending}
          disabled={token.trim().length === 0}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  content: { flex: 1, padding: spacing.lg, justifyContent: 'center' },
  back: { position: 'absolute', top: spacing.lg, left: spacing.lg },
  iconCircle: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: colors.tealPale,
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'center',
    marginBottom: spacing.lg,
  },
  subtitle: { marginTop: spacing.xs, marginBottom: spacing.xl },
  errorBox: { backgroundColor: colors.redPale, borderRadius: 12, padding: spacing.sm, marginBottom: spacing.md },
});
