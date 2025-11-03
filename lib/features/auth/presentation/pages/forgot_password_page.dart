import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/utils/validators.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quho_app/shared/design_system/design_system.dart';
import 'package:quho_app/shared/widgets/buttons/primary_button.dart';
import 'package:quho_app/shared/widgets/inputs/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RequestPasswordResetEvent(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Hemos enviado un link de recuperación a tu email',
                ),
                backgroundColor: AppColors.green,
              ),
            );
            // Volver a login después de 2 segundos
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.pop();
              }
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
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
                          color: AppColors.orangeLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          color: AppColors.orange,
                          size: 40,
                        ),
                      ),
                    ),

                    AppSpacing.verticalLg,

                    // Título
                    Text(
                      'Recupera tu contraseña',
                      style: AppTextStyles.h2(),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.verticalSm,

                    Text(
                      'Ingresa tu email y te enviaremos un link para restablecer tu contraseña',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.gray600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.verticalXxl,

                    // Email
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'tu@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleSubmit(),
                    ),

                    AppSpacing.verticalXl,

                    // Botón de enviar
                    PrimaryButton(
                      text: 'Enviar Link de Recuperación',
                      onPressed: isLoading ? null : _handleSubmit,
                      isLoading: isLoading,
                      icon: Icons.send_outlined,
                    ),

                    AppSpacing.verticalLg,

                    // Volver a login
                    Center(
                      child: TextButton(
                        onPressed: isLoading ? null : () => context.pop(),
                        child: Text(
                          'Volver a Iniciar Sesión',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

