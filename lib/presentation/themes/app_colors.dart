import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF4A6FFF); // Brighter blue
  static const Color primaryDarkColor = Color(0xFF3D5CCC);
  static const Color primaryLightColor = Color(0xFF8AA5FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light background
  static const Color surfaceColor = Colors.white; // White surface
  static const Color errorColor = Color(0xFFE53935); // Brighter red
  static const Color textPrimaryColor = Color(0xFF212121); // Dark text
  static const Color textSecondaryColor = Color(0xFF616161); // Medium dark text
  static const Color textTertiaryColor = Color(0xFF9E9E9E); // Light text
  static const Color borderColor = Color(0xFFE0E0E0); // Light border
  static const Color dividerColor = Color(0xFFEEEEEE); // Very light divider
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color backgroundLight = Color(0xFF2A2A2A);
  static const Color textGrayColor = Color(0xFFAAAAAA);
  static const Color textWhiteColor = Colors.white;
  static const Color chartBlue = Color(0xFF4285F4);
  static const Color chartGreen = Color(0xFF0F9D58);
  static const Color chartPurple = Color(0xFF9C27B0);
  static const Color chartOrange = Color(0xFFFF9800);
  static const Color chartYellow = Color(0xFFFFEB3B);

  // Custom app colors
  static const Color cardColor = Colors.white;
  static const Color disabledColor = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color chartProtein = Color(0xFF4285F4);
  static const Color chartCarbs = Color(0xFF0F9D58);
  static const Color chartFat = Color(0xFFFFEB3B);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color linkColor = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFFBB86FC);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Dark theme variants (keeping for future dark mode support)
  static const Color darkPrimary = Color(0xFF4A6FFF);
  static const Color darkSecondary = Color(0xFF03DAC6);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkAccent = Color(0xFF03DAC6);
  static const Color accentDark = Color(0xFF018786);
  static const Color secondaryDark = Color(0xFF018786);

  // Aliases for compatibility
  static Color get primary => primaryColor;
  static Color get primaryDark => primaryDarkColor;
  static Color get accent => secondaryColor;
  static Color get error => errorColor;
  static Color get background => backgroundColor;
  static Color get backgroundDark => darkBackground;
  static Color get surface => surfaceColor;
  static Color get onBackground => textPrimaryColor;
  static Color get onSurface => textPrimaryColor;
  static Color get onPrimary => textWhiteColor;
  static Color get onSecondary => textWhiteColor;
  static Color get onError => textWhiteColor;
  static Color get textPrimary => textPrimaryColor;
  static Color get textSecondary => textSecondaryColor;
  static Color get divider => dividerColor;
  static Color get dividerDark => Color(0xFF555555);
  static Color get border => borderColor;
  static Color get borderDark => Color(0xFF444444);
}
