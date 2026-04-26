import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../platform/android_alarm/android_alarm.dart';
import '../../data/api/api_client.dart';
import '../../data/storage/settings_store.dart';
import '../../data/storage/token_store.dart';
import '../../platform/android_alarm/android_permissions.dart';
import '../../app/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  late final TokenStore _tokenStore = TokenStore(const FlutterSecureStorage());
  late final ApiClient _api = ApiClient(
    baseUrl: _baseUrl,
    tokenStore: _tokenStore,
    onUnauthorized: authState.logout,
  );
  late final SettingsStore _settings = SettingsStore(const FlutterSecureStorage());

  bool _working = false;
  bool _loadingPrefs = true;
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final v = await _settings.getRemindersEnabled();
    if (!mounted) return;
    setState(() {
      _remindersEnabled = v;
      _loadingPrefs = false;
    });
  }

  Future<void> _signOut() async {
    setState(() => _working = true);
    await authState.logout();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This permanently deletes your account and tasks from the server.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _working = true);
    try {
      await _api.deleteJson('/me');
    } catch (_) {
      // Even if server deletion fails, clear local tokens to avoid lock-in.
    } finally {
      await authState.logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  Future<void> _toggleReminders(bool v) async {
    setState(() {
      _working = true;
      _remindersEnabled = v;
    });
    await _settings.setRemindersEnabled(v);

    try {
      final data = await _api.getJson('/tasks');
      final items = (data['items'] as List?) ?? const [];

      if (!v) {
        // Bulk cancel alarms for all tasks.
        for (final it in items) {
          if (it is! Map) continue;
          final id = (it['id'] ?? '').toString();
          if (id.isEmpty) continue;
          await AndroidAlarm.cancelAlarm(taskId: id);
        }
        return;
      }

      // Enabling reminders: request perms and bulk schedule all upcoming triggers.
      await AndroidPermissions.requestPostNotifications();

      final canExact = await AndroidPermissions.canScheduleExactAlarms();
      if (!canExact && mounted) {
        final go = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Enable exact alarms?'),
            content: const Text(
              'To fire reminders at the exact time you choose, Android requires a special app access.\n\n'
              'You can still use the app without this, but reminders may be delayed.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Not now')),
              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Open settings')),
            ],
          ),
        );
        if (go == true) {
          await AndroidPermissions.openExactAlarmSettings();
        }
      }

      for (final it in items) {
        if (it is! Map) continue;
        final t = it.cast<String, dynamic>();
        final id = (t['id'] ?? '').toString();
        final title = (t['title'] ?? 'Task').toString();
        final next = (t['nextTriggerAt'] ?? '').toString();
        final active = t['active'] == true;
        if (!active || id.isEmpty || next.isEmpty) continue;
        final dt = DateTime.tryParse(next);
        if (dt == null) continue;
        await AndroidAlarm.scheduleExactAlarm(
          taskId: id,
          triggerAtEpochMillis: dt.toLocal().millisecondsSinceEpoch,
          title: title.isEmpty ? 'Task' : title,
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Icon(Icons.person, color: Colors.white.withValues(alpha: 0.8), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your profile', style: AppTextStyles.cta.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Settings and account actions will live here.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loadingPrefs)
              const LinearProgressIndicator()
            else
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: const Text('Task reminders'),
                subtitle: Text(
                  _remindersEnabled
                      ? 'Enabled (Android notifications + alarms)'
                      : 'Disabled (no local reminders)',
                ),
                value: _remindersEnabled,
                onChanged: _working ? null : _toggleReminders,
              ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Exact alarms access'),
              subtitle: const Text('Recommended for time-sensitive reminders'),
              onTap: _working
                  ? null
                  : () async {
                      await AndroidPermissions.openExactAlarmSettings();
                    },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Streak stats'),
              onTap: () => context.go(AppRoutes.streaks),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Data & privacy'),
              onTap: () => context.go(AppRoutes.privacy),
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Alarm screen (demo)'),
              onTap: () => context.go(AppRoutes.alarm),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: _working ? null : _signOut,
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Delete account',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: const Text('Permanently delete your account and data'),
              onTap: _working ? null : _deleteAccount,
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

