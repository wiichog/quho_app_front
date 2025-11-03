import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quho_app/core/constants/app_constants.dart';
import 'package:quho_app/core/errors/exceptions.dart';
import 'package:quho_app/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Interfaz del datasource local de autenticación
abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> clearSession();

  Future<bool> hasActiveSession();
}

/// Implementación del datasource local de autenticación
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const String _cachedUserKey = 'cached_user';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
      );
      await secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
    } catch (e) {
      throw CacheException('Error al guardar tokens: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await secureStorage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      throw CacheException('Error al obtener access token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException('Error al obtener refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      // Guardar usuario completo en SharedPreferences (datos no sensibles)
      final userJson = json.encode(user.toJson());
      await sharedPreferences.setString(_cachedUserKey, userJson);

      // Guardar datos específicos en secure storage
      await secureStorage.write(
        key: AppConstants.userIdKey,
        value: user.id,
      );
      await secureStorage.write(
        key: AppConstants.userEmailKey,
        value: user.email,
      );
      await secureStorage.write(
        key: AppConstants.userNameKey,
        value: user.fullName,
      );

      // Guardar flag de onboarding
      await sharedPreferences.setBool(
        AppConstants.onboardingCompletedKey,
        user.onboardingCompleted,
      );
    } catch (e) {
      throw CacheException('Error al guardar usuario: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = sharedPreferences.getString(_cachedUserKey);
      if (userJson == null) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException('Error al obtener usuario: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      // Limpiar tokens
      await secureStorage.delete(key: AppConstants.accessTokenKey);
      await secureStorage.delete(key: AppConstants.refreshTokenKey);
      await secureStorage.delete(key: AppConstants.userIdKey);
      await secureStorage.delete(key: AppConstants.userEmailKey);
      await secureStorage.delete(key: AppConstants.userNameKey);

      // Limpiar usuario en caché
      await sharedPreferences.remove(_cachedUserKey);
      await sharedPreferences.remove(AppConstants.onboardingCompletedKey);
    } catch (e) {
      throw CacheException('Error al limpiar sesión: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasActiveSession() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      return accessToken != null && refreshToken != null;
    } catch (e) {
      return false;
    }
  }
}

