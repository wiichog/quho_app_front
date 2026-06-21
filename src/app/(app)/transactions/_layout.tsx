import { Stack } from 'expo-router';
import { colors } from '@/theme';

export default function TransactionsLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: colors.gray50 },
      }}
    >
      <Stack.Screen name="index" />
      <Stack.Screen name="add" options={{ presentation: 'modal' }} />
      <Stack.Screen name="[id]" options={{ presentation: 'modal' }} />
    </Stack>
  );
}
