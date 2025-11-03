# 🦉 Guía de Desarrollo Flutter - QUHO
## Finanzas Personales Gamificadas con IA

**Versión**: 1.0  
**Fecha**: Noviembre 2025  
**Target**: Flutter 3.16+ (Web + Mobile: iOS + Android)

---

## 📋 Tabla de Contenido

1. [Filosofía y Principios](#1-filosofía-y-principios)
2. [Estructura del Proyecto](#2-estructura-del-proyecto)
3. [Arquitectura y Patrones](#3-arquitectura-y-patrones)
4. [Sistema de Diseño](#4-sistema-de-diseño)
5. [Gestión de Estado](#5-gestión-de-estado)
6. [Networking y API](#6-networking-y-api)
7. [Autenticación y Seguridad](#7-autenticación-y-seguridad)
8. [Módulos de la Aplicación](#8-módulos-de-la-aplicación)
9. [Gamificación](#9-gamificación)
10. [Animaciones y Micro-interacciones](#10-animaciones-y-micro-interacciones)
11. [Responsive Design](#11-responsive-design)
12. [Accesibilidad](#12-accesibilidad)
13. [Testing](#13-testing)
14. [Build y Deployment](#14-build-y-deployment)
15. [Convenciones de Código](#15-convenciones-de-código)

---

## 1. Filosofía y Principios

### 1.1 Principios Core de Diseño

#### **Claridad ante todo**
```dart
// ✅ CORRECTO: Claro y directo
Text(
  'Saldo disponible',
  style: TextStyle(fontSize: 14, color: AppColors.gray600),
)

// ❌ INCORRECTO: Jerga técnica
Text(
  'Liquidez disponible neta',
  style: TextStyle(fontSize: 14, color: AppColors.gray600),
)
```

#### **Progresión visible**
- Cada acción debe tener feedback visual inmediato
- Las animaciones deben durar 200-300ms
- Mostrar progreso en tareas largas
- Celebrar cada logro del usuario

#### **Confianza y seguridad**
```dart
// Siempre mostrar indicadores de seguridad en datos sensibles
Row(
  children: [
    Icon(Icons.lock, size: 16, color: AppColors.teal),
    SizedBox(width: 4),
    Text('Encriptado', style: AppTextStyles.caption),
  ],
)
```

#### **Mobile-first, responsive always**
- Diseñar para mobile primero
- Adaptar a tablet y desktop (no convertir)
- Touch targets mínimo 44x44 dp
- Navegación accesible con el pulgar

### 1.2 Filosofía UX

**Progresión, no perfección:**
- Permitir saltar pasos en onboarding
- No bloquear por datos incompletos
- Estados: `INCOMPLETE` → `BASIC` → `FUNCTIONAL` → `COMPLETE`

**Feedback positivo:**
- Celebrar pequeños logros
- Lenguaje motivacional, nunca crítico
- Gamificación sin penalizaciones

**Transparencia en IA:**
- Mostrar por qué la IA recomienda algo
- Permitir ignorar recomendaciones
- Explicar cálculos de score

---

## 2. Estructura del Proyecto

### 2.1 Organización de Carpetas

```
quho_flutter/
├── lib/
│   ├── main.dart                      # Entry point
│   ├── app.dart                       # App widget principal
│   │
│   ├── core/                          # Núcleo de la aplicación
│   │   ├── config/                    # Configuración
│   │   │   ├── app_config.dart
│   │   │   ├── api_config.dart
│   │   │   └── theme_config.dart
│   │   ├── constants/                 # Constantes
│   │   │   ├── app_constants.dart
│   │   │   ├── api_endpoints.dart
│   │   │   └── storage_keys.dart
│   │   ├── errors/                    # Manejo de errores
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/                   # Cliente HTTP
│   │   │   ├── api_client.dart
│   │   │   ├── interceptors.dart
│   │   │   └── network_info.dart
│   │   ├── routes/                    # Navegación
│   │   │   ├── app_router.dart
│   │   │   └── route_guards.dart
│   │   └── utils/                     # Utilidades
│   │       ├── formatters.dart
│   │       ├── validators.dart
│   │       ├── currency_helper.dart
│   │       └── date_helper.dart
│   │
│   ├── features/                      # Features modulares
│   │   ├── auth/                      # Autenticación
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │
│   │   ├── onboarding/                # Onboarding conversacional
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── dashboard/                 # Dashboard principal
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── finances/                  # Gestión financiera
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── budget/
│   │   │       ├── transactions/
│   │   │       ├── categories/
│   │   │       └── goals/
│   │   │
│   │   ├── gamification/              # Sistema de gamificación
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── points/
│   │   │       ├── levels/
│   │   │       ├── challenges/
│   │   │       ├── badges/
│   │   │       └── leaderboard/
│   │   │
│   │   ├── ai/                        # Interacción con IA
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── settings/                  # Configuración y perfil
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── shared/                        # Componentes compartidos
│   │   ├── design_system/             # Design System
│   │   │   ├── colors/
│   │   │   │   └── app_colors.dart
│   │   │   ├── typography/
│   │   │   │   └── app_text_styles.dart
│   │   │   ├── spacing/
│   │   │   │   └── app_spacing.dart
│   │   │   └── theme/
│   │   │       └── app_theme.dart
│   │   │
│   │   ├── widgets/                   # Widgets reutilizables
│   │   │   ├── buttons/
│   │   │   │   ├── primary_button.dart
│   │   │   │   ├── secondary_button.dart
│   │   │   │   └── icon_button.dart
│   │   │   ├── cards/
│   │   │   │   ├── base_card.dart
│   │   │   │   ├── glassmorphic_card.dart
│   │   │   │   └── stat_card.dart
│   │   │   ├── inputs/
│   │   │   │   ├── text_input.dart
│   │   │   │   ├── currency_input.dart
│   │   │   │   └── date_picker.dart
│   │   │   ├── loaders/
│   │   │   │   ├── skeleton_loader.dart
│   │   │   │   └── spinner.dart
│   │   │   ├── modals/
│   │   │   │   ├── bottom_sheet_modal.dart
│   │   │   │   └── dialog_modal.dart
│   │   │   └── feedback/
│   │   │       ├── snackbar.dart
│   │   │       ├── toast.dart
│   │   │       └── confetti.dart
│   │   │
│   │   └── extensions/                # Extensions de Dart
│   │       ├── context_extensions.dart
│   │       ├── string_extensions.dart
│   │       └── num_extensions.dart
│   │
│   └── l10n/                          # Internacionalización
│       ├── app_en.arb
│       └── app_es.arb
│
├── assets/                            # Assets estáticos
│   ├── icons/
│   ├── images/
│   ├── lottie/
│   └── fonts/
│
├── test/                              # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml                       # Dependencias
└── README.md
```

### 2.2 Nombrado de Archivos

**Convención**: `snake_case` para todos los archivos

```
✅ CORRECTO:
- transaction_card.dart
- user_profile_page.dart
- api_client.dart

❌ INCORRECTO:
- TransactionCard.dart
- userProfilePage.dart
- ApiClient.dart
```

---

## 3. Arquitectura y Patrones

### 3.1 Clean Architecture + Feature-First

Cada feature sigue Clean Architecture con 3 capas:

```
feature/
├── data/           # Capa de datos
│   ├── datasources/    # Fuentes de datos (API, DB local)
│   ├── models/         # DTOs y serialización
│   └── repositories/   # Implementación de repositorios
├── domain/         # Capa de dominio (Business Logic)
│   ├── entities/       # Entidades de negocio
│   ├── repositories/   # Contratos de repositorios
│   └── usecases/       # Casos de uso
└── presentation/   # Capa de presentación (UI)
    ├── bloc/           # Estado (BLoC)
    ├── pages/          # Páginas/Pantallas
    └── widgets/        # Widgets específicos
```

### 3.2 Ejemplo de Feature: Transacciones

```dart
// ===== DOMAIN LAYER =====
// domain/entities/transaction.dart
class Transaction extends Equatable {
  final String id;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String description;
  final TransactionType type; // income, expense

  const Transaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [id, amount, currency, category, date, description, type];
}

// domain/repositories/transaction_repository.dart
abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions(String month);
  Future<Either<Failure, Transaction>> createTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
}

// domain/usecases/get_transactions.dart
class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, List<Transaction>>> call(String month) {
    return repository.getTransactions(month);
  }
}

// ===== DATA LAYER =====
// data/models/transaction_model.dart
class TransactionModel extends Transaction {
  const TransactionModel({
    required String id,
    required double amount,
    required String currency,
    required String category,
    required DateTime date,
    required String description,
    required TransactionType type,
  }) : super(
          id: id,
          amount: amount,
          currency: currency,
          category: category,
          date: date,
          description: description,
          type: type,
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'type': type.name,
    };
  }
}

// data/datasources/transaction_remote_datasource.dart
abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(String month);
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;

  TransactionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TransactionModel>> getTransactions(String month) async {
    final response = await apiClient.get(
      '/api/v1/transactions/',
      queryParameters: {'month': month},
    );
    
    return (response.data as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final response = await apiClient.post(
      '/api/v1/transactions/',
      data: transaction.toJson(),
    );
    
    return TransactionModel.fromJson(response.data);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await apiClient.delete('/api/v1/transactions/$id/');
  }
}

// ===== PRESENTATION LAYER =====
// presentation/bloc/transaction_event.dart
abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String month;
  LoadTransactions(this.month);
  @override
  List<Object?> get props => [month];
}

class CreateTransaction extends TransactionEvent {
  final Transaction transaction;
  CreateTransaction(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

// presentation/bloc/transaction_state.dart
abstract class TransactionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}
class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  TransactionLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];
}
class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}

// presentation/bloc/transaction_bloc.dart
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final CreateTransactionUsecase createTransaction;

  TransactionBloc({
    required this.getTransactions,
    required this.createTransaction,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<CreateTransaction>(_onCreateTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    
    final result = await getTransactions(event.month);
    
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionLoaded) return;
    
    final result = await createTransaction(event.transaction);
    
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) {
        final updatedList = [...currentState.transactions, transaction];
        emit(TransactionLoaded(updatedList));
      },
    );
  }
}
```

---

## 4. Sistema de Diseño

### 4.1 Colores

```dart
// shared/design_system/colors/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary - Navy Blue
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color navy = Color(0xFF334155);
  static const Color mediumNavy = Color(0xFF475569);

  // Accent - Teal
  static const Color tealDark = Color(0xFF0D9488);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFF5EEAD4);
  static const Color tealPale = Color(0xFFCCFBF1);

  // Functional - Success
  static const Color green = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFD1FAE5);

  // Functional - Warning
  static const Color orange = Color(0xFFF59E0B);
  static const Color orangeLight = Color(0xFFFEF3C7);

  // Functional - Error
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEE2E2);

  // Functional - Info
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFDBEAFE);

  // Gamification - Levels
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color diamond = Color(0xFFB9F2FF);

  // Category Colors
  static const Color categoryFood = Color(0xFFF59E0B);
  static const Color categoryTransport = Color(0xFF3B82F6);
  static const Color categoryHousing = Color(0xFF8B5CF6);
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryEntertainment = Color(0xFFEC4899);
  static const Color categoryEducation = Color(0xFF6366F1);
  static const Color categoryDebt = Color(0xFFEF4444);
  static const Color categoryOther = Color(0xFF64748B);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);
  static const Color black = Color(0xFF000000);

  // Gradients
  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkNavy, tealDark],
  );

  static const LinearGradient gradientPremium = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, blue],
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [green, teal],
  );
}
```

### 4.2 Tipografía

```dart
// shared/design_system/typography/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';

class AppTextStyles {
  // Headlines - Poppins
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 48,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.darkNavy,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 36,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.darkNavy,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 28,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.darkNavy,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 24,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.navy,
  );

  static TextStyle h5 = GoogleFonts.inter(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
  );

  static TextStyle h6 = GoogleFonts.inter(
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
  );

  // Body - Inter
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.gray600,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.gray500,
  );

  // Money - Poppins
  static TextStyle moneyLarge = GoogleFonts.poppins(
    fontSize: 36,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.darkNavy,
  );

  static TextStyle moneyMedium = GoogleFonts.poppins(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.navy,
  );

  static TextStyle moneySmall = GoogleFonts.inter(
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.gray700,
  );

  // Button
  static TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Responsive sizes for mobile
  static TextStyle h1Mobile = GoogleFonts.poppins(
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.darkNavy,
  );

  static TextStyle h2Mobile = GoogleFonts.poppins(
    fontSize: 28,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.darkNavy,
  );
}
```

### 4.3 Espaciado

```dart
// shared/design_system/spacing/app_spacing.dart
class AppSpacing {
  // Base: 4px
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Padding helpers
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);

  // Vertical padding
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);

  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 9999.0;

  // Border radius helpers
  static BorderRadius borderRadiusSM = BorderRadius.circular(radiusSM);
  static BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);
  static BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);
  static BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);
  static BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);
}
```

### 4.4 Theme Configuration

```dart
// shared/design_system/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../typography/app_text_styles.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.teal,
      secondary: AppColors.navy,
      surface: AppColors.white,
      background: AppColors.gray50,
      error: AppColors.red,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.gray800,
      onBackground: AppColors.gray800,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.gray50,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.gray800),
      titleTextStyle: AppTextStyles.h5,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.gray400),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.teal,
      unselectedItemColor: AppColors.gray500,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
```

---

## 5. Gestión de Estado

### 5.1 Patrón BLoC (Business Logic Component)

**Usar `flutter_bloc` para gestión de estado:**

```yaml
# pubspec.yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
```

### 5.2 Estados Globales vs Locales

**Estados Globales (BLoC):**
- Auth
- User Profile
- Gamification (puntos, nivel, streaks)
- Settings

**Estados Locales (StatefulWidget o Riverpod):**
- Estados de UI temporales
- Form validation
- Animations

### 5.3 Ejemplo: Auth BLoC

```dart
// features/auth/presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  AuthBloc({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await getCurrentUserUsecase();
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUsecase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUsecase();
    emit(AuthUnauthenticated());
  }
}
```

---

## 6. Networking y API

### 6.1 Configuración de Dio

```dart
// core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../constants/storage_keys.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token de autenticación
          final token = await _secureStorage.read(key: StorageKeys.accessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Log request (solo en debug)
          debugPrint('🚀 REQUEST: ${options.method} ${options.path}');
          debugPrint('📦 DATA: ${options.data}');
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response (solo en debug)
          debugPrint('✅ RESPONSE: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('❌ ERROR: ${error.response?.statusCode}');
          
          // Refresh token si es 401
          if (error.response?.statusCode == 401) {
            try {
              final newToken = await _refreshToken();
              if (newToken != null) {
                // Retry request con nuevo token
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (e) {
              // Redirect a login
              return handler.reject(error);
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) return null;

      final response = await _dio.post(
        '/api/v1/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'] as String;
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: newAccessToken,
      );

      return newAccessToken;
    } catch (e) {
      await _secureStorage.deleteAll();
      return null;
    }
  }

  // Métodos públicos
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
```

### 6.2 API Endpoints

```dart
// core/constants/api_endpoints.dart
class ApiEndpoints {
  // Base
  static const String baseUrl = 'https://api.quho.app';
  static const String version = '/api/v1';

  // Auth
  static const String login = '$version/auth/login/';
  static const String register = '$version/auth/register/';
  static const String logout = '$version/auth/logout/';
  static const String refresh = '$version/auth/refresh/';
  static const String me = '$version/auth/me/';

  // Finances
  static const String budgetTheoretical = '$version/finances/budget/theoretical/';
  static const String budgetExecution = '$version/finances/budget/execution/';
  static const String transactions = '$version/finances/transactions/';
  static const String incomes = '$version/finances/incomes/';
  static const String expenses = '$version/finances/expenses/';
  static const String categories = '$version/finances/categories/';
  static const String goals = '$version/finances/goals/';
  static const String savingsAccounts = '$version/finances/savings-accounts/';

  // Gamification
  static const String points = '$version/gamification/points/';
  static const String level = '$version/gamification/level/';
  static const String streaks = '$version/gamification/streaks/';
  static const String challenges = '$version/gamification/challenges/';
  static const String badges = '$version/gamification/badges/';
  static const String leaderboard = '$version/gamification/leaderboard/';

  // AI
  static const String aiChat = '$version/ai/chat/';
  static const String aiInsights = '$version/ai/insights/';
  static const String aiRecommendations = '$version/ai/recommendations/';

  // Notifications
  static const String notifications = '$version/notifications/';
  static const String pushToken = '$version/notifications/token/';

  // Billing
  static const String subscription = '$version/billing/subscription/';
  static const String plans = '$version/billing/plans/';
}
```

---

## 7. Autenticación y Seguridad

### 7.1 Secure Storage

```dart
// core/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Auth tokens
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  // User data
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: StorageKeys.userId);
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### 7.2 Biometric Authentication

```dart
// core/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    return await _auth.canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate({
    required String localizedReason,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('Error en autenticación biométrica: $e');
      return false;
    }
  }
}
```

---

## 8. Módulos de la Aplicación

### 8.1 Dashboard

```dart
// features/dashboard/presentation/pages/dashboard_page.dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<DashboardBloc>().add(RefreshDashboard());
          },
          child: CustomScrollView(
            slivers: [
              // Header con balance
              SliverToBoxAdapter(
                child: _buildBalanceHeader(context),
              ),
              
              // Quick stats
              SliverToBoxAdapter(
                child: _buildQuickStats(context),
              ),
              
              // Reto del día
              SliverToBoxAdapter(
                child: _buildDailyChallenge(context),
              ),
              
              // Últimas transacciones
              SliverToBoxAdapter(
                child: _buildRecentTransactions(context),
              ),
              
              // AI Insights
              SliverToBoxAdapter(
                child: _buildAIInsights(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: QuhoBottomNav(),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBalanceHeader(BuildContext context) {
    return BlocBuilder<FinancesBloc, FinancesState>(
      builder: (context, state) {
        if (state is FinancesLoaded) {
          return GlassmorphicCard(
            margin: AppSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance disponible',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.visibility, color: AppColors.white),
                      onPressed: () {
                        // Toggle visibility
                      },
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  CurrencyHelper.format(state.availableBalance),
                  style: AppTextStyles.moneyLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildMiniStat(
                      'Ingresos',
                      state.totalIncome,
                      AppColors.green,
                      Icons.trending_up,
                    ),
                    SizedBox(width: AppSpacing.md),
                    _buildMiniStat(
                      'Gastos',
                      state.totalExpenses,
                      AppColors.red,
                      Icons.trending_down,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return SkeletonLoader(height: 200);
      },
    );
  }
}
```

### 8.2 Transacciones

```dart
// features/finances/presentation/pages/transactions_page.dart
class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transacciones'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return SkeletonLoader(count: 10);
          }
          
          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long,
                title: 'Sin transacciones',
                subtitle: 'Agrega tu primera transacción',
                actionLabel: 'Agregar',
                onAction: () => _showAddTransaction(context),
              );
            }
            
            return ListView.builder(
              padding: AppSpacing.paddingMD,
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                return TransactionCard(
                  transaction: transaction,
                  onTap: () => _showTransactionDetail(context, transaction),
                );
              },
            );
          }
          
          if (state is TransactionError) {
            return ErrorState(
              message: state.message,
              onRetry: () {
                context.read<TransactionBloc>().add(
                  LoadTransactions(DateHelper.currentMonth()),
                );
              },
            );
          }
          
          return SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransaction(context),
        icon: Icon(Icons.add),
        label: Text('Nueva'),
      ),
    );
  }
}
```

### 8.3 Onboarding Conversacional

```dart
// features/onboarding/presentation/pages/onboarding_chat_page.dart
class OnboardingChatPage extends StatefulWidget {
  @override
  _OnboardingChatPageState createState() => _OnboardingChatPageState();
}

class _OnboardingChatPageState extends State<OnboardingChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      '¡Hola! 👋 Soy tu asistente financiero.\n\n'
      'Cuéntame sobre tu situación financiera:\n'
      '• ¿Cuánto ganas al mes?\n'
      '• ¿Cuáles son tus gastos principales?\n'
      '• ¿Tienes algún ahorro o meta?'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuración Inicial'),
            Text(
              'Paso 1 de 1',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: AppSpacing.paddingMD,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isUser: message.isUser,
                  timestamp: message.timestamp,
                );
              },
            ),
          ),
          
          // Input
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu respuesta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    final isLoading = state is OnboardingProcessing;
                    return IconButton(
                      onPressed: isLoading ? null : _sendMessage,
                      icon: isLoading
                          ? CircularProgressIndicator()
                          : Icon(Icons.send),
                      color: AppColors.teal,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Agregar mensaje del usuario
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _messageController.clear();

    // Scroll al final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Enviar a la IA
    context.read<OnboardingBloc>().add(
      ProcessOnboardingMessage(text),
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }
}
```

---

## 9. Gamificación

### 9.1 Sistema de Puntos

```dart
// features/gamification/presentation/widgets/points_display.dart
class PointsDisplay extends StatelessWidget {
  final int points;
  final int pointsToNextLevel;

  const PointsDisplay({
    required this.points,
    required this.pointsToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = points / (points + pointsToNextLevel);
    
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tus puntos', style: AppTextStyles.bodySmall),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    points.toString(),
                    style: AppTextStyles.moneyMedium.copyWith(
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.stars_rounded,
                size: 48,
                color: AppColors.gold,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Faltan $pointsToNextLevel pts para siguiente nivel',
            style: AppTextStyles.caption,
          ),
          SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation(AppColors.teal),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
```

### 9.2 Celebración de Logros

```dart
// shared/widgets/feedback/celebration_overlay.dart
class CelebrationOverlay {
  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int points,
    Widget? badge,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _CelebrationContent(
          title: title,
          subtitle: subtitle,
          points: points,
          badge: badge,
        ),
      ),
    );

    // Auto-dismiss después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      if (context.mounted) Navigator.of(context).pop();
    });
  }
}

class _CelebrationContent extends StatefulWidget {
  final String title;
  final String subtitle;
  final int points;
  final Widget? badge;

  const _CelebrationContent({
    required this.title,
    required this.subtitle,
    required this.points,
    this.badge,
  });

  @override
  _CelebrationContentState createState() => _CelebrationContentState();
}

class _CelebrationContentState extends State<_CelebrationContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Mostrar confetti
    _showConfetti();
  }

  void _showConfetti() {
    ConfettiWidget.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: AppSpacing.paddingXL,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge o icono
            if (widget.badge != null)
              widget.badge!
            else
              Icon(
                Icons.emoji_events,
                size: 80,
                color: AppColors.gold,
              ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Título
            Text(
              widget.title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSpacing.sm),
            
            // Subtítulo
            Text(
              widget.subtitle,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Puntos ganados
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.tealPale,
                borderRadius: AppSpacing.borderRadiusLG,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, color: AppColors.teal),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '+${widget.points} puntos',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 9.3 Streak Tracker

```dart
// features/gamification/presentation/widgets/streak_tracker.dart
class StreakTracker extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActivity;

  const StreakTracker({
    required this.currentStreak,
    required this.bestStreak,
    this.lastActivity,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = _isActiveToday();
    
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: isActive ? AppColors.orange : AppColors.gray400,
                  size: 32,
                ),
                SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Racha actual', style: AppTextStyles.bodySmall),
                    Text(
                      '$currentStreak días',
                      style: AppTextStyles.h4,
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // Calendario de últimos 7 días
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = DateTime.now().subtract(Duration(days: 6 - index));
                final isCompleted = _isDayCompleted(day);
                return _DayCircle(
                  day: DateFormat('E').format(day),
                  isCompleted: isCompleted,
                  isToday: index == 6,
                );
              }),
            ),
            
            SizedBox(height: AppSpacing.md),
            
            Text(
              'Mejor racha: $bestStreak días 🏆',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  bool _isActiveToday() {
    if (lastActivity == null) return false;
    final now = DateTime.now();
    return lastActivity!.year == now.year &&
           lastActivity!.month == now.month &&
           lastActivity!.day == now.day;
  }

  bool _isDayCompleted(DateTime day) {
    // Implementar lógica de verificación
    return false;
  }
}

class _DayCircle extends StatelessWidget {
  final String day;
  final bool isCompleted;
  final bool isToday;

  const _DayCircle({
    required this.day,
    required this.isCompleted,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: AppTextStyles.caption.copyWith(
            color: isToday ? AppColors.teal : AppColors.gray500,
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.teal : AppColors.gray200,
            border: isToday
                ? Border.all(color: AppColors.teal, width: 2)
                : null,
          ),
          child: isCompleted
              ? Icon(Icons.check, color: AppColors.white, size: 16)
              : null,
        ),
      ],
    );
  }
}
```

---

## 10. Animaciones y Micro-interacciones

### 10.1 Duración de Animaciones

```dart
// core/constants/app_constants.dart
class AppAnimations {
  // Duraciones
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}
```

### 10.2 Glassmorphic Card

```dart
// shared/widgets/cards/glassmorphic_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double opacity;
  final Gradient? gradient;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.blur = 10.0,
    this.opacity = 0.15,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? AppSpacing.paddingMD,
      child: ClipRRect(
        borderRadius: AppSpacing.borderRadiusLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? AppSpacing.paddingMD,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.white.withOpacity(opacity),
                      AppColors.white.withOpacity(opacity * 0.5),
                    ],
                  ),
              borderRadius: AppSpacing.borderRadiusLG,
              border: Border.all(
                color: AppColors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

### 10.3 Shimmer Loader

```dart
// shared/widgets/loaders/skeleton_loader.dart
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final int count;
  final EdgeInsetsGeometry margin;

  const SkeletonLoader({
    this.height = 80,
    this.width = double.infinity,
    this.count = 1,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (index) => Container(
          margin: margin,
          child: Shimmer.fromColors(
            baseColor: AppColors.gray200,
            highlightColor: AppColors.gray100,
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: AppSpacing.borderRadiusLG,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 10.4 Confetti Animation

```dart
// shared/widgets/feedback/confetti_widget.dart
import 'package:confetti/confetti.dart';

class ConfettiWidget {
  static void show(BuildContext context) {
    final controller = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.teal,
              AppColors.orange,
              AppColors.green,
              AppColors.blue,
              AppColors.gold,
            ],
          ),
        ],
      ),
    );

    controller.play();

    Future.delayed(Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
```

---

## 11. Responsive Design

### 11.1 Breakpoints y Utilities

```dart
// core/utils/responsive_helper.dart
import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) return DeviceType.mobile;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  static double getResponsivePadding(BuildContext context) {
    return responsive(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }

  static int getResponsiveGridColumns(BuildContext context) {
    return responsive(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }
}
```

### 11.2 Layout Responsivo

```dart
// shared/widgets/layout/responsive_layout.dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveHelper.tabletMaxWidth) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveHelper.mobileMaxWidth) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### 11.3 Ejemplo de Dashboard Responsivo

```dart
// Dashboard adaptativo
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(/* ... */),
          SliverList(/* contenido en columna */),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(/* ... */),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar compacto
          NavigationRail(/* ... */),
          // Contenido principal
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar expandido
          SizedBox(
            width: 250,
            child: NavigationDrawer(/* ... */),
          ),
          // Contenido principal
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildMainContent()),
                // Panel lateral
                Expanded(flex: 1, child: _buildSidePanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 12. Accesibilidad

### 12.1 Semantic Widgets

```dart
// Siempre usar Semantics para widgets interactivos
Semantics(
  label: 'Agregar nueva transacción',
  hint: 'Doble tap para agregar',
  button: true,
  enabled: true,
  child: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

### 12.2 Contraste de Colores

```dart
// Verificar que todos los pares de colores cumplan WCAG AA
// Normal text: 4.5:1
// Large text: 3:1

// Ejemplo: función helper
class AccessibilityHelper {
  static double getContrastRatio(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    
    final lighter = max(luminance1, luminance2);
    final darker = min(luminance1, luminance2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool meetsWCAGAA(Color foreground, Color background, {bool largeText = false}) {
    final ratio = getContrastRatio(foreground, background);
    final minimumRatio = largeText ? 3.0 : 4.5;
    return ratio >= minimumRatio;
  }
}
```

### 12.3 Touch Targets

```dart
// Todos los elementos interactivos deben tener mínimo 44x44 dp
class TappableArea extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double minSize;

  const TappableArea({
    required this.child,
    required this.onTap,
    this.minSize = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
```

---

## 13. Testing

### 13.1 Unit Tests

```dart
// test/unit/usecases/get_transactions_test.dart
void main() {
  late GetTransactions usecase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    usecase = GetTransactions(mockRepository);
  });

  group('GetTransactions', () {
    final testTransactions = [
      Transaction(
        id: '1',
        amount: 100,
        currency: 'GTQ',
        category: 'food',
        date: DateTime.now(),
        description: 'Almuerzo',
        type: TransactionType.expense,
      ),
    ];

    test('should get transactions from repository', () async {
      // arrange
      when(mockRepository.getTransactions(any))
          .thenAnswer((_) async => Right(testTransactions));

      // act
      final result = await usecase('2025-11');

      // assert
      expect(result, Right(testTransactions));
      verify(mockRepository.getTransactions('2025-11'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(mockRepository.getTransactions(any))
          .thenAnswer((_) async => Left(ServerFailure('Error')));

      // act
      final result = await usecase('2025-11');

      // assert
      expect(result, Left(ServerFailure('Error')));
    });
  });
}
```

### 13.2 Widget Tests

```dart
// test/widget/transaction_card_test.dart
void main() {
  testWidgets('TransactionCard displays transaction data', (tester) async {
    // arrange
    final transaction = Transaction(
      id: '1',
      amount: 100,
      currency: 'GTQ',
      category: 'food',
      date: DateTime.now(),
      description: 'Almuerzo',
      type: TransactionType.expense,
    );

    // act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionCard(transaction: transaction),
        ),
      ),
    );

    // assert
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.text('Q100.00'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
  });
}
```

### 13.3 Integration Tests

```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('QUHO Integration Tests', () {
    testWidgets('Complete user flow', (tester) async {
      // 1. Launch app
      await tester.pumpWidget(QuhoApp());
      await tester.pumpAndSettle();

      // 2. Login
      await tester.enterText(find.byKey(Key('email_input')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_input')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // 3. Verify dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // 4. Add transaction
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('amount_input')), '50');
      await tester.enterText(find.byKey(Key('description_input')), 'Coffee');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // 5. Verify transaction appears
      expect(find.text('Coffee'), findsOneWidget);
    });
  });
}
```

---

## 14. Build y Deployment

### 14.1 Configuración de Flavors

```dart
// lib/core/config/app_config.dart
enum Environment { dev, staging, production }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;

  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
  });

  factory AppConfig.dev() {
    return AppConfig(
      environment: Environment.dev,
      apiBaseUrl: 'https://dev.api.quho.app',
      appName: 'QUHO Dev',
    );
  }

  factory AppConfig.staging() {
    return AppConfig(
      environment: Environment.staging,
      apiBaseUrl: 'https://staging.api.quho.app',
      appName: 'QUHO Staging',
    );
  }

  factory AppConfig.production() {
    return AppConfig(
      environment: Environment.production,
      apiBaseUrl: 'https://api.quho.app',
      appName: 'QUHO',
    );
  }
}
```

### 14.2 Scripts de Build

```bash
# build_scripts/build_all.sh
#!/bin/bash

echo "🚀 Building QUHO for all platforms..."

# Android
echo "📱 Building Android APK..."
flutter build apk --release

echo "📱 Building Android App Bundle..."
flutter build appbundle --release

# iOS
echo "🍎 Building iOS..."
flutter build ios --release

# Web
echo "🌐 Building Web..."
flutter build web --release

echo "✅ Build complete!"
```

### 14.3 GitHub Actions CI/CD

```yaml
# .github/workflows/flutter_ci.yml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Build Android APK
        run: flutter build apk --release
      
      - name: Build Web
        run: flutter build web --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: release-builds
          path: |
            build/app/outputs/flutter-apk/
            build/web/
```

### 14.4 App Store / Play Store

**Android (Google Play):**
```bash
# Generar signing key
keytool -genkey -v -keystore quho-release-key.keystore \
  -alias quho -keyalg RSA -keysize 2048 -validity 10000

# Build bundle
flutter build appbundle --release

# Upload a Google Play Console
```

**iOS (App Store):**
```bash
# Asegurar que tienes certificado de desarrollo configurado

# Build para App Store
flutter build ios --release

# Abrir Xcode
open ios/Runner.xcworkspace

# Archive y distribuir desde Xcode
```

**Web:**
```bash
# Build para producción
flutter build web --release

# Deploy a Firebase Hosting
firebase deploy --only hosting
```

---

## 15. Convenciones de Código

### 15.1 Dart Style Guide

```dart
// ✅ CORRECTO: Nombres descriptivos
class UserTransactionList extends StatelessWidget {}
double calculateMonthlyBudget() {}
const String apiBaseUrl = 'https://api.quho.app';

// ❌ INCORRECTO: Nombres ambiguos
class UTL extends StatelessWidget {}
double calc() {}
const String url = 'https://api.quho.app';

// ✅ CORRECTO: Comentarios útiles
/// Calcula el presupuesto disponible restando los gastos fijos
/// del ingreso total mensual.
/// 
/// Retorna un número negativo si los gastos exceden los ingresos.
double calculateAvailableBudget({
  required double income,
  required double fixedExpenses,
}) {
  return income - fixedExpenses;
}

// ✅ CORRECTO: Imports ordenados
// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports
import '../core/utils/formatters.dart';
import '../shared/widgets/buttons/primary_button.dart';
```

### 15.2 Widget Composition

```dart
// ✅ CORRECTO: Widgets pequeños y composables
class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionItem(transaction: transactions[index]);
      },
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: TransactionIcon(category: transaction.category),
        title: Text(transaction.description),
        subtitle: Text(DateHelper.format(transaction.date)),
        trailing: MoneyText(amount: transaction.amount),
      ),
    );
  }
}

// ❌ INCORRECTO: Widget monolítico
class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(/* categoría logic */),
            ),
            title: Text(/* descripción */),
            subtitle: Text(/* fecha con lógica de formato */),
            trailing: Text(/* monto con lógica de formato */),
          ),
        );
      },
    );
  }
}
```

### 15.3 Error Handling

```dart
// ✅ CORRECTO: Manejo explícito de errores
Future<void> loadTransactions() async {
  try {
    emit(TransactionLoading());
    
    final result = await _getTransactions();
    
    result.fold(
      (failure) {
        emit(TransactionError(message: _mapFailureToMessage(failure)));
      },
      (transactions) {
        emit(TransactionLoaded(transactions: transactions));
      },
    );
  } catch (e, stackTrace) {
    debugPrint('Error loading transactions: $e');
    debugPrint(stackTrace.toString());
    emit(TransactionError(message: 'Error inesperado'));
  }
}

String _mapFailureToMessage(Failure failure) {
  if (failure is ServerFailure) {
    return 'No pudimos conectarnos. ¿Revisas tu internet?';
  } else if (failure is CacheFailure) {
    return 'Error al cargar datos guardados';
  } else {
    return 'Algo salió mal';
  }
}

// ❌ INCORRECTO: Ignorar errores
Future<void> loadTransactions() async {
  final transactions = await _getTransactions();
  emit(TransactionLoaded(transactions: transactions));
}
```

### 15.4 Constantes y Strings

```dart
// ✅ CORRECTO: Strings localizados y constantes
// l10n/app_es.arb
{
  "welcome_message": "¡Hola! 👋 Soy tu asistente financiero",
  "add_transaction": "Agregar transacción",
  "balance_available": "Saldo disponible"
}

// En código
Text(AppLocalizations.of(context)!.welcome_message)

// Constantes
class AppConstants {
  static const int maxTransactionsPerPage = 20;
  static const Duration cacheTimeout = Duration(minutes: 5);
}

// ❌ INCORRECTO: Strings hardcoded
Text('¡Hola! Soy tu asistente financiero')
const maxItems = 20; // Sin contexto
```

---

## 📦 Dependencias Recomendadas

```yaml
# pubspec.yaml
name: quho
description: Finanzas personales gamificadas con IA
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Networking
  dio: ^5.3.3
  retrofit: ^4.0.3
  json_annotation: ^4.8.1

  # Local Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Navigation
  go_router: ^12.1.1

  # UI
  google_fonts: ^6.1.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  confetti: ^0.7.0
  flutter_svg: ^2.0.9

  # Utils
  intl: ^0.18.1
  dartz: ^0.10.1
  get_it: ^7.6.4
  injectable: ^2.3.2

  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  firebase_analytics: ^10.8.0

  # Biometrics
  local_auth: ^2.1.8

  # Accessibility
  flutter_accessibility_service: ^0.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^3.0.1
  
  # Testing
  mockito: ^5.4.4
  bloc_test: ^9.1.5
  
  # Code Generation
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.4
  injectable_generator: ^2.4.1
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/lottie/
  
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter-Regular.ttf
        - asset: fonts/Inter-Medium.ttf
          weight: 500
        - asset: fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: fonts/Inter-Bold.ttf
          weight: 700
    
    - family: Poppins
      fonts:
        - asset: fonts/Poppins-Medium.ttf
          weight: 500
        - asset: fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: fonts/Poppins-Bold.ttf
          weight: 700
```

---

## 🎯 Checklist de Implementación

### Para cada pantalla:

```
□ Responsive (mobile, tablet, desktop)
□ Estados: normal, loading, error, empty
□ Accesibilidad (Semantics, contrast, touch targets)
□ Animaciones y transiciones
□ Textos siguiendo tono y voz de QUHO
□ Colores de la paleta
□ Tipografía correcta (Inter/Poppins)
□ Espaciado según AppSpacing
□ Manejo de errores
□ Tests unitarios
□ Tests de widget
```

### Para cada feature:

```
□ Clean Architecture (data, domain, presentation)
□ BLoC para estado
□ Repositorio con Either<Failure, Success>
□ Casos de uso específicos
□ Modelos con fromJson/toJson
□ Manejo de cache cuando aplique
□ Tests de integración
□ Documentación de API
```

---

## 🚨 Reglas Críticas

1. **NUNCA** hacer llamadas de API directamente desde widgets
2. **SIEMPRE** usar BLoC para lógica de negocio
3. **SIEMPRE** manejar estados de loading, error y vacío
4. **NUNCA** hardcodear strings (usar l10n)
5. **SIEMPRE** validar inputs del usuario
6. **NUNCA** almacenar tokens en SharedPreferences (usar SecureStorage)
7. **SIEMPRE** usar const constructors cuando sea posible
8. **NUNCA** hacer setState en initState sin addPostFrameCallback
9. **SIEMPRE** dispose controllers y streams
10. **NUNCA** ignorar errores silenciosamente

---

## 📚 Recursos Adicionales

**Documentación oficial:**
- Flutter: https://docs.flutter.dev
- Dart: https://dart.dev/guides
- Material Design 3: https://m3.material.io

**Paquetes clave:**
- flutter_bloc: https://bloclibrary.dev
- dio: https://pub.dev/packages/dio
- go_router: https://pub.dev/packages/go_router

**Inspiración de diseño:**
- QUHO Design Guide (referencia principal)
- iOS Design Guidelines
- Material Design 3

---

## 🦉 Notas Finales

Esta guía es un documento vivo que debe evolucionar con el proyecto. Prioriza siempre:

1. **Simplicidad sobre complejidad**
2. **Experiencia de usuario sobre features**
3. **Performance sobre belleza**
4. **Código mantenible sobre código clever**

**Contacto para dudas:**
- Tech Lead: [email]
- Product Manager: [email]

---

**Versión:** 1.0  
**Última actualización:** Noviembre 2025  
**Próxima revisión:** Al completar MVP

🦉 **QUHO - Finanzas inteligentes con IA**
