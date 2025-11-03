/// Excepciones personalizadas para QUHO
/// Las excepciones son convertidas a Failures en el repositorio

// ========== SERVER EXCEPTIONS ==========

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([
    this.message = 'Error de conexión',
  ]);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;

  const TimeoutException([
    this.message = 'Timeout',
  ]);

  @override
  String toString() => 'TimeoutException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([
    this.message = 'No autorizado',
  ]);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;

  const ForbiddenException([
    this.message = 'Prohibido',
  ]);

  @override
  String toString() => 'ForbiddenException: $message';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException([
    this.message = 'No encontrado',
  ]);

  @override
  String toString() => 'NotFoundException: $message';
}

class BadRequestException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  const BadRequestException({
    this.message = 'Solicitud inválida',
    this.errors,
  });

  @override
  String toString() => 'BadRequestException: $message (Errors: $errors)';
}

// ========== CACHE EXCEPTIONS ==========

class CacheException implements Exception {
  final String message;

  const CacheException([
    this.message = 'Error de caché',
  ]);

  @override
  String toString() => 'CacheException: $message';
}

class CacheNotFoundException implements Exception {
  final String message;

  const CacheNotFoundException([
    this.message = 'No encontrado en caché',
  ]);

  @override
  String toString() => 'CacheNotFoundException: $message';
}

// ========== VALIDATION EXCEPTIONS ==========

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required this.message,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message (Fields: $fieldErrors)';
}

// ========== AUTH EXCEPTIONS ==========

class AuthException implements Exception {
  final String message;

  const AuthException([
    this.message = 'Error de autenticación',
  ]);

  @override
  String toString() => 'AuthException: $message';
}

class InvalidCredentialsException implements Exception {
  final String message;

  const InvalidCredentialsException([
    this.message = 'Credenciales inválidas',
  ]);

  @override
  String toString() => 'InvalidCredentialsException: $message';
}

class UserAlreadyExistsException implements Exception {
  final String message;

  const UserAlreadyExistsException([
    this.message = 'Usuario ya existe',
  ]);

  @override
  String toString() => 'UserAlreadyExistsException: $message';
}

class EmailNotVerifiedException implements Exception {
  final String message;

  const EmailNotVerifiedException([
    this.message = 'Email no verificado',
  ]);

  @override
  String toString() => 'EmailNotVerifiedException: $message';
}

class AccountDisabledException implements Exception {
  final String message;

  const AccountDisabledException([
    this.message = 'Cuenta deshabilitada',
  ]);

  @override
  String toString() => 'AccountDisabledException: $message';
}

// ========== BIOMETRIC EXCEPTIONS ==========

class BiometricException implements Exception {
  final String message;

  const BiometricException([
    this.message = 'Error biométrico',
  ]);

  @override
  String toString() => 'BiometricException: $message';
}

class BiometricNotAvailableException implements Exception {
  final String message;

  const BiometricNotAvailableException([
    this.message = 'Biométrico no disponible',
  ]);

  @override
  String toString() => 'BiometricNotAvailableException: $message';
}

class BiometricNotEnrolledException implements Exception {
  final String message;

  const BiometricNotEnrolledException([
    this.message = 'Biométrico no configurado',
  ]);

  @override
  String toString() => 'BiometricNotEnrolledException: $message';
}

// ========== FILE/STORAGE EXCEPTIONS ==========

class StorageException implements Exception {
  final String message;

  const StorageException([
    this.message = 'Error de almacenamiento',
  ]);

  @override
  String toString() => 'StorageException: $message';
}

class FileNotFoundException implements Exception {
  final String message;

  const FileNotFoundException([
    this.message = 'Archivo no encontrado',
  ]);

  @override
  String toString() => 'FileNotFoundException: $message';
}

class InsufficientStorageException implements Exception {
  final String message;

  const InsufficientStorageException([
    this.message = 'Almacenamiento insuficiente',
  ]);

  @override
  String toString() => 'InsufficientStorageException: $message';
}

// ========== PERMISSION EXCEPTIONS ==========

class PermissionException implements Exception {
  final String message;

  const PermissionException([
    this.message = 'Permiso denegado',
  ]);

  @override
  String toString() => 'PermissionException: $message';
}

// ========== BUSINESS LOGIC EXCEPTIONS ==========

class InsufficientFundsException implements Exception {
  final String message;

  const InsufficientFundsException([
    this.message = 'Fondos insuficientes',
  ]);

  @override
  String toString() => 'InsufficientFundsException: $message';
}

class BudgetExceededException implements Exception {
  final String message;

  const BudgetExceededException([
    this.message = 'Presupuesto excedido',
  ]);

  @override
  String toString() => 'BudgetExceededException: $message';
}

class LimitReachedException implements Exception {
  final String message;

  const LimitReachedException([
    this.message = 'Límite alcanzado',
  ]);

  @override
  String toString() => 'LimitReachedException: $message';
}

class SubscriptionRequiredException implements Exception {
  final String message;

  const SubscriptionRequiredException([
    this.message = 'Suscripción requerida',
  ]);

  @override
  String toString() => 'SubscriptionRequiredException: $message';
}

// ========== AI EXCEPTIONS ==========

class AIException implements Exception {
  final String message;

  const AIException([
    this.message = 'Error de IA',
  ]);

  @override
  String toString() => 'AIException: $message';
}

class AIQuotaExceededException implements Exception {
  final String message;

  const AIQuotaExceededException([
    this.message = 'Cuota de IA excedida',
  ]);

  @override
  String toString() => 'AIQuotaExceededException: $message';
}

// ========== PAYMENT EXCEPTIONS ==========

class PaymentException implements Exception {
  final String message;

  const PaymentException([
    this.message = 'Error de pago',
  ]);

  @override
  String toString() => 'PaymentException: $message';
}

class CardDeclinedException implements Exception {
  final String message;

  const CardDeclinedException([
    this.message = 'Tarjeta rechazada',
  ]);

  @override
  String toString() => 'CardDeclinedException: $message';
}

// ========== GENERIC EXCEPTION ==========

class UnexpectedException implements Exception {
  final String message;
  final dynamic originalException;

  const UnexpectedException({
    required this.message,
    this.originalException,
  });

  @override
  String toString() => 
      'UnexpectedException: $message (Original: $originalException)';
}

