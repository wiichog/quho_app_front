import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:quho_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:quho_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:quho_app/shared/design_system/design_system.dart';
import 'package:quho_app/shared/widgets/buttons/primary_button.dart';
import 'package:quho_app/shared/widgets/feedback/loading_indicator.dart';

class ConversationalOnboardingPage extends StatelessWidget {
  const ConversationalOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<OnboardingBloc>()..add(const CheckOnboardingStatusEvent()),
        ),
      ],
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<OnboardingBloc>().add(SendMessageEvent(message));
    _messageController.clear();

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            context.go(RouteNames.home);
          } else if (state is OnboardingSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Progreso guardado. Puedes continuar cuando quieras.'),
                backgroundColor: AppColors.teal,
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              context.go(RouteNames.home);
            });
          } else if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          }

          // Auto scroll on new messages
          if (state is OnboardingConversation || state is OnboardingSessionStarted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },
        builder: (context, state) {
          // Verificando si hay sesión previa
          if (state is OnboardingResuming) {
            return const LoadingIndicator(message: 'Verificando progreso...');
          }

          // Pantalla de bienvenida antes de iniciar
          if (state is OnboardingInitial) {
            return const _WelcomeScreen();
          }

          if (state is OnboardingLoading) {
            return const LoadingIndicator(message: 'Iniciando asistente...');
          }

          if (state is OnboardingSessionStarted ||
              state is OnboardingConversation ||
              state is OnboardingMessageSending) {
            final messages = state is OnboardingSessionStarted
                ? state.messages
                : state is OnboardingConversation
                    ? state.messages
                    : state is OnboardingMessageSending
                        ? state.messages
                        : [];

            final isLoading = state is OnboardingMessageSending;
            final completeness = state is OnboardingConversation
                ? state.session.completenessScore
                : state is OnboardingSessionStarted
                    ? state.session.completenessScore
                    : state is OnboardingMessageSending
                        ? state.session.completenessScore
                        : 0;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Conversación con IA'),
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cerrar Sesión'),
                          content: const Text('¿Estás seguro de que deseas salir? Se perderá tu progreso actual.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.read<AuthBloc>().add(const LogoutEvent());
                              },
                              child: Text(
                                'Salir',
                                style: TextStyle(color: AppColors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    tooltip: 'Cerrar sesión',
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Progress bar
                  if (completeness > 0)
                  Container(
                    padding: AppSpacing.paddingMd,
                    color: AppColors.gray100,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso',
                              style: AppTextStyles.caption(color: AppColors.gray600),
                            ),
                            Text(
                              '$completeness%',
                              style: AppTextStyles.caption(color: AppColors.teal).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSm,
                        LinearProgressIndicator(
                          value: completeness / 100,
                          backgroundColor: AppColors.gray200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                        ),
                      ],
                    ),
                  ),

                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: AppSpacing.paddingLg,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _MessageBubble(
                        message: message.content,
                        isUser: message.isUser,
                        time: message.createdAt,
                      );
                    },
                  ),
                ),

                // Loading indicator
                if (isLoading)
                  Container(
                    padding: AppSpacing.paddingMd,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                          ),
                        ),
                        AppSpacing.horizontalSm,
                        Text(
                          'Pensando...',
                          style: AppTextStyles.caption(color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ),

                // Input area
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gray900.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Describe tus ingresos, gastos o ahorros...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                borderSide: const BorderSide(color: AppColors.gray300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                borderSide: const BorderSide(color: AppColors.teal),
                              ),
                              contentPadding: AppSpacing.paddingMd,
                            ),
                            enabled: !isLoading,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        AppSpacing.horizontalSm,
                        IconButton(
                          onPressed: isLoading ? null : _sendMessage,
                          icon: const Icon(Icons.send),
                          color: AppColors.teal,
                          disabledColor: AppColors.gray400,
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gray900.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        // Verificar si el usuario completó los 3 pasos (contando mensajes del usuario)
                        Builder(
                          builder: (context) {
                            // Contar mensajes del usuario (deben ser 3: ingresos, gastos, ahorros)
                            final userMessagesCount = messages.where((m) => m.isUser).length;
                            final assistantMessagesCount = messages.where((m) => !m.isUser).length;
                            final isReadyToComplete = userMessagesCount >= 3;
                            
                            print('[ONBOARDING_PAGE] 📊 Total mensajes: ${messages.length}');
                            print('[ONBOARDING_PAGE] 📊 Mensajes usuario: $userMessagesCount');
                            print('[ONBOARDING_PAGE] 📊 Mensajes asistente: $assistantMessagesCount');
                            print('[ONBOARDING_PAGE] 📊 Listo para completar: $isReadyToComplete');
                            
                            // Debug: Mostrar todos los mensajes y sus roles
                            for (var i = 0; i < messages.length; i++) {
                              final msg = messages[i];
                              print('[ONBOARDING_PAGE] 📨 Mensaje $i: ${msg.isUser ? "USER" : "ASSISTANT"} - ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...');
                            }
                            
                            return Column(
                              children: [
                                // Complete button (cuando ha completado los 3 pasos)
                                if (isReadyToComplete) ...[
                                  PrimaryButton(
                                    text: '🎯 Finalizar y Crear mi Presupuesto',
                                    onPressed: () {
                                      print('[ONBOARDING_PAGE] 🎯 Usuario presionó Finalizar');
                                      context.read<OnboardingBloc>().add(
                                        const CompleteOnboardingEvent(),
                                      );
                                    },
                                    icon: Icons.check_circle_outline,
                                  ),
                                  AppSpacing.verticalSm,
                                ],
                                
                                // Save and exit button (siempre visible si hay mensajes)
                                if (messages.isNotEmpty && !isReadyToComplete)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text('Guardar y salir'),
                                          content: const Text(
                                            'Tu progreso se guardará automáticamente. '
                                            'Podrás continuar desde donde lo dejaste cuando vuelvas.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(dialogContext).pop(),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext).pop();
                                                context.read<OnboardingBloc>().add(
                                                  const SaveAndExitOnboardingEvent(),
                                                );
                                              },
                                              child: const Text('Guardar y salir'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.save_outlined),
                                    label: const Text('Guardar y continuar después'),
                                    style: OutlinedButton.styleFrom(
                                      padding: AppSpacing.paddingMd,
                                      minimumSize: const Size(double.infinity, 48),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            );
          }

          return const Center(child: Text('Estado desconocido'));
        },
      ),
    );
  }
}

/// Pantalla de bienvenida que explica el onboarding
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<AuthBloc>().add(const LogoutEvent());
                      },
                      child: Text(
                        'Salir',
                        style: TextStyle(color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Salir'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.verticalXl,

              // Ícono principal
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientHero,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: AppColors.white,
                    size: 50,
                  ),
                ),
              ),

              AppSpacing.verticalXl,

              // Título
              Text(
                '¡Bienvenido a tu Asistente Financiero!',
                style: AppTextStyles.h2(),
                textAlign: TextAlign.center,
              ),

              AppSpacing.verticalMd,

              // Descripción
              Text(
                'Voy a ayudarte a crear tu presupuesto personalizado de forma simple y conversacional.',
                style: AppTextStyles.bodyMedium(color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),

              AppSpacing.verticalXxl,

              // Instrucciones
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: AppColors.tealPale,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.teal),
                        AppSpacing.horizontalSm,
                        Text(
                          'Cómo funciona',
                          style: AppTextStyles.h5(color: AppColors.teal),
                        ),
                      ],
                    ),
                    AppSpacing.verticalMd,
                    _InstructionItem(
                      icon: Icons.chat_bubble_outline,
                      text: 'Habla naturalmente sobre tus ingresos, gastos y metas',
                    ),
                    AppSpacing.verticalSm,
                    _InstructionItem(
                      icon: Icons.psychology_outlined,
                      text: 'La IA comprenderá tu situación financiera',
                    ),
                    AppSpacing.verticalSm,
                    _InstructionItem(
                      icon: Icons.auto_awesome,
                      text: 'Crearemos tu presupuesto personalizado automáticamente',
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalXxl,

              // Ejemplos
              Text(
                'Ejemplos de lo que puedes decir:',
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              AppSpacing.verticalMd,

              _ExampleItem(text: '"Gano Q15,000 al mes como diseñador"'),
              AppSpacing.verticalSm,
              _ExampleItem(text: '"Pago Q3,000 de renta y Q500 de luz"'),
              AppSpacing.verticalSm,
              _ExampleItem(text: '"Quiero ahorrar Q2,000 mensuales"'),

              AppSpacing.verticalXxl,

              // Botón para comenzar
              PrimaryButton(
                text: '¡Comenzar!',
                onPressed: () {
                  context.read<OnboardingBloc>().add(const StartOnboardingEvent());
                },
                icon: Icons.arrow_forward,
              ),

              AppSpacing.verticalMd,
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.teal),
        AppSpacing.horizontalSm,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall(color: AppColors.gray700),
          ),
        ),
      ],
    );
  }
}

class _ExampleItem extends StatelessWidget {
  final String text;

  const _ExampleItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat, size: 16, color: AppColors.gray500),
          AppSpacing.horizontalSm,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall(color: AppColors.gray700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime time;

  const _MessageBubble({
    required this.message,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.tealPale,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppColors.teal,
                size: 20,
              ),
            ),
            AppSpacing.horizontalSm,
          ],
          Flexible(
            child: Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: isUser ? AppColors.teal : AppColors.gray100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? AppSpacing.radiusMd : 4),
                  topRight: Radius.circular(isUser ? 4 : AppSpacing.radiusMd),
                  bottomLeft: Radius.circular(AppSpacing.radiusMd),
                  bottomRight: Radius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                message,
                style: AppTextStyles.bodyMedium(
                  color: isUser ? AppColors.white : AppColors.gray900,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            AppSpacing.horizontalSm,
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

