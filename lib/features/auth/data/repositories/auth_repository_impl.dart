import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quho_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:quho_app/features/auth/data/models/user_model.dart';
import 'package:quho_app/features/auth/domain/entities/auth_response.dart';
import 'package:quho_app/features/auth/domain/entities/user.dart';
import 'package:quho_app/features/auth/domain/repositories/auth_repository.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Guardar tokens y usuario
      await localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      
      await localDataSource.saveUser(result.user as UserModel);

      final entity = result.toEntity();
      return Right(entity);
    } on InvalidCredentialsException catch (e) {
      return const Left(InvalidCredentialsFailure());
    } on UnauthorizedException catch (e) {
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      return Left(UnexpectedFailure('Error inesperado al iniciar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      return const Right(null);
    } on UserAlreadyExistsException catch (e) {
      return Left(UserAlreadyExistsFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado al registrarse'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> verifyEmail({
    required String code,
  }) async {
    try {
      final result = await remoteDataSource.verifyEmail(code: code);

      // Guardar tokens y usuario
      await localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await localDataSource.saveUser(result.user as UserModel);

      return Right(result.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado al verificar email'));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationCode({
    required String email,
  }) async {
    try {
      await remoteDataSource.resendVerificationCode(email: email);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al reenviar código'));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset({
    required String email,
  }) async {
    try {
      await remoteDataSource.requestPasswordReset(email: email);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al solicitar reset de contraseña'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    try {
      await remoteDataSource.confirmPasswordReset(
        token: token,
        password: password,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al confirmar reset de contraseña'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al cambiar contraseña'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshAccessToken({
    required String refreshToken,
  }) async {
    try {
      final newAccessToken = await remoteDataSource.refreshAccessToken(
        refreshToken: refreshToken,
      );

      // Guardar nuevo access token
      final currentRefreshToken = await localDataSource.getRefreshToken();
      if (currentRefreshToken != null) {
        await localDataSource.saveTokens(
          accessToken: newAccessToken,
          refreshToken: currentRefreshToken,
        );
      }

      return Right(newAccessToken);
    } on UnauthorizedException catch (e) {
      // Token de refresh inválido o expirado
      await localDataSource.clearSession();
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al refrescar token'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Intentar obtener del caché primero
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        // Actualizar en background
        _updateUserInBackground();
        return Right(cachedUser.toEntity());
      }

      // Si no hay caché, obtener del servidor
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);
      return Right(user.toEntity());
    } on UnauthorizedException catch (e) {
      await localDataSource.clearSession();
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      // Si hay error de red pero hay caché, devolver caché
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al obtener usuario'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Obtener el refresh token antes de limpiar la sesión
      final refreshToken = await localDataSource.getRefreshToken();
      
      // Intentar invalidar el token en el servidor
      if (refreshToken != null) {
        try {
          await remoteDataSource.logout(refreshToken: refreshToken);
        } catch (e) {
          // Si falla la invalidación en el servidor, igual continuar con el logout local
          // (por ejemplo, si no hay conexión a internet)
        }
      }
      
      // Limpiar la sesión local
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> socialAuth({
    required String provider,
    required String accessToken,
    String? idToken,
    String? authorizationCode,
  }) async {
    try {
      final authResponse = await remoteDataSource.socialAuth(
        provider: provider,
        accessToken: accessToken,
        idToken: idToken,
        authorizationCode: authorizationCode,
      );

      // Guardar tokens
      await localDataSource.saveTokens(
        accessToken: authResponse.access,
        refreshToken: authResponse.refresh,
      );

      // Guardar usuario
      await localDataSource.saveUser(authResponse.user);

      return Right(authResponse.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error en autenticación social'));
    }
  }

  @override
  Future<bool> hasActiveSession() async {
    try {
      return await localDataSource.hasActiveSession();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await localDataSource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return await localDataSource.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await localDataSource.getRefreshToken();
  }

  @override
  Future<void> clearSession() async {
    await localDataSource.clearSession();
  }

  /// Actualiza el usuario en background sin bloquear
  Future<void> _updateUserInBackground() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);
    } catch (e) {
      // Ignorar errores en actualización de background
    }
  }
}

