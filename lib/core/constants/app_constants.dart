/// Constantes de la aplicación QUHO
class AppConstants {
  // ========== APP INFO ==========
  static const String appName = 'QUHO';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Tu asistente financiero personal con IA';

  // ========== API CONFIGURATION ==========
  // Las URLs se configuran en EnvironmentConfig
  static const String apiVersion = 'v1';
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/me';
  static const String transactionsEndpoint = '/transactions';
  static const String budgetsEndpoint = '/budget';
  static const String goalsEndpoint = '/goals';
  static const String gamificationEndpoint = '/gamification';
  static const String aiEndpoint = '/ai';
  
  // ========== PAGINATION ==========
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // ========== LOCAL STORAGE KEYS ==========
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String biometricsEnabledKey = 'biometrics_enabled';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // ========== GAMIFICATION ==========
  static const int pointsPerTransaction = 10;
  static const int pointsPerBudgetCreated = 25;
  static const int pointsPerGoalAchieved = 100;
  static const int pointsPerStreakDay = 5;
  static const int pointsPerChallenge = 50;
  
  // Niveles
  static const List<String> levelNames = [
    'Novato',
    'Aprendiz',
    'Intermedio',
    'Avanzado',
    'Experto',
    'Maestro',
    'Leyenda',
  ];
  
  // ========== FINANCIAL LIMITS ==========
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999.99;
  static const double minBudgetAmount = 1.0;
  static const double maxBudgetAmount = 999999.99;
  static const double minGoalAmount = 1.0;
  static const double maxGoalAmount = 9999999.99;
  
  // ========== CATEGORÍAS ==========
  static const List<String> expenseCategories = [
    'Alimentos',
    'Transporte',
    'Vivienda',
    'Salud',
    'Entretenimiento',
    'Educación',
    'Deuda',
    'Ropa',
    'Tecnología',
    'Servicios',
    'Otros',
  ];
  
  static const List<String> incomeCategories = [
    'Salario',
    'Freelance',
    'Negocios',
    'Inversiones',
    'Bonos',
    'Regalo',
    'Reembolso',
    'Otros',
  ];
  
  // ========== MONEDAS ==========
  static const String defaultCurrency = 'MXN';
  static const List<String> supportedCurrencies = [
    'MXN',
    'USD',
    'EUR',
  ];
  
  // ========== FECHA Y TIEMPO ==========
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // ========== BIOMETRICS ==========
  static const String biometricsLocalizedReason = 'Autentica para continuar';
  
  // ========== NOTIFICATIONS ==========
  static const String fcmChannelId = 'quho_channel';
  static const String fcmChannelName = 'QUHO Notifications';
  static const String fcmChannelDescription = 'Notificaciones de QUHO';
  
  // ========== LINKS ==========
  static const String privacyPolicyUrl = 'https://quho.app/privacy';
  static const String termsOfServiceUrl = 'https://quho.app/terms';
  static const String helpUrl = 'https://quho.app/help';
  static const String contactEmail = 'soporte@quho.app';
  
  // ========== ANIMACIONES ==========
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // ========== DEBOUNCE ==========
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration formDebounce = Duration(milliseconds: 300);
  
  // ========== SMS PARSING ==========
  static const List<String> bankKeywords = [
    'banco',
    'santander',
    'bbva',
    'citibanamex',
    'hsbc',
    'scotiabank',
    'banorte',
    'inbursa',
    'azteca',
  ];
  
  static const List<String> transactionKeywords = [
    'compra',
    'cargo',
    'retiro',
    'transferencia',
    'pago',
    'deposito',
  ];
  
  // ========== REGEX PATTERNS ==========
  static const String emailPattern = 
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\d{10}$';
  static const String amountPattern = r'^\d+(\.\d{1,2})?$';
  
  // ========== FEATURE FLAGS ==========
  static const bool enableBiometrics = true;
  static const bool enableNotifications = true;
  static const bool enableSmsSync = true;
  static const bool enableAIChat = true;
  static const bool enableGamification = true;
  static const bool enableReferrals = true;
  
  // ========== SUBSCRIPTION ==========
  static const String freePlanId = 'free';
  static const String premiumPlanId = 'premium';
  
  // Límites Free
  static const int freeBudgetsLimit = 3;
  static const int freeGoalsLimit = 2;
  static const int freeAIQueriesPerMonth = 10;
  
  // Límites Premium
  static const int premiumBudgetsLimit = 999;
  static const int premiumGoalsLimit = 999;
  static const int premiumAIQueriesPerMonth = 999;
  
  // ========== ERROR MESSAGES ==========
  static const String genericErrorMessage = 
      'Algo salió mal. Por favor intenta de nuevo.';
  static const String networkErrorMessage = 
      'Error de conexión. Verifica tu internet.';
  static const String timeoutErrorMessage = 
      'La solicitud tardó demasiado. Intenta de nuevo.';
  static const String unauthorizedErrorMessage = 
      'Sesión expirada. Por favor inicia sesión de nuevo.';
  
  // Private constructor
  AppConstants._();
}

