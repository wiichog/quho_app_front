import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Resultado de autenticación social
class SocialAuthResult {
  final String provider; // 'google', 'apple', 'facebook'
  final String? accessToken;
  final String? idToken;
  final String? authorizationCode;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;

  SocialAuthResult({
    required this.provider,
    this.accessToken,
    this.idToken,
    this.authorizationCode,
    this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
  });
}

/// Servicio para manejar autenticación social con Google, Apple y Facebook
class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in con Google
  Future<SocialAuthResult?> signInWithGoogle() async {
    try {
      print('🔵 [SOCIAL_AUTH] Iniciando Google Sign In...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('⚠️ [SOCIAL_AUTH] Usuario canceló Google Sign In');
        return null;
      }

      print('✅ [SOCIAL_AUTH] Usuario autenticado: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      return SocialAuthResult(
        provider: 'google',
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
        email: googleUser.email,
        firstName: googleUser.displayName?.split(' ').first,
        lastName: googleUser.displayName?.split(' ').skip(1).join(' '),
        profilePictureUrl: googleUser.photoUrl,
      );
    } catch (e, stackTrace) {
      print('❌ [SOCIAL_AUTH] Error en Google Sign In: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sign in con Apple
  Future<SocialAuthResult?> signInWithApple() async {
    try {
      print('🍎 [SOCIAL_AUTH] Iniciando Apple Sign In...');

      if (!Platform.isIOS && !Platform.isMacOS) {
        print('⚠️ [SOCIAL_AUTH] Apple Sign In solo disponible en iOS/macOS');
        throw UnsupportedError('Apple Sign In solo disponible en iOS/macOS');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('✅ [SOCIAL_AUTH] Apple Sign In exitoso');

      return SocialAuthResult(
        provider: 'apple',
        idToken: credential.identityToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );
    } catch (e, stackTrace) {
      print('❌ [SOCIAL_AUTH] Error en Apple Sign In: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sign in con Facebook
  Future<SocialAuthResult?> signInWithFacebook() async {
    try {
      print('📘 [SOCIAL_AUTH] Iniciando Facebook Sign In...');

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        print('✅ [SOCIAL_AUTH] Facebook login exitoso');

        // Obtener datos del usuario
        final userData = await FacebookAuth.instance.getUserData();
        
        return SocialAuthResult(
          provider: 'facebook',
          accessToken: result.accessToken?.tokenString,
          email: userData['email'],
          firstName: userData['first_name'],
          lastName: userData['last_name'],
          profilePictureUrl: userData['picture']?['data']?['url'],
        );
      } else if (result.status == LoginStatus.cancelled) {
        print('⚠️ [SOCIAL_AUTH] Usuario canceló Facebook Sign In');
        return null;
      } else {
        print('❌ [SOCIAL_AUTH] Error en Facebook Sign In: ${result.message}');
        throw Exception(result.message ?? 'Error desconocido en Facebook login');
      }
    } catch (e, stackTrace) {
      print('❌ [SOCIAL_AUTH] Error en Facebook Sign In: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Cerrar sesión de Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('✅ [SOCIAL_AUTH] Sesión de Google cerrada');
    } catch (e) {
      print('❌ [SOCIAL_AUTH] Error cerrando sesión de Google: $e');
    }
  }

  /// Cerrar sesión de Facebook
  Future<void> signOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
      print('✅ [SOCIAL_AUTH] Sesión de Facebook cerrada');
    } catch (e) {
      print('❌ [SOCIAL_AUTH] Error cerrando sesión de Facebook: $e');
    }
  }

  /// Cerrar todas las sesiones sociales
  Future<void> signOutAll() async {
    await Future.wait([
      signOutGoogle(),
      signOutFacebook(),
    ]);
    print('✅ [SOCIAL_AUTH] Todas las sesiones sociales cerradas');
  }
}

