import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_theme.dart';

class FieldCalendarScreen extends StatelessWidget {
  const FieldCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Field Calendar')),
      body: Center(
        child: Text(
          'Field Calendar',
          style: AppTheme.light().textTheme.headlineMedium,
        ),
      ),
    );
  }
}