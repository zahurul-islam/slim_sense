import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings (with Material Design naming aliases)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );

  // Legacy names (for backward compatibility)
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle heading2 = headlineMedium;
  static const TextStyle heading3 = headlineSmall;
  static const TextStyle heading4 = titleLarge;
  static const TextStyle heading5 = titleMedium;

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textPrimaryColor,
  );

  // Buttons
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhiteColor,
  );
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhiteColor,
  );
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhiteColor,
  );
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhiteColor,
  );

  // Stats
  static const TextStyle statsLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle statsMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle statsSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryColor,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryColor,
  );

  // Captions
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondaryColor,
  );
}
