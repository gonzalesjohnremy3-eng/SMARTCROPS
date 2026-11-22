import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';

enum CropGlassTone { raised, dark, capture }

class CropGlassSurface extends StatelessWidget {
  const CropGlassSurface({
    super.key,
    required this.child,
    this.tone = CropGlassTone.raised,
    this.blur = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(CropRadius.lg)),
    this.padding = const EdgeInsets.all(CropSpacing.s4),
  });

  final Widget child;
  final CropGlassTone tone;
  final bool blur;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  Color get _tint => switch (tone) {
    CropGlassTone.raised => CropGlass.raised,
    CropGlassTone.dark => CropGlass.dark,
    CropGlassTone.capture => CropGlass.capture,
  };

  Color get _border =>
      tone == CropGlassTone.raised ? CropGlass.border : CropGlass.darkBorder;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _tint,
          borderRadius: borderRadius,
          border: Border.all(color: _border),
        ),
        child: blur
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: CropGlass.sigma,
                  sigmaY: CropGlass.sigma,
                ),
                child: content,
              )
            : content,
      ),
    );
  }
}
