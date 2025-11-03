import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/finances/data/datasources/finances_remote_datasource.dart';
import 'package:quho_app/features/finances/domain/entities/finances_overview.dart';
import 'package:quho_app/features/finances/domain/repositories/finances_repository.dart';

/// Implementation of finances repository
class FinancesRepositoryImpl implements FinancesRepository {
  final FinancesRemoteDataSource remoteDataSource;

  FinancesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FinancesOverview>> getFinancesOverview({required String month}) async {
    try {
      final overview = await remoteDataSource.getFinancesOverview(month: month);
      return Right(overview);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnexpectedFailure(e.message));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure('No autenticado'));
      }
      return const Left(ServerFailure('Error de conexión'));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }
}

