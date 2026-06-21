import { MaterialIcons } from '@expo/vector-icons';
import { zodResolver } from '@hookform/resolvers/zod';
import { useRouter } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Text, TextField } from '@/components';
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
    <SafeAreaView style={styles.safe}>
      <View style={styles.content}>
        <Pressable onPress={() => router.back()} hitSlop={8} style={styles.back}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>

        <Text variant="h2">Recupera tu contraseña</Text>
        <Text variant="bodyMedium" color={colors.gray500} style={styles.subtitle}>
          Ingresa tu email y te enviaremos instrucciones para restablecerla.
        </Text>

        {reset.isSuccess ? (
          <View style={styles.successBox}>
            <Text variant="bodySmall" color={colors.green}>
              Si el email existe, enviamos un enlace para restablecer tu contraseña.
            </Text>
          </View>
        ) : null}

        {reset.isError ? (
          <View style={styles.errorBox}>
            <Text variant="bodySmall" color={colors.red}>
              {reset.error?.message}
            </Text>
          </View>
        ) : null}

        <Controller
          control={control}
          name="email"
          render={({ field: { onChange, onBlur, value } }) => (
            <TextField
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

        <Button title="Enviar instrucciones" onPress={handleSubmit(onSubmit)} loading={reset.isPending} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  content: { flex: 1, padding: spacing.lg, justifyContent: 'center' },
  back: { position: 'absolute', top: spacing.lg, left: spacing.lg },
  subtitle: { marginTop: spacing.xs, marginBottom: spacing.lg },
  successBox: { backgroundColor: colors.greenLight, borderRadius: 12, padding: spacing.sm, marginBottom: spacing.md },
  errorBox: { backgroundColor: colors.redPale, borderRadius: 12, padding: spacing.sm, marginBottom: spacing.md },
});
