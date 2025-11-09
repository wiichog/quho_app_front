import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/dashboard/domain/repositories/dashboard_repository.dart';

/// UseCase para obtener transacciones pendientes de categorización
class GetPendingCategorizationTransactionsUseCase {
  final DashboardRepository repository;

  GetPendingCategorizationTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> call({String ordering = 'asc'}) async {
    return await repository.getPendingCategorizationTransactions(ordering: ordering);
  }
}

