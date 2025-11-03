import 'package:equatable/equatable.dart';

/// Eventos de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Verificar si hay sesión activa
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Login
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, phone];
}

/// Verificar email
class VerifyEmailEvent extends AuthEvent {
  final String code;

  const VerifyEmailEvent({required this.code});

  @override
  List<Object?> get props => [code];
}

/// Reenviar código de verificación
class ResendVerificationCodeEvent extends AuthEvent {
  final String email;

  const ResendVerificationCodeEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Solicitar reset de contraseña
class RequestPasswordResetEvent extends AuthEvent {
  final String email;

  const RequestPasswordResetEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Logout
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

