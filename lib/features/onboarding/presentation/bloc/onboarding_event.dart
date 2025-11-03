import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class StartOnboardingEvent extends OnboardingEvent {
  const StartOnboardingEvent();
}

class SendMessageEvent extends OnboardingEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class CompleteOnboardingEvent extends OnboardingEvent {
  const CompleteOnboardingEvent();
}

class SaveAndExitOnboardingEvent extends OnboardingEvent {
  const SaveAndExitOnboardingEvent();
}

class CheckOnboardingStatusEvent extends OnboardingEvent {
  const CheckOnboardingStatusEvent();
}

