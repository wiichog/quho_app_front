import { zodResolver } from '@hookform/resolvers/zod';
import { Link } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { StyleSheet, View } from 'react-native';
import { AuthScreen, Button, MarkDot, Text, TextField } from '@/components';
import { useLogin } from '@/features/auth/hooks';
import { colors, spacing } from '@/theme';
import { loginSchema, type LoginInput } from '@/utils/validators';

export default function LoginScreen() {
  const login = useLogin();
  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginInput>({
    resolver: zodResolver(loginSchema),
    defaultValues: { identifier: '', password: '' },
  });

  const onSubmit = (values: LoginInput) => login.mutate(values);

  return (
    <AuthScreen>
      <View style={styles.header}>
        <MarkDot size={44} />
        <Text variant="h3" color={colors.white} style={styles.brand}>
          QUHO
        </Text>
        <Text variant="caption" color="rgba(255,255,255,0.5)" style={styles.subtitle}>
          Bienvenido de vuelta
        </Text>
      </View>

      {login.isError ? (
        <View style={styles.errorBox}>
          <Text variant="bodySmall" color="#FCA5A5">
            {login.error?.message}
          </Text>
        </View>
      ) : null}

      <Controller
        control={control}
        name="identifier"
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
            error={errors.identifier?.message}
          />
        )}
      />

      <Controller
        control={control}
        name="password"
        render={({ field: { onChange, onBlur, value } }) => (
          <TextField
            tone="dark"
            label="Contraseña"
            placeholder="••••••••"
            leftIcon="lock-outline"
            password
            value={value}
            onChangeText={onChange}
            onBlur={onBlur}
            error={errors.password?.message}
          />
        )}
      />

      <Link href="/(auth)/forgot-password" style={styles.forgot}>
        <Text variant="caption" color={colors.purple}>
          ¿Olvidaste tu contraseña?
        </Text>
      </Link>

      <Button
        title="Iniciar sesión"
        variant="accent"
        onPress={handleSubmit(onSubmit)}
        loading={login.isPending}
        style={styles.submit}
      />

      <View style={styles.footer}>
        <Text variant="bodyMedium" color="rgba(255,255,255,0.5)">
          ¿No tienes cuenta?{' '}
        </Text>
        <Link href="/(auth)/register">
          <Text variant="bodyMedium" color={colors.purple}>
            Regístrate
          </Text>
        </Link>
      </View>
    </AuthScreen>
  );
}

const styles = StyleSheet.create({
  header: { alignItems: 'center', marginBottom: spacing.xl },
  brand: { marginTop: spacing.sm, letterSpacing: 3, textTransform: 'uppercase' },
  subtitle: { marginTop: spacing.xxs, textTransform: 'uppercase', letterSpacing: 1.5 },
  errorBox: {
    backgroundColor: 'rgba(239,68,68,0.12)',
    borderColor: 'rgba(239,68,68,0.4)',
    borderWidth: 1,
    borderRadius: 8,
    padding: spacing.sm,
    marginBottom: spacing.md,
  },
  forgot: { alignSelf: 'flex-end', marginBottom: spacing.lg },
  submit: { marginTop: spacing.xs },
  footer: { flexDirection: 'row', justifyContent: 'center', marginTop: spacing.xl },
});
