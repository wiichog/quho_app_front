import { ActivityIndicator, StyleSheet, View } from 'react-native';
import { colors, spacing } from '@/theme';
import { Text } from './Text';

export function Loading({ message }: { message?: string }) {
  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" color={colors.teal} />
      {message ? (
        <Text variant="bodyMedium" color={colors.gray500} style={styles.message}>
          {message}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing.sm },
  message: { marginTop: spacing.xs },
});
