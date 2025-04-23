import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppColors.primaryDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: Colors.white),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: Colors.white,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(color: Colors.white),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: Colors.white,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: Colors.white,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: Colors.white,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(color: Colors.white),
        titleMedium: AppTypography.titleMedium.copyWith(color: Colors.white),
        titleSmall: AppTypography.titleSmall.copyWith(color: Colors.white),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.white),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: Colors.white),
        bodySmall: AppTypography.bodySmall.copyWith(color: Colors.white70),
        labelLarge: AppTypography.labelLarge.copyWith(color: Colors.white),
        labelMedium: AppTypography.labelMedium.copyWith(color: Colors.white),
        labelSmall: AppTypography.labelSmall.copyWith(color: Colors.white70),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryDark,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
