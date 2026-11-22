import 'package:flutter/material.dart';
import 'package:smart_crops/cropcare/screens/cropcare_shell.dart';
import 'package:smart_crops/cropcare/theme/cropcare_tokens.dart';
import 'package:smart_crops/cropcare/widgets/crop_glass_surface.dart';

// shortcut: hardcoded English on the isolated comparison branch; localize before merging.
class CropCareProfileScreen extends StatelessWidget {
  const CropCareProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CropCareShell(
      index: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: CropSpacing.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(title: const Text('Profile')),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CropSpacing.s6,
                vertical: CropSpacing.s5,
              ),
              child: CropGlassSurface(
                tone: CropGlassTone.dark,
                padding: const EdgeInsets.all(CropSpacing.s5),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: CropColors.inverse,
                      size: 28,
                    ),
                    const SizedBox(width: CropSpacing.s4),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Farmer',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: CropColors.inverse,
                            ),
                          ),
                          Text(
                            'San Isidro Plot · 2 crops',
                            style: TextStyle(color: CropColors.inverse),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CropSpacing.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CropColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: CropSpacing.s3),
                  _Setting(title: 'Main crops', value: 'Rice, Pechay'),
                  SizedBox(height: CropSpacing.s5),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: CropColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: CropSpacing.s3),
                  _Setting(
                    title: 'Notifications',
                    value: 'Advisories and scan reminders',
                  ),
                  SizedBox(height: CropSpacing.s3),
                  _Setting(title: 'Language', value: 'English'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Setting extends StatelessWidget {
  const _Setting({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(value, style: const TextStyle(color: CropColors.textSecondary)),
        ],
      ),
    );
  }
}
