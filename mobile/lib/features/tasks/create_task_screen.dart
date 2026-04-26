import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/auth_text_field.dart';
import '../../app/widgets/glass_panel.dart';
import '../../app/auth_state.dart';
import '../../data/api/api_client.dart';
import '../../data/storage/settings_store.dart';
import '../../data/storage/token_store.dart';
import '../../platform/android_alarm/android_alarm.dart';
import '../../platform/android_alarm/android_permissions.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  static const _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  final _title = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _loading = false;
  String? _error;

  late final ApiClient _api = ApiClient(
    baseUrl: _baseUrl,
    tokenStore: TokenStore(const FlutterSecureStorage()),
    onUnauthorized: authState.logout,
  );
  late final SettingsStore _settings = SettingsStore(const FlutterSecureStorage());

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final remindersEnabled = await _settings.getRemindersEnabled();
      if (remindersEnabled) {
        // Ask for notifications permission in-context (Android 13+). Best-effort.
        await AndroidPermissions.requestPostNotifications();
      }

      final resp = await _api.postJson('/tasks', {
        'title': _title.text.trim(),
        'timezone': 'Asia/Kolkata',
        'schedule': {'type': 'daily', 'hour': _time.hour, 'minute': _time.minute},
      });
      final id = (resp['id'] ?? '').toString();
      final next = (resp['nextTriggerAt'] ?? '').toString();
      // Best-effort local scheduling (Android only). If it fails, task still exists on backend.
      if (remindersEnabled && id.isNotEmpty && next.isNotEmpty) {
        final dt = DateTime.tryParse(next);
        if (dt != null) {
          final canExact = await AndroidPermissions.canScheduleExactAlarms();
          if (!canExact) {
            // Allow user to continue without exact alarms; deep link is available in Profile.
          }
          await AndroidAlarm.scheduleExactAlarm(
            taskId: id,
            triggerAtEpochMillis: dt.toLocal().millisecondsSinceEpoch,
            title: _title.text.trim().isEmpty ? 'Task' : _title.text.trim(),
          );
        }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create task'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _loading ? null : () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('SET YOUR STAKE', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
              const SizedBox(height: 8),
              Text(
                'Define the task or face the friction.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Task title',
                controller: _title,
                hintText: 'e.g., 5AM Deep Work Session',
                prefixIcon: Icons.edit,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'DEADLINE',
                      style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            final picked = await showTimePicker(context: context, initialTime: _time);
                            if (picked != null) setState(() => _time = picked);
                          },
                    child: Text(
                      _time.format(context),
                      style: AppTextStyles.cta.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: AppTextStyles.bodyMd.copyWith(color: cs.error)),
              ],
              const Spacer(),
              SizedBox(
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _save,
                  child: Text(_loading ? 'CREATING…' : 'CREATE TASK', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

