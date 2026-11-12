import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Text(
          'Farmer Profile',
          style: AppTheme.light().textTheme.headlineMedium,
        ),
      ),
    );
  }
}