/// Configuración de entornos para QUHO
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  // Detectar ambiente desde variables de entorno o usar default
  static Environment get _currentEnvironment {
    const envString = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (envString) {
      case 'production':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      default:
        return Environment.development;
    }
  }

  static Environment get current => _currentEnvironment;

  /// URL base del API según el entorno
  static String get apiBaseUrl {
    // Primero intentar obtener de variable de entorno
    const apiUrl = String.fromEnvironment('API_URL');
    if (apiUrl.isNotEmpty) {
      return apiUrl;
    }
    
    // Fallback según ambiente
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:8000/api/v1';
      case Environment.staging:
        return 'https://api-staging.quhoapp.com/api/v1';
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
  static bool get enableLogging => !isProduction;

  /// Configuración de analytics
  static bool get enableAnalytics => isProduction;

  // Private constructor
  EnvironmentConfig._();
}

