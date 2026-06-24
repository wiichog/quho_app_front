/**
 * Endpoint de reportes de bug/soporte (apps.tickets, POST /tickets/report/).
 * Las superficies de cliente SOLO reportan; el triage vive en la consola interna.
 */
import { api } from './client';

export interface ReportAttachment {
  uri: string;
  name: string;
  type: string; // mime, p. ej. image/jpeg
}

export interface ReportPayload {
  description: string;
  type?: 'bug' | 'feature' | 'support';
  surface: 'mobile_ios' | 'mobile_android';
  app_version?: string;
  build_number?: string;
  os_version?: string;
  device_model?: string;
  screen?: string;
  stack_trace?: string;
  context?: Record<string, unknown>;
  attachment?: ReportAttachment | null;
}

export interface ReportResult {
  id: number;
  message: string;
}

export async function reportTicket(payload: ReportPayload): Promise<ReportResult> {
  const { attachment, context, ...fields } = payload;

  if (attachment) {
    const form = new FormData();
    Object.entries(fields).forEach(([k, v]) => {
      if (v != null && v !== '') form.append(k, String(v));
    });
    if (context) form.append('context', JSON.stringify(context));
    // RN FormData file part
    form.append('attachment', {
      uri: attachment.uri,
      name: attachment.name,
      type: attachment.type,
    } as unknown as Blob);

    const { data } = await api.post<ReportResult>('/tickets/report/', form, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return data;
  }

  const { data } = await api.post<ReportResult>('/tickets/report/', {
    ...fields,
    context: context ?? undefined,
  });
  return data;
}
