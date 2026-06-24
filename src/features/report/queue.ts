/**
 * Cola offline de reportes. Si no hay red al enviar, el reporte se persiste en
 * AsyncStorage y se reintenta (al reabrir la app / volver a primer plano).
 */
import AsyncStorage from '@react-native-async-storage/async-storage';
import { reportTicket, type ReportPayload } from '@/api/tickets';

const QUEUE_KEY = 'ticket_report_queue';

async function readQueue(): Promise<ReportPayload[]> {
  try {
    const raw = await AsyncStorage.getItem(QUEUE_KEY);
    return raw ? (JSON.parse(raw) as ReportPayload[]) : [];
  } catch {
    return [];
  }
}

async function writeQueue(items: ReportPayload[]): Promise<void> {
  await AsyncStorage.setItem(QUEUE_KEY, JSON.stringify(items));
}

export async function enqueueReport(payload: ReportPayload): Promise<void> {
  const items = await readQueue();
  items.push(payload);
  await writeQueue(items);
}

/**
 * Intenta enviar todos los reportes encolados. Los que fallan por red se
 * conservan; los enviados se eliminan. Devuelve cuántos se enviaron.
 */
export async function flushQueue(): Promise<number> {
  const items = await readQueue();
  if (items.length === 0) return 0;

  const remaining: ReportPayload[] = [];
  let sent = 0;
  for (const item of items) {
    try {
      await reportTicket(item);
      sent += 1;
    } catch {
      remaining.push(item); // sigue sin red / falló: reintentar luego
    }
  }
  await writeQueue(remaining);
  return sent;
}
