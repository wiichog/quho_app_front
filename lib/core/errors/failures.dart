import 'package:equatable/equatable.dart';

/// Clase base para todos los errores en QUHO
/// Usa el patrón Either<Failure, Success> con dartz
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ========== NETWORK FAILURES ==========

class ServerFailure extends Failure {
  const ServerFailure([
    String message = 'Error del servidor. Por favor intenta más tarde.',
  ]) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'Error de conexión. Verifica tu internet.',
  ]) : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([
    String message = 'La solicitud tardó demasiado. Intenta de nuevo.',
  ]) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    String message = 'Sesión expirada. Por favor inicia sesión de nuevo.',
  ]) : super(message);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    String message = 'No tienes permiso para realizar esta acción.',
  ]) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    String message = 'Recurso no encontrado.',
  ]) : super(message);
}

class BadRequestFailure extends Failure {
  const BadRequestFailure([
    String message = 'Solicitud inválida.',
  ]) : super(message);
}

// ========== CACHE FAILURES ==========

class CacheFailure extends Failure {
  const CacheFailure([
    String message = 'Error al acceder al almacenamiento local.',
  ]) : super(message);
}

class CacheNotFoundFailure extends Failure {
  const CacheNotFoundFailure([
    String message = 'Datos no encontrados en caché.',
  ]) : super(message);
}

// ========== VALIDATION FAILURES ==========

class ValidationFailure extends Failure {
  const ValidationFailure([
    String message = 'Datos inválidos.',
  ]) : super(message);
}

class InvalidEmailFailure extends ValidationFailure {
  const InvalidEmailFailure([
    String message = 'Email inválido.',
  ]) : super(message);
}

class InvalidPasswordFailure extends ValidationFailure {
  const InvalidPasswordFailure([
    String message = 'Contraseña inválida.',
  ]) : super(message);
}

class InvalidAmountFailure extends ValidationFailure {
  const InvalidAmountFailure([
    String message = 'Monto inválido.',
  ]) : super(message);
}

// ========== AUTH FAILURES ==========

class AuthFailure extends Failure {
  const AuthFailure([
    String message = 'Error de autenticación.',
  ]) : super(message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    String message = 'Email o contraseña incorrectos.',
  ]) : super(message);
}

class UserAlreadyExistsFailure extends AuthFailure {
  const UserAlreadyExistsFailure([
    String message = 'Este email ya está registrado.',
  ]) : super(message);
}

class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure([
    String message = 'Por favor verifica tu email.',
  ]) : super(message);
}

class AccountDisabledFailure extends AuthFailure {
  const AccountDisabledFailure([
    String message = 'Tu cuenta ha sido deshabilitada.',
  ]) : super(message);
}

// ========== BIOMETRIC FAILURES ==========

class BiometricFailure extends Failure {
  const BiometricFailure([
    String message = 'Error de autenticación biométrica.',
  ]) : super(message);
}

class BiometricNotAvailableFailure extends BiometricFailure {
  const BiometricNotAvailableFailure([
    String message = 'Autenticación biométrica no disponible.',
  ]) : super(message);
}

class BiometricNotEnrolledFailure extends BiometricFailure {
  const BiometricNotEnrolledFailure([
    String message = 'No hay biometría configurada en el dispositivo.',
  ]) : super(message);
}

// ========== FILE/STORAGE FAILURES ==========

class StorageFailure extends Failure {
  const StorageFailure([
    String message = 'Error al acceder al almacenamiento.',
  ]) : super(message);
}

class FileNotFoundFailure extends StorageFailure {
  const FileNotFoundFailure([
    String message = 'Archivo no encontrado.',
  ]) : super(message);
}

class InsufficientStorageFailure extends StorageFailure {
  const InsufficientStorageFailure([
    String message = 'Espacio de almacenamiento insuficiente.',
  ]) : super(message);
}

// ========== PERMISSION FAILURES ==========

class PermissionFailure extends Failure {
  const PermissionFailure([
    String message = 'Permiso denegado.',
  ]) : super(message);
}

class LocationPermissionFailure extends PermissionFailure {
  const LocationPermissionFailure([
    String message = 'Permiso de ubicación denegado.',
  ]) : super(message);
}

class CameraPermissionFailure extends PermissionFailure {
  const CameraPermissionFailure([
    String message = 'Permiso de cámara denegado.',
  ]) : super(message);
}

class NotificationPermissionFailure extends PermissionFailure {
  const NotificationPermissionFailure([
    String message = 'Permiso de notificaciones denegado.',
  ]) : super(message);
}

// ========== BUSINESS LOGIC FAILURES ==========

class InsufficientFundsFailure extends Failure {
  const InsufficientFundsFailure([
    String message = 'Fondos insuficientes.',
  ]) : super(message);
}

class BudgetExceededFailure extends Failure {
  const BudgetExceededFailure([
    String message = 'Presupuesto excedido.',
  ]) : super(message);
}

class LimitReachedFailure extends Failure {
  const LimitReachedFailure([
    String message = 'Límite alcanzado.',
  ]) : super(message);
}

class SubscriptionRequiredFailure extends Failure {
  const SubscriptionRequiredFailure([
    String message = 'Esta función requiere una suscripción Premium.',
  ]) : super(message);
}

// ========== AI FAILURES ==========

class AIFailure extends Failure {
  const AIFailure([
    String message = 'Error al procesar la solicitud de IA.',
  ]) : super(message);
}

class AIQuotaExceededFailure extends AIFailure {
  const AIQuotaExceededFailure([
    String message = 'Has alcanzado tu límite mensual de consultas de IA.',
  ]) : super(message);
}

class AIUnavailableFailure extends AIFailure {
  const AIUnavailableFailure([
    String message = 'El servicio de IA no está disponible en este momento.',
  ]) : super(message);
}

// ========== PAYMENT FAILURES ==========

class PaymentFailure extends Failure {
  const PaymentFailure([
    String message = 'Error al procesar el pago.',
  ]) : super(message);
}

class CardDeclinedFailure extends PaymentFailure {
  const CardDeclinedFailure([
    String message = 'Tarjeta rechazada.',
  ]) : super(message);
}

class InsufficientFundsForPaymentFailure extends PaymentFailure {
  const InsufficientFundsForPaymentFailure([
    String message = 'Fondos insuficientes para el pago.',
  ]) : super(message);
}

// ========== GENERIC FAILURE ==========

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    String message = 'Algo salió mal. Por favor intenta de nuevo.',
  ]) : super(message);
}

