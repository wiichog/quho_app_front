import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/transactions/domain/usecases/get_transactions_usecase.dart';

/// Repositorio para manejar transacciones
abstract class TransactionsRepository {
  Future<Either<Failure, PaginatedTransactions>> getTransactions(GetTransactionsParams params);
}

