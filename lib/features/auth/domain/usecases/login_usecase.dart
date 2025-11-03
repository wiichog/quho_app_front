import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/auth/domain/entities/auth_response.dart';
import 'package:quho_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case para hacer login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

