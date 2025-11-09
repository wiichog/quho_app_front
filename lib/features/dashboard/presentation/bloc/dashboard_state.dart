import 'package:equatable/equatable.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_advice.dart';

/// Estados del Dashboard
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Cargando datos
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Datos cargados correctamente
class DashboardLoaded extends DashboardState {
  final BudgetSummary budgetSummary;
  final List<Transaction> recentTransactions;
  final List<BudgetAdvice> budgetAdvice;
  final List<Transaction> pendingCategorizationTransactions;
  final String pendingTransactionsOrdering; // 'asc' o 'desc'

  const DashboardLoaded({
    required this.budgetSummary,
    required this.recentTransactions,
    required this.budgetAdvice,
    this.pendingCategorizationTransactions = const [],
    this.pendingTransactionsOrdering = 'asc',
  });

  DashboardLoaded copyWith({
    BudgetSummary? budgetSummary,
    List<Transaction>? recentTransactions,
    List<BudgetAdvice>? budgetAdvice,
    List<Transaction>? pendingCategorizationTransactions,
    String? pendingTransactionsOrdering,
  }) {
    return DashboardLoaded(
      budgetSummary: budgetSummary ?? this.budgetSummary,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      budgetAdvice: budgetAdvice ?? this.budgetAdvice,
      pendingCategorizationTransactions: pendingCategorizationTransactions ?? this.pendingCategorizationTransactions,
      pendingTransactionsOrdering: pendingTransactionsOrdering ?? this.pendingTransactionsOrdering,
    );
  }

  @override
  List<Object?> get props => [budgetSummary, recentTransactions, budgetAdvice, pendingCategorizationTransactions, pendingTransactionsOrdering];
}

/// Error al cargar datos
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

