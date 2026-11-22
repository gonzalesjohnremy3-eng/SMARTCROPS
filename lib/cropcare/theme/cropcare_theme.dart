import 'package:flutter/material.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';

class CropCareTheme {
  CropCareTheme._();

  static ThemeData light() {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: CropColors.primary,
      onPrimary: CropColors.inverse,
      secondary: CropColors.accent,
      onSecondary: CropColors.textPrimary,
      error: CropColors.critical,
      onError: CropColors.inverse,
      surface: CropColors.surface,
      onSurface: CropColors.textPrimary,
      surfaceContainerHighest: CropColors.surfaceSubtle,
      outline: CropColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: CropColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: CropColors.bg,
        foregroundColor: CropColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CropColors.accent,
          foregroundColor: CropColors.textPrimary,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CropRadius.md),
          ),
        ),
      ),
    );
  }
}
