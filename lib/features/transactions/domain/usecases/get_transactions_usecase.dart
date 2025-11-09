import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/transactions/domain/repositories/transactions_repository.dart';

/// Parámetros para obtener transacciones con filtros
class GetTransactionsParams {
  final int page;
  final int limit;
  final String? type; // 'income', 'expense', o null para todos
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;

  const GetTransactionsParams({
    this.page = 1,
    this.limit = 20,
    this.type,
    this.category,
    this.startDate,
    this.endDate,
    this.search,
  });
}

/// Resultado paginado de transacciones
class PaginatedTransactions {
  final List<Transaction> transactions;
  final int count;
  final bool hasNext;
  final bool hasPrevious;

  const PaginatedTransactions({
    required this.transactions,
    required this.count,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Use case para obtener transacciones con filtros y paginación
class GetTransactionsUseCase {
  final TransactionsRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, PaginatedTransactions>> call(GetTransactionsParams params) async {
    return await repository.getTransactions(params);
  }
}

