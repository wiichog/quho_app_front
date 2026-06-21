import { ReactNode } from 'react';
import {
  RefreshControl,
  ScrollView,
  StyleSheet,
  View,
  ViewStyle,
} from 'react-native';
import { Edge, SafeAreaView } from 'react-native-safe-area-context';
import { colors, spacing } from '@/theme';

interface ScreenContainerProps {
  children: ReactNode;
  scroll?: boolean;
  padded?: boolean;
  refreshing?: boolean;
  onRefresh?: () => void;
  backgroundColor?: string;
  edges?: Edge[];
  contentStyle?: ViewStyle;
}

/**
 * Contenedor base de pantalla: SafeArea + padding + scroll/pull-to-refresh opcional.
 */
export function ScreenContainer({
  children,
  scroll = false,
  padded = true,
  refreshing,
  onRefresh,
  backgroundColor = colors.gray50,
  edges = ['top'],
  contentStyle,
}: ScreenContainerProps) {
  const padStyle = padded ? { paddingHorizontal: spacing.screenH } : undefined;

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor }]} edges={edges}>
      {scroll ? (
        <ScrollView
          style={styles.flex}
          contentContainerStyle={[styles.scrollContent, padStyle, contentStyle]}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
          refreshControl={
            onRefresh ? (
              <RefreshControl
                refreshing={!!refreshing}
                onRefresh={onRefresh}
                tintColor={colors.teal}
              />
            ) : undefined
          }
        >
          {children}
        </ScrollView>
      ) : (
        <View style={[styles.flex, padStyle, contentStyle]}>{children}</View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  flex: { flex: 1 },
  scrollContent: { paddingVertical: spacing.lg, paddingBottom: spacing.xxxl },
});
