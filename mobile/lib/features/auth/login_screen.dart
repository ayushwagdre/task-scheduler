import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/auth_text_field.dart';
import '../../app/widgets/glass_panel.dart';
import '../../app/launch_state.dart';
import '../../app/auth_state.dart';
import '../../data/api/api_client.dart';
import '../../data/storage/token_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  static const _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  late final ApiClient _api = ApiClient(
    baseUrl: _baseUrl,
    tokenStore: TokenStore(const FlutterSecureStorage()),
  );

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.postJson('/auth/login', {
        'email': _email.text.trim(),
        'password': _password.text.trim(),
      });
      final token = (data['accessToken'] ?? '').toString();
      if (token.isEmpty) throw ApiException('Missing token');
      await _api.tokenStore.setAccessToken(token);
      await authState.setLoggedIn(true);
      if (!mounted) return;
      final pending = LaunchState.pendingTaskId.value;
      if (pending != null && pending.isNotEmpty) {
        LaunchState.pendingTaskId.value = null;
        context.go('${AppRoutes.alarm}?taskId=$pending');
        return;
      }
      context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background decor (blurred orbs)
          Positioned(
            top: -140,
            left: -140,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withValues(alpha: 0.10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tertiary.withValues(alpha: 0.10),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand header
                      Text(
                        'DOORPAY',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.onSurface,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'DISCIPLINE IS THE ONLY CURRENCY',
                        style: AppTextStyles.labelCaps.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              label: 'Email',
                              controller: _email,
                              hintText: 'your@discipline.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.mail_outline,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'PASSWORD',
                                    style: AppTextStyles.labelCaps.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          context.push(AppRoutes.forgot);
                                        },
                                  child: Text(
                                    'FORGOT?',
                                    style: AppTextStyles.labelCaps.copyWith(
                                      fontSize: 10,
                                      letterSpacing: 2.0,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AuthTextField(
                              label: '',
                              controller: _password,
                              hintText: '••••••••',
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icons.lock_outline,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: AppTextStyles.bodyMd.copyWith(color: cs.error),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 56,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.onSurface,
                                  foregroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _loading ? null : _login,
                                child: Text(
                                  _loading ? 'LOGGING IN…' : 'LOGIN',
                                  style: AppTextStyles.cta.copyWith(letterSpacing: 2.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                      Text(
                        "Don't have an account?",
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                context.push(AppRoutes.signup);
                              },
                        child: Text(
                          'Sign up',
                          style: AppTextStyles.cta.copyWith(
                            color: AppColors.onSurface,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Keep debug info minimal but available during development.
                      Opacity(
                        opacity: 0.35,
                        child: Text(
                          'Backend: $_baseUrl',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

