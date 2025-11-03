import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_advice.dart';

/// Repositorio del Dashboard
abstract class DashboardRepository {
  /// Obtener resumen del presupuesto del mes actual
  Future<Either<Failure, BudgetSummary>> getBudgetSummary({
    required String month, // YYYY-MM
  });

  /// Obtener transacciones recientes
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    int limit = 5,
  });

  /// Obtener transacciones pendientes de categorización
  Future<Either<Failure, List<Transaction>>> getPendingCategorizationTransactions();

  /// Obtener consejos de presupuesto del usuario
  Future<Either<Failure, List<BudgetAdvice>>> getBudgetAdvice();
}

