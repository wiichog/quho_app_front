/**
 * Captura del último error JS no manejado para adjuntarlo a un reporte.
 * Se registra un handler global (sin reemplazar el comportamiento por defecto)
 * y el ErrorBoundary también alimenta este buffer.
 */
export interface CapturedError {
  message: string;
  stack: string;
  at: number;
}

let lastError: CapturedError | null = null;

export function setLastError(error: unknown): void {
  const err = error as { message?: string; stack?: string } | undefined;
  lastError = {
    message: err?.message ?? String(error),
    stack: err?.stack ?? '',
    at: Date.now(),
  };
}

/** Devuelve el último error si ocurrió en los últimos 60s (evita stacks viejos). */
export function consumeRecentError(maxAgeMs = 60_000): CapturedError | null {
  if (lastError && Date.now() - lastError.at <= maxAgeMs) {
    const e = lastError;
    return e;
  }
  return null;
}

export function clearLastError(): void {
  lastError = null;
}

let installed = false;

/** Registra el handler global de errores JS (idempotente). */
export function installGlobalErrorHandler(): void {
  if (installed) return;
  installed = true;
  const g = globalThis as unknown as {
    ErrorUtils?: {
      getGlobalHandler: () => (e: unknown, isFatal?: boolean) => void;
      setGlobalHandler: (h: (e: unknown, isFatal?: boolean) => void) => void;
    };
  };
  const eu = g.ErrorUtils;
  if (!eu) return;
  const previous = eu.getGlobalHandler();
  eu.setGlobalHandler((error, isFatal) => {
    setLastError(error);
    previous(error, isFatal);
  });
}
