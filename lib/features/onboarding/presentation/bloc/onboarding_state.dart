import 'package:equatable/equatable.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_message.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_session.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  final String message;
  
  const OnboardingLoading({this.message = 'Cargando...'});
  
  @override
  List<Object?> get props => [message];
}

class OnboardingSessionStarted extends OnboardingState {
  final OnboardingSession session;
  final List<OnboardingMessage> messages;

  const OnboardingSessionStarted({
    required this.session,
    required this.messages,
  });

  @override
  List<Object?> get props => [session, messages];
}

class OnboardingMessageSending extends OnboardingState {
  final OnboardingSession session;
  final List<OnboardingMessage> messages;

  const OnboardingMessageSending({
    required this.session,
    required this.messages,
  });

  @override
  List<Object?> get props => [session, messages];
}

class OnboardingConversation extends OnboardingState {
  final OnboardingSession session;
  final List<OnboardingMessage> messages;

  const OnboardingConversation({
    required this.session,
    required this.messages,
  });

  @override
  List<Object?> get props => [session, messages];
}

class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

class OnboardingSaved extends OnboardingState {
  const OnboardingSaved();
}

class OnboardingResuming extends OnboardingState {
  const OnboardingResuming();
}

