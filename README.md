# 📱 QUHO — App Móvil (React Native / Expo)

Asistente financiero personal con IA. Migrada de Flutter a **React Native + Expo (SDK 56) + TypeScript**.

## Stack

- **Expo** + **expo-router** (navegación por archivos)
- **@tanstack/react-query** (estado de servidor) + **zustand** (sesión)
- **axios** con refresh automático de JWT
- **expo-secure-store** (tokens) + **AsyncStorage** (preferencias)
- **react-hook-form** + **zod** (formularios/validación)
- Design system propio (Poppins/Inter, paleta QUHO)

## Cómo correr

```bash
npm install
npx expo start            # luego: a (Android), i (iOS), o Expo Go
```

El backend debe estar corriendo (`back/`, puerto 8000). Por defecto la app apunta a:
- Android emulador: `http://10.0.2.2:8000/api/v1`
- iOS/web: `http://localhost:8000/api/v1`

Para un dispositivo físico, crea un archivo `.env`:

```
EXPO_PUBLIC_API_URL=http://192.168.X.X:8000/api/v1
```

## Estructura

```
src/
├── app/                 # Rutas (expo-router)
│   ├── _layout.tsx      # Providers, fuentes, gating de sesión
│   ├── index.tsx        # Splash
│   ├── (auth)/          # login, register, verify-email, forgot-password
│   ├── onboarding.tsx   # Onboarding conversacional (Claude)
│   └── (app)/           # Área autenticada (tabs)
│       ├── dashboard.tsx
│       ├── transactions/  (index, add, [id])
│       ├── finances.tsx
│       ├── gamification.tsx   (Fase 3)
│       └── profile.tsx
├── api/                 # Cliente axios + módulos por dominio
├── features/            # Hooks react-query por feature
├── components/          # Design system (Button, Card, TextField, …)
├── store/               # zustand (authStore)
├── theme/               # colors, spacing, typography
├── utils/               # formatters, validators (zod), money
├── constants/           # constantes de app
├── config/              # environment
└── types/               # tipos de la API
```

## Estado

- ✅ **Fase 1** — Fundación (design system, API, navegación, auth completo)
- ✅ **Fase 2** — Dashboard, transacciones, finanzas, perfil, onboarding (contra el backend real)
- ✅ **Fase 3** — Gamificación, chat IA, suscripción (Stripe) y notificaciones (push + ajustes)

> Suscripción y push requieren configuración externa (claves de Stripe; build de desarrollo/EAS para push remoto). La confirmación de transacciones por SMS necesita lectura nativa de SMS (Android, no disponible en Expo Go); el endpoint de ingesta ya existe en el backend.

## Verificación

```bash
npx tsc --noEmit                          # typecheck
npx expo export --platform android        # valida el bundle/route tree
```

## Notas de integración (contratos reales del backend)

- Login: `POST /auth/login/` acepta `identifier` o `email`; responde `{ access, refresh, user }`.
- Verificación: `POST /auth/verify/` espera `{ token }` (no `code`).
- Reset: `POST /auth/password/reset/confirm/` espera `{ token, new_password }`.
- Refresh: `POST /auth/token/refresh/` con `{ refresh }`.
- Montos: el backend usa django-money; los campos `*_display` traen `{ amount, currency, formatted }`.
- Transacciones: campo `transaction_type` (`expense|income|transfer`).
