import 'package:quho_app/features/onboarding/domain/entities/onboarding_message.dart';

class OnboardingMessageModel extends OnboardingMessage {
  const OnboardingMessageModel({
    required super.id,
    required super.role,
    required super.content,
    required super.createdAt,
  });

  factory OnboardingMessageModel.fromJson(Map<String, dynamic> json) {
    try {
      print('[MODEL_MESSAGE] 🔵 Parseando OnboardingMessage');
      print('[MODEL_MESSAGE] 📦 JSON: $json');
      print('[MODEL_MESSAGE] 📦 JSON keys: ${json.keys.toList()}');
      
      // Parsear ID
      final id = json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      print('[MODEL_MESSAGE] 📦 id: $id (${id.runtimeType})');
      
      // Parsear role
      final roleValue = json['role'];
      print('[MODEL_MESSAGE] 📦 role raw: $roleValue (${roleValue.runtimeType})');
      final role = roleValue is String ? roleValue : roleValue?.toString() ?? 'assistant';
      print('[MODEL_MESSAGE] 📦 role parsed: $role');
      
      // Parsear content/message
      final contentValue = json['content'];
      final messageValue = json['message'];
      print('[MODEL_MESSAGE] 📦 content raw: $contentValue (${contentValue.runtimeType})');
      print('[MODEL_MESSAGE] 📦 message raw: $messageValue (${messageValue.runtimeType})');
      
      String content = '';
      if (contentValue != null) {
        content = contentValue is String ? contentValue : contentValue.toString();
      } else if (messageValue != null) {
        content = messageValue is String ? messageValue : messageValue.toString();
      }
      print('[MODEL_MESSAGE] 📦 content parsed: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
      
      // Parsear created_at
      final createdAtValue = json['created_at'];
      print('[MODEL_MESSAGE] 📦 created_at raw: $createdAtValue (${createdAtValue?.runtimeType})');
      
      DateTime createdAt;
      if (createdAtValue != null && createdAtValue is String) {
        createdAt = DateTime.parse(createdAtValue);
      } else {
        createdAt = DateTime.now();
      }
      print('[MODEL_MESSAGE] 📦 created_at parsed: $createdAt');
      
      print('[MODEL_MESSAGE] ✅ Mensaje parseado correctamente');
      
      return OnboardingMessageModel(
        id: id,
        role: role,
        content: content,
        createdAt: createdAt,
      );
    } catch (e, stackTrace) {
      print('[MODEL_MESSAGE] ❌ Error parseando mensaje: $e');
      print('[MODEL_MESSAGE] ❌ JSON: $json');
      print('[MODEL_MESSAGE] ❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  OnboardingMessage toEntity() {
    return OnboardingMessage(
      id: id,
      role: role,
      content: content,
      createdAt: createdAt,
    );
  }
}

