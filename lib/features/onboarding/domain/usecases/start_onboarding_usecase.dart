import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class StartOnboardingUseCase {
  final OnboardingRepository repository;

  StartOnboardingUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.startSession();
  }
}

