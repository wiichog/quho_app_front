import 'package:dartz/dartz.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/errors/failures.dart';
import 'package:quho_app/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:quho_app/features/onboarding/data/models/onboarding_message_model.dart';
import 'package:quho_app/features/onboarding/data/models/onboarding_session_model.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_message.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_session.dart';
import 'package:quho_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Implementación del repositorio del Onboarding
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> startSession() async {
    try {
      final result = await remoteDataSource.startSession();
      
      // Extraer sesión y mensaje inicial
      final session = OnboardingSessionModel.fromJson(result);
      final welcomeMessage = result['message'] as String? ?? '';
      
      return Right({
        'session': session.toEntity(),
        'message': welcomeMessage,
      });
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al iniciar onboarding: $e'));
    }
  }

  @override
  Future<Either<Failure, OnboardingMessage>> sendMessage(String message) async {
    try {
      final result = await remoteDataSource.sendMessage(message);
      
      // Extraer la respuesta del asistente
      final responseMessage = OnboardingMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: result['response'] as String? ?? result['message'] as String? ?? '',
        createdAt: DateTime.now(),
      );
      
      return Right(responseMessage.toEntity());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al enviar mensaje: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatus() async {
    try {
      final result = await remoteDataSource.getStatus();
      
      // Parsear sesión
      final session = OnboardingSessionModel.fromJson(result);
      
      // Parsear mensajes del historial
      final conversationHistory = result['conversation_history'] as List<dynamic>? ?? [];
      final messages = conversationHistory.map((msg) {
        return OnboardingMessageModel.fromJson(msg as Map<String, dynamic>).toEntity();
      }).toList();
      
      return Right({
        'session': session.toEntity(),
        'messages': messages,
      });
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al obtener estado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      await remoteDataSource.completeOnboarding();
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error al completar onboarding: $e'));
    }
  }
}

