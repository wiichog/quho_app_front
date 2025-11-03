import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
import 'package:quho_app/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Use case para obtener resumen del presupuesto
class GetBudgetSummaryUseCase {
  final DashboardRepository repository;

  GetBudgetSummaryUseCase(this.repository);

  Future<Either<Failure, BudgetSummary>> call(GetBudgetSummaryParams params) async {
    return await repository.getBudgetSummary(month: params.month);
  }
}

class GetBudgetSummaryParams extends Equatable {
  final String month;

  const GetBudgetSummaryParams({required this.month});

  @override
  List<Object?> get props => [month];
}

