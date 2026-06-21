/**
 * Utilidades de formateo para QUHO (port de formatters.dart).
 * Moneda por código ISO (default MXN); fechas en español.
 */
import { format, formatDistanceToNowStrict } from 'date-fns';
import { es } from 'date-fns/locale';
import { CURRENCY } from '@/constants/app';

function toDate(value: Date | string | number): Date {
  return value instanceof Date ? value : new Date(value);
}

/** $1,234.56 — usa el código de moneda del usuario (default MXN). */
export function currency(amount: number, code: string = CURRENCY.default): string {
  return new Intl.NumberFormat(CURRENCY.locale, {
    style: 'currency',
    currency: code,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount ?? 0);
}

/** $1.2K — moneda compacta. */
export function currencyCompact(amount: number, code: string = CURRENCY.default): string {
  return new Intl.NumberFormat(CURRENCY.locale, {
    style: 'currency',
    currency: code,
    notation: 'compact',
    maximumFractionDigits: 1,
  }).format(amount ?? 0);
}

/** 1,234.56 sin símbolo. */
export function decimal(amount: number): string {
  return new Intl.NumberFormat(CURRENCY.locale, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount ?? 0);
}

/** 1,234 entero. */
export function number(value: number): string {
  return new Intl.NumberFormat(CURRENCY.locale).format(value ?? 0);
}

/** 45.5% */
export function percentage(value: number): string {
  return `${(value ?? 0).toFixed(1)}%`;
}

export const dateShort = (d: Date | string | number) => format(toDate(d), 'dd/MM/yyyy');
export const dateTime = (d: Date | string | number) => format(toDate(d), 'dd/MM/yyyy HH:mm');
export const time = (d: Date | string | number) => format(toDate(d), 'HH:mm');
export const monthYear = (d: Date | string | number) =>
  format(toDate(d), 'MMMM yyyy', { locale: es });
export const dayMonth = (d: Date | string | number) =>
  format(toDate(d), 'dd MMM', { locale: es });

/** "hace 2 horas", "ayer", etc. */
export function relativeDate(d: Date | string | number): string {
  return `hace ${formatDistanceToNowStrict(toDate(d), { locale: es })}`;
}

/** Mes en formato API: YYYY-MM. */
export function apiMonth(d: Date = new Date()): string {
  return format(d, 'yyyy-MM');
}

export function capitalize(textValue: string): string {
  if (!textValue) return textValue;
  return textValue[0].toUpperCase() + textValue.slice(1).toLowerCase();
}

export function truncate(textValue: string, maxLength: number): string {
  if (textValue.length <= maxLength) return textValue;
  return `${textValue.slice(0, maxLength)}...`;
}

/** Iniciales para avatar: "Juan Pérez" -> "JP". */
export function initials(name?: string | null): string {
  if (!name) return '?';
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '?';
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}
