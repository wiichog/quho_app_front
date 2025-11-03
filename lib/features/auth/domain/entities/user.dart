import 'package:equatable/equatable.dart';

/// Entidad de Usuario en el dominio
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profilePicture;
  final String plan; // 'free' | 'premium'
  final bool onboardingCompleted;
  final bool emailVerified;
  final int level;
  final int points;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profilePicture,
    required this.plan,
    required this.onboardingCompleted,
    required this.emailVerified,
    required this.level,
    required this.points,
    required this.createdAt,
    this.lastLogin,
  });

  /// Nombre completo del usuario
  String get fullName => '$firstName $lastName';

  /// Iniciales del usuario
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Es usuario premium
  bool get isPremium => plan == 'premium';

  /// Es usuario free
  bool get isFree => plan == 'free';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        profilePicture,
        plan,
        onboardingCompleted,
        emailVerified,
        level,
        points,
        createdAt,
        lastLogin,
      ];
}

