/// Configuración de entornos para QUHO
enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static const Environment _currentEnvironment = 
      // TODO: Cambiar a production para el release
      Environment.development;

  static Environment get current => _currentEnvironment;

  /// URL base del API según el entorno
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:8000/api/v1';
      case Environment.production:
        return 'https://api.quhoapp.com/api/v1';
    }
  }

  /// Indica si estamos en modo debug
  static bool get isDebug => _currentEnvironment == Environment.development;

  /// Indica si estamos en producción
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// Timeout para peticiones HTTP
  static Duration get connectionTimeout {
    return isDebug 
        ? const Duration(seconds: 60) // Más tiempo en desarrollo
        : const Duration(seconds: 30);
  }

  /// Configuración de logging
  static bool get enableLogging => isDebug;

  /// Configuración de analytics
  static bool get enableAnalytics => isProduction;

  // Private constructor
  EnvironmentConfig._();
}

