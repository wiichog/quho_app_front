/**
 * Constantes de la aplicación QUHO (port de app_constants.dart).
 */
export const APP = {
  name: 'QUHO',
  version: '1.0.0',
  description: 'Tu asistente financiero personal con IA',
} as const;

/** Endpoints base (las rutas completas viven en src/api/*). */
export const ENDPOINTS = {
  auth: '/auth',
  me: '/me',
  onboarding: '/onboarding',
  transactions: '/transactions',
  budget: '/budget',
  goals: '/goals',
  incomes: '/incomes',
  fixedExpenses: '/fixed-expenses',
  categories: '/categories',
  gamification: '/gamification',
  ai: '/ai',
  billing: '/billing',
} as const;

/** Llaves de almacenamiento. Tokens -> SecureStore; el resto -> AsyncStorage. */
export const STORAGE_KEYS = {
  accessToken: 'access_token',
  refreshToken: 'refresh_token',
  userId: 'user_id',
  userEmail: 'user_email',
  userName: 'user_name',
  onboardingCompleted: 'onboarding_completed',
  biometricsEnabled: 'biometrics_enabled',
  notificationsEnabled: 'notifications_enabled',
  language: 'language',
} as const;

export const PAGINATION = {
  defaultPageSize: 20,
  maxPageSize: 100,
} as const;

export const GAMIFICATION = {
  pointsPerTransaction: 10,
  pointsPerBudgetCreated: 25,
  pointsPerGoalAchieved: 100,
  pointsPerStreakDay: 5,
  pointsPerChallenge: 50,
  levelNames: ['Novato', 'Aprendiz', 'Intermedio', 'Avanzado', 'Experto', 'Maestro', 'Leyenda'],
} as const;

export const LIMITS = {
  minTransactionAmount: 0.01,
  maxTransactionAmount: 999999.99,
} as const;

export const EXPENSE_CATEGORIES = [
  'Alimentos', 'Transporte', 'Vivienda', 'Salud', 'Entretenimiento',
  'Educación', 'Deuda', 'Ropa', 'Tecnología', 'Servicios', 'Otros',
] as const;

export const INCOME_CATEGORIES = [
  'Salario', 'Freelance', 'Negocios', 'Inversiones', 'Bonos', 'Regalo', 'Reembolso', 'Otros',
] as const;

export const CURRENCY = {
  default: 'MXN',
  locale: 'es-MX',
  supported: ['MXN', 'USD', 'EUR'],
} as const;

export const PLAN = {
  free: 'free',
  premium: 'premium',
  freeAIQueriesPerMonth: 10,
  freeBudgetsLimit: 3,
  freeGoalsLimit: 2,
} as const;

export const ERROR_MESSAGES = {
  generic: 'Algo salió mal. Por favor intenta de nuevo.',
  network: 'Error de conexión. Verifica tu internet.',
  timeout: 'La solicitud tardó demasiado. Intenta de nuevo.',
  unauthorized: 'Sesión expirada. Por favor inicia sesión de nuevo.',
} as const;

export const LINKS = {
  privacy: 'https://quho.app/privacy',
  terms: 'https://quho.app/terms',
  help: 'https://quho.app/help',
  contactEmail: 'soporte@quho.app',
} as const;
