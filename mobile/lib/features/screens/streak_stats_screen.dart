import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';

class StreakStatsScreen extends StatelessWidget {
  const StreakStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT STREAK', style: AppTextStyles.labelCaps.copyWith(color: AppColors.tertiary)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('14', style: AppTextStyles.display.copyWith(color: Colors.white)),
                const SizedBox(width: 8),
                Text('DAYS', style: AppTextStyles.cta.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "This screen is UI-first; we’ll wire real streaks once `/streaks` is implemented in the template backend.",
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                onPressed: () => context.go(AppRoutes.home),
                child: Text('BACK', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

