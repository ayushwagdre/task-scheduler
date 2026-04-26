import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('VERIFICATION (MOCK)', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
            const SizedBox(height: 12),
            Text(
              'Photo upload is intentionally disabled for the tasks+alarms MVP.\n\n'
              'For now, use “Mark done” from the Alarm screen.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const Spacer(),
            SizedBox(
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
    );
  }
}

