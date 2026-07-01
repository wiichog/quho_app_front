/**
 * Sistema de colores de QUHO (port directo de Flutter app_colors.dart).
 */
export const colors = {
  // Primary - Navy Blue
  darkNavy: '#1E293B',
  navy: '#334155',
  mediumNavy: '#475569',

  // Accent - Teal (acento del PRODUCTO)
  tealDark: '#0D9488',
  teal: '#14B8A6',
  tealLight: '#5EEAD4',
  tealPale: '#CCFBF1',

  // Editorial - Purple (marca única: login + producto, look editorial)
  purple: '#5E0ED7',
  purpleDark: '#4A0BAA',
  purpleDeep: '#2A0E5F', // fondo de heros/gradientes (alto contraste con texto blanco)
  purpleLight: '#C4B5FD', // texto/íconos sobre superficies moradas oscuras
  purplePale: '#EDE7FF', // fondos suaves (chips de ícono, estados sutiles)

  // Functional - Success
  green: '#10B981',
  greenLight: '#D1FAE5',

  // Functional - Warning
  orange: '#F59E0B',
  orangeLight: '#FEF3C7',

  // Functional - Error
  red: '#EF4444',
  redLight: '#FEE2E2',
  redPale: '#FEF2F2',

  // Functional - Info
  blue: '#3B82F6',
  blueLight: '#DBEAFE',

  // Gamification - Levels
  bronze: '#CD7F32',
  silver: '#C0C0C0',
  gold: '#FFD700',
  diamond: '#B9F2FF',

  // Category Colors
  categoryFood: '#F59E0B',
  categoryTransport: '#3B82F6',
  categoryHousing: '#8B5CF6',
  categoryHealth: '#10B981',
  categoryEntertainment: '#EC4899',
  categoryEducation: '#6366F1',
  categoryDebt: '#EF4444',
  categoryOther: '#64748B',

  // Neutrals
  white: '#FFFFFF',
  gray50: '#F8FAFC',
  gray100: '#F1F5F9',
  gray200: '#E2E8F0',
  gray300: '#CBD5E1',
  gray400: '#94A3B8',
  gray500: '#64748B',
  gray600: '#475569',
  gray700: '#334155',
  gray800: '#1E293B',
  gray900: '#0F172A',
  black: '#000000',

  transparent: 'transparent',
} as const;

/** Gradientes (array de colores para expo-linear-gradient). */
export const gradients = {
  hero: [colors.purpleDeep, colors.purple], // marca editorial: morado profundo → morado (tarjetas/heros)
  dark: [colors.purpleDeep, colors.gray900], // pantallas completas oscuras (login/lock): near-black con tinte morado, para que el acento morado resalte
  premium: [colors.purple, colors.blue],
  success: [colors.green, colors.teal],
} as const;

/** Mapeo de nombre de categoría -> color (para chips/iconos). */
export const categoryColor: Record<string, string> = {
  Alimentos: colors.categoryFood,
  Transporte: colors.categoryTransport,
  Vivienda: colors.categoryHousing,
  Salud: colors.categoryHealth,
  Entretenimiento: colors.categoryEntertainment,
  Educación: colors.categoryEducation,
  Deuda: colors.categoryDebt,
};

export function colorForCategory(name?: string | null): string {
  if (!name) return colors.categoryOther;
  return categoryColor[name] ?? colors.categoryOther;
}

export type ColorName = keyof typeof colors;
