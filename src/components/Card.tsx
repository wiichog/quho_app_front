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
        elevated ? shadow.elevated : null,
        style,
      ]}
      {...rest}
    />
  );
}

// Look editorial: tarjeta plana, esquina sutil y borde nítido (sin sombra por defecto).
const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.white,
    borderRadius: radius.sm,
    borderWidth: 1,
    borderColor: colors.gray200,
  },
});
