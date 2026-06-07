import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Theme-aware colors for cards, fields, and text on tool screens.
abstract final class AppSurfaces {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageBackground(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : Colors.transparent;

  static Color card(BuildContext context) => isDark(context)
      ? const Color(0xFF2D2D2D)
      : Colors.white.withValues(alpha: 0.95);

  static Color fieldFill(BuildContext context) =>
      isDark(context) ? const Color(0xFF3A3A3A) : const Color(0xFFFFFDE7);

  static Color accentPanel(BuildContext context) => isDark(context)
      ? const Color(0xFF1E3A2A)
      : const Color(0xFFE8F5E9);

  static Color totalPanel(BuildContext context) => isDark(context)
      ? const Color(0xFF1A2E42)
      : const Color(0xFFE3F2FD);

  static Color primaryText(BuildContext context) =>
      isDark(context) ? Colors.white : Colors.black87;

  static Color secondaryText(BuildContext context) =>
      isDark(context) ? Colors.white70 : Colors.black54;

  static Color sectionHeading(BuildContext context) => isDark(context)
      ? const Color(0xFF81C784)
      : AppColors.letterheadGreen;

  static const Color headerOnGreen = Colors.white;

  static Color fieldBorder(BuildContext context) => isDark(context)
      ? Colors.white24
      : Colors.black26;
}
