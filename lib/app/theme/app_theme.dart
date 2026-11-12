import 'package:flutter/material.dart';

import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.actionPrimary,
      onPrimary: AppColors.textInverse,
      secondary: AppColors.actionSecondary,
      onSecondary: AppColors.surfaceDark,
      surface: AppColors.surfaceCanvas,
      onSurface: AppColors.textPrimary,
      error: AppColors.statusRisk,
      onError: AppColors.textInverse,
      outline: AppColors.borderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceCanvas,
      fontFamily: AppTypography.families['body'],
      textTheme: _textTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceCanvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _textTheme() {
    return TextTheme(
      displayLarge: AppTypography.scale['display']?.style,
      headlineMedium: AppTypography.scale['h1']?.style,
      headlineSmall: AppTypography.scale['h2']?.style,
      titleLarge: AppTypography.scale['h3']?.style,
      bodyLarge: AppTypography.scale['body']?.style,
      bodyMedium: AppTypography.scale['body']?.style,
      bodySmall: AppTypography.scale['small']?.style,
      labelLarge: AppTypography.scale['button']?.style,
      labelMedium: AppTypography.scale['smallStrong']?.style,
      labelSmall: AppTypography.scale['caption']?.style,
    );
  }
}
