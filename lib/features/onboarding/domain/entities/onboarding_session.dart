import 'package:equatable/equatable.dart';

/// Sesión de onboarding conversacional
class OnboardingSession extends Equatable {
  final String id;
  final String status;
  final int completenessScore;
  final DateTime? completedAt;

  const OnboardingSession({
    required this.id,
    required this.status,
    required this.completenessScore,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, status, completenessScore, completedAt];
}

