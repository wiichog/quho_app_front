import 'package:equatable/equatable.dart';

/// Mensaje de la conversación de onboarding
class OnboardingMessage extends Equatable {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;

  const OnboardingMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  @override
  List<Object?> get props => [id, role, content, createdAt];
}

