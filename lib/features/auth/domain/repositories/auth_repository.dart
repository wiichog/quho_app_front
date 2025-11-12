import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/auth/domain/entities/auth_response.dart';
import 'package:quho_app/features/auth/domain/entities/user.dart';

/// Interfaz del repositorio de autenticación
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  /// Registro de nuevo usuario
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  });

  /// Verificar email con código
  Future<Either<Failure, AuthResponse>> verifyEmail({
    required String code,
  });

  /// Reenviar código de verificación
  Future<Either<Failure, void>> resendVerificationCode({
    required String email,
  });

  /// Solicitar reset de contraseña
  Future<Either<Failure, void>> requestPasswordReset({
    required String email,
  });

  /// Confirmar reset de contraseña
  Future<Either<Failure, void>> confirmPasswordReset({
    required String token,
    required String password,
  });

  /// Cambiar contraseña (usuario autenticado)
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Refrescar access token
  Future<Either<Failure, String>> refreshAccessToken({
    required String refreshToken,
  });

  /// Obtener usuario actual
  Future<Either<Failure, User>> getCurrentUser();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Social Auth (Google, Apple, Facebook)
  Future<Either<Failure, AuthResponse>> socialAuth({
    required String provider,
    required String accessToken,
    String? idToken,
    String? authorizationCode,
  });

  /// Verificar si hay una sesión activa
  Future<bool> hasActiveSession();

  /// Guardar tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Obtener access token guardado
  Future<String?> getAccessToken();

  /// Obtener refresh token guardado
  Future<String?> getRefreshToken();

  /// Limpiar sesión
  Future<void> clearSession();
}

