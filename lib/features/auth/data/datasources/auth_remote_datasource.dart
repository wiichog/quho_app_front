import 'package:dio/dio.dart';
import 'package:quho_app/core/constants/app_constants.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/network/api_client.dart';
import 'package:quho_app/features/auth/data/models/auth_response_model.dart';
import 'package:quho_app/features/auth/data/models/user_model.dart';

/// Interfaz del datasource remoto de autenticación
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  });

  Future<AuthResponseModel> verifyEmail({required String code});

  Future<void> resendVerificationCode({required String email});

  Future<void> requestPasswordReset({required String email});

  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<String> refreshAccessToken({required String refreshToken});

  Future<UserModel> getCurrentUser();

  Future<void> logout({required String refreshToken});
}

/// Implementación del datasource remoto de autenticación
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }  ) async {
    try {
      final response = await apiClient.post(
        '${AppConstants.authEndpoint}/login/',
        data: {
          'identifier': email, // El backend espera 'identifier' en lugar de 'email'
          'password': password,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(responseData);
      return authResponse;
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al iniciar sesión',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      await apiClient.post(
        '${AppConstants.authEndpoint}/register/',
        data: {
          'email': email,
          'password': password,
          'password_confirm': password,
          'first_name': firstName,
          'last_name': lastName,
          if (phone != null) 'phone': phone,
        },
      );
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al registrarse',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<AuthResponseModel> verifyEmail({required String code}) async {
    try {
      final response = await apiClient.post(
        '${AppConstants.authEndpoint}/verify/',
        data: {'code': code},
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al verificar email',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<void> resendVerificationCode({required String email}) async {
    try {
      await apiClient.post(
        '${AppConstants.authEndpoint}/verify/resend/',
        data: {'email': email},
      );
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al reenviar código',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await apiClient.post(
        '${AppConstants.authEndpoint}/password/reset/request/',
        data: {'email': email},
      );
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al solicitar reset',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    try {
      await apiClient.post(
        '${AppConstants.authEndpoint}/password/reset/confirm/',
        data: {
          'token': token,
          'password': password,
          'password_confirm': password,
        },
      );
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al confirmar reset',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.post(
        '${AppConstants.authEndpoint}/password/change/',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirm': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al cambiar contraseña',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<String> refreshAccessToken({required String refreshToken}) async {
    try {
      final response = await apiClient.post(
        '${AppConstants.authEndpoint}/refresh/',
        data: {'refresh': refreshToken},
      );

      return response.data['access'] as String;
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al refrescar token',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get(
        '${AppConstants.usersEndpoint}/',
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener usuario',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await apiClient.post(
        '${AppConstants.authEndpoint}/logout/',
        data: {'refresh': refreshToken},
      );
    } on DioException catch (e) {
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al cerrar sesión',
        originalException: e,
      );
    } catch (e) {
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }
}

