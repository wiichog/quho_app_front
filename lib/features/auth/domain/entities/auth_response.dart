import 'package:equatable/equatable.dart';
import 'package:quho_app/features/auth/domain/entities/user.dart';

/// Respuesta de autenticación
class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}

