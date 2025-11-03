import 'package:quho_app/features/onboarding/domain/entities/onboarding_session.dart';

class OnboardingSessionModel extends OnboardingSession {
  const OnboardingSessionModel({
    required super.id,
    required super.status,
    required super.completenessScore,
    super.completedAt,
  });

  factory OnboardingSessionModel.fromJson(Map<String, dynamic> json) {
    try {
      print('[MODEL_SESSION] 🔵 Parseando OnboardingSessionModel');
      print('[MODEL_SESSION] 📦 JSON: $json');
      
      // Extraer id con fallbacks
      final id = _extractId(json);
      print('[MODEL_SESSION] 📦 id extraído: $id');
      
      // Extraer status con validación
      final status = _extractStatus(json);
      print('[MODEL_SESSION] 📦 status extraído: $status');
      
      // Extraer completeness
      final completeness = _extractCompleteness(json);
      print('[MODEL_SESSION] 📦 completeness extraído: $completeness');
      
      // Extraer completed_at
      final completedAt = _extractCompletedAt(json);
      print('[MODEL_SESSION] 📦 completedAt extraído: $completedAt');
      
      print('[MODEL_SESSION] ✅ Modelo parseado correctamente');
      
      return OnboardingSessionModel(
        id: id,
        status: status,
        completenessScore: completeness,
        completedAt: completedAt,
      );
    } catch (e, stackTrace) {
      print('[MODEL_SESSION] ❌ Error parseando: $e');
      print('[MODEL_SESSION] ❌ Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  static String _extractId(Map<String, dynamic> json) {
    // Probar diferentes posibles campos
    final sessionId = json['session_id'];
    final id = json['id'];
    
    if (sessionId != null) {
      if (sessionId is String) return sessionId;
      if (sessionId is Map) {
        // Si es un objeto, intentar extraer algún campo ID
        print('[MODEL_SESSION] ⚠️ session_id es un Map: $sessionId');
        return sessionId['id']?.toString() ?? sessionId.toString();
      }
      return sessionId.toString();
    }
    
    if (id != null) {
      if (id is String) return id;
      return id.toString();
    }
    
    throw Exception('No se encontró campo id o session_id en JSON');
  }
  
  static String _extractStatus(Map<String, dynamic> json) {
    final status = json['status'];
    if (status == null) {
      return 'not_started'; // valor por defecto
    }
    if (status is String) return status;
    return status.toString();
  }
  
  static int _extractCompleteness(Map<String, dynamic> json) {
    final completeness = json['completeness'];
    if (completeness == null) return 0;
    if (completeness is int) return completeness;
    if (completeness is num) return completeness.toInt();
    if (completeness is String) return int.tryParse(completeness) ?? 0;
    return 0;
  }
  
  static DateTime? _extractCompletedAt(Map<String, dynamic> json) {
    final completedAt = json['completed_at'];
    if (completedAt == null) return null;
    if (completedAt is String) {
      try {
        return DateTime.parse(completedAt);
      } catch (e) {
        print('[MODEL_SESSION] ⚠️ Error parseando completed_at: $e');
        return null;
      }
    }
    return null;
  }

  OnboardingSession toEntity() {
    return OnboardingSession(
      id: id,
      status: status,
      completenessScore: completenessScore,
      completedAt: completedAt,
    );
  }
}

