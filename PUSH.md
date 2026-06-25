# Push Notifications (Expo Push) — QUHO

Arquitectura **Expo Push** (NO Firebase nativo): la app obtiene un `ExponentPushToken[...]`
con `expo-notifications` y lo registra en el backend. El backend envía vía la API de
Expo Push (`https://exp.host/--/api/v2/push/send`), que rutea a **APNs (iOS)** y **FCM
(Android)**. El backend **no** habla con APNs ni FCM directo.

## App (`app-movil`)
- `src/lib/push.ts` → `registerForPush()`: pide permiso, obtiene el token con
  `getExpoPushTokenAsync({ projectId })` y hace `POST /devices { push_token, platform }`.
- Se llama tras **login** y en **arranque autenticado** (`src/store/authStore.ts`).
- Requiere `app.json → extra.eas.projectId` (lo crea `eas init`). ✅ ya presente.
- ⛔ No se usa `@react-native-firebase/*`, ni `use_frameworks`, ni `getDevicePushTokenAsync()`.

## Backend (`back/apps/notifications`)
- Modelo **`Device`** `{ user, push_token (unique), platform }` (tabla `push_devices`).
- `POST /api/v1/devices` → upsert por `push_token` (autenticado).
- `services/push.py → enviar_push(user, title, body, data)`: gateado por `PUSH_ENABLED`,
  arma los mensajes, llama a Expo, borra el `Device` si `DeviceNotRegistered`, y consulta
  los **receipts** (entrega real) a los ~4s.
- Enganchado en `apps/tickets/services/notifications.py` (avisar al reportante al resolver).
- Settings: `PUSH_ENABLED` (default True), `EXPO_ACCESS_TOKEN` (opcional, Enhanced Security).
- **Migración**: `0003_device` → corre `migrate` en el server (`bash deploy/manage-prod.sh migrate`).

## Credenciales (lo que más cuesta — háganlo bien)
Esto es config en **EAS/Apple/Expo**, no código. La key vive en el servidor de Expo;
cambiarla **NO** requiere rebuild.

**iOS** — la **APNs Auth Key (.p8)** que Expo usa debe existir en el portal de Apple
(Keys) y ser de entorno **Production** (TestFlight/App Store usan Production; Sandbox-only
NO sirve). Si Expo apunta a una key que ya no está → APNs responde `InvalidProviderToken`
(403) y no entrega.
```bash
eas credentials        # -> iOS -> production -> Push Notifications Key -> generar nueva
# Apple limita las keys por cuenta: si te topa, revocá una vieja/sandbox primero.
# Una APNs key es a nivel de cuenta: la misma Production sirve para todas tus apps
# (eas credentials -> "Use an existing push key").
```

**Android** — subí el **service account de FCM** al proyecto de Expo:
```bash
eas credentials        # -> Android -> Google Service Account -> FCM V1
# Sin esto, Android no entrega.
```

## Verificación (definitiva)
Tras instalar el build en un **dispositivo real** y loguearte (registra el token):
```bash
# Local:
python manage.py push_diag --email tu@correo.com
# En el server (prod):
bash deploy/manage-prod.sh push_diag --email tu@correo.com
```
Imprime si PUSH está habilitado, lista los devices del user, envía un push y consulta el receipt.

Interpretación:
- **`receipt: ok`** → Expo entregó a APNs/FCM. Si igual no aparece en el device → permiso/Focus del teléfono.
- **`InvalidProviderToken` / `InvalidCredentials`** → key APNs mala/ausente en EAS (ver iOS arriba).
- **`DeviceNotRegistered`** → token vencido; reabrí la app para re-registrar.

## Tests
`back/apps/notifications/tests.py` (mockean el POST a Expo):
```bash
DATABASE_URL=sqlite:///test.db python manage.py test apps.notifications
```
Cubren: (a) request armado con el token, (b) `DeviceNotRegistered` borra el device,
(c) `PUSH_ENABLED=False` no llama a Expo.
