import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../data/analytics/app_analytics.dart';
import '../../data/storage/settings_store.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: AppColors.surface)),
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.error.withValues(alpha: 0.06),
                boxShadow: [
                  BoxShadow(
                    color: cs.error.withValues(alpha: 0.10),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.onboarding2);
                          }
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceContainerLow,
                        child: Icon(Icons.person, color: Colors.white.withValues(alpha: 0.75)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'DOORPAY',
                        style: AppTextStyles.cta.copyWith(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.local_fire_department, color: Colors.white),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'FAIL = PAY',
                    style: AppTextStyles.display.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Accountability isn't free. Miss your targets and your penalty triggers instantly.",
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(active: false),
                      const SizedBox(width: 8),
                      _dot(active: false),
                      const SizedBox(width: 8),
                      _dot(active: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final settings = SettingsStore(const FlutterSecureStorage());
                        await settings.setHasSeenOnboarding(true);
                        try {
                          await buildAnalytics().trackOnboardingCompleted();
                        } catch (_) {}
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      child: Text('GET STARTED', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
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

  Widget _dot({required bool active}) {
    return Container(
      height: 4,
      width: active ? 48 : 32,
      decoration: BoxDecoration(
        color: active ? Colors.white : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

