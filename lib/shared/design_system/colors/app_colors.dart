import 'package:flutter/material.dart';

/// Sistema de colores de QUHO
/// Basado en la guía de diseño oficial
class AppColors {
  // Primary - Navy Blue
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color navy = Color(0xFF334155);
  static const Color mediumNavy = Color(0xFF475569);

  // Accent - Teal
  static const Color tealDark = Color(0xFF0D9488);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFF5EEAD4);
  static const Color tealPale = Color(0xFFCCFBF1);

  // Functional - Success
  static const Color green = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFD1FAE5);

  // Functional - Warning
  static const Color orange = Color(0xFFF59E0B);
  static const Color orangeLight = Color(0xFFFEF3C7);

  // Functional - Error
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEE2E2);
  static const Color redPale = Color(0xFFFEF2F2);

  // Functional - Info
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFDBEAFE);

  // Gamification - Levels
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color diamond = Color(0xFFB9F2FF);

  // Category Colors
  static const Color categoryFood = Color(0xFFF59E0B);
  static const Color categoryTransport = Color(0xFF3B82F6);
  static const Color categoryHousing = Color(0xFF8B5CF6);
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryEntertainment = Color(0xFFEC4899);
  static const Color categoryEducation = Color(0xFF6366F1);
  static const Color categoryDebt = Color(0xFFEF4444);
  static const Color categoryOther = Color(0xFF64748B);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);
  static const Color black = Color(0xFF000000);

  // Gradients
  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkNavy, tealDark],
  );

  static const LinearGradient gradientPremium = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, blue],
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [green, teal],
  );

  // Private constructor para prevenir instanciación
  AppColors._();
}

