import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_advice.dart';
import 'package:quho_app/features/dashboard/domain/usecases/get_budget_summary_usecase.dart';
import 'package:quho_app/features/dashboard/domain/usecases/get_recent_transactions_usecase.dart';
import 'package:quho_app/features/dashboard/domain/usecases/get_budget_advice_usecase.dart';
import 'package:quho_app/features/dashboard/domain/usecases/get_pending_categorization_transactions_usecase.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_state.dart';

/// BLoC del Dashboard
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetBudgetSummaryUseCase getBudgetSummaryUseCase;
  final GetRecentTransactionsUseCase getRecentTransactionsUseCase;
  final GetBudgetAdviceUseCase getBudgetAdviceUseCase;
  final GetPendingCategorizationTransactionsUseCase getPendingCategorizationTransactionsUseCase;

  DashboardBloc({
    required this.getBudgetSummaryUseCase,
    required this.getRecentTransactionsUseCase,
    required this.getBudgetAdviceUseCase,
    required this.getPendingCategorizationTransactionsUseCase,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
    on<UpdateBalanceEvent>(_onUpdateBalance);
    on<ChangePendingTransactionsOrderingEvent>(_onChangePendingTransactionsOrdering);
  }

  /// Cargar datos del dashboard
  Future<void> _onLoadDashboardData(
    LoadDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    print('🔵 [BLOC] Cargando datos del dashboard');
    emit(const DashboardLoading());

    // Obtener mes actual en formato YYYY-MM
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    print('🔵 [BLOC] Mes actual: $month');

    // Hacer todas las peticiones en paralelo
    print('🔵 [BLOC] Iniciando peticiones en paralelo');
    final results = await Future.wait([
      getBudgetSummaryUseCase(GetBudgetSummaryParams(month: month)),
      getRecentTransactionsUseCase(limit: 5),
      getBudgetAdviceUseCase(),
      getPendingCategorizationTransactionsUseCase(),
    ]);

    final budgetResult = results[0];
    final transactionsResult = results[1];
    final adviceResult = results[2];
    final pendingResult = results[3];

    print('🔵 [BLOC] Peticiones completadas');
    print('📦 [BLOC] Budget result isLeft: ${budgetResult.isLeft()}');
    print('📦 [BLOC] Transactions result isLeft: ${transactionsResult.isLeft()}');
    print('📦 [BLOC] Advice result isLeft: ${adviceResult.isLeft()}');

    // Verificar si hay errores
    if (budgetResult.isLeft()) {
      final failure = budgetResult.fold((l) => l, (r) => null);
      print('❌ [BLOC] Error en budget: ${failure?.message}');
      print('❌ [BLOC] Failure type: ${failure.runtimeType}');
      emit(DashboardError(message: failure?.message ?? 'Error desconocido'));
      return;
    }

    if (transactionsResult.isLeft()) {
      final failure = transactionsResult.fold((l) => l, (r) => null);
      print('❌ [BLOC] Error en transactions: ${failure?.message}');
      print('❌ [BLOC] Failure type: ${failure.runtimeType}');
      emit(DashboardError(message: failure?.message ?? 'Error desconocido'));
      return;
    }

    // Extraer valores
    print('🔵 [BLOC] Extrayendo valores de los resultados');
    final budgetSummary = budgetResult.fold((l) => throw l, (r) => r) as BudgetSummary;
    final transactions = transactionsResult.fold((l) => throw l, (r) => r) as List<Transaction>;
    // Los consejos son opcionales, si fallan no afectan el resto
    final advice = adviceResult.fold(
      (l) {
        print('[BLOC] ⚠️ No se pudieron cargar consejos: ${l.message}');
        return <BudgetAdvice>[];
      },
      (r) => r as List<BudgetAdvice>,
    );
    // Las transacciones pendientes también son opcionales
    final pending = pendingResult.fold(
      (l) {
        print('[BLOC] ⚠️ No se pudieron cargar transacciones pendientes: ${l.message}');
        return <Transaction>[];
      },
      (r) => r as List<Transaction>,
    );

    print('✅ [BLOC] Dashboard cargado correctamente');
    print('📦 [BLOC] Budget summary month: ${budgetSummary.month}');
    print('📦 [BLOC] Transactions count: ${transactions.length}');
    print('📦 [BLOC] Advice count: ${advice.length}');
    print('📦 [BLOC] Pending categorization count: ${pending.length}');

    emit(DashboardLoaded(
      budgetSummary: budgetSummary,
      recentTransactions: transactions,
      budgetAdvice: advice,
      pendingCategorizationTransactions: pending,
    ));
  }

  /// Refrescar dashboard
  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // Reutilizar la lógica de carga
    add(const LoadDashboardDataEvent());
  }

  /// Actualizar balance
  Future<void> _onUpdateBalance(
    UpdateBalanceEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // TODO: Implementar actualización del balance en el backend
    // Por ahora solo recargamos los datos
    print('[BLOC] 📝 Balance actualizado a: ${event.newBalance}');
    add(const LoadDashboardDataEvent());
  }

  /// Cambiar ordenamiento de transacciones pendientes
  Future<void> _onChangePendingTransactionsOrdering(
    ChangePendingTransactionsOrderingEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    print('[BLOC] 🔄 Cambiando ordenamiento de transacciones pendientes a: ${event.ordering}');

    // Obtener las transacciones con el nuevo ordenamiento
    final result = await getPendingCategorizationTransactionsUseCase(ordering: event.ordering);

    result.fold(
      (failure) {
        print('[BLOC] ❌ Error al cambiar ordenamiento: ${failure.message}');
        // Mantener el estado actual si hay error
      },
      (transactions) {
        print('[BLOC] ✅ Transacciones pendientes reordenadas: ${transactions.length}');
        emit(currentState.copyWith(
          pendingCategorizationTransactions: transactions,
          pendingTransactionsOrdering: event.ordering,
        ));
      },
    );
  }
}

