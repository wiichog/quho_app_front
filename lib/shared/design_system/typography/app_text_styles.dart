import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';

/// Sistema de tipografía de QUHO
/// - Headings: Poppins (600-700)
/// - Body: Inter (400-600)
class AppTextStyles {
  // ========== HEADINGS (Poppins) ==========
  
  // H1 - Hero titles
  static TextStyle h1({Color? color}) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: color ?? AppColors.gray900,
      );

  // H2 - Section headers
  static TextStyle h2({Color? color}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
        color: color ?? AppColors.gray900,
      );

  // H3 - Card headers
  static TextStyle h3({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.2,
        color: color ?? AppColors.gray800,
      );

  // H4 - Widget titles
  static TextStyle h4({Color? color}) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.1,
        color: color ?? AppColors.gray800,
      );

  // H5 - Mini headers
  static TextStyle h5({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: color ?? AppColors.gray700,
      );

  // ========== BODY TEXT (Inter) ==========

  // Body Large
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.gray700,
      );

  // Body Medium (Default)
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.gray700,
      );

  // Body Small
  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.gray600,
      );

  // ========== SPECIAL STYLES ==========

  // Button Text
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.2,
        color: color ?? AppColors.white,
      );

  // Caption (labels, hints)
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.3,
        color: color ?? AppColors.gray500,
      );

  // Overline (uppercase labels)
  static TextStyle overline({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.6,
        letterSpacing: 1.5,
        color: color ?? AppColors.gray500,
      ).copyWith(
        // Force uppercase in style
        fontFeatures: [const FontFeature.enable('smcp')],
      );

  // Number Display (financial amounts)
  static TextStyle numberLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -1,
        color: color ?? AppColors.gray900,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  static TextStyle numberMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.5,
        color: color ?? AppColors.gray800,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  static TextStyle numberSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color ?? AppColors.gray700,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  // Private constructor
  AppTextStyles._();
}

