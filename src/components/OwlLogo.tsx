import { View } from 'react-native';
import { colors } from '@/theme';

/** Marca minimalista editorial (anillo + punto en morado). Marca única de QUHO
 *  (igual al ícono/splash nativo). Reemplaza al búho teal retirado. */
export function MarkDot({ size = 40 }: { size?: number }) {
  const dot = Math.round(size * 0.3);
  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: size / 2,
        borderWidth: 2,
        borderColor: colors.purple,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <View
        style={{ width: dot, height: dot, borderRadius: dot / 2, backgroundColor: colors.purple }}
      />
    </View>
  );
}
