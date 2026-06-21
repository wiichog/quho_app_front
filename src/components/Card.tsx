import { View, ViewProps, StyleSheet } from 'react-native';
import { colors, radius, shadow, spacing } from '@/theme';

export interface CardProps extends ViewProps {
  padded?: boolean;
  elevated?: boolean;
}

export function Card({ padded = true, elevated = false, style, ...rest }: CardProps) {
  return (
    <View
      style={[
        styles.card,
        padded && { padding: spacing.md },
        elevated ? shadow.elevated : shadow.card,
        style,
      ]}
      {...rest}
    />
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.white,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.gray100,
  },
});
