import { zodResolver } from '@hookform/resolvers/zod';
import { Link } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import {
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, OwlLogo, Text, TextField } from '@/components';
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
    <SafeAreaView style={styles.safe}>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={styles.content}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.header}>
            <OwlLogo size={52} wordmarkSize={34} />
            <Text variant="bodyLarge" color={colors.gray500} style={styles.subtitle}>
              Bienvenido de vuelta
            </Text>
          </View>

          {login.isError ? (
            <View style={styles.errorBox}>
              <Text variant="bodySmall" color={colors.red}>
                {login.error?.message}
              </Text>
            </View>
          ) : null}

          <Controller
            control={control}
            name="identifier"
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
                error={errors.identifier?.message}
              />
            )}
          />

          <Controller
            control={control}
            name="password"
            render={({ field: { onChange, onBlur, value } }) => (
              <TextField
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
            <Text variant="caption" color={colors.teal}>
              ¿Olvidaste tu contraseña?
            </Text>
          </Link>

          <Button
            title="Iniciar sesión"
            onPress={handleSubmit(onSubmit)}
            loading={login.isPending}
            style={styles.submit}
          />

          <View style={styles.footer}>
            <Text variant="bodyMedium" color={colors.gray500}>
              ¿No tienes cuenta?{' '}
            </Text>
            <Link href="/(auth)/register">
              <Text variant="bodyMedium" color={colors.teal}>
                Regístrate
              </Text>
            </Link>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  flex: { flex: 1 },
  content: { flexGrow: 1, justifyContent: 'center', padding: spacing.lg },
  header: { alignItems: 'center', marginBottom: spacing.xl },
  subtitle: { marginTop: spacing.xs },
  errorBox: {
    backgroundColor: colors.redPale,
    borderRadius: 12,
    padding: spacing.sm,
    marginBottom: spacing.md,
  },
  forgot: { alignSelf: 'flex-end', marginBottom: spacing.lg },
  submit: { marginTop: spacing.xs },
  footer: { flexDirection: 'row', justifyContent: 'center', marginTop: spacing.xl },
});
