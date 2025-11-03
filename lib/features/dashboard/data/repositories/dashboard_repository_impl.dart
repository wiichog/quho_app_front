import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_advice.dart';
import 'package:quho_app/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Implementación del repositorio del Dashboard
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BudgetSummary>> getBudgetSummary({
    required String month,
  }) async {
    try {
      print('🔵 [REPOSITORY] Obteniendo resumen de presupuesto para mes: $month');
      final result = await remoteDataSource.getBudgetSummary(month: month);
      
      print('✅ [REPOSITORY] Convirtiendo modelo a entidad');
      final entity = result.toEntity();
      print('✅ [REPOSITORY] Entidad creada correctamente');
      
      return Right(entity);
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
      return Left(UnexpectedFailure('Error al obtener resumen del presupuesto: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    int limit = 5,
  }) async {
    try {
      print('🔵 [REPOSITORY] Obteniendo transacciones recientes (limit: $limit)');
      final result = await remoteDataSource.getRecentTransactions(limit: limit);
      
      print('✅ [REPOSITORY] Convirtiendo ${result.length} transacciones a entidades');
      final entities = result.map((model) => model.toEntity()).toList();
      print('✅ [REPOSITORY] Transacciones convertidas correctamente');
      
      return Right(entities);
    } on UnauthorizedException catch (e) {
      print('❌ [REPOSITORY] UnauthorizedException en transacciones: $e');
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      print('❌ [REPOSITORY] NetworkException en transacciones: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      print('❌ [REPOSITORY] TimeoutException en transacciones: ${e.message}');
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      print('❌ [REPOSITORY] ServerException en transacciones: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      print('❌ [REPOSITORY] Exception inesperada en transacciones: $e');
      print('❌ [REPOSITORY] Tipo de error: ${e.runtimeType}');
      print('❌ [REPOSITORY] Stack trace: $stackTrace');
      return Left(UnexpectedFailure('Error al obtener transacciones: $e')      );
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getPendingCategorizationTransactions() async {
    try {
      print('🔵 [REPOSITORY] Obteniendo transacciones pendientes de categorización');
      final result = await remoteDataSource.getPendingCategorizationTransactions();
      
      print('✅ [REPOSITORY] Convirtiendo ${result.length} transacciones pendientes a entidades');
      final entities = result.map((model) => model.toEntity()).toList();
      print('✅ [REPOSITORY] Transacciones pendientes convertidas correctamente');
      
      return Right(entities);
    } on UnauthorizedException catch (e) {
      print('❌ [REPOSITORY] UnauthorizedException en transacciones pendientes: $e');
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      print('❌ [REPOSITORY] NetworkException en transacciones pendientes: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      print('❌ [REPOSITORY] TimeoutException en transacciones pendientes: ${e.message}');
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      print('❌ [REPOSITORY] ServerException en transacciones pendientes: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      print('❌ [REPOSITORY] Exception inesperada en transacciones pendientes: $e');
      print('❌ [REPOSITORY] Tipo de error: ${e.runtimeType}');
      print('❌ [REPOSITORY] Stack trace: $stackTrace');
      return Left(UnexpectedFailure('Error al obtener transacciones pendientes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetAdvice>>> getBudgetAdvice() async {
    try {
      print('[DASHBOARD_REPO] 🔵 Obteniendo consejos de presupuesto');
      final result = await remoteDataSource.getBudgetAdvice();
      print('[DASHBOARD_REPO] ✅ Convirtiendo ${result.length} consejos a entidades');
      final entities = result.map((model) => model.toEntity()).toList();
      print('[DASHBOARD_REPO] ✅ Consejos convertidos correctamente');
      return Right(entities);
    } on UnauthorizedException catch (e) {
      print('[DASHBOARD_REPO] ❌ UnauthorizedException en consejos: $e');
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      print('[DASHBOARD_REPO] ❌ NetworkException en consejos: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      print('[DASHBOARD_REPO] ❌ TimeoutException en consejos: ${e.message}');
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      print('[DASHBOARD_REPO] ❌ ServerException en consejos: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      print('[DASHBOARD_REPO] ❌ Exception inesperada en consejos: $e');
      print('[DASHBOARD_REPO] ❌ Tipo de error: ${e.runtimeType}');
      print('[DASHBOARD_REPO] ❌ Stack trace: $stackTrace');
      return Left(UnexpectedFailure('Error al obtener consejos: $e'));
    }
  }
}

