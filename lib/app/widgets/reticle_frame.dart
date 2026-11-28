import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

/// Scan-reticle corners around [child], the motif shared by the logo,
/// Auth, Onboarding and the Scan screen.
class ReticleFrame extends StatelessWidget {
  const ReticleFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s4,
      vertical: AppSpacing.s3,
    ),
    this.arm = AppSpacing.s4,
  });

  final Widget child;
  final EdgeInsets padding;
  final double arm;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ReticlePainter(arm),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  _ReticlePainter(this.arm);

  final double arm;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.leaf
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final right = size.width;
    final bottom = size.height;
    final corners = [
      [Offset(0, arm), Offset.zero, Offset(arm, 0)],
      [Offset(right - arm, 0), Offset(right, 0), Offset(right, arm)],
      [Offset(0, bottom - arm), Offset(0, bottom), Offset(arm, bottom)],
      [
        Offset(right - arm, bottom),
        Offset(right, bottom),
        Offset(right, bottom - arm),
      ],
    ];
    for (final corner in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(corner[0].dx, corner[0].dy)
          ..lineTo(corner[1].dx, corner[1].dy)
          ..lineTo(corner[2].dx, corner[2].dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ReticlePainter oldDelegate) => oldDelegate.arm != arm;
}
