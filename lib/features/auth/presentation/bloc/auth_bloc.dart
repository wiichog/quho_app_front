import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quho_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:quho_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:quho_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:quho_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:quho_app/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:quho_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_state.dart';

/// BLoC de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyEmailUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ResendVerificationCodeEvent>(_onResendVerificationCode);
    on<RequestPasswordResetEvent>(_onRequestPasswordReset);
    on<LogoutEvent>(_onLogout);
  }

  /// Verificar si hay sesión activa
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final hasSession = await authRepository.hasActiveSession();
    
    if (!hasSession) {
      emit(const Unauthenticated());
      return;
    }

    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        emit(const Unauthenticated());
      },
      (user) {
        emit(Authenticated(user: user));
      },
    );
  }

  /// Login
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (authResponse) {
        emit(Authenticated(user: authResponse.user));
      },
    );
  }

  /// Register
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(RegistrationSuccess(email: event.email)),
    );
  }

  /// Verificar email
  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await verifyEmailUseCase(
      VerifyEmailParams(code: event.code),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authResponse) => emit(Authenticated(user: authResponse.user)),
    );
  }

  /// Reenviar código de verificación
  Future<void> _onResendVerificationCode(
    ResendVerificationCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    // No cambiar el estado actual, solo hacer la petición
    final currentState = state;

    final result = await authRepository.resendVerificationCode(
      email: event.email,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) {
        // Volver al estado anterior y emitir un estado temporal de éxito
        emit(const VerificationCodeResent());
        // Después de un momento, volver al estado de registro
        Future.delayed(const Duration(seconds: 2), () {
          if (currentState is RegistrationSuccess) {
            emit(currentState);
          }
        });
      },
    );
  }

  /// Solicitar reset de contraseña
  Future<void> _onRequestPasswordReset(
    RequestPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.requestPasswordReset(
      email: event.email,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const PasswordResetEmailSent()),
    );
  }

  /// Logout
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }
}

