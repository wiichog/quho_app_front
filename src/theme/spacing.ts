/**
 * Sistema de espaciado de QUHO (port de Flutter app_spacing.dart). Escala base 4px.
 */
const base = 4;

export const spacing = {
  xxs: base, // 4
  xs: base * 2, // 8
  sm: base * 3, // 12
  md: base * 4, // 16
  lg: base * 6, // 24
  xl: base * 8, // 32
  xxl: base * 10, // 40
  xxxl: base * 12, // 48

  screenH: base * 4, // 16
  screenV: base * 6, // 24
} as const;

export const radius = {
  xs: 8,
  sm: 12,
  md: 16,
  lg: 20,
  xl: 24,
  full: 999,
} as const;

export const iconSize = {
  xs: 16,
  sm: 20,
  md: 24,
  lg: 32,
  xl: 40,
} as const;

/** Sombra estándar de tarjeta (cross-platform). */
export const shadow = {
  card: {
    shadowColor: '#0F172A',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 2,
  },
  elevated: {
    shadowColor: '#0F172A',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.12,
    shadowRadius: 16,
    elevation: 6,
  },
} as const;
