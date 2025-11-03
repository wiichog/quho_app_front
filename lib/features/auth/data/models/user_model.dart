import 'package:json_annotation/json_annotation.dart';
import 'package:quho_app/features/auth/domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.profilePicture,
    required super.plan,
    required super.onboardingCompleted,
    required super.emailVerified,
    required super.level,
    required super.points,
    required super.createdAt,
    super.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      print('👤 UserModel: Parseando usuario...');
      print('👤 UserModel: Keys disponibles: ${json.keys.toList()}');
      
      // ID puede venir como int o String
      final id = json['id'] is int 
          ? (json['id'] as int).toString()
          : json['id'] as String;
      print('👤 UserModel: id = $id (tipo: ${id.runtimeType})');
      
      final email = json['email'] as String;
      print('👤 UserModel: email = $email');
      
      // El backend puede no enviar first_name y last_name en login
      // Usar username como fallback o valores por defecto
      String firstName;
      if (json['first_name'] != null) {
        firstName = json['first_name'] as String;
      } else if (json['username'] != null) {
        final username = json['username'] as String;
        firstName = username.split('+').first;
      } else {
        firstName = 'Usuario';
      }
      print('👤 UserModel: first_name = $firstName');
      
      final lastName = json['last_name'] as String? ?? 
                       (json['username'] as String?) ?? 
                       '';
      print('👤 UserModel: last_name = $lastName');
      
      final phone = json['phone'] as String?;
      print('👤 UserModel: phone = $phone');
      
      final profilePicture = json['profile_picture'] as String?;
      print('👤 UserModel: profile_picture = $profilePicture');
      
      final plan = json['plan'] as String? ?? 'free';
      print('👤 UserModel: plan = $plan');
      
      // El backend envía 'onboarding_status' que es un string ('complete', 'incomplete', etc.)
      // Necesitamos convertirlo a bool
      final onboardingStatusStr = json['onboarding_status'] as String? ?? 'incomplete';
      final onboardingCompleted = onboardingStatusStr == 'complete' || 
                                  onboardingStatusStr == 'functional' ||
                                  (json['onboarding_completed'] as bool? ?? false);
      print('👤 UserModel: onboarding_status = $onboardingStatusStr -> completed = $onboardingCompleted');
      
      final emailVerified = json['email_verified'] as bool? ?? false;
      print('👤 UserModel: email_verified = $emailVerified');
      
      final level = json['level'] as int? ?? 1;
      print('👤 UserModel: level = $level');
      
      final points = json['points'] as int? ?? 0;
      print('👤 UserModel: points = $points');
      
      // created_at puede no venir en login, usar fecha actual como fallback
      final createdAtStr = json['created_at'] as String?;
      final createdAt = createdAtStr != null
          ? DateTime.parse(createdAtStr)
          : DateTime.now();
      print('👤 UserModel: created_at = $createdAt');
      
      final lastLoginStr = json['last_login'] as String?;
      final lastLogin = lastLoginStr != null
          ? DateTime.parse(lastLoginStr)
          : null;
      print('👤 UserModel: last_login = $lastLogin');
      
      final user = UserModel(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        profilePicture: profilePicture,
        plan: plan,
        onboardingCompleted: onboardingCompleted,
        emailVerified: emailVerified,
        level: level,
        points: points,
        createdAt: createdAt,
        lastLogin: lastLogin,
      );
      
      print('✅ UserModel: Parseado correctamente');
      return user;
    } catch (e, stackTrace) {
      print('❌ UserModel: Error al parsear - $e');
      print('❌ UserModel: StackTrace: $stackTrace');
      print('❌ UserModel: JSON recibido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_picture': profilePicture,
      'plan': plan,
      'onboarding_completed': onboardingCompleted,
      'email_verified': emailVerified,
      'level': level,
      'points': points,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Convierte de entidad User a UserModel
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      profilePicture: user.profilePicture,
      plan: user.plan,
      onboardingCompleted: user.onboardingCompleted,
      emailVerified: user.emailVerified,
      level: user.level,
      points: user.points,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
    );
  }

  /// Convierte a entidad User
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      profilePicture: profilePicture,
      plan: plan,
      onboardingCompleted: onboardingCompleted,
      emailVerified: emailVerified,
      level: level,
      points: points,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }
}

