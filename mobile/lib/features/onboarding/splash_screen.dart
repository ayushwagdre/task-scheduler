import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/launch_state.dart';
import '../../data/storage/token_store.dart';
import '../../data/storage/settings_store.dart';
import '../../platform/android_alarm/launch_intent.dart';
import '../../data/analytics/app_analytics.dart';

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
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Track install once (best-effort).
    try {
      await buildAnalytics().trackInstallOnce();
    } catch (_) {}

    // If launched from an alarm notification, capture taskId for post-login routing.
    try {
      final taskId = await LaunchIntent.consumeInitialTaskId();
      if (taskId != null) {
        LaunchState.pendingTaskId.value = taskId;
      }
    } catch (_) {
      // Ignore: platform channel not available (e.g. web).
    }

    final tokenStore = TokenStore(const FlutterSecureStorage());
    final token = await tokenStore.getAccessToken();
    final settings = SettingsStore(const FlutterSecureStorage());
    final hasSeenOnboarding = await settings.getHasSeenOnboarding();

    _timer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (token != null && token.isNotEmpty) {
        final pending = LaunchState.pendingTaskId.value;
        if (pending != null && pending.isNotEmpty) {
          context.go('${AppRoutes.alarm}?taskId=$pending');
          return;
        }
        context.go(AppRoutes.home);
      } else {
        context.go(hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding1);
      }
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

