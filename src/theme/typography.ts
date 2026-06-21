import { TextStyle } from 'react-native';
import { colors } from './colors';

/**
 * Tipografía de QUHO (port de Flutter app_text_styles.dart).
 * Headings: Poppins. Body: Inter. Cargadas vía @expo-google-fonts en el root layout.
 */
export const fonts = {
  poppinsRegular: 'Poppins_400Regular',
  poppinsMedium: 'Poppins_500Medium',
  poppinsSemiBold: 'Poppins_600SemiBold',
  poppinsBold: 'Poppins_700Bold',
  interRegular: 'Inter_400Regular',
  interMedium: 'Inter_500Medium',
  interSemiBold: 'Inter_600SemiBold',
} as const;

type StyleFn = (color?: string) => TextStyle;

const h = (
  fontFamily: string,
  fontSize: number,
  lineHeight: number,
  letterSpacing: number,
  defaultColor: string,
): StyleFn => (color?: string) => ({
  fontFamily,
  fontSize,
  lineHeight,
  letterSpacing,
  color: color ?? defaultColor,
});

export const text = {
  // Headings (Poppins)
  h1: h(fonts.poppinsBold, 32, 38, -0.5, colors.gray900),
  h2: h(fonts.poppinsBold, 24, 31, -0.3, colors.gray900),
  h3: h(fonts.poppinsSemiBold, 20, 28, -0.2, colors.gray800),
  h4: h(fonts.poppinsSemiBold, 18, 25, -0.1, colors.gray800),
  h5: h(fonts.poppinsSemiBold, 16, 24, 0, colors.gray700),

  // Body (Inter)
  bodyLarge: h(fonts.interRegular, 16, 24, 0, colors.gray700),
  bodyMedium: h(fonts.interRegular, 14, 21, 0, colors.gray700),
  bodySmall: h(fonts.interRegular, 12, 18, 0, colors.gray600),

  // Special
  button: h(fonts.interSemiBold, 16, 20, 0.2, colors.white),
  caption: h(fonts.interMedium, 12, 17, 0.3, colors.gray500),
  overline: h(fonts.interSemiBold, 10, 16, 1.5, colors.gray500),

  // Numbers (financial amounts, tabular)
  numberLarge: h(fonts.poppinsBold, 40, 48, -1, colors.gray900),
  numberMedium: h(fonts.poppinsSemiBold, 24, 31, -0.5, colors.gray800),
  numberSmall: h(fonts.poppinsSemiBold, 16, 22, 0, colors.gray700),
} as const;

export type TextVariant = keyof typeof text;
