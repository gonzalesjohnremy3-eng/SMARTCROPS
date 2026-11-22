import 'package:flutter/material.dart';
import 'package:smart_crops/cropcare/screens/cropcare_shell.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';
import 'package:smart_crops/cropcare/widgets/crop_glass_surface.dart';

// shortcut: hardcoded English on the isolated comparison branch; localize before merging.
class CropCareScanScreen extends StatelessWidget {
  const CropCareScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CropCareShell(
      index: 1,
      child: Column(
        children: [
          AppBar(title: const Text('Scan Crop')),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: CropSpacing.s8),
              child: Column(
                children: [
                  Container(
                    height: 420,
                    margin: const EdgeInsets.symmetric(
                      horizontal: CropSpacing.s6,
                      vertical: CropSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(CropRadius.lg),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/overlays/scan.webp'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.fromBorderSide(
                                  BorderSide(
                                    color: CropColors.accent,
                                    width: 3,
                                  ),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(CropRadius.md),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(CropSpacing.s4),
                            child: Text(
                              'Fill the frame with the affected leaf',
                              style: TextStyle(
                                color: CropColors.inverse,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CropSpacing.s6,
                    ),
                    child: CropGlassSurface(
                      tone: CropGlassTone.capture,
                      padding: const EdgeInsets.symmetric(
                        horizontal: CropSpacing.s5,
                        vertical: CropSpacing.s3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Import',
                              style: TextStyle(color: CropColors.inverse),
                            ),
                          ),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: CropColors.accent,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Flash',
                              style: TextStyle(color: CropColors.inverse),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(CropSpacing.s6),
                    child: Text(
                      'Hold steady. A clear photo gives a more useful diagnosis.',
                      style: TextStyle(color: CropColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
