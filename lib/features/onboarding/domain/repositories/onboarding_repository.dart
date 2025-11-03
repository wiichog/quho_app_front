import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_message.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_session.dart';

/// Repositorio del Onboarding
abstract class OnboardingRepository {
  /// Iniciar sesión de onboarding - retorna sesión y mensaje inicial
  Future<Either<Failure, Map<String, dynamic>>> startSession();

  /// Enviar mensaje y obtener respuesta
  Future<Either<Failure, OnboardingMessage>> sendMessage(String message);

  /// Obtener estado actual con historial de mensajes
  Future<Either<Failure, Map<String, dynamic>>> getStatus();

  /// Completar onboarding
  Future<Either<Failure, void>> completeOnboarding();
}

