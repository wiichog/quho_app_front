/**
 * Orquesta el reporte de errores en la app:
 * - expone useReport().openReport()
 * - registra el handler global de errores JS
 * - shake-to-report (acelerómetro)
 * - reintenta la cola offline al volver a primer plano
 * - captura la ruta actual (expo-router) y el último stack
 */
import { usePathname } from 'expo-router';
import { Accelerometer } from 'expo-sensors';
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import { AppState } from 'react-native';
import { ReportErrorSheet } from '@/components/ReportErrorSheet';
import { consumeRecentError, installGlobalErrorHandler } from './errorCapture';
import { flushQueue } from './queue';

interface ReportContextValue {
  openReport: () => void;
}

const ReportContext = createContext<ReportContextValue>({ openReport: () => {} });

export function useReport(): ReportContextValue {
  return useContext(ReportContext);
}

const SHAKE_THRESHOLD = 1.8; // g
const SHAKE_DEBOUNCE_MS = 3000;

export function ReportProvider({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const pathnameRef = useRef(pathname);
  pathnameRef.current = pathname;

  const [visible, setVisible] = useState(false);
  const [screen, setScreen] = useState('');
  const [stackTrace, setStackTrace] = useState('');
  const lastShakeRef = useRef(0);

  const openReport = useCallback(() => {
    setScreen(pathnameRef.current ?? '');
    setStackTrace(consumeRecentError()?.stack ?? '');
    setVisible(true);
  }, []);

  // Handler global + flush inicial + flush al volver a primer plano.
  useEffect(() => {
    installGlobalErrorHandler();
    flushQueue().catch(() => undefined);
    const sub = AppState.addEventListener('change', (state) => {
      if (state === 'active') flushQueue().catch(() => undefined);
    });
    return () => sub.remove();
  }, []);

  // Shake-to-report.
  useEffect(() => {
    Accelerometer.setUpdateInterval(120);
    const sub = Accelerometer.addListener(({ x, y, z }) => {
      const magnitude = Math.sqrt(x * x + y * y + z * z);
      const now = Date.now();
      if (magnitude > SHAKE_THRESHOLD && now - lastShakeRef.current > SHAKE_DEBOUNCE_MS) {
        lastShakeRef.current = now;
        setVisible((v) => {
          if (v) return v; // ya abierto
          setScreen(pathnameRef.current ?? '');
          setStackTrace(consumeRecentError()?.stack ?? '');
          return true;
        });
      }
    });
    return () => sub.remove();
  }, []);

  return (
    <ReportContext.Provider value={{ openReport }}>
      {children}
      <ReportErrorSheet
        visible={visible}
        onClose={() => setVisible(false)}
        screen={screen}
        stackTrace={stackTrace}
      />
    </ReportContext.Provider>
  );
}
