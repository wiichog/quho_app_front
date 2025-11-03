import 'package:dio/dio.dart';
import 'package:quho_app/core/constants/app_constants.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/core/network/api_client.dart';
import 'package:quho_app/features/onboarding/data/models/onboarding_message_model.dart';
import 'package:quho_app/features/onboarding/data/models/onboarding_session_model.dart';

/// Interfaz del datasource remoto del Onboarding
abstract class OnboardingRemoteDataSource {
  Future<Map<String, dynamic>> startSession();
  Future<Map<String, dynamic>> sendMessage(String message);
  Future<Map<String, dynamic>> getStatus();
  Future<void> completeOnboarding();
}

/// Implementación del datasource remoto del Onboarding
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final ApiClient apiClient;

  OnboardingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> startSession() async {
    try {
      print('[ONBOARDING] Iniciando sesión de onboarding...');
      final response = await apiClient.post('/onboarding/start/');

      print('[ONBOARDING] Sesión iniciada: ${response.data}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('[ERROR] DioException al iniciar sesión: ${e.message}');
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al iniciar onboarding',
        originalException: e,
      );
    } catch (e) {
      print('[ERROR] Exception al iniciar sesión: $e');
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      print('[ONBOARDING_DS] 🔵 Enviando mensaje al API...');
      print('[ONBOARDING_DS] 📤 Longitud del mensaje: ${message.length} caracteres');
      print('[ONBOARDING_DS] 📤 Primeros 200 chars: ${message.substring(0, message.length > 200 ? 200 : message.length)}...');
      
      final response = await apiClient.post(
        '/onboarding/conversation/',
        data: {'message': message},
      );

      print('[ONBOARDING_DS] ✅ Respuesta recibida');
      print('[ONBOARDING_DS] 📦 Status code: ${response.statusCode}');
      print('[ONBOARDING_DS] 📦 Data type: ${response.data.runtimeType}');
      print('[ONBOARDING_DS] 📦 Data: ${response.data}');
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('[ONBOARDING_DS] ❌ DioException al enviar mensaje: ${e.type}');
      print('[ONBOARDING_DS] ❌ Message: ${e.message}');
      print('[ONBOARDING_DS] ❌ Error: ${e.error}');
      print('[ONBOARDING_DS] ❌ Error type: ${e.error.runtimeType}');
      print('[ONBOARDING_DS] ❌ Response: ${e.response?.data}');
      print('[ONBOARDING_DS] ❌ Status code: ${e.response?.statusCode}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al enviar mensaje',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('[ONBOARDING_DS] ❌ Exception inesperada al enviar: $e');
      print('[ONBOARDING_DS] ❌ Tipo: ${e.runtimeType}');
      print('[ONBOARDING_DS] ❌ Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al enviar mensaje',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getStatus() async {
    try {
      print('[ONBOARDING_DS] 🔵 Obteniendo estado...');
      final response = await apiClient.get('/onboarding/status/');

      print('[ONBOARDING_DS] ✅ Respuesta recibida');
      print('[ONBOARDING_DS] 📦 Status code: ${response.statusCode}');
      print('[ONBOARDING_DS] 📦 Data type: ${response.data.runtimeType}');
      print('[ONBOARDING_DS] 📦 Data completo: ${response.data}');
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        print('[ONBOARDING_DS] 📦 Keys: ${data.keys.toList()}');
        
        // Verificar cada campo esperado
        print('[ONBOARDING_DS] 📦 session_id: ${data['session_id']} (${data['session_id'].runtimeType})');
        print('[ONBOARDING_DS] 📦 id: ${data['id']} (${data['id']?.runtimeType})');
        print('[ONBOARDING_DS] 📦 status: ${data['status']} (${data['status']?.runtimeType})');
        print('[ONBOARDING_DS] 📦 completeness: ${data['completeness']} (${data['completeness']?.runtimeType})');
        print('[ONBOARDING_DS] 📦 completed_at: ${data['completed_at']} (${data['completed_at']?.runtimeType})');
        print('[ONBOARDING_DS] 📦 conversation_history: ${data['conversation_history']?.runtimeType}');
        
        return data;
      }
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('[ONBOARDING_DS] ❌ DioException: ${e.type}');
      print('[ONBOARDING_DS] ❌ Message: ${e.message}');
      print('[ONBOARDING_DS] ❌ Error: ${e.error}');
      print('[ONBOARDING_DS] ❌ Response: ${e.response?.data}');
      print('[ONBOARDING_DS] ❌ Status code: ${e.response?.statusCode}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al obtener estado',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('[ONBOARDING_DS] ❌ Exception inesperada: $e');
      print('[ONBOARDING_DS] ❌ Tipo: ${e.runtimeType}');
      print('[ONBOARDING_DS] ❌ Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado',
        originalException: e,
      );
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      print('[ONBOARDING_DS] 🔵 Completando onboarding...');
      
      // El API requiere enviar {"accepted": true} en el body
      final response = await apiClient.post(
        '/onboarding/complete/',
        data: {'accepted': true},
      );
      
      print('[ONBOARDING_DS] ✅ Onboarding completado exitosamente');
      print('[ONBOARDING_DS] 📦 Status code: ${response.statusCode}');
      print('[ONBOARDING_DS] 📦 Response data type: ${response.data.runtimeType}');
      print('[ONBOARDING_DS] 📦 Response data: ${response.data}');
    } on DioException catch (e) {
      print('[ONBOARDING_DS] ❌ DioException al completar: ${e.type}');
      print('[ONBOARDING_DS] ❌ Message: ${e.message}');
      print('[ONBOARDING_DS] ❌ Error: ${e.error}');
      print('[ONBOARDING_DS] ❌ Error type: ${e.error.runtimeType}');
      print('[ONBOARDING_DS] ❌ Response data: ${e.response?.data}');
      print('[ONBOARDING_DS] ❌ Response data type: ${e.response?.data.runtimeType}');
      print('[ONBOARDING_DS] ❌ Status code: ${e.response?.statusCode}');
      
      if (e.error is Exception) {
        throw e.error as Exception;
      }
      throw UnexpectedException(
        message: 'Error al completar onboarding',
        originalException: e,
      );
    } catch (e, stackTrace) {
      print('[ONBOARDING_DS] ❌ Exception inesperada al completar: $e');
      print('[ONBOARDING_DS] ❌ Tipo: ${e.runtimeType}');
      print('[ONBOARDING_DS] ❌ Stack trace: $stackTrace');
      throw UnexpectedException(
        message: 'Error inesperado al completar',
        originalException: e,
      );
    }
  }
}

