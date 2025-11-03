import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quho_app/core/constants/app_constants.dart';
import 'package:quho_app/core/services/session_manager.dart';

/// Interceptor para agregar el token de autenticación a las peticiones
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SessionManager _sessionManager = SessionManager();

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obtener el access token del secure storage
    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);

    if (accessToken != null && accessToken.isNotEmpty) {
      // Agregar el token al header
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Si el error es 401 (Unauthorized), intentar refrescar el token
    if (err.response?.statusCode == 401) {
      print('[AUTH_INTERCEPTOR] 🔴 401 Unauthorized detectado');
      
      // Intentar refrescar el token
      final refreshed = await _refreshToken();

      if (refreshed) {
        print('[AUTH_INTERCEPTOR] ✅ Token refrescado, reintentando petición');
        // Reintentar la petición original
        try {
          final response = await _dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
          );
          return handler.resolve(response);
        } catch (e) {
          print('[AUTH_INTERCEPTOR] ❌ Error al reintentar petición: $e');
          return handler.next(err);
        }
      } else {
        // No se pudo refrescar el token, limpiar sesión y notificar
        print('[AUTH_INTERCEPTOR] ❌ No se pudo refrescar token - Limpiando sesión');
        await _clearSession();
        
        // Notificar que la sesión expiró para redirigir al login
        _sessionManager.notifySessionExpired();
        
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Intenta refrescar el access token usando el refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(
        key: AppConstants.refreshTokenKey,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Llamar al endpoint de refresh
      final response = await _dio.post(
        '${AppConstants.authEndpoint}/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            // No incluir el access token para este request
            'Authorization': null,
          },
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String?;

        // Guardar los nuevos tokens
        await _storage.write(
          key: AppConstants.accessTokenKey,
          value: newAccessToken,
        );

        if (newRefreshToken != null) {
          await _storage.write(
            key: AppConstants.refreshTokenKey,
            value: newRefreshToken,
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Limpia la sesión del usuario
  Future<void> _clearSession() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userIdKey);
    await _storage.delete(key: AppConstants.userEmailKey);
    await _storage.delete(key: AppConstants.userNameKey);
  }
}

