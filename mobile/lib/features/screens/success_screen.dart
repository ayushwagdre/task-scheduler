import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 72, color: AppColors.tertiary),
              const SizedBox(height: 16),
              Text('SUCCESS', style: AppTextStyles.display.copyWith(fontSize: 40, color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                'You kept the chain alive.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text('BACK HOME', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

