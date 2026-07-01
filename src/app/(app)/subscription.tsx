import { MaterialIcons } from '@expo/vector-icons';
import { useMutation } from '@tanstack/react-query';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import * as WebBrowser from 'expo-web-browser';
import { Alert, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { createCheckoutSession } from '@/api/billing';
import { Button, Card, Text } from '@/components';
import { usePlan } from '@/features/finances/hooks';
import { colors, gradients, radius, spacing } from '@/theme';

const BENEFITS = [
  'Presupuestos y metas ilimitados',
  'Consultas ilimitadas al asesor IA',
  'Insights y score financiero mensual',
  'Reportes avanzados',
  'Soporte prioritario',
];

export default function SubscriptionScreen() {
  const router = useRouter();
  const plan = usePlan();
  const isPremium = plan.data?.is_premium;

  const checkout = useMutation({
    mutationFn: () => createCheckoutSession('monthly'),
    onSuccess: async (res) => {
      if (res.checkout_url) await WebBrowser.openBrowserAsync(res.checkout_url);
    },
    onError: () =>
      Alert.alert(
        'Pagos no disponibles',
        'La suscripción no está configurada en el servidor todavía. Inténtalo más tarde.',
      ),
  });

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>
        <Text variant="h4" style={{ textTransform: 'uppercase', letterSpacing: 1 }}>
          Suscripción
        </Text>
        <View style={{ width: 24 }} />
      </View>

      <View style={styles.content}>
        {isPremium ? (
          <Card>
            <View style={styles.premiumRow}>
              <MaterialIcons name="workspace-premium" size={28} color={colors.gold} />
              <View>
                <Text variant="h4">Plan Premium activo</Text>
                <Text variant="bodySmall" color={colors.gray500}>
                  Disfrutas de todas las funciones
                </Text>
              </View>
            </View>
          </Card>
        ) : (
          <>
            <LinearGradient
              colors={gradients.premium as unknown as [string, string]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.hero}
            >
              <MaterialIcons name="workspace-premium" size={36} color={colors.white} />
              <Text variant="h2" color={colors.white} style={{ marginTop: spacing.xs }}>
                QUHO Premium
              </Text>
              <Text variant="bodyMedium" color={colors.white}>
                Lleva tus finanzas al siguiente nivel
              </Text>
            </LinearGradient>

            <Card style={{ marginTop: spacing.md }}>
              {BENEFITS.map((b) => (
                <View key={b} style={styles.benefitRow}>
                  <MaterialIcons name="check-circle" size={20} color={colors.purple} />
                  <Text variant="bodyMedium" style={styles.flex}>
                    {b}
                  </Text>
                </View>
              ))}
            </Card>

            <Button
              title="Mejorar a Premium"
              icon="bolt"
              onPress={() => checkout.mutate()}
              loading={checkout.isPending}
              style={{ marginTop: spacing.lg }}
            />
            <Text variant="caption" color={colors.gray400} center style={{ marginTop: spacing.sm }}>
              Pago seguro procesado por Stripe
            </Text>
          </>
        )}
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
  hero: { borderRadius: radius.lg, padding: spacing.lg, alignItems: 'center' },
  benefitRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, paddingVertical: spacing.xs },
  premiumRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
});
