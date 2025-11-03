import 'package:quho_app/features/onboarding/domain/entities/onboarding_step.dart';

/// Servicio que maneja el flujo conversacional del onboarding en memoria
class ConversationFlowService {
  // Respuestas del usuario almacenadas en memoria
  String? _incomeResponse;
  String? _expensesResponse;
  String? _savingsResponse;

  // Paso actual
  OnboardingStepType _currentStep = OnboardingStepType.welcome;

  /// Obtiene el paso actual
  OnboardingStepType get currentStep => _currentStep;

  /// Obtiene la pregunta inicial de bienvenida
  String getWelcomeMessage() {
    return '''Voy a ayudarte a crear tu primer presupuesto de forma simple y rápida. Solo necesito que me cuentes sobre tu situación financiera en tus propias palabras.

**Empecemos con tus ingresos** 💰

¿De dónde viene tu dinero cada mes? Cuéntame de forma natural, por ejemplo:

📝 **Ejemplos:**
• "Trabajo como diseñador y gano Q15,000 al mes"
• "Tengo un salario de Q8,000 quincenales y un negocio que me da Q3,000"
• "Soy freelance, gano entre Q10,000 y Q20,000 al mes, varía"
• "Mi sueldo es de Q12,000 mensuales más comisiones"

No te preocupes por ser exacto, solo cuéntame en tus palabras 😊''';
  }

  /// Procesa el mensaje del usuario y retorna la respuesta del asistente
  /// Retorna null si necesita enviar al API
  String? processUserMessage(String message) {
    switch (_currentStep) {
      case OnboardingStepType.welcome:
        // El primer mensaje del usuario es sobre ingresos
        _incomeResponse = message;
        _currentStep = OnboardingStepType.income;
        return _getExpensesQuestion();

      case OnboardingStepType.income:
        // El usuario ya respondió sobre gastos
        _expensesResponse = message;
        _currentStep = OnboardingStepType.expenses;
        return _getSavingsQuestion();

      case OnboardingStepType.expenses:
        // El usuario respondió sobre ahorros (o puede decir "ninguno")
        _savingsResponse = message;
        _currentStep = OnboardingStepType.savings;
        return _getCompletionMessage();

      case OnboardingStepType.savings:
      case OnboardingStepType.completed:
        // Ya completó, no hay más preguntas
        return null;
    }
  }

  /// Pregunta sobre gastos
  String _getExpensesQuestion() {
    return '''¡Perfecto! Ya tengo información sobre tus ingresos. 👍

**Ahora cuéntame sobre tus gastos mensuales** 💳

¿En qué gastas tu dinero cada mes? Cuéntame sobre tus principales gastos, por ejemplo:

📝 **Ejemplos:**
• "Pago Q3,000 de renta, Q500 de luz, Q1,000 en comida, Q800 en transporte"
• "Tengo hipoteca de Q2,500, servicios Q1,200, colegios Q3,000"
• "Gasto Q5,000 en renta, Q2,000 en comida, Q1,500 en salidas"
• "Mi esposa maneja algunos gastos, yo pago Q4,000 en total aproximadamente"

No importa si no recuerdas todo exactamente, dime lo que recuerdes 😊''';
  }

  /// Pregunta sobre ahorros (opcional)
  String _getSavingsQuestion() {
    return '''¡Excelente! Ya tengo clara tu situación de ingresos y gastos. 👏

**Una última pregunta (opcional):** ¿Tienes algún ahorro o meta de ahorro? 💰

Esto es **completamente opcional**, pero me ayuda a crear un mejor presupuesto para ti.

📝 **Ejemplos:**
• "Quiero ahorrar Q2,000 al mes para emergencias"
• "Tengo Q15,000 ahorrados y quiero seguir ahorrando Q1,500 mensual"
• "No tengo ahorros, pero me gustaría empezar"
• "No, por ahora no" (o simplemente escribe "ninguno")

Si no tienes o no quieres compartir, puedes escribir "ninguno" o "no" 😊''';
  }

  /// Mensaje de finalización
  String _getCompletionMessage() {
    return '''¡Perfecto! Ya tengo toda la información que necesito. ✅

Voy a crear tu presupuesto personalizado basado en:
• Tus ingresos mensuales
• Tus gastos actuales
• Tus metas de ahorro

**¿Estás listo para que cree tu presupuesto?**

Presiona el botón "Finalizar onboarding" para que procese toda la información y cree tu plan financiero personalizado. 🚀''';
  }

  /// Verifica si el usuario completó todos los pasos requeridos
  bool isReadyToComplete() {
    return _incomeResponse != null && 
           _expensesResponse != null && 
           _currentStep == OnboardingStepType.savings;
  }

  /// Obtiene todas las respuestas como un mensaje consolidado para el API
  String getConsolidatedMessage() {
    final buffer = StringBuffer();
    
    buffer.writeln('=== INFORMACIÓN DEL USUARIO ===\n');
    
    buffer.writeln('INGRESOS:');
    buffer.writeln(_incomeResponse ?? 'No proporcionado');
    buffer.writeln();
    
    buffer.writeln('GASTOS:');
    buffer.writeln(_expensesResponse ?? 'No proporcionado');
    buffer.writeln();
    
    buffer.writeln('AHORROS:');
    buffer.writeln(_savingsResponse ?? 'No proporcionado');
    
    return buffer.toString();
  }

  /// Resetea el flujo
  void reset() {
    _incomeResponse = null;
    _expensesResponse = null;
    _savingsResponse = null;
    _currentStep = OnboardingStepType.welcome;
  }

  /// Getters para acceder a las respuestas individuales
  String? get incomeResponse => _incomeResponse;
  String? get expensesResponse => _expensesResponse;
  String? get savingsResponse => _savingsResponse;
}

