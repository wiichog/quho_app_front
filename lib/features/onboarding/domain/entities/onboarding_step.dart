import 'package:equatable/equatable.dart';

/// Representa un paso del onboarding conversacional
enum OnboardingStepType {
  welcome,
  income,
  expenses,
  savings,
  completed,
}

/// Entidad que representa el estado actual del flujo de onboarding
class OnboardingStep extends Equatable {
  final OnboardingStepType type;
  final String question;
  final bool isOptional;
  final String? userResponse;

  const OnboardingStep({
    required this.type,
    required this.question,
    this.isOptional = false,
    this.userResponse,
  });

  OnboardingStep copyWith({
    OnboardingStepType? type,
    String? question,
    bool? isOptional,
    String? userResponse,
  }) {
    return OnboardingStep(
      type: type ?? this.type,
      question: question ?? this.question,
      isOptional: isOptional ?? this.isOptional,
      userResponse: userResponse ?? this.userResponse,
    );
  }

  @override
  List<Object?> get props => [type, question, isOptional, userResponse];
}

