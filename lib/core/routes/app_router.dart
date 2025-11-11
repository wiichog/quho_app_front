import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quho_app/features/auth/presentation/pages/login_page.dart';
import 'package:quho_app/features/auth/presentation/pages/register_page.dart';
import 'package:quho_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:quho_app/features/auth/presentation/pages/verify_email_page.dart';
import 'package:quho_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:quho_app/features/onboarding/presentation/pages/conversational_onboarding_page.dart';
import 'package:quho_app/features/finances/presentation/pages/finances_page.dart';
import 'package:quho_app/features/transactions/presentation/pages/transactions_page.dart';
import 'package:quho_app/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:quho_app/features/profile/presentation/pages/profile_page.dart';

/// Configuración de rutas de la aplicación con GoRouter
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteNames.splash,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        print('[APP_ROUTER] 🔄 Redirect check para: ${state.matchedLocation}');
        
        final authState = authBloc.state;
        print('[APP_ROUTER] 📦 Estado de auth: ${authState.runtimeType}');
        
        final isUnauthenticated = authState is Unauthenticated;
        final isOnAuthPage = state.matchedLocation == RouteNames.login ||
            state.matchedLocation == RouteNames.register ||
            state.matchedLocation == RouteNames.forgotPassword ||
            state.matchedLocation == RouteNames.splash ||
            state.matchedLocation.startsWith('/verify-email');
        
        // Si está no autenticado y no está en una página de auth, redirigir al login
        if (isUnauthenticated && !isOnAuthPage) {
          print('[APP_ROUTER] ⚠️ Usuario no autenticado, redirigiendo a login');
          return RouteNames.login;
        }
        
        // Si está autenticado y está en una página de auth (excepto verify-email), redirigir al home
        if (authState is Authenticated && isOnAuthPage && !state.matchedLocation.startsWith('/verify-email')) {
          print('[APP_ROUTER] ⚠️ Usuario autenticado en página de auth, redirigiendo a home');
          final shouldGoToOnboarding = !authState.user.onboardingCompleted;
          return shouldGoToOnboarding ? RouteNames.onboarding : RouteNames.home;
        }
        
        return null; // No redirect
      },
      routes: [
      // ========== SPLASH ==========
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // ========== AUTH ==========
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verifyEmail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          return VerifyEmailPage(email: email);
        },
      ),

      // ========== ONBOARDING ==========
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
            builder: (context, state) => const ConversationalOnboardingPage(),
      ),

      // ========== MAIN APP ==========
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const DashboardPage(),
        routes: [

          // Finances
          GoRoute(
            path: 'finances',
            name: 'finances',
            builder: (context, state) => const FinancesPage(),
          ),

          // Transactions
          GoRoute(
            path: 'transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: 'transaction/:id',
            name: 'transactionDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TransactionDetailPage(transactionId: id);
            },
          ),
          GoRoute(
            path: 'add-transaction',
            name: 'addTransaction',
            builder: (context, state) => const AddTransactionPage(),
          ),

          // Budgets
          GoRoute(
            path: 'budgets',
            name: 'budgets',
            builder: (context, state) => const BudgetsPage(),
          ),
          GoRoute(
            path: 'budget/:id',
            name: 'budgetDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BudgetDetailPage(budgetId: id);
            },
          ),
          GoRoute(
            path: 'create-budget',
            name: 'createBudget',
            builder: (context, state) => const CreateBudgetPage(),
          ),

          // Goals
          GoRoute(
            path: 'goals',
            name: 'goals',
            builder: (context, state) => const GoalsPage(),
          ),
          GoRoute(
            path: 'goal/:id',
            name: 'goalDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return GoalDetailPage(goalId: id);
            },
          ),
          GoRoute(
            path: 'create-goal',
            name: 'createGoal',
            builder: (context, state) => const CreateGoalPage(),
          ),

          // Gamification
          GoRoute(
            path: 'gamification',
            name: 'gamification',
            builder: (context, state) => const GamificationPage(),
          ),
          GoRoute(
            path: 'challenges',
            name: 'challenges',
            builder: (context, state) => const ChallengesPage(),
          ),
          GoRoute(
            path: 'badges',
            name: 'badges',
            builder: (context, state) => const BadgesPage(),
          ),

          // AI Chat
          GoRoute(
            path: 'ai-chat',
            name: 'aiChat',
            builder: (context, state) => const AIChatPage(),
          ),

          // Settings
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: 'security',
            name: 'security',
            builder: (context, state) => const SecurityPage(),
          ),
          GoRoute(
            path: 'subscription',
            name: 'subscription',
            builder: (context, state) => const SubscriptionPage(),
          ),
        ],
      ),
    ],
      errorBuilder: (context, state) => ErrorPage(error: state.error),
    );
  }
  
  // Router singleton (se inicializa en main.dart)
  static late final GoRouter router;
}

/// Helper class to convert a Stream to a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ========== PLACEHOLDER PAGES ==========
// Estas páginas serán implementadas en los siguientes TODOs

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    print('🎨 SplashPage: Inicializado');
    _navigate();
  }

  void _navigate() async {
    print('🎨 SplashPage: Esperando 2 segundos...');
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    print('🎨 SplashPage: Navegando a login...');
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 SplashPage: Renderizando...');
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando QUHO...'),
          ],
        ),
      ),
    );
  }
}

// Las páginas reales están importadas al inicio del archivo
// Ya no se necesitan los placeholders

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏠 HomePage: Renderizando...');
    return const Scaffold(
      body: Center(child: Text('Home Page - TODO')),
    );
  }
}

// Placeholders pendientes
class PlaceholderDashboardPage extends StatelessWidget {
  const PlaceholderDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Dashboard Page - TODO')),
    );
  }
}

// TransactionsPage ahora se importa desde features/transactions
// Ver: lib/features/transactions/presentation/pages/transactions_page.dart

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;
  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Detail')),
      body: Center(child: Text('Transaction Detail Page - TODO: $transactionId')),
    );
  }
}

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: const Center(child: Text('Add Transaction Page - TODO')),
    );
  }
}

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: const Center(child: Text('Budgets Page - TODO')),
    );
  }
}

class BudgetDetailPage extends StatelessWidget {
  final String budgetId;
  const BudgetDetailPage({super.key, required this.budgetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Detail')),
      body: Center(child: Text('Budget Detail Page - TODO: $budgetId')),
    );
  }
}

class CreateBudgetPage extends StatelessWidget {
  const CreateBudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Budget')),
      body: const Center(child: Text('Create Budget Page - TODO')),
    );
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(child: Text('Goals Page - TODO')),
    );
  }
}

class GoalDetailPage extends StatelessWidget {
  final String goalId;
  const GoalDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goal Detail')),
      body: Center(child: Text('Goal Detail Page - TODO: $goalId')),
    );
  }
}

class CreateGoalPage extends StatelessWidget {
  const CreateGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Goal')),
      body: const Center(child: Text('Create Goal Page - TODO')),
    );
  }
}

class GamificationPage extends StatelessWidget {
  const GamificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gamification')),
      body: const Center(child: Text('Gamification Page - TODO')),
    );
  }
}

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: const Center(child: Text('Challenges Page - TODO')),
    );
  }
}

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: const Center(child: Text('Badges Page - TODO')),
    );
  }
}

class AIChatPage extends StatelessWidget {
  const AIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: const Center(child: Text('AI Chat Page - TODO')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page - TODO')),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notifications Page - TODO')),
    );
  }
}

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: const Center(child: Text('Security Page - TODO')),
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: const Center(child: Text('Subscription Page - TODO')),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final Exception? error;
  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Error: ${error?.toString() ?? "Unknown error"}'),
      ),
    );
  }
}

