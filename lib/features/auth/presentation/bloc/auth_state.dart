import 'package:equatable/equatable.dart';
import 'package:quho_app/features/auth/domain/entities/user.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Verificando estado de autenticación
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Usuario autenticado
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Usuario no autenticado
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Registro exitoso, pendiente de verificación
class RegistrationSuccess extends AuthState {
  final String email;

  const RegistrationSuccess({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Código de verificación reenviado
class VerificationCodeResent extends AuthState {
  const VerificationCodeResent();
}

/// Email de reset enviado
class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}

/// Error de autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

