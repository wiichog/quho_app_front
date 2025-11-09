import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'package:quho_app/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:quho_app/features/transactions/domain/usecases/get_transactions_usecase.dart';

/// Implementación del repositorio de transacciones
class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource remoteDataSource;

  TransactionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedTransactions>> getTransactions(
    GetTransactionsParams params,
  ) async {
    try {
      print('🔵 [REPOSITORY] Obteniendo transacciones con filtros');
      final result = await remoteDataSource.getTransactions(params);

      print('✅ [REPOSITORY] ${result.transactions.length} transacciones obtenidas');
      return Right(result);
    } on UnauthorizedException catch (e) {
      print('❌ [REPOSITORY] UnauthorizedException: $e');
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      print('❌ [REPOSITORY] NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      print('❌ [REPOSITORY] TimeoutException: ${e.message}');
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      print('❌ [REPOSITORY] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      print('❌ [REPOSITORY] NotFoundException: ${e.message}');
      return Left(NotFoundFailure(e.message));
    } catch (e, stackTrace) {
      print('❌ [REPOSITORY] Exception inesperada: $e');
      print('❌ [REPOSITORY] Tipo de error: ${e.runtimeType}');
      print('❌ [REPOSITORY] Stack trace: $stackTrace');
      return Left(UnexpectedFailure('Error al obtener transacciones: $e'));
    }
  }
}

