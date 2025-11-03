import 'package:dio/dio.dart';
import 'package:quho_app/core/errors/exceptions.dart';

/// Interceptor para convertir errores de Dio en excepciones personalizadas
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const TimeoutException('La solicitud tardó demasiado');
        break;

      case DioExceptionType.connectionError:
        exception = const NetworkException(
          'Error de conexión. Verifica tu internet',
        );
        break;

      case DioExceptionType.badResponse:
        exception = _handleBadResponse(err.response);
        break;

      case DioExceptionType.cancel:
        exception = const ServerException(
          message: 'Solicitud cancelada',
        );
        break;

      case DioExceptionType.unknown:
        if (err.error.toString().contains('SocketException')) {
          exception = const NetworkException(
            'Sin conexión a internet',
          );
        } else {
          exception = UnexpectedException(
            message: 'Error inesperado',
            originalException: err.error,
          );
        }
        break;

      default:
        exception = UnexpectedException(
          message: 'Error desconocido',
          originalException: err,
        );
    }

    // Reemplazar el error original con nuestra excepción personalizada
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  /// Maneja errores de respuesta HTTP (4xx, 5xx)
  Exception _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerException(message: 'Respuesta nula del servidor');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    
    // Extraer mensaje de error del response
    String message = 'Error del servidor';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        // Bad Request
        return BadRequestException(
          message: message,
          errors: data is Map<String, dynamic> ? data : null,
        );

      case 401:
        // Unauthorized
        return UnauthorizedException(message);

      case 403:
        // Forbidden
        return ForbiddenException(message);

      case 404:
        // Not Found
        return NotFoundException(message);

      case 409:
        // Conflict - Usuario ya existe
        return UserAlreadyExistsException(message);

      case 422:
        // Unprocessable Entity - Validation Error
        return ValidationException(
          message: message,
          fieldErrors: _extractFieldErrors(data),
        );

      case 429:
        // Too Many Requests
        return const ServerException(
          message: 'Demasiadas solicitudes. Intenta más tarde',
        );

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        // Server Errors
        return ServerException(
          message: 'Error del servidor. Por favor intenta más tarde',
          statusCode: statusCode,
        );

      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
    }
  }

  /// Extrae errores de campos del response de validación
  Map<String, String>? _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    
    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return null;

    final fieldErrors = <String, String>{};
    
    for (final entry in errors.entries) {
      if (entry.value is List && (entry.value as List).isNotEmpty) {
        fieldErrors[entry.key] = (entry.value as List).first.toString();
      } else if (entry.value is String) {
        fieldErrors[entry.key] = entry.value;
      }
    }

    return fieldErrors.isEmpty ? null : fieldErrors;
  }
}

