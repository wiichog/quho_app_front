/**
 * Helpers para los montos del backend, que llegan en dos formas:
 *  - Money "display": { amount: "1234.56", currency: "MXN", formatted: "..." }
 *  - Valor crudo: string | number (MoneyField serializado como decimal)
 */
import { currency as fmtCurrency } from './formatters';

export interface MoneyDict {
  amount: string | number;
  currency: string;
  formatted?: string;
}

export type MoneyValue = MoneyDict | string | number | null | undefined;

function isMoneyDict(v: unknown): v is MoneyDict {
  return typeof v === 'object' && v !== null && 'amount' in v;
}

/** Devuelve el monto numérico de cualquier representación. */
export function amountOf(v: MoneyValue): number {
  if (v == null) return 0;
  if (isMoneyDict(v)) return Number(v.amount) || 0;
  if (typeof v === 'number') return v;
  return Number(v) || 0;
}

/** Devuelve el código de moneda si está disponible. */
export function currencyOf(v: MoneyValue, fallback = 'MXN'): string {
  if (isMoneyDict(v) && v.currency) return v.currency;
  return fallback;
}

/** Devuelve el texto formateado (usa `formatted` del backend si existe). */
export function moneyText(v: MoneyValue, fallbackCode = 'MXN'): string {
  if (isMoneyDict(v) && v.formatted) return v.formatted;
  return fmtCurrency(amountOf(v), currencyOf(v, fallbackCode));
}
