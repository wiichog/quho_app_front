/// Nombres de rutas de la aplicación QUHO
class RouteNames {
  // ========== SPLASH ==========
  static const String splash = '/';

  // ========== AUTH ==========
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // ========== ONBOARDING ==========
  static const String onboarding = '/onboarding';

  // ========== MAIN APP ==========
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';

  // ========== TRANSACTIONS ==========
  static const String transactions = '/home/transactions';
  static const String transactionDetail = '/home/transaction/:id';
  static const String addTransaction = '/home/add-transaction';

  // ========== FINANCES ==========
  static const String finances = '/home/finances';

  // ========== BUDGETS ==========
  static const String budgets = '/home/budgets';
  static const String budgetDetail = '/home/budget/:id';
  static const String createBudget = '/home/create-budget';

  // ========== GOALS ==========
  static const String goals = '/home/goals';
  static const String goalDetail = '/home/goal/:id';
  static const String createGoal = '/home/create-goal';

  // ========== GAMIFICATION ==========
  static const String gamification = '/home/gamification';
  static const String challenges = '/home/challenges';
  static const String badges = '/home/badges';

  // ========== AI ==========
  static const String aiChat = '/home/ai-chat';

  // ========== SETTINGS ==========
  static const String settings = '/home/settings';
  static const String profile = '/home/profile';
  static const String notifications = '/home/notifications';
  static const String security = '/home/security';
  static const String subscription = '/home/subscription';

  // Private constructor
  RouteNames._();
}

