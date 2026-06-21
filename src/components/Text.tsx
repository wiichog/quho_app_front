import { Text as RNText, TextProps as RNTextProps } from 'react-native';
import { text, TextVariant } from '@/theme';

export interface TextProps extends RNTextProps {
  variant?: TextVariant;
  color?: string;
  center?: boolean;
}

/**
 * Texto tipado con las variantes del design system (h1..h5, body*, number*, etc.).
 */
export function Text({ variant = 'bodyMedium', color, center, style, ...rest }: TextProps) {
  return (
    <RNText
      style={[text[variant](color), center && { textAlign: 'center' }, style]}
      {...rest}
    />
  );
}
