import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// Interceptor para logging de peticiones HTTP
/// Útil para debugging en desarrollo
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    return handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    developer.log(
      '┌── REQUEST ────────────────────────────────────────────────',
      name: 'API',
    );
    developer.log(
      '│ ${options.method} ${options.uri}',
      name: 'API',
    );
    
    if (options.queryParameters.isNotEmpty) {
      developer.log(
        '│ Query: ${options.queryParameters}',
        name: 'API',
      );
    }
    
    if (options.headers.isNotEmpty) {
      developer.log(
        '│ Headers: ${_sanitizeHeaders(options.headers)}',
        name: 'API',
      );
    }
    
    if (options.data != null) {
      developer.log(
        '│ Body: ${_sanitizeBody(options.data)}',
        name: 'API',
      );
    }
    
    developer.log(
      '└───────────────────────────────────────────────────────────',
      name: 'API',
    );
  }

  void _logResponse(Response response) {
    developer.log(
      '┌── RESPONSE ───────────────────────────────────────────────',
      name: 'API',
    );
    developer.log(
      '│ ${response.requestOptions.method} ${response.requestOptions.uri}',
      name: 'API',
    );
    developer.log(
      '│ Status: ${response.statusCode} ${response.statusMessage}',
      name: 'API',
    );
    
    if (response.data != null) {
      developer.log(
        '│ Data: ${_truncateData(response.data)}',
        name: 'API',
      );
    }
    
    developer.log(
      '└───────────────────────────────────────────────────────────',
      name: 'API',
    );
  }

  void _logError(DioException err) {
    developer.log(
      '┌── ERROR ──────────────────────────────────────────────────',
      name: 'API',
      error: err.error,
    );
    developer.log(
      '│ ${err.requestOptions.method} ${err.requestOptions.uri}',
      name: 'API',
    );
    developer.log(
      '│ Type: ${err.type}',
      name: 'API',
    );
    
    if (err.response != null) {
      developer.log(
        '│ Status: ${err.response?.statusCode} ${err.response?.statusMessage}',
        name: 'API',
      );
      developer.log(
        '│ Data: ${_truncateData(err.response?.data)}',
        name: 'API',
      );
    }
    
    if (err.error != null) {
      developer.log(
        '│ Error: ${err.error}',
        name: 'API',
      );
    }
    
    developer.log(
      '└───────────────────────────────────────────────────────────',
      name: 'API',
    );
  }

  /// Sanitiza los headers para no mostrar tokens sensibles
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    
    // Ocultar tokens de autenticación
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '***HIDDEN***';
    }
    
    return sanitized;
  }

  /// Sanitiza el body para no mostrar información sensible
  dynamic _sanitizeBody(dynamic body) {
    if (body is! Map<String, dynamic>) {
      return body;
    }

    final sanitized = Map<String, dynamic>.from(body);
    
    // Lista de campos sensibles a ocultar
    const sensitiveFields = [
      'password',
      'password_confirmation',
      'current_password',
      'new_password',
      'token',
      'access_token',
      'refresh_token',
      'credit_card',
      'cvv',
      'pin',
    ];

    for (final field in sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '***HIDDEN***';
      }
    }

    return sanitized;
  }

  /// Trunca datos largos para mejor legibilidad en logs
  String _truncateData(dynamic data) {
    const maxLength = 500;
    final dataString = data.toString();
    
    if (dataString.length <= maxLength) {
      return dataString;
    }
    
    return '${dataString.substring(0, maxLength)}... (truncated)';
  }
}

