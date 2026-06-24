import { Component, type ReactNode } from 'react';
import { StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { setLastError } from '@/features/report/errorCapture';
import { useReport } from '@/features/report/ReportProvider';
import { colors, spacing } from '@/theme';
import { Button } from './Button';
import { Text } from './Text';

interface State {
  hasError: boolean;
}

/**
 * Captura errores de render y los alimenta al buffer de reporte. El fallback
 * permite al usuario reportar el problema (usa el ReportProvider, que debe
 * envolver a este boundary).
 */
export class ErrorBoundary extends Component<{ children: ReactNode }, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError(): State {
    return { hasError: true };
  }

  componentDidCatch(error: Error) {
    setLastError(error);
  }

  reset = () => this.setState({ hasError: false });

  render() {
    if (this.state.hasError) {
      return <ErrorFallback onRetry={this.reset} />;
    }
    return this.props.children;
  }
}

function ErrorFallback({ onRetry }: { onRetry: () => void }) {
  const { openReport } = useReport();
  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.content}>
        <Text variant="h3" center>
          Algo salió mal
        </Text>
        <Text variant="bodyMedium" color={colors.gray500} center style={styles.msg}>
          Tuvimos un problema inesperado. Puedes reportarlo para ayudarnos a solucionarlo.
        </Text>
        <Button title="Reportar problema" icon="bug-report" onPress={openReport} />
        <Button title="Reintentar" variant="ghost" onPress={onRetry} style={styles.retry} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  content: { flex: 1, justifyContent: 'center', padding: spacing.lg, gap: spacing.sm },
  msg: { marginBottom: spacing.md },
  retry: { marginTop: spacing.xs },
});
