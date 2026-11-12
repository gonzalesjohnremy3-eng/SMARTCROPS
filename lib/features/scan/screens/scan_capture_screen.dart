import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_theme.dart';

class ScanCaptureScreen extends StatelessWidget {
  const ScanCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Crop')),
      body: Center(
        child: Text(
          'Scan Capture',
          style: AppTheme.light().textTheme.headlineMedium,
        ),
      ),
    );
  }
}