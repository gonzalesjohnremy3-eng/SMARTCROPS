import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_theme.dart';

class CropsScreen extends StatelessWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crops')),
      body: Center(
        child: Text(
          'My Crops',
          style: AppTheme.light().textTheme.headlineMedium,
        ),
      ),
    );
  }
}