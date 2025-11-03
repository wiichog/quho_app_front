import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quho_app/shared/design_system/design_system.dart';
import 'package:quho_app/shared/widgets/buttons/primary_button.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _handleVerify() {
    if (_code.length == 6) {
      context.read<AuthBloc>().add(VerifyEmailEvent(code: _code));
    }
  }

  void _handleResend() {
    context.read<AuthBloc>().add(
          ResendVerificationCodeEvent(email: widget.email),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Email'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Ir a onboarding
            context.go(RouteNames.onboarding);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          } else if (state is VerificationCodeResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código reenviado'),
                backgroundColor: AppColors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSpacing.verticalXl,

                  // Icono
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.tealPale,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: AppColors.teal,
                        size: 40,
                      ),
                    ),
                  ),

                  AppSpacing.verticalLg,

                  // Título
                  Text(
                    'Verifica tu email',
                    style: AppTextStyles.h2(),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalSm,

                  Text(
                    'Hemos enviado un código de 6 dígitos a',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalXs,

                  Text(
                    widget.email,
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalXxl,

                  // Campos de código
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => SizedBox(
                        width: 48,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          enabled: !isLoading,
                          style: AppTextStyles.h2(),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.gray300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.teal,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (_code.length == 6) {
                              _handleVerify();
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  AppSpacing.verticalXl,

                  // Botón de verificar
                  PrimaryButton(
                    text: 'Verificar',
                    onPressed: isLoading || _code.length != 6
                        ? null
                        : _handleVerify,
                    isLoading: isLoading,
                  ),

                  AppSpacing.verticalLg,

                  // Reenviar código
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No recibiste el código? ',
                        style: AppTextStyles.bodyMedium(),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : _handleResend,
                        child: Text(
                          'Reenviar',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

