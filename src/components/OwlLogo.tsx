import { StyleSheet, View } from 'react-native';
import Svg, { Circle, Defs, LinearGradient, Path, Rect, Stop } from 'react-native-svg';
import { colors, spacing } from '@/theme';
import { Text } from './Text';

/** Marca QUHO: mosaico con degradado teal + búho blanco (igual que el ícono de la app). */
export function OwlMark({ size = 32 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 512 512">
      <Defs>
        <LinearGradient id="owlGrad" x1="0" y1="0" x2="1" y2="1">
          <Stop offset="0" stopColor={colors.teal} />
          <Stop offset="1" stopColor={colors.tealDark} />
        </LinearGradient>
      </Defs>
      <Rect width="512" height="512" rx="116" fill="url(#owlGrad)" />
      <Path d="M150 152 L122 78 L198 122 Z" fill="#FFFFFF" />
      <Path d="M362 152 L390 78 L314 122 Z" fill="#FFFFFF" />
      <Circle cx="190" cy="238" r="80" fill="#FFFFFF" />
      <Circle cx="322" cy="238" r="80" fill="#FFFFFF" />
      <Circle cx="190" cy="238" r="33" fill="#1E293B" />
      <Circle cx="322" cy="238" r="33" fill="#1E293B" />
      <Circle cx="201" cy="227" r="11" fill="#FFFFFF" />
      <Circle cx="333" cy="227" r="11" fill="#FFFFFF" />
      <Path d="M256 280 L233 310 L279 310 Z" fill="#F59E0B" />
    </Svg>
  );
}

interface OwlLogoProps {
  size?: number;
  wordmark?: boolean;
  wordmarkColor?: string;
  wordmarkSize?: number;
}

export function OwlLogo({ size = 36, wordmark = true, wordmarkColor = colors.gray900, wordmarkSize }: OwlLogoProps) {
  return (
    <View style={styles.row}>
      <OwlMark size={size} />
      {wordmark ? (
        <Text
          variant="h3"
          color={wordmarkColor}
          style={[styles.word, wordmarkSize ? { fontSize: wordmarkSize } : null]}
        >
          QUHO
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.xs },
  word: { letterSpacing: 0.5 },
});
