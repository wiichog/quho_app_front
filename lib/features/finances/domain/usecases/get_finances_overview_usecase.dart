import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/finances/domain/entities/finances_overview.dart';
import 'package:quho_app/features/finances/domain/repositories/finances_repository.dart';

/// Use case for getting finances overview
class GetFinancesOverviewUseCase {
  final FinancesRepository repository;

  GetFinancesOverviewUseCase(this.repository);

  Future<Either<Failure, FinancesOverview>> call({required String month}) async {
    return await repository.getFinancesOverview(month: month);
  }
}

