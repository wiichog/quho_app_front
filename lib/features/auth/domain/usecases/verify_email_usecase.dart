import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/auth/domain/entities/auth_response.dart';
import 'package:quho_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case para verificar email
class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(VerifyEmailParams params) async {
    return await repository.verifyEmail(code: params.code);
  }
}

class VerifyEmailParams extends Equatable {
  final String code;

  const VerifyEmailParams({required this.code});

  @override
  List<Object?> get props => [code];
}

