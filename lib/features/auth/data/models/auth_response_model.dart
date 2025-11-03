import 'package:json_annotation/json_annotation.dart';
import 'package:quho_app/features/auth/data/models/user_model.dart';
import 'package:quho_app/features/auth/domain/entities/auth_response.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔑 AuthResponseModel: Parseando respuesta...');
      print('🔑 AuthResponseModel: Keys disponibles: ${json.keys.toList()}');
      
      final access = json['access'] as String?;
      if (access == null) {
        throw Exception('Campo "access" no encontrado en la respuesta');
      }
      print('🔑 AuthResponseModel: access token encontrado (${access.length} caracteres)');
      
      final refresh = json['refresh'] as String?;
      if (refresh == null) {
        throw Exception('Campo "refresh" no encontrado en la respuesta');
      }
      print('🔑 AuthResponseModel: refresh token encontrado (${refresh.length} caracteres)');
      
      final userJson = json['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        throw Exception('Campo "user" no encontrado en la respuesta');
      }
      print('🔑 AuthResponseModel: user encontrado, parseando...');
      
      final user = UserModel.fromJson(userJson);
      
      print('✅ AuthResponseModel: Parseado correctamente');
      return AuthResponseModel(
        accessToken: access,
        refreshToken: refresh,
        user: user,
      );
    } catch (e, stackTrace) {
      print('❌ AuthResponseModel: Error al parsear - $e');
      print('❌ AuthResponseModel: StackTrace: $stackTrace');
      print('❌ AuthResponseModel: JSON recibido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
      'user': (user as UserModel).toJson(),
    };
  }

  AuthResponse toEntity() {
    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }
}

