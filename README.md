# 📱 QUHO - App Móvil Flutter

> Tu asistente financiero personal con IA

## 🎉 Estado del Proyecto

**MVP COMPLETADO** ✅

- ✅ Autenticación completa (Login, Register, Verify, Password Reset)
- ✅ Dashboard funcional con datos reales del API
- ✅ Onboarding guiado de 4 pasos
- ✅ Clean Architecture implementada
- ✅ Material Design 3
- ✅ Integración con backend

---

## 🚀 Quick Start

### Requisitos
- Flutter 3.35.7 o superior
- Dart 3.9.2 o superior
- Backend corriendo (localhost:8000 o api.quhoapp.com)

### Instalación

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Generar archivos de código (opcional, ya están incluidos)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Ejecutar app
flutter run
```

### Configuración de Entornos

Editar `lib/core/config/environment.dart`:

```dart
// Para desarrollo local
Environment.development → http://localhost:8000/api/v1

// Para producción
Environment.production → https://api.quhoapp.com/api/v1
```

---

## 📁 Estructura del Proyecto

```
lib/
├── core/                     # Núcleo de la aplicación
│   ├── config/              # Configuración y DI
│   │   ├── app_config.dart      # Dependency Injection (GetIt)
│   │   └── environment.dart     # Configuración de entornos
│   ├── constants/           # Constantes globales
│   ├── errors/              # Manejo de errores
│   │   ├── exceptions.dart      # Excepciones personalizadas
│   │   └── failures.dart        # Errores del dominio
│   ├── network/             # Cliente HTTP
│   │   ├── api_client.dart      # Cliente Dio
│   │   └── interceptors/        # Auth, Error, Logging
│   ├── routes/              # Navegación
│   │   ├── app_router.dart      # GoRouter config
│   │   └── route_names.dart     # Nombres de rutas
│   └── utils/               # Utilidades
│       ├── formatters.dart      # Formateo de datos
│       ├── validators.dart      # Validaciones
│       └── helpers.dart         # Funciones helper
│
├── features/                # Features por módulo
│   ├── auth/               # Autenticación
│   │   ├── domain/         # Lógica de negocio
│   │   │   ├── entities/       # User, AuthResponse
│   │   │   ├── repositories/   # Interfaces
│   │   │   └── usecases/       # Login, Register, etc.
│   │   ├── data/           # Capa de datos
│   │   │   ├── datasources/    # Remote & Local
│   │   │   ├── models/         # DTOs
│   │   │   └── repositories/   # Implementación
│   │   └── presentation/   # UI
│   │       ├── bloc/           # State management
│   │       ├── pages/          # Pantallas
│   │       └── widgets/        # Componentes
│   ├── dashboard/          # Dashboard principal
│   └── onboarding/         # Onboarding
│
└── shared/                 # Código compartido
    ├── design_system/      # Sistema de diseño
    │   ├── colors/            # Paleta de colores
    │   ├── typography/        # Estilos de texto
    │   ├── spacing/           # Espaciado
    │   └── theme/             # Tema Material 3
    └── widgets/            # Widgets reutilizables
        ├── buttons/           # Primary, Secondary
        ├── cards/             # Info, Transaction
        ├── inputs/            # CustomTextField
        └── feedback/          # Loading, EmptyState
```

---

## 🏗️ Arquitectura

### Clean Architecture

```
Presentation Layer (UI)
    ↓ BLoC/Cubit
Domain Layer (Business Logic)
    ↓ Use Cases
Data Layer (API/Storage)
```

### Principios
- ✅ Separation of Concerns
- ✅ Dependency Inversion
- ✅ Single Responsibility
- ✅ Testable
- ✅ Scalable

---

## 🎨 Sistema de Diseño

### Colores
```dart
// Primary
AppColors.teal          // #14B8A6
AppColors.darkNavy      // #1E293B

// Functional
AppColors.green         // Success
AppColors.orange        // Warning
AppColors.red           // Error
AppColors.blue          // Info

// Categorías
AppColors.categoryFood
AppColors.categoryTransport
// ... más categorías
```

### Tipografía
```dart
AppTextStyles.h1()      // Headers (Poppins)
AppTextStyles.h2()
AppTextStyles.bodyLarge()   // Body (Inter)
AppTextStyles.bodyMedium()
AppTextStyles.numberLarge() // Montos (tabular)
```

### Espaciado
```dart
AppSpacing.xs          // 8px
AppSpacing.sm          // 12px
AppSpacing.md          // 16px
AppSpacing.lg          // 24px
AppSpacing.xl          // 32px
```

---

## 📦 Gestión de Estado

### BLoC Pattern

```dart
// 1. Definir eventos
class LoginEvent extends AuthEvent {
  final String email;
  final String password;
}

// 2. Definir estados
class Authenticated extends AuthState {
  final User user;
}

// 3. Implementar BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ... lógica
}

// 4. Usar en UI
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is Authenticated) {
      return DashboardPage();
    }
    // ...
  },
)
```

---

## 🔌 Integración con API

### Endpoints Implementados

```dart
// Auth
POST   /auth/login/
POST   /auth/register/
POST   /auth/verify/
POST   /auth/password/reset/request/
POST   /auth/refresh/
GET    /me/

// Dashboard
GET    /budget/{month}/summary/
GET    /transactions/?limit=5&ordering=-date
```

### Ejemplo de Uso

```dart
// 1. Use Case
final result = await loginUseCase(
  LoginParams(email: email, password: password),
);

// 2. Manejo de Either
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (authResponse) => print('Success: ${authResponse.user.email}'),
);
```

---

## 🧪 Testing

```bash
# Tests unitarios
flutter test

# Test específico
flutter test test/features/auth/domain/usecases/login_usecase_test.dart

# Coverage
flutter test --coverage
```

---

## 📱 Navegación

### Rutas Principales

```
/                    → Splash
/login               → Login
/register            → Registro
/verify-email        → Verificar email
/forgot-password     → Recuperar contraseña
/onboarding          → Onboarding
/home                → Dashboard
  /transactions      → Transacciones
  /budgets           → Presupuestos
  /goals             → Metas
  /gamification      → Gamificación
  /settings          → Configuración
```

### Uso

```dart
// Navegar
context.push(RouteNames.login);

// Navegar y reemplazar
context.go(RouteNames.home);

// Regresar
context.pop();
```

---

## 🔒 Seguridad

### Almacenamiento Seguro
```dart
// Tokens → Secure Storage (cifrado)
await secureStorage.write(key: 'access_token', value: token);

// Datos no sensibles → SharedPreferences
await prefs.setString('user_name', name);
```

### Refresh Token Automático
```dart
// AuthInterceptor maneja automáticamente:
1. Detecta 401 Unauthorized
2. Intenta refresh con refresh_token
3. Reintenta request original
4. Si falla → logout
```

---

## 📚 Documentación Adicional

- [API Screen Mapping](documentation/API_SCREEN_MAPPING.md) - Mapeo completo de pantallas y APIs
- [MVP Summary](documentation/MVP_SUMMARY.md) - Resumen del MVP
- [Implementation Progress](documentation/IMPLEMENTATION_PROGRESS.md) - Progreso de implementación
- [Flutter Development Guide](documentation/QUHO_FLUTTER_DEVELOPMENT_GUIDE.md) - Guía de desarrollo

---

## 🛠️ Comandos Útiles

```bash
# Limpiar build
flutter clean

# Obtener dependencias
flutter pub get

# Actualizar dependencias
flutter pub upgrade

# Analizar código
flutter analyze

# Formatear código
flutter format lib/

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Watch para auto-generar
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## 🐛 Troubleshooting

### Error: "No se encuentra el backend"
```bash
# 1. Verificar que el backend esté corriendo
curl http://localhost:8000/api/v1/health/

# 2. Verificar configuración en environment.dart
```

### Error: "Token inválido"
```bash
# Limpiar datos de la app
flutter run --clear-cache

# O en el emulador/dispositivo:
Settings → Apps → QUHO → Clear Data
```

### Error al generar código
```bash
# Limpiar y regenerar
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📞 Soporte

Para reportar bugs o solicitar features:
- Crear issue en el repositorio
- Contactar al equipo de desarrollo

---

## 📄 Licencia

Privado - QUHO © 2024

---

**Desarrollado con ❤️ usando Flutter**
