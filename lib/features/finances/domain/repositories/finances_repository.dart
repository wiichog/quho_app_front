import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/finances/domain/entities/finances_overview.dart';

/// Repository interface for finances
abstract class FinancesRepository {
  Future<Either<Failure, FinancesOverview>> getFinancesOverview({required String month});
}

