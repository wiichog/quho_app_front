import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Card, Text, TextField } from '@/components';
import { useDeleteAccount } from '@/features/me/hooks';
import { colors, radius, spacing } from '@/theme';

const CONFIRM_WORD = 'ELIMINAR';

export default function DeleteAccountScreen() {
  const router = useRouter();
  const remove = useDeleteAccount();
  const [password, setPassword] = useState('');
  const [confirmText, setConfirmText] = useState('');

  const canSubmit =
    password.length > 0 && confirmText.trim().toUpperCase() === CONFIRM_WORD;

  const onSubmit = () => {
    Alert.alert(
      'Eliminar cuenta',
      'Esta acción es permanente. Se borrarán tu cuenta y todos tus datos financieros. No se puede deshacer.',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Eliminar',
          style: 'destructive',
          onPress: () => remove.mutate(password),
        },
      ],
    );
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>
        <Text variant="h4" style={{ textTransform: 'uppercase', letterSpacing: 1 }}>
          Eliminar cuenta
        </Text>
        <View style={{ width: 24 }} />
      </View>

      <View style={styles.content}>
        <Card style={styles.warning}>
          <MaterialIcons name="warning-amber" size={22} color={colors.red} />
          <Text variant="bodySmall" color={colors.gray700} style={styles.flex}>
            Al eliminar tu cuenta se borran de forma permanente tu perfil,
            transacciones, presupuestos y metas. Esta acción no se puede deshacer.
          </Text>
        </Card>

        {remove.isError ? (
          <View style={styles.errorBox}>
            <Text variant="bodySmall" color={colors.red}>
              {remove.error?.message}
            </Text>
          </View>
        ) : null}

        <TextField
          label="Confirma tu contraseña"
          placeholder="••••••••"
          leftIcon="lock-outline"
          password
          value={password}
          onChangeText={setPassword}
        />

        <TextField
          label={`Escribe "${CONFIRM_WORD}" para confirmar`}
          placeholder={CONFIRM_WORD}
          leftIcon="delete-outline"
          autoCapitalize="characters"
          value={confirmText}
          onChangeText={setConfirmText}
        />

        <Button
          title="Eliminar mi cuenta"
          variant="danger"
          icon="delete-forever"
          onPress={onSubmit}
          loading={remove.isPending}
          disabled={!canSubmit}
          style={{ marginTop: spacing.md }}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  flex: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: spacing.md,
  },
  content: { flex: 1, padding: spacing.lg },
  warning: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: spacing.sm,
    backgroundColor: colors.redPale,
    borderRadius: radius.md,
    marginBottom: spacing.lg,
  },
  errorBox: {
    backgroundColor: colors.redPale,
    borderRadius: 12,
    padding: spacing.sm,
    marginBottom: spacing.md,
  },
});
