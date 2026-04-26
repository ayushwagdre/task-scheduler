import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'onboarding_screen_1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen1()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black),
          ),
          // Subtle center glow
          Center(
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 120,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Outer ring + inner badge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.12),
                                blurRadius: 25,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'DOORPAY',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.labelCaps.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 2.2,
                        ),
                        children: [
                          const TextSpan(text: 'COMPLETE IT. '),
                          TextSpan(text: 'OR PAY.', style: TextStyle(color: cs.error)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Loading bar
                    SizedBox(
                      width: 48,
                      height: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withValues(alpha: 0.10),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.40),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            left: 24,
            child: Text(
              'system_v4.0.2',
              style: AppTextStyles.labelCaps.copyWith(
                fontSize: 10,
                letterSpacing: 2.0,
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Text(
              '00:00:00:00',
              style: AppTextStyles.labelCaps.copyWith(
                fontSize: 10,
                letterSpacing: 2.0,
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

