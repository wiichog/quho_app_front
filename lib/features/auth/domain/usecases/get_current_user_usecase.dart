import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/auth/domain/entities/user.dart';
import 'package:quho_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case para obtener el usuario actual
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}

