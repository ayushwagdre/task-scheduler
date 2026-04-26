import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/auth_state.dart';
import '../../data/api/api_client.dart';
import '../../data/storage/settings_store.dart';
import '../../data/storage/token_store.dart';
import '../../platform/android_alarm/android_alarm.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key, required this.taskId});

  final String? taskId;

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  static const _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  late final ApiClient _api = ApiClient(
    baseUrl: _baseUrl,
    tokenStore: TokenStore(const FlutterSecureStorage()),
    onUnauthorized: authState.logout,
  );
  late final SettingsStore _settings = SettingsStore(const FlutterSecureStorage());

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _task;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.taskId;
    if (id == null || id.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Missing taskId';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.getJson('/tasks/$id');
      _task = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markDone() async {
    final id = widget.taskId;
    if (id == null || id.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final remindersEnabled = await _settings.getRemindersEnabled();
      final updated = await _api.postJson('/tasks/$id/complete', {});
      final next = (updated['nextTriggerAt'] ?? '').toString();
      final title = (updated['title'] ?? _task?['title'] ?? 'Task').toString();

      // Reschedule the next reminder locally (Android only).
      if (remindersEnabled) {
        final dt = DateTime.tryParse(next);
        if (dt != null) {
          await AndroidAlarm.scheduleExactAlarm(
            taskId: id,
            triggerAtEpochMillis: dt.toLocal().millisecondsSinceEpoch,
            title: title.isEmpty ? 'Task' : title,
          );
        }
      } else {
        await AndroidAlarm.cancelAlarm(taskId: id);
      }

      if (!mounted) return;
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

    final title = (_task?['title'] ?? 'Task').toString();
    final id = widget.taskId ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text('DOORPAY', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Alarm', style: AppTextStyles.display.copyWith(fontSize: 40, color: Colors.white)),
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: AppTextStyles.bodyMd.copyWith(color: cs.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Opacity(
                          opacity: 0.5,
                          child: Text('taskId: $id', style: Theme.of(context).textTheme.bodySmall),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _load,
                            child: Text('RETRY', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      const Spacer(),
                      Text('Threat Level: High', style: AppTextStyles.labelCaps.copyWith(color: cs.error)),
                      const SizedBox(height: 8),
                      Text(title, style: AppTextStyles.display.copyWith(fontSize: 40, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text(
                        'Mark done to reschedule the next reminder.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: 0.5,
                        child: Text(
                          'Proof upload is mocked for now.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Spacer(),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _loading ? null : _markDone,
                  child: Text('MARK DONE', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
                ),
              ),
              const SizedBox(height: 18),
              Opacity(
                opacity: 0.4,
                child: Text(
                  'FAILURE IS NOT AN OPTION • ACCOUNTABILITY IS THE ONLY WAY',
                  style: AppTextStyles.labelCaps.copyWith(fontSize: 10, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

