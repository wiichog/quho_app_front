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

  const DashboardLoaded({
    required this.budgetSummary,
    required this.recentTransactions,
    required this.budgetAdvice,
    this.pendingCategorizationTransactions = const [],
  });

  @override
  List<Object?> get props => [budgetSummary, recentTransactions, budgetAdvice, pendingCategorizationTransactions];
}

/// Error al cargar datos
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

