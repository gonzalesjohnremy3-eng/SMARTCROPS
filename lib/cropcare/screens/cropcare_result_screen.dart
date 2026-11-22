import 'package:flutter/material.dart';
import 'package:smart_crops/cropcare/screens/cropcare_shell.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';
import 'package:smart_crops/cropcare/widgets/crop_glass_surface.dart';

// shortcut: hardcoded English on the isolated comparison branch; localize before merging.
class CropCareResultScreen extends StatelessWidget {
  const CropCareResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CropCareShell(
      index: 2,
      child: Column(
        children: [
          AppBar(title: const Text('Scan Result')),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: CropSpacing.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CropSpacing.s6,
                    ),
                    child: CropGlassSurface(
                      tone: CropGlassTone.raised,
                      padding: const EdgeInsets.all(CropSpacing.s5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: CropSpacing.s3,
                              vertical: CropSpacing.s2,
                            ),
                            decoration: BoxDecoration(
                              color: CropColors.primarySoft,
                              borderRadius: BorderRadius.circular(
                                CropRadius.pill,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: CropColors.healthy,
                                ),
                                SizedBox(width: CropSpacing.s2),
                                Text(
                                  'Healthy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CropColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: CropSpacing.s3),
                          const Text(
                            'No disease detected',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: CropColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Pechay · scanned today',
                            style: TextStyle(color: CropColors.textSecondary),
                          ),
                          const SizedBox(height: CropSpacing.s4),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '94%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: CropColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: CropSpacing.s2),
                              Text(
                                'confidence',
                                style: TextStyle(
                                  color: CropColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(CropSpacing.s6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What to do next',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: CropColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: CropSpacing.s3),
                        _Step(
                          title: 'Keep watering in the morning',
                          body: 'Check the soil before the next irrigation.',
                        ),
                        _Step(
                          title: 'Watch for new spots',
                          body:
                              'Scan again in seven days or earlier if leaves change.',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CropSpacing.s6,
                    ),
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('Save to Health Log'),
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Scan again')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: CropSpacing.s3),
      padding: const EdgeInsets.all(CropSpacing.s4),
      decoration: BoxDecoration(
        color: CropColors.surface,
        border: Border.all(color: CropColors.border),
        borderRadius: BorderRadius.circular(CropRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(body, style: const TextStyle(color: CropColors.textSecondary)),
        ],
      ),
    );
  }
}
