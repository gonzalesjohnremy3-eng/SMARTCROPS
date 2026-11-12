import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

Map<String, dynamic> _tokens() {
  final file = File('design/tokens.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Color _colorFromToken(String value) {
  if (value.startsWith('#')) {
    final hex = value.substring(1).padLeft(8, 'F').toUpperCase();
    return Color(int.parse(hex, radix: 16));
  }

  final match = RegExp(
    r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)',
  ).firstMatch(value);
  if (match == null) {
    throw FormatException('Unsupported color token: $value');
  }
  final alpha = (double.parse(match.group(4)!) * 255).round();
  return Color.fromARGB(
    alpha,
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

void main() {
  test('brand colors match the approved design tokens', () {
    final expected = (_tokens()['color'] as Map<String, dynamic>)['brand']
        as Map<String, dynamic>;

    for (final entry in expected.entries) {
      expect(
        AppColors.brand[entry.key],
        _colorFromToken(entry.value as String),
        reason: 'Brand token ${entry.key} drifted from design/tokens.json',
      );
    }
  });

  test('semantic colors match the approved design tokens', () {
    final expected = (_tokens()['color'] as Map<String, dynamic>)['semantic']
        as Map<String, dynamic>;

    for (final entry in expected.entries) {
      expect(
        AppColors.semantic[entry.key],
        _colorFromToken(entry.value as String),
        reason: 'Semantic token ${entry.key} drifted from design/tokens.json',
      );
    }
  });

  test('spacing and radius scales match the approved design tokens', () {
    final tokens = _tokens();
    final spacing = tokens['spacing'] as Map<String, dynamic>;
    final radius = tokens['radius'] as Map<String, dynamic>;

    for (final entry in spacing.entries) {
      expect(
        AppSpacing.scale[entry.key],
        (entry.value as num).toDouble(),
        reason: 'Spacing token ${entry.key} drifted from design/tokens.json',
      );
    }
    for (final entry in radius.entries) {
      expect(
        AppRadius.scale[entry.key],
        (entry.value as num).toDouble(),
        reason: 'Radius token ${entry.key} drifted from design/tokens.json',
      );
    }
  });

  test('layout breakpoints and limits match the approved design tokens', () {
    final layout = _tokens()['layout'] as Map<String, dynamic>;
    final breakpoints = layout['breakpoints'] as Map<String, dynamic>;
    final gutters = layout['gutters'] as Map<String, dynamic>;
    final maxWidths = layout['maxWidths'] as Map<String, dynamic>;
    final navigation = layout['navigation'] as Map<String, dynamic>;

    for (final entry in breakpoints.entries) {
      expect(
        AppLayout.breakpoints[entry.key],
        (entry.value as num).toDouble(),
        reason: 'Breakpoint ${entry.key} drifted from design/tokens.json',
      );
    }
    for (final entry in gutters.entries) {
      expect(
        AppLayout.gutters[entry.key],
        (entry.value as num).toDouble(),
        reason: 'Gutter ${entry.key} drifted from design/tokens.json',
      );
    }
    for (final entry in maxWidths.entries) {
      expect(
        AppLayout.maxWidths[entry.key],
        (entry.value as num).toDouble(),
        reason: 'Max width ${entry.key} drifted from design/tokens.json',
      );
    }
    for (final entry in navigation.entries) {
      expect(
        AppLayout.navigation[entry.key],
        (entry.value as num).toDouble(),
        reason: 'Navigation token ${entry.key} drifted from design/tokens.json',
      );
    }

    expect(AppLayout.touchTarget, layout['touchTarget']);
    expect(AppLayout.minimumTextScale, layout['minimumTextScale']);
    expect(
      AppLayout.maximumSupportedTextScale,
      layout['maximumSupportedTextScale'],
    );
  });

  test('typography scale matches the approved design tokens', () {
    final typography = _tokens()['typography'] as Map<String, dynamic>;
    final families = typography['families'] as Map<String, dynamic>;
    final weights = typography['weights'] as Map<String, dynamic>;
    final scale = typography['scale'] as Map<String, dynamic>;

    expect(AppTypography.families['display'], families['display']);
    expect(AppTypography.families['body'], families['body']);
    for (final entry in weights.entries) {
      expect(
        AppTypography.weights[entry.key]?.value,
        entry.value,
        reason: 'Font weight ${entry.key} drifted from design/tokens.json',
      );
    }

    for (final entry in scale.entries) {
      final token = entry.value as Map<String, dynamic>;
      final style = AppTypography.scale[entry.key]!;
      final family = token['family'] as String;

      expect(
        style.family,
        AppTypography.families[family],
        reason: 'Family for ${entry.key} drifted from design/tokens.json',
      );
      expect(
        style.size,
        (token['size'] as num).toDouble(),
        reason: 'Size for ${entry.key} drifted from design/tokens.json',
      );
      expect(
        style.lineHeight,
        (token['lineHeight'] as num).toDouble(),
        reason: 'Line height for ${entry.key} drifted from design/tokens.json',
      );
      expect(
        style.weight.value,
        token['weight'],
        reason: 'Weight for ${entry.key} drifted from design/tokens.json',
      );
      expect(
        style.letterSpacing,
        (token['letterSpacing'] as num).toDouble(),
        reason: 'Letter spacing for ${entry.key} drifted from tokens',
      );
      expect(
        style.tabularFigures,
        token['numeric'] == 'tabular',
        reason: 'Numeric style for ${entry.key} drifted from tokens',
      );
    }
  });

  test('required text and action pairs meet WCAG AA contrast', () {
    final pairs = <(Color, Color)>[
      (AppColors.textPrimary, AppColors.surfaceCanvas),
      (AppColors.textPrimary, AppColors.surfaceRaised),
      (AppColors.textSecondary, AppColors.surfaceRaised),
      (AppColors.textInverse, AppColors.actionPrimary),
      (AppColors.statusRisk, AppColors.surfaceRaised),
      (AppColors.statusInfo, AppColors.surfaceRaised),
      (AppColors.textPrimary, AppColors.statusWatch),
      (AppColors.focusRing, AppColors.surfaceDark),
    ];

    for (final (foreground, background) in pairs) {
      expect(
        AppContrast.ratio(foreground, background),
        greaterThanOrEqualTo(4.5),
        reason: 'Contrast failed for $foreground on $background',
      );
    }
  });

  test('light theme applies the approved color and type tokens', () {
    final theme = AppTheme.light();

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.actionPrimary);
    expect(theme.colorScheme.onPrimary, AppColors.textInverse);
    expect(theme.colorScheme.surface, AppColors.surfaceCanvas);
    expect(theme.scaffoldBackgroundColor, AppColors.surfaceCanvas);
    expect(theme.colorScheme.error, AppColors.statusRisk);
    expect(theme.textTheme.bodyMedium?.fontSize, 16);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Public Sans');
    expect(theme.textTheme.headlineMedium?.fontFamily, 'Fraunces');
  });
}
