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
import 'package:quho_app/shared/widgets/inputs/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            // Ir a pantalla de verificación
            context.go(
              '/verify-email',
              extra: {'email': state.email},
            );
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
                    AppSpacing.verticalLg,

                    // Título
                    Text(
                      'Crea tu cuenta',
                      style: AppTextStyles.h2(),
                    ),

                    AppSpacing.verticalSm,

                    Text(
                      'Completa tus datos para comenzar',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.gray600,
                      ),
                    ),

                    AppSpacing.verticalXl,

                    // Nombre
                    CustomTextField(
                      controller: _firstNameController,
                      label: 'Nombre',
                      hint: 'Juan',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outlined,
                      validator: Validators.required,
                      enabled: !isLoading,
                    ),

                    AppSpacing.verticalMd,

                    // Apellido
                    CustomTextField(
                      controller: _lastNameController,
                      label: 'Apellido',
                      hint: 'Pérez',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outlined,
                      validator: Validators.required,
                      enabled: !isLoading,
                    ),

                    AppSpacing.verticalMd,

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

                    // Teléfono (opcional)
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Teléfono (opcional)',
                      hint: '+52 999 999 9999',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.phone_outlined,
                      enabled: !isLoading,
                    ),

                    AppSpacing.verticalMd,

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: Validators.password,
                      enabled: !isLoading,
                    ),

                    AppSpacing.verticalXs,

                    // Requisitos de contraseña
                    Text(
                      'Mínimo 8 caracteres, 1 mayúscula, 1 minúscula y 1 número',
                      style: AppTextStyles.caption(
                        color: AppColors.gray500,
                      ),
                    ),

                    AppSpacing.verticalMd,

                    // Confirmar Password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar Contraseña',
                      hint: '••••••••',
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: Validators.passwordConfirmation(
                        _passwordController.text,
                      ),
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleRegister(),
                    ),

                    AppSpacing.verticalXl,

                    // Botón de registro
                    PrimaryButton(
                      text: 'Crear Cuenta',
                      onPressed: isLoading ? null : _handleRegister,
                      isLoading: isLoading,
                      icon: Icons.person_add_outlined,
                    ),

                    AppSpacing.verticalLg,

                    // Link a login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: AppTextStyles.bodyMedium(),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : () => context.pop(),
                          child: Text(
                            'Inicia Sesión',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.verticalXl,
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

