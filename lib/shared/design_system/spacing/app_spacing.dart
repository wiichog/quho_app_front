import 'package:flutter/material.dart';

/// Sistema de espaciado de QUHO
/// Basado en escala de 4px
class AppSpacing {
  // Base unit: 4px
  static const double base = 4.0;

  // Spacing scale
  static const double xxs = base; // 4px
  static const double xs = base * 2; // 8px
  static const double sm = base * 3; // 12px
  static const double md = base * 4; // 16px
  static const double lg = base * 6; // 24px
  static const double xl = base * 8; // 32px
  static const double xxl = base * 10; // 40px
  static const double xxxl = base * 12; // 48px

  // Screen padding
  static const double screenPaddingHorizontal = md; // 16px
  static const double screenPaddingVertical = lg; // 24px

  // Card spacing
  static const double cardPadding = md; // 16px
  static const double cardRadius = sm; // 12px
  static const double cardElevation = 2.0;

  // Button spacing
  static const double buttonPaddingHorizontal = lg; // 24px
  static const double buttonPaddingVertical = sm; // 12px
  static const double buttonRadius = xs; // 8px

  // Icon sizes
  static const double iconXs = base * 4; // 16px
  static const double iconSm = base * 5; // 20px
  static const double iconMd = base * 6; // 24px
  static const double iconLg = base * 8; // 32px
  static const double iconXl = base * 10; // 40px

  // Border radius
  static const double radiusXs = xxs; // 4px
  static const double radiusSm = xs; // 8px
  static const double radiusMd = sm; // 12px
  static const double radiusLg = md; // 16px
  static const double radiusXl = lg; // 24px
  static const double radiusFull = 999.0; // Circle

  // Common EdgeInsets
  static const EdgeInsets paddingXxs = EdgeInsets.all(xxs);
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);

  // Screen safe padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  static const EdgeInsets screenPaddingHorizontalOnly = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
  );

  // Common SizedBox
  static const SizedBox spaceXxs = SizedBox(width: xxs, height: xxs);
  static const SizedBox spaceXs = SizedBox(width: xs, height: xs);
  static const SizedBox spaceSm = SizedBox(width: sm, height: sm);
  static const SizedBox spaceMd = SizedBox(width: md, height: md);
  static const SizedBox spaceLg = SizedBox(width: lg, height: lg);
  static const SizedBox spaceXl = SizedBox(width: xl, height: xl);
  static const SizedBox spaceXxl = SizedBox(width: xxl, height: xxl);

  // Vertical spacing
  static const SizedBox verticalXxs = SizedBox(height: xxs);
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);

  // Horizontal spacing
  static const SizedBox horizontalXxs = SizedBox(width: xxs);
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
  static const SizedBox horizontalXxl = SizedBox(width: xxl);

  // Private constructor
  AppSpacing._();
}

