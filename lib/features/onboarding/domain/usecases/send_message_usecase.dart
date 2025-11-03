import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_message.dart';
import 'package:quho_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class SendMessageUseCase {
  final OnboardingRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, OnboardingMessage>> call(String message) async {
    return await repository.sendMessage(message);
  }
}

