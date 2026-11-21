import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

enum GlassTone { canvas, raised, dark, accent }

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.tone = GlassTone.raised,
    this.blur = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.card)),
    this.padding = const EdgeInsets.all(AppSpacing.s4),
  });

  final Widget child;
  final GlassTone tone;
  final bool blur;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  Color get _tint => switch (tone) {
        GlassTone.canvas => AppGlass.tintCanvas,
        GlassTone.raised => AppGlass.tintRaised,
        GlassTone.dark => AppGlass.tintDark,
        GlassTone.accent => AppGlass.tintAccent,
      };

  @override
  Widget build(BuildContext context) {
    final sigma = MediaQuery.sizeOf(context).width >= AppLayout.breakpoints['expanded']!
        ? AppGlass.sigmaExpanded
        : AppGlass.sigmaCompact;

    final content = Padding(padding: padding, child: child);

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _tint,
          borderRadius: borderRadius,
          border: Border.all(color: AppGlass.border),
        ),
        child: blur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: content,
              )
            : content,
      ),
    );
  }
}
