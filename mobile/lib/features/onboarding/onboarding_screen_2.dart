import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(color: AppColors.surface),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.20,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tertiary.withValues(alpha: 0.05),
                    blurRadius: 150,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
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
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceContainerLow,
                        child: Icon(Icons.person, color: Colors.white.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 4,
                              width: 32,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                              width: 32,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Complete Tasks, Not Just Alarms',
                          style: AppTextStyles.cta.copyWith(
                            fontSize: 28,
                            height: 1.25,
                            letterSpacing: -0.2,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No more snooze button loops. Prove your discipline with photo verification or lose your stake.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),

                        // Minimal “task card” visualization (Material-adapted).
                        _taskCard(
                          leadingColor: AppColors.tertiary.withValues(alpha: 0.20),
                          leadingIcon: Icons.check_circle,
                          leadingIconColor: AppColors.tertiary,
                          title: 'Morning Workout',
                          subtitle: 'VERIFIED AT 06:15 AM',
                          trailing: const Icon(Icons.image, color: Colors.white54),
                          borderSide: BorderSide(color: AppColors.tertiary, width: 3),
                        ),
                        const SizedBox(height: 12),
                        _taskCard(
                          leadingColor: AppColors.primary.withValues(alpha: 0.20),
                          leadingIcon: Icons.camera_alt,
                          leadingIconColor: AppColors.primary,
                          title: 'Hydrate & Journal',
                          subtitle: 'TIME REMAINING: 04:22',
                          trailing: Text(
                            '- \$5.00',
                            style: AppTextStyles.cta.copyWith(color: cs.error),
                          ),
                          highlight: true,
                        ),
                        const SizedBox(height: 12),
                        _taskCard(
                          leadingColor: AppColors.surfaceContainerLow,
                          leadingIcon: Icons.schedule,
                          leadingIconColor: AppColors.onSurfaceVariant,
                          title: 'Cold Shower',
                          subtitle: 'UNLOCKS AT 08:30 AM',
                          trailing: const SizedBox.shrink(),
                          dimmed: true,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              // Step 3 not requested yet; go to Login.
                              context.go(AppRoutes.onboarding3);
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
                        const SizedBox(height: 10),
                        Text(
                          'STEP 2 OF 3',
                          style: AppTextStyles.labelCaps.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.40),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard({
    required Color leadingColor,
    required IconData leadingIcon,
    required Color leadingIconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    BorderSide? borderSide,
    bool highlight = false,
    bool dimmed = false,
  }) {
    final base = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.20),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: leadingColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(leadingIcon, color: leadingIconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cta.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.labelCaps.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.8,
                    color: highlight ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    final wrapped = dimmed
        ? Opacity(opacity: 0.55, child: base)
        : base;

    if (borderSide == null) return wrapped;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border(left: borderSide),
      ),
      child: wrapped,
    );
  }
}

