import { zodResolver } from '@hookform/resolvers/zod';
import { Link, useRouter } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import {
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  View,
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Text, TextField } from '@/components';
import { useRegister } from '@/features/auth/hooks';
import { colors, spacing } from '@/theme';
import { registerSchema, type RegisterInput } from '@/utils/validators';

export default function RegisterScreen() {
  const router = useRouter();
  const register = useRegister();
  const {
    control,
    handleSubmit,
    getValues,
    formState: { errors },
  } = useForm<RegisterInput>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      password: '',
      passwordConfirm: '',
    },
  });

  const onSubmit = (values: RegisterInput) => {
    register.mutate(
      {
        first_name: values.firstName,
        last_name: values.lastName,
        email: values.email,
        phone: values.phone || undefined,
        password: values.password,
      },
      {
        onSuccess: () =>
          router.replace({ pathname: '/(auth)/verify-email', params: { email: getValues('email') } }),
      },
    );
  };

  return (
    <SafeAreaView style={styles.safe}>
      <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
          <Pressable onPress={() => router.back()} hitSlop={8} style={styles.back}>
            <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
          </Pressable>

          <Text variant="h2">Crea tu cuenta</Text>
          <Text variant="bodyMedium" color={colors.gray500} style={styles.subtitle}>
            Empieza a tomar el control de tus finanzas
          </Text>

          {register.isError ? (
            <View style={styles.errorBox}>
              <Text variant="bodySmall" color={colors.red}>
                {register.error?.message}
              </Text>
            </View>
          ) : null}

          <View style={styles.row}>
            <View style={styles.half}>
              <Controller
                control={control}
                name="firstName"
                render={({ field: { onChange, onBlur, value } }) => (
                  <TextField
                    label="Nombre"
                    placeholder="Juan"
                    value={value}
                    onChangeText={onChange}
                    onBlur={onBlur}
                    error={errors.firstName?.message}
                  />
                )}
              />
            </View>
            <View style={styles.half}>
              <Controller
                control={control}
                name="lastName"
                render={({ field: { onChange, onBlur, value } }) => (
                  <TextField
                    label="Apellido"
                    placeholder="Pérez"
                    value={value}
                    onChangeText={onChange}
                    onBlur={onBlur}
                    error={errors.lastName?.message}
                  />
                )}
              />
            </View>
          </View>

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

          <Controller
            control={control}
            name="phone"
            render={({ field: { onChange, onBlur, value } }) => (
              <TextField
                label="Teléfono (opcional)"
                placeholder="55 1234 5678"
                leftIcon="phone"
                keyboardType="phone-pad"
                value={value ?? ''}
                onChangeText={onChange}
                onBlur={onBlur}
                error={errors.phone?.message}
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

          <Controller
            control={control}
            name="passwordConfirm"
            render={({ field: { onChange, onBlur, value } }) => (
              <TextField
                label="Confirmar contraseña"
                placeholder="••••••••"
                leftIcon="lock-outline"
                password
                value={value}
                onChangeText={onChange}
                onBlur={onBlur}
                error={errors.passwordConfirm?.message}
              />
            )}
          />

          <Button
            title="Crear cuenta"
            onPress={handleSubmit(onSubmit)}
            loading={register.isPending}
            style={styles.submit}
          />

          <View style={styles.footer}>
            <Text variant="bodyMedium" color={colors.gray500}>
              ¿Ya tienes cuenta?{' '}
            </Text>
            <Link href="/(auth)/login">
              <Text variant="bodyMedium" color={colors.teal}>
                Inicia sesión
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
  content: { padding: spacing.lg, paddingBottom: spacing.xxxl },
  back: { marginBottom: spacing.md },
  subtitle: { marginTop: spacing.xs, marginBottom: spacing.lg },
  errorBox: { backgroundColor: colors.redPale, borderRadius: 12, padding: spacing.sm, marginBottom: spacing.md },
  row: { flexDirection: 'row', gap: spacing.sm },
  half: { flex: 1 },
  submit: { marginTop: spacing.xs },
  footer: { flexDirection: 'row', justifyContent: 'center', marginTop: spacing.lg },
});
