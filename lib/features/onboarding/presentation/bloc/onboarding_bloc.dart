import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_message.dart';
import 'package:quho_app/features/onboarding/domain/entities/onboarding_session.dart';
import 'package:quho_app/features/onboarding/domain/services/conversation_flow_service.dart';
import 'package:quho_app/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:quho_app/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import 'package:quho_app/features/onboarding/domain/usecases/send_message_usecase.dart';
import 'package:quho_app/features/onboarding/domain/usecases/start_onboarding_usecase.dart';
import 'package:quho_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:quho_app/features/onboarding/presentation/bloc/onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final StartOnboardingUseCase startOnboardingUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;
  final GetOnboardingStatusUseCase getOnboardingStatusUseCase;
  final ConversationFlowService _conversationFlow = ConversationFlowService();

  OnboardingSession? _currentSession;
  final List<OnboardingMessage> _messages = [];
  int _messageIdCounter = 0;

  OnboardingBloc({
    required this.startOnboardingUseCase,
    required this.sendMessageUseCase,
    required this.completeOnboardingUseCase,
    required this.getOnboardingStatusUseCase,
  }) : super(const OnboardingInitial()) {
    on<StartOnboardingEvent>(_onStartOnboarding);
    on<SendMessageEvent>(_onSendMessage);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
    on<SaveAndExitOnboardingEvent>(_onSaveAndExit);
    on<CheckOnboardingStatusEvent>(_onCheckStatus);
  }

  Future<void> _onStartOnboarding(
    StartOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    print('[ONBOARDING_BLOC] 🔵 Iniciando onboarding con flujo conversacional local');
    emit(const OnboardingLoading(message: 'Iniciando conversación...'));

    final result = await startOnboardingUseCase();

    result.fold(
      (failure) {
        print('[ONBOARDING_BLOC] ❌ Error al iniciar sesión: ${failure.message}');
        emit(OnboardingError(failure.message));
      },
      (data) {
        print('[ONBOARDING_BLOC] ✅ Sesión iniciada en backend');
        _currentSession = data['session'] as OnboardingSession;
        _messages.clear();
        _messageIdCounter = 0;
        _conversationFlow.reset();

        // Usar el mensaje de bienvenida generado localmente
        final welcomeMessage = OnboardingMessage(
          id: '${_messageIdCounter++}',
          role: 'assistant',
          content: _conversationFlow.getWelcomeMessage(),
          createdAt: DateTime.now(),
        );
        _messages.add(welcomeMessage);

        print('[ONBOARDING_BLOC] 📝 Mensaje de bienvenida agregado');
        emit(OnboardingSessionStarted(
          session: _currentSession!,
          messages: List.from(_messages),
        ));
      },
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (_currentSession == null) {
      emit(const OnboardingError('No hay sesión activa'));
      return;
    }

    print('[ONBOARDING_BLOC] 📤 Usuario envió mensaje (procesando localmente)');
    
    // Agregar mensaje del usuario
    final userMessage = OnboardingMessage(
      id: '${_messageIdCounter++}',
      role: 'user',
      content: event.message,
      createdAt: DateTime.now(),
    );
    _messages.add(userMessage);

    emit(OnboardingMessageSending(
      session: _currentSession!,
      messages: List.from(_messages),
    ));

    // Simular pequeño delay para mejor UX
    await Future.delayed(const Duration(milliseconds: 500));

    // Procesar el mensaje localmente con el servicio de flujo
    final assistantResponse = _conversationFlow.processUserMessage(event.message);

    if (assistantResponse != null) {
      print('[ONBOARDING_BLOC] 🤖 Respuesta generada localmente');
      
      // Generar respuesta del asistente localmente
      final assistantMessage = OnboardingMessage(
        id: '${_messageIdCounter++}',
        role: 'assistant',
        content: assistantResponse,
        createdAt: DateTime.now(),
      );
      _messages.add(assistantMessage);

      print('[ONBOARDING_BLOC] 📊 Paso actual: ${_conversationFlow.currentStep}');
      print('[ONBOARDING_BLOC] ✅ Listo para completar: ${_conversationFlow.isReadyToComplete()}');

      emit(OnboardingConversation(
        session: _currentSession!,
        messages: List.from(_messages),
      ));
    } else {
      // Ya no hay más preguntas, el usuario debe completar el onboarding
      print('[ONBOARDING_BLOC] ⚠️ No hay más preguntas, usuario debe completar');
      emit(OnboardingConversation(
        session: _currentSession!,
        messages: List.from(_messages),
      ));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    print('[ONBOARDING_BLOC] 🎯 Completando onboarding');
    
    if (!_conversationFlow.isReadyToComplete()) {
      emit(const OnboardingError(
        'Debes completar todos los pasos antes de finalizar.',
      ));
      return;
    }

    emit(const OnboardingLoading(message: 'Enviando tu información...'));

    print('[ONBOARDING_BLOC] 📦 Información recopilada:');
    print('[ONBOARDING_BLOC] 💰 Ingresos: ${_conversationFlow.incomeResponse?.substring(0, 100)}...');
    print('[ONBOARDING_BLOC] 💳 Gastos: ${_conversationFlow.expensesResponse?.substring(0, 100)}...');
    print('[ONBOARDING_BLOC] 💵 Ahorros: ${_conversationFlow.savingsResponse ?? "No proporcionado"}');

    // PASO 1: Enviar los 3 mensajes del usuario al backend para que se guarden
    print('[ONBOARDING_BLOC] 📤 Enviando mensajes individuales al backend...');
    
    // Enviar ingresos
    if (_conversationFlow.incomeResponse != null) {
      print('[ONBOARDING_BLOC] 📤 Enviando ingresos...');
      final incomeResult = await sendMessageUseCase(_conversationFlow.incomeResponse!);
      if (incomeResult.isLeft()) {
        print('[ONBOARDING_BLOC] ❌ Error enviando ingresos');
        emit(const OnboardingError('Error al enviar información de ingresos'));
        return;
      }
    }
    
    // Enviar gastos
    if (_conversationFlow.expensesResponse != null) {
      print('[ONBOARDING_BLOC] 📤 Enviando gastos...');
      final expensesResult = await sendMessageUseCase(_conversationFlow.expensesResponse!);
      if (expensesResult.isLeft()) {
        print('[ONBOARDING_BLOC] ❌ Error enviando gastos');
        emit(const OnboardingError('Error al enviar información de gastos'));
        return;
      }
    }
    
    // Enviar ahorros
    if (_conversationFlow.savingsResponse != null) {
      print('[ONBOARDING_BLOC] 📤 Enviando ahorros...');
      final savingsResult = await sendMessageUseCase(_conversationFlow.savingsResponse!);
      if (savingsResult.isLeft()) {
        print('[ONBOARDING_BLOC] ❌ Error enviando ahorros');
        emit(const OnboardingError('Error al enviar información de ahorros'));
        return;
      }
    }

    print('[ONBOARDING_BLOC] ✅ Todos los mensajes enviados al backend');
    
    // PASO 2: Completar el onboarding - El backend analizará TODO el historial con Claude
    emit(const OnboardingLoading(message: 'Analizando tu información con IA...'));
    print('[ONBOARDING_BLOC] 🤖 Completando onboarding - Claude analizará todo el historial...');
    
    final completeResult = await completeOnboardingUseCase();

    completeResult.fold(
      (failure) {
        print('[ONBOARDING_BLOC] ❌ Error al completar: ${failure.message}');
        emit(OnboardingError('Error al crear presupuesto: ${failure.message}'));
      },
      (_) {
        print('[ONBOARDING_BLOC] 🎉 Onboarding completado exitosamente');
        emit(const OnboardingCompleted());
      },
    );
  }

  Future<void> _onSaveAndExit(
    SaveAndExitOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    // El progreso ya está guardado en el servidor
    // Solo cambiamos el estado local
    emit(const OnboardingSaved());
  }

  Future<void> _onCheckStatus(
    CheckOnboardingStatusEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingResuming());

    final result = await getOnboardingStatusUseCase();

    result.fold(
      (failure) {
        // No hay sesión previa o hubo error, mostrar pantalla inicial
        print('[ONBOARDING_BLOC] No hay sesión previa o error: ${failure.message}');
        emit(const OnboardingInitial());
      },
      (data) {
        print('[ONBOARDING_BLOC] Sesión previa encontrada');
        // Hay sesión previa, restaurar el estado
        _currentSession = data['session'] as OnboardingSession;
        _messages.clear();
        
        final historicalMessages = data['messages'] as List<OnboardingMessage>;
        print('[ONBOARDING_BLOC] Mensajes históricos: ${historicalMessages.length}');
        _messages.addAll(historicalMessages);
        
        if (_messages.isEmpty) {
          // Si no hay mensajes históricos, iniciar nueva conversación
          print('[ONBOARDING_BLOC] Sin mensajes, iniciando nueva conversación');
          add(const StartOnboardingEvent());
        } else {
          // Restaurar conversación con mensajes previos
          print('[ONBOARDING_BLOC] Restaurando conversación con ${_messages.length} mensajes');
          emit(OnboardingConversation(
            session: _currentSession!,
            messages: List.from(_messages),
          ));
        }
      },
    );
  }
}

