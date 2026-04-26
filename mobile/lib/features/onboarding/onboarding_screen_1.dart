import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          // Background image approximation (Stitch uses a remote image). We use a gradient + overlay.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.70),
                    AppColors.surface.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          // Bottom glow
          Positioned(
            bottom: -120,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: AppColors.primary.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top app bar (simple)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Row(
                    children: [
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
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceContainerLow,
                        child: Icon(Icons.person, color: Colors.white.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP 01 / DISCIPLINE',
                        style: AppTextStyles.labelCaps.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'STOP SNOOZING\nYOUR LIFE.',
                        style: AppTextStyles.display.copyWith(
                          color: Colors.white,
                          fontSize: 44,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Every snooze button press is a micro-failure of character. Wake up, or pay the price. Literally.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            height: 4,
                            width: 48,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 4,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 4,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.go(AppRoutes.onboarding2);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('NEXT', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            context.go(AppRoutes.login);
                          },
                          child: Text(
                            'ALREADY A MEMBER? LOG IN',
                            style: AppTextStyles.cta.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

