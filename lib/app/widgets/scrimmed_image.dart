import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

/// A cover-fitted photograph with an explicit scrim painted above it.
///
/// The scrim is a real overlay rather than a [BlendMode.darken] colour filter,
/// so its strength is predictable and can be tuned to keep overlaid icons
/// legible on bright photography.
class ScrimmedImage extends StatelessWidget {
  const ScrimmedImage({
    super.key,
    required this.imagePath,
    this.borderRadius = BorderRadius.zero,
    this.scrim = AppColors.imageScrim,
    this.child,
  });

  final String imagePath;
  final BorderRadius borderRadius;
  final Color scrim;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: scrim,
        ),
        child: child,
      ),
    );
  }
}
