import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_advice.dart';
import 'package:quho_app/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Use case para obtener los consejos de presupuesto
class GetBudgetAdviceUseCase {
  final DashboardRepository repository;

  GetBudgetAdviceUseCase(this.repository);

  Future<Either<Failure, List<BudgetAdvice>>> call() async {
    return await repository.getBudgetAdvice();
  }
}








