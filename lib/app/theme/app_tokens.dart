import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const forestInk = Color(0xFF12372A);
  static const canopy = Color(0xFF1F6B45);
  static const leaf = Color(0xFF7AC943);
  static const mist = Color(0xFFF2F6EC);
  static const paper = Color(0xFFFFFDF7);
  static const palay = Color(0xFFD9A441);
  static const clay = Color(0xFFB4482E);
  static const rain = Color(0xFF3B6E8F);

  static const brand = <String, Color>{
    'forestInk': forestInk,
    'canopy': canopy,
    'leaf': leaf,
    'mist': mist,
    'paper': paper,
    'palay': palay,
    'clay': clay,
    'rain': rain,
  };

  static const textPrimary = Color(0xFF12372A);
  static const textSecondary = Color(0xFF5C6B62);
  static const textMuted = Color(0xFF7A877E);
  static const textInverse = Color(0xFFFFFDF7);
  static const surfaceCanvas = Color(0xFFF2F6EC);
  static const surfaceRaised = Color(0xFFFFFDF7);
  static const surfaceSunken = Color(0xFFE9EFE4);
  static const surfaceDark = Color(0xFF12372A);
  static const borderSubtle = Color(0xFFDCE5DA);
  static const borderStrong = Color(0xFFA8B5AC);
  static const actionPrimary = Color(0xFF1F6B45);
  static const actionPrimaryPressed = Color(0xFF185537);
  static const actionPrimaryDisabled = Color(0xFFA8B5AC);
  static const actionSecondary = Color(0xFF7AC943);
  static const focusRing = Color(0xFF7AC943);
  static const overlayScrim = Color(0x8C12372A);
  static const statusHealthy = Color(0xFF1F6B45);
  static const statusWatch = Color(0xFFD9A441);
  static const statusRisk = Color(0xFFB4482E);
  static const statusInfo = Color(0xFF3B6E8F);
  static const statusCriticalSurface = Color(0xFFFBEDE9);
  static const statusWarningSurface = Color(0xFFFBF3E2);
  static const statusInfoSurface = Color(0xFFEAF1F5);
  static const statusHealthySurface = Color(0xFFE8F2EA);

  static const semantic = <String, Color>{
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'textMuted': textMuted,
    'textInverse': textInverse,
    'surfaceCanvas': surfaceCanvas,
    'surfaceRaised': surfaceRaised,
    'surfaceSunken': surfaceSunken,
    'surfaceDark': surfaceDark,
    'borderSubtle': borderSubtle,
    'borderStrong': borderStrong,
    'actionPrimary': actionPrimary,
    'actionPrimaryPressed': actionPrimaryPressed,
    'actionPrimaryDisabled': actionPrimaryDisabled,
    'actionSecondary': actionSecondary,
    'focusRing': focusRing,
    'overlayScrim': overlayScrim,
    'statusHealthy': statusHealthy,
    'statusWatch': statusWatch,
    'statusRisk': statusRisk,
    'statusInfo': statusInfo,
    'statusCriticalSurface': statusCriticalSurface,
    'statusWarningSurface': statusWarningSurface,
    'statusInfoSurface': statusInfoSurface,
    'statusHealthySurface': statusHealthySurface,
  };
}

class AppSpacing {
  AppSpacing._();

  static const s0 = 0.0;
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
  static const s16 = 64.0;

  static const scale = <String, double>{
    '0': s0,
    '1': s1,
    '2': s2,
    '3': s3,
    '4': s4,
    '5': s5,
    '6': s6,
    '8': s8,
    '10': s10,
    '12': s12,
    '16': s16,
  };
}

class AppRadius {
  AppRadius._();

  static const none = 0.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const button = 10.0;
  static const card = 16.0;
  static const sheet = 24.0;
  static const hero = 28.0;
  static const pill = 999.0;

  static const scale = <String, double>{
    'none': none,
    'xs': xs,
    'sm': sm,
    'button': button,
    'card': card,
    'sheet': sheet,
    'hero': hero,
    'pill': pill,
  };
}

class AppLayout {
  AppLayout._();

  static const breakpoints = <String, double>{
    'compact': 0,
    'medium': 600,
    'expanded': 840,
    'large': 1200,
  };

  static const gutters = <String, double>{
    'compact': 16,
    'medium': 24,
    'expanded': 32,
  };

  static const maxWidths = <String, double>{
    'form': 560,
    'reading': 720,
    'dashboard': 1120,
    'wide': 1440,
  };

  static const navigation = <String, double>{
    'compactHeight': 80,
    'scanFabSize': 64,
    'railWidthCollapsed': 96,
    'railWidthExtended': 240,
  };

  static const touchTarget = 48.0;
  static const minimumTextScale = 1.0;
  static const maximumSupportedTextScale = 2.0;
}

class AppContrast {
  AppContrast._();

  static double ratio(Color foreground, Color background) {
    final first = foreground.computeLuminance();
    final second = background.computeLuminance();
    final lighter = first > second ? first : second;
    final darker = first > second ? second : first;
    return (lighter + 0.05) / (darker + 0.05);
  }
}

class AppTypeToken {
  const AppTypeToken({
    required this.family,
    required this.size,
    required this.lineHeight,
    required this.weight,
    required this.letterSpacing,
    this.tabularFigures = false,
  });

  final String family;
  final double size;
  final double lineHeight;
  final FontWeight weight;
  final double letterSpacing;
  final bool tabularFigures;

  TextStyle get style => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    fontFeatures: tabularFigures
        ? const [FontFeature.tabularFigures()]
        : null,
  );
}

class AppTypography {
  AppTypography._();

  static const families = <String, String>{
    'display': 'Fraunces',
    'body': 'Public Sans',
  };

  static const weights = <String, FontWeight>{
    'regular': FontWeight.w400,
    'medium': FontWeight.w500,
    'semibold': FontWeight.w600,
    'bold': FontWeight.w700,
  };

  static const scale = <String, AppTypeToken>{
    'display': AppTypeToken(
      family: 'Fraunces',
      size: 32,
      lineHeight: 36,
      weight: FontWeight.w600,
      letterSpacing: -0.4,
    ),
    'h1': AppTypeToken(
      family: 'Fraunces',
      size: 26,
      lineHeight: 32,
      weight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    'h2': AppTypeToken(
      family: 'Public Sans',
      size: 22,
      lineHeight: 28,
      weight: FontWeight.w600,
      letterSpacing: -0.1,
    ),
    'h3': AppTypeToken(
      family: 'Public Sans',
      size: 18,
      lineHeight: 24,
      weight: FontWeight.w600,
      letterSpacing: 0,
    ),
    'body': AppTypeToken(
      family: 'Public Sans',
      size: 16,
      lineHeight: 24,
      weight: FontWeight.w400,
      letterSpacing: 0,
    ),
    'bodyStrong': AppTypeToken(
      family: 'Public Sans',
      size: 16,
      lineHeight: 24,
      weight: FontWeight.w600,
      letterSpacing: 0,
    ),
    'small': AppTypeToken(
      family: 'Public Sans',
      size: 14,
      lineHeight: 20,
      weight: FontWeight.w400,
      letterSpacing: 0,
    ),
    'smallStrong': AppTypeToken(
      family: 'Public Sans',
      size: 14,
      lineHeight: 20,
      weight: FontWeight.w600,
      letterSpacing: 0,
    ),
    'caption': AppTypeToken(
      family: 'Public Sans',
      size: 12,
      lineHeight: 16,
      weight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    'data': AppTypeToken(
      family: 'Public Sans',
      size: 13,
      lineHeight: 18,
      weight: FontWeight.w600,
      letterSpacing: 0,
      tabularFigures: true,
    ),
    'button': AppTypeToken(
      family: 'Public Sans',
      size: 16,
      lineHeight: 20,
      weight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
  };
}
