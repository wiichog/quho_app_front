import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/core/config/environment.dart';
import 'package:quho_app/core/routes/app_router.dart';
import 'package:quho_app/core/services/session_manager.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

void main() async {
  print('🚀 QUHO App iniciando...');
  
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ Flutter binding inicializado');

  // Initialize date formatting for locales
  await initializeDateFormatting('es_MX', null);
  await initializeDateFormatting('es', null);
  print('✅ Locales de fecha inicializados');

  // Setup dependencies (API Client, Storage, etc.)
  print('⚙️  Configurando dependencias...');
  print('🌐 API URL: ${EnvironmentConfig.apiBaseUrl}');
  print('🔧 Entorno: ${EnvironmentConfig.current.name}');
  
  await setupDependencies();
  print('✅ Dependencias configuradas');

  print('🎨 Iniciando app...');
  runApp(const QuhoApp());
}

class QuhoApp extends StatefulWidget {
  const QuhoApp({super.key});

  @override
  State<QuhoApp> createState() => _QuhoAppState();
}

class _QuhoAppState extends State<QuhoApp> {
  final SessionManager _sessionManager = SessionManager();
  StreamSubscription<void>? _sessionExpiredSubscription;
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    
    // Crear el AuthBloc
    _authBloc = getIt<AuthBloc>()..add(const CheckAuthStatusEvent());
    
    // Crear el router con el AuthBloc
    _router = AppRouter.createRouter(_authBloc);
    AppRouter.router = _router; // Asignar al singleton
    
    // Escuchar eventos de sesión expirada
    _sessionExpiredSubscription = _sessionManager.sessionExpiredStream.listen((_) {
      print('[MAIN] 🚨 Sesión expirada detectada - Ejecutando logout');
      // Dispatch logout event al AuthBloc
      _authBloc.add(const LogoutEvent());
    });
    
    print('[MAIN] ✅ Listener de sesión expirada configurado');
  }

  @override
  void dispose() {
    _sessionExpiredSubscription?.cancel();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'QUHO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
