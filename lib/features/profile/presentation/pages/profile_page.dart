import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Página de perfil del usuario
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Perfil',
          style: AppTextStyles.h4().copyWith(color: AppColors.gray900),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(
              child: Text('Usuario no autenticado'),
            );
          }

          final user = state.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                AppSpacing.verticalMd,

                // Header con avatar
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingLg,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.teal,
                              AppColors.teal.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(user.fullName.isNotEmpty ? user.fullName : user.email),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      AppSpacing.verticalMd,

                      // Nombre
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : 'Usuario',
                        style: AppTextStyles.h4(),
                        textAlign: TextAlign.center,
                      ),

                      AppSpacing.verticalSm,

                      // Email
                      Text(
                        user.email,
                        style: AppTextStyles.bodyMedium(color: AppColors.gray600),
                        textAlign: TextAlign.center,
                      ),

                      AppSpacing.verticalMd,

                      // Botón de editar perfil
                      OutlinedButton.icon(
                        onPressed: () {
                          _showEditProfileDialog(context, user.fullName, user.email);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Editar perfil'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.teal,
                          side: const BorderSide(color: AppColors.teal),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.verticalMd,

                // Sección de configuración
                Container(
                  color: AppColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: AppSpacing.paddingMd,
                        child: Text(
                          'Configuración',
                          style: AppTextStyles.bodySmall(color: AppColors.gray600).copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _ProfileOption(
                        icon: Icons.lock_outline,
                        title: 'Cambiar contraseña',
                        onTap: () {
                          _showChangePasswordDialog(context);
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileOption(
                        icon: Icons.notifications_outlined,
                        title: 'Notificaciones',
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {
                            // TODO: Implementar cambio de notificaciones
                          },
                          activeColor: AppColors.teal,
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileOption(
                        icon: Icons.language_outlined,
                        title: 'Idioma',
                        subtitle: 'Español',
                        onTap: () {
                          // TODO: Implementar cambio de idioma
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileOption(
                        icon: Icons.attach_money_outlined,
                        title: 'Moneda predeterminada',
                        subtitle: 'GTQ (Quetzales)',
                        onTap: () {
                          // TODO: Implementar cambio de moneda
                        },
                      ),
                    ],
                  ),
                ),

                AppSpacing.verticalMd,

                // Sección de información
                Container(
                  color: AppColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: AppSpacing.paddingMd,
                        child: Text(
                          'Información',
                          style: AppTextStyles.bodySmall(color: AppColors.gray600).copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _ProfileOption(
                        icon: Icons.help_outline,
                        title: 'Centro de ayuda',
                        onTap: () {
                          // TODO: Implementar centro de ayuda
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileOption(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Política de privacidad',
                        onTap: () {
                          // TODO: Implementar política de privacidad
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileOption(
                        icon: Icons.description_outlined,
                        title: 'Términos y condiciones',
                        onTap: () {
                          // TODO: Implementar términos
                        },
                      ),
                      const Divider(height: 1),
                      _ProfileOption(
                        icon: Icons.info_outline,
                        title: 'Acerca de',
                        subtitle: 'Versión 1.0.0',
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),

                AppSpacing.verticalMd,

                // Botón de cerrar sesión
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLogoutConfirmation(context);
                      },
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Cerrar sesión'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: const BorderSide(color: AppColors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                AppSpacing.verticalXl,
              ],
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar perfil', style: AppTextStyles.h5()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            AppSpacing.verticalMd,
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              enabled: false, // Email no editable
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar actualización de perfil
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil actualizado exitosamente'),
                  backgroundColor: AppColors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cambiar contraseña', style: AppTextStyles.h5()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            AppSpacing.verticalMd,
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            AppSpacing.verticalMd,
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar cambio de contraseña
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña cambiada exitosamente'),
                  backgroundColor: AppColors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Acerca de Quho', style: AppTextStyles.h5()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quho es tu asistente personal de finanzas, diseñado para ayudarte a tomar el control de tu dinero de manera simple e inteligente.',
              style: AppTextStyles.bodyMedium(),
            ),
            AppSpacing.verticalMd,
            Text(
              'Versión: 1.0.0',
              style: AppTextStyles.bodySmall(color: AppColors.gray600),
            ),
            Text(
              '© 2025 Quho App',
              style: AppTextStyles.bodySmall(color: AppColors.gray600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cerrar sesión', style: AppTextStyles.h5()),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
              context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.teal,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium().copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.caption(color: AppColors.gray600),
            )
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.gray400) : null),
      onTap: onTap,
      contentPadding: AppSpacing.paddingMd,
    );
  }
}

