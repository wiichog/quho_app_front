import 'dart:async';

/// Servicio singleton para gestionar eventos de sesión globales
/// Usado para notificar cuando la sesión expira y redirigir al login
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Stream controller para eventos de sesión expirada
  final _sessionExpiredController = StreamController<void>.broadcast();

  /// Stream que emite cuando la sesión ha expirado (401 sin posibilidad de refresh)
  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  /// Notifica que la sesión ha expirado
  void notifySessionExpired() {
    print('[SESSION_MANAGER] 🚨 Sesión expirada - Notificando a listeners');
    _sessionExpiredController.add(null);
  }

  /// Limpia recursos
  void dispose() {
    _sessionExpiredController.close();
  }
}

