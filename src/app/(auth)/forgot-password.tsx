import { MaterialIcons } from '@expo/vector-icons';
import { zodResolver } from '@hookform/resolvers/zod';
import { useRouter } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { Pressable, StyleSheet, View } from 'react-native';
import { AuthScreen, Button, Text, TextField } from '@/components';
import { useRequestPasswordReset } from '@/features/auth/hooks';
import { colors, spacing } from '@/theme';
import { forgotPasswordSchema, type ForgotPasswordInput } from '@/utils/validators';

export default function ForgotPasswordScreen() {
  const router = useRouter();
  const reset = useRequestPasswordReset();
  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<ForgotPasswordInput>({
    resolver: zodResolver(forgotPasswordSchema),
    defaultValues: { email: '' },
  });

  const onSubmit = (values: ForgotPasswordInput) => reset.mutate(values.email);

  return (
    <AuthScreen>
      <Pressable onPress={() => router.back()} hitSlop={8} style={styles.back}>
        <MaterialIcons name="arrow-back" size={24} color={colors.white} />
      </Pressable>

      <Text variant="h2" color={colors.white} style={styles.title}>
        Recupera tu contraseña
      </Text>
      <Text variant="caption" color="rgba(255,255,255,0.5)" style={styles.subtitle}>
        Ingresa tu email y te enviaremos instrucciones para restablecerla.
      </Text>

      {reset.isSuccess ? (
        <View style={styles.successBox}>
          <Text variant="bodySmall" color="#86EFAC">
            Si el email existe, enviamos un enlace para restablecer tu contraseña.
          </Text>
        </View>
      ) : null}

      {reset.isError ? (
        <View style={styles.errorBox}>
          <Text variant="bodySmall" color="#FCA5A5">
            {reset.error?.message}
          </Text>
        </View>
      ) : null}

      <Controller
        control={control}
        name="email"
        render={({ field: { onChange, onBlur, value } }) => (
          <TextField
            tone="dark"
            label="Email"
            placeholder="tu@email.com"
            leftIcon="mail-outline"
            autoCapitalize="none"
            keyboardType="email-address"
            value={value}
            onChangeText={onChange}
            onBlur={onBlur}
            error={errors.email?.message}
          />
        )}
      />

      <Button
        title="Enviar instrucciones"
        variant="accent"
        onPress={handleSubmit(onSubmit)}
        loading={reset.isPending}
      />

      <Pressable onPress={() => router.push('/(auth)/reset-password')} style={styles.haveCode}>
        <Text variant="bodyMedium" color={colors.purple}>
          ¿Ya tienes un código? Restablecer
        </Text>
      </Pressable>
    </AuthScreen>
  );
}

const styles = StyleSheet.create({
  back: { marginBottom: spacing.md, alignSelf: 'flex-start' },
  title: { textTransform: 'uppercase', letterSpacing: 1 },
  subtitle: { marginTop: spacing.xs, marginBottom: spacing.lg },
  successBox: {
    backgroundColor: 'rgba(16,185,129,0.12)',
    borderColor: 'rgba(16,185,129,0.4)',
    borderWidth: 1,
    borderRadius: 8,
    padding: spacing.sm,
    marginBottom: spacing.md,
  },
  errorBox: {
    backgroundColor: 'rgba(239,68,68,0.12)',
    borderColor: 'rgba(239,68,68,0.4)',
    borderWidth: 1,
    borderRadius: 8,
    padding: spacing.sm,
    marginBottom: spacing.md,
  },
  haveCode: { alignItems: 'center', marginTop: spacing.lg },
});
