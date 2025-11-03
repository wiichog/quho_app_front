import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/core/utils/validators.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quho_app/shared/design_system/design_system.dart';
import 'package:quho_app/shared/widgets/buttons/primary_button.dart';
import 'package:quho_app/shared/widgets/buttons/secondary_button.dart';
import 'package:quho_app/shared/widgets/inputs/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            print('✅ [LOGIN_PAGE] Usuario autenticado: ${state.user.email}');
            print('📦 [LOGIN_PAGE] Onboarding completado: ${state.user.onboardingCompleted}');
            
            // Si el usuario completó onboarding → Dashboard
            if (state.user.onboardingCompleted) {
              print('🔵 [LOGIN_PAGE] Navegando al Dashboard');
              context.go(RouteNames.home);
            } else {
              // Si no → Onboarding
              print('🔵 [LOGIN_PAGE] Navegando al Onboarding');
              context.go(RouteNames.onboarding);
            }
          } else if (state is AuthError) {
            print('❌ [LOGIN_PAGE] Error de autenticación: ${state.message}');
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

                    // Logo y título
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientHero,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    AppSpacing.verticalLg,

                    Text(
                      '¡Bienvenido a QUHO!',
                      style: AppTextStyles.h1(),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.verticalSm,

                    Text(
                      'Tu asistente financiero personal con IA',
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
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                      enabled: !isLoading,
                    ),

                    AppSpacing.verticalMd,

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: Validators.required,
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleLogin(),
                    ),

                    AppSpacing.verticalMd,

                    // Olvidé mi contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.push(RouteNames.forgotPassword),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: AppTextStyles.caption(
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),

                    AppSpacing.verticalLg,

                    // Botón de login
                    PrimaryButton(
                      text: 'Iniciar Sesión',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading,
                    ),

                    AppSpacing.verticalMd,

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: AppSpacing.paddingHorizontalMd,
                          child: Text(
                            'o',
                            style: AppTextStyles.caption(),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    AppSpacing.verticalMd,

                    // Botón de registro
                    SecondaryButton(
                      text: 'Crear Cuenta',
                      onPressed: isLoading
                          ? null
                          : () => context.push(RouteNames.register),
                      icon: Icons.person_add_outlined,
                    ),

                    AppSpacing.verticalXxl,

                    // Términos y condiciones
                    Text(
                      'Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad',
                      style: AppTextStyles.caption(
                        color: AppColors.gray500,
                      ),
                      textAlign: TextAlign.center,
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

