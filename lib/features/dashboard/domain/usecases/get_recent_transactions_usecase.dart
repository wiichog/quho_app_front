import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Use case para obtener transacciones recientes
class GetRecentTransactionsUseCase {
  final DashboardRepository repository;

  GetRecentTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> call({int limit = 5}) async {
    return await repository.getRecentTransactions(limit: limit);
  }
}

