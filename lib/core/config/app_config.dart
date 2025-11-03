import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:quho_app/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quho_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quho_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:quho_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quho_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quho_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:quho_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:quho_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:quho_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:quho_app/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:quho_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:quho_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quho_app/features/dashboard/domain/usecases/get_budget_summary_usecase.dart';
import 'package:quho_app/features/dashboard/domain/usecases/get_recent_transactions_usecase.dart';
import 'package:quho_app/features/dashboard/domain/usecases/get_pending_categorization_transactions_usecase.dart';
import 'package:quho_app/features/dashboard/domain/usecases/get_budget_advice_usecase.dart';
import 'package:quho_app/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:quho_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:quho_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:quho_app/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:quho_app/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import 'package:quho_app/features/onboarding/domain/usecases/send_message_usecase.dart';
import 'package:quho_app/features/onboarding/domain/usecases/start_onboarding_usecase.dart';
import 'package:quho_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:quho_app/features/finances/data/datasources/finances_remote_datasource.dart';
import 'package:quho_app/features/finances/data/repositories/finances_repository_impl.dart';
import 'package:quho_app/features/finances/domain/repositories/finances_repository.dart';
import 'package:quho_app/features/finances/domain/usecases/get_finances_overview_usecase.dart';
import 'package:quho_app/features/finances/presentation/bloc/finances_bloc.dart';

/// Singleton para configuración global de la aplicación
final getIt = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
Future<void> setupDependencies() async {
  // ========== CORE ==========
  
  // Secure Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // API Client
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // ========== AUTH - DATA SOURCES ==========
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt(),
      sharedPreferences: getIt(),
    ),
  );

  // ========== AUTH - REPOSITORIES ==========
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // ========== AUTH - USE CASES ==========
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  // ========== AUTH - BLOC ==========
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      verifyEmailUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
      logoutUseCase: getIt(),
      authRepository: getIt(),
    ),
  );

  // ========== DASHBOARD - DATA SOURCES ==========
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: getIt()),
  );

  // ========== DASHBOARD - REPOSITORIES ==========
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: getIt()),
  );

  // ========== DASHBOARD - USE CASES ==========
  getIt.registerLazySingleton(() => GetBudgetSummaryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetRecentTransactionsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPendingCategorizationTransactionsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetBudgetAdviceUseCase(getIt()));

  // ========== DASHBOARD - BLOC ==========
  getIt.registerFactory(
    () => DashboardBloc(
      getBudgetSummaryUseCase: getIt(),
      getRecentTransactionsUseCase: getIt(),
      getBudgetAdviceUseCase: getIt(),
      getPendingCategorizationTransactionsUseCase: getIt(),
    ),
  );

  // ========== ONBOARDING - DATA SOURCES ==========
  getIt.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(apiClient: getIt()),
  );

  // ========== ONBOARDING - REPOSITORIES ==========
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(remoteDataSource: getIt()),
  );

  // ========== ONBOARDING - USE CASES ==========
  getIt.registerLazySingleton(() => StartOnboardingUseCase(getIt()));
  getIt.registerLazySingleton(() => SendMessageUseCase(getIt()));
  getIt.registerLazySingleton(() => CompleteOnboardingUseCase(getIt()));
  getIt.registerLazySingleton(() => GetOnboardingStatusUseCase(getIt()));

  // ========== ONBOARDING - BLOC ==========
  getIt.registerFactory(
    () => OnboardingBloc(
      startOnboardingUseCase: getIt(),
      sendMessageUseCase: getIt(),
      completeOnboardingUseCase: getIt(),
      getOnboardingStatusUseCase: getIt(),
    ),
  );

  // ========== FINANCES - DATA SOURCES ==========
  getIt.registerLazySingleton<FinancesRemoteDataSource>(
    () => FinancesRemoteDataSourceImpl(apiClient: getIt()),
  );

  // ========== FINANCES - REPOSITORIES ==========
  getIt.registerLazySingleton<FinancesRepository>(
    () => FinancesRepositoryImpl(remoteDataSource: getIt()),
  );

  // ========== FINANCES - USE CASES ==========
  getIt.registerLazySingleton(() => GetFinancesOverviewUseCase(getIt()));

  // ========== FINANCES - BLOC ==========
  getIt.registerFactory(
    () => FinancesBloc(
      getFinancesOverviewUseCase: getIt(),
    ),
  );
}

/// Reinicia todas las dependencias (útil para testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}

