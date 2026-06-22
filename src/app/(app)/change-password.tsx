import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Text, TextField } from '@/components';
import { useChangePassword } from '@/features/auth/hooks';
import { colors, spacing } from '@/theme';
import { passwordSchema } from '@/utils/validators';

export default function ChangePasswordScreen() {
  const router = useRouter();
  const change = useChangePassword();
  const [current, setCurrent] = useState('');
  const [next, setNext] = useState('');
  const [confirm, setConfirm] = useState('');
  const [localError, setLocalError] = useState<string | null>(null);

  const onSubmit = () => {
    setLocalError(null);
    const pwd = passwordSchema.safeParse(next);
    if (!pwd.success) {
      setLocalError(pwd.error.issues[0].message);
      return;
    }
    if (next !== confirm) {
      setLocalError('Las contraseñas no coinciden');
      return;
    }
    change.mutate(
      { current, next },
      {
        onSuccess: () => {
          Alert.alert('Listo', 'Tu contraseña fue actualizada.');
          router.back();
        },
      },
    );
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>
        <Text variant="h4">Cambiar contraseña</Text>
        <View style={{ width: 24 }} />
      </View>

      <View style={styles.content}>
        {localError || change.isError ? (
          <View style={styles.errorBox}>
            <Text variant="bodySmall" color={colors.red}>
              {localError ?? change.error?.message}
            </Text>
          </View>
        ) : null}

        <TextField
          label="Contraseña actual"
          placeholder="••••••••"
          leftIcon="lock-outline"
          password
          value={current}
          onChangeText={setCurrent}
        />
        <TextField
          label="Nueva contraseña"
          placeholder="••••••••"
          leftIcon="lock-outline"
          password
          value={next}
          onChangeText={setNext}
        />
        <TextField
          label="Confirmar nueva contraseña"
          placeholder="••••••••"
          leftIcon="lock-outline"
          password
          value={confirm}
          onChangeText={setConfirm}
        />

        <Button
          title="Actualizar contraseña"
          onPress={onSubmit}
          loading={change.isPending}
          disabled={!current || !next || !confirm}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: spacing.md,
  },
  content: { flex: 1, padding: spacing.lg },
  errorBox: { backgroundColor: colors.redPale, borderRadius: 12, padding: spacing.sm, marginBottom: spacing.md },
});
