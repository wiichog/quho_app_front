import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utilidades helper para QUHO
class Helpers {
  // ========== NAVEGACIÓN ==========

  /// Cierra el teclado
  static void closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Verifica si el teclado está visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  // ========== HAPTIC FEEDBACK ==========

  /// Feedback ligero (para selecciones)
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Feedback medio (para acciones)
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Feedback fuerte (para confirmaciones importantes)
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Feedback de selección (para cambios en UI)
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Feedback de vibración (para notificaciones)
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  // ========== CÁLCULOS FINANCIEROS ==========

  /// Calcula el porcentaje entre dos valores
  /// Ejemplo: percentage(50, 200) = 25.0 (50 es el 25% de 200)
  static double percentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  /// Calcula el valor de un porcentaje
  /// Ejemplo: percentageOf(25, 200) = 50.0 (el 25% de 200 es 50)
  static double percentageOf(double percentage, double total) {
    return (percentage / 100) * total;
  }

  /// Calcula la diferencia porcentual entre dos valores
  /// Ejemplo: percentageDifference(100, 150) = 50.0 (50% de incremento)
  static double percentageDifference(double oldValue, double newValue) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  /// Redondea un número a N decimales
  static double roundToDecimals(double value, int decimals) {
    final mod = 10.0 * decimals;
    return ((value * mod).round().toDouble() / mod);
  }

  // ========== CATEGORÍAS ==========

  /// Retorna el color de una categoría según su nombre
  static Color getCategoryColor(String category) {
    final categoryLower = category.toLowerCase();
    
    switch (categoryLower) {
      case 'comida':
      case 'alimentos':
      case 'restaurantes':
        return const Color(0xFFF59E0B);
      
      case 'transporte':
      case 'uber':
      case 'gasolina':
        return const Color(0xFF3B82F6);
      
      case 'vivienda':
      case 'renta':
      case 'casa':
        return const Color(0xFF8B5CF6);
      
      case 'salud':
      case 'médico':
      case 'farmacia':
        return const Color(0xFF10B981);
      
      case 'entretenimiento':
      case 'ocio':
      case 'diversión':
        return const Color(0xFFEC4899);
      
      case 'educación':
      case 'cursos':
      case 'libros':
        return const Color(0xFF6366F1);
      
      case 'deuda':
      case 'crédito':
      case 'préstamo':
        return const Color(0xFFEF4444);
      
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Retorna el icono de una categoría según su nombre
  static IconData getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();
    
    switch (categoryLower) {
      case 'comida':
      case 'alimentos':
      case 'restaurantes':
        return Icons.restaurant_outlined;
      
      case 'transporte':
      case 'uber':
      case 'gasolina':
        return Icons.directions_car_outlined;
      
      case 'vivienda':
      case 'renta':
      case 'casa':
        return Icons.home_outlined;
      
      case 'salud':
      case 'médico':
      case 'farmacia':
        return Icons.local_hospital_outlined;
      
      case 'entretenimiento':
      case 'ocio':
      case 'diversión':
        return Icons.movie_outlined;
      
      case 'educación':
      case 'cursos':
      case 'libros':
        return Icons.school_outlined;
      
      case 'deuda':
      case 'crédito':
      case 'préstamo':
        return Icons.credit_card_outlined;
      
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  // ========== GAMIFICACIÓN ==========

  /// Retorna el nombre del nivel según los puntos
  static String getLevelName(int points) {
    if (points < 100) return 'Novato';
    if (points < 500) return 'Aprendiz';
    if (points < 1000) return 'Intermedio';
    if (points < 2500) return 'Avanzado';
    if (points < 5000) return 'Experto';
    if (points < 10000) return 'Maestro';
    return 'Leyenda';
  }

  /// Retorna el número de nivel según los puntos
  static int getLevel(int points) {
    return (points / 100).floor() + 1;
  }

  /// Retorna los puntos necesarios para el siguiente nivel
  static int pointsToNextLevel(int currentPoints) {
    final currentLevel = getLevel(currentPoints);
    final nextLevelPoints = currentLevel * 100;
    return nextLevelPoints - currentPoints;
  }

  /// Retorna el progreso hacia el siguiente nivel (0.0 a 1.0)
  static double levelProgress(int currentPoints) {
    final currentLevel = getLevel(currentPoints);
    final previousLevelPoints = (currentLevel - 1) * 100;
    final nextLevelPoints = currentLevel * 100;
    final pointsInLevel = currentPoints - previousLevelPoints;
    final pointsNeeded = nextLevelPoints - previousLevelPoints;
    return pointsInLevel / pointsNeeded;
  }

  // ========== TIEMPO ==========

  /// Retorna el saludo según la hora del día
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  /// Retorna si es de día (entre 6am y 6pm)
  static bool isDaytime() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  /// Retorna el primer día del mes actual
  static DateTime startOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  /// Retorna el último día del mes actual
  static DateTime endOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 0);
  }

  /// Retorna si dos fechas son del mismo día
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Retorna la diferencia en días entre dos fechas
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  // ========== STRINGS ==========

  /// Retorna las iniciales de un nombre
  /// Ejemplo: "Juan Pérez" -> "JP"
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Retorna un color consistente basado en un string (para avatares)
  static Color getColorFromString(String text) {
    final colors = [
      const Color(0xFF14B8A6), // Teal
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF10B981), // Green
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEF4444), // Red
    ];
    
    final hash = text.hashCode.abs();
    return colors[hash % colors.length];
  }

  // ========== VALIDACIÓN ==========

  /// Retorna si un valor está entre un rango
  static bool inRange(double value, double min, double max) {
    return value >= min && value <= max;
  }

  /// Retorna si una lista está vacía o es nula
  static bool isNullOrEmpty(List? list) {
    return list == null || list.isEmpty;
  }

  /// Retorna si un string está vacío o es nulo
  static bool isNullOrEmptyString(String? text) {
    return text == null || text.trim().isEmpty;
  }

  // Private constructor
  Helpers._();
}

