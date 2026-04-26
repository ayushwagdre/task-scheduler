import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_state.dart';
import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/auth_text_field.dart';
import '../../app/widgets/glass_panel.dart';
import '../../data/api/api_client.dart';
import '../../data/storage/settings_store.dart';
import '../../data/storage/token_store.dart';
import '../../platform/android_alarm/android_alarm.dart';
import '../../platform/android_alarm/android_permissions.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({
    super.key,
    required this.taskId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialSchedule,
    required this.initialTimezone,
  });

  final String taskId;
  final String initialTitle;
  final String initialDescription;
  final Map<String, dynamic> initialSchedule;
  final String initialTimezone;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  static const _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  late final _title = TextEditingController(text: widget.initialTitle);
  late final _description = TextEditingController(
    text: widget.initialDescription.isEmpty ? 'Stay disciplined.' : widget.initialDescription,
  );

  late TimeOfDay _time = _initialTime();
  late String _frequency = (widget.initialSchedule['type'] ?? 'daily').toString();
  late final Set<int> _daysOfWeek = _initialDaysOfWeek();
  late int _dayOfMonth = _initialDayOfMonth();

  bool _loading = false;
  String? _error;

  late final ApiClient _api = ApiClient(
    baseUrl: _baseUrl,
    tokenStore: TokenStore(const FlutterSecureStorage()),
    onUnauthorized: authState.logout,
  );
  late final SettingsStore _settings = SettingsStore(const FlutterSecureStorage());

  TimeOfDay _initialTime() {
    final h = widget.initialSchedule['hour'];
    final m = widget.initialSchedule['minute'];
    if (h is int && m is int) return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
    return const TimeOfDay(hour: 9, minute: 0);
  }

  Set<int> _initialDaysOfWeek() {
    final raw = widget.initialSchedule['daysOfWeek'];
    if (raw is List) {
      return raw.whereType<int>().where((d) => d >= 0 && d <= 6).toSet();
    }
    return {DateTime.now().weekday % 7};
  }

  int _initialDayOfMonth() {
    final raw = widget.initialSchedule['dayOfMonth'];
    if (raw is int) return raw.clamp(1, 31);
    return DateTime.now().day.clamp(1, 31);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
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
        await AndroidPermissions.requestPostNotifications();
      }

      final schedule = <String, dynamic>{
        'type': _frequency,
        'hour': _time.hour,
        'minute': _time.minute,
        if (_frequency == 'weekly') 'daysOfWeek': _daysOfWeek.toList()..sort(),
        if (_frequency == 'monthly') 'dayOfMonth': _dayOfMonth,
      };

      final updated = await _api.putJson('/tasks/${widget.taskId}', {
        'title': _title.text.trim(),
        'description':
            _description.text.trim().isEmpty ? 'Stay disciplined.' : _description.text.trim(),
        'timezone': widget.initialTimezone,
        'schedule': schedule,
      });

      final next = (updated['nextTriggerAt'] ?? '').toString();
      final title = (updated['title'] ?? _title.text.trim()).toString();
      final active = updated['active'] == true;

      if (remindersEnabled && active) {
        final dt = DateTime.tryParse(next);
        if (dt != null) {
          await AndroidAlarm.scheduleExactAlarm(
            taskId: widget.taskId,
            triggerAtEpochMillis: dt.toLocal().millisecondsSinceEpoch,
            title: title.isEmpty ? 'Task' : title,
          );
        }
      } else {
        await AndroidAlarm.cancelAlarm(taskId: widget.taskId);
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
        title: const Text('Edit task'),
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
        padding: const EdgeInsets.all(16),
        child: GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('EDIT YOUR STAKE', style: AppTextStyles.cta.copyWith(letterSpacing: 2.0)),
                      const SizedBox(height: 8),
                      Text(
                        'Tweak the plan. Keep the discipline.',
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
                      AuthTextField(
                        label: 'Description',
                        controller: _description,
                        hintText: 'Why this matters…',
                        prefixIcon: Icons.notes,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'FREQUENCY',
                        style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _frequency,
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                        ],
                        onChanged: _loading
                            ? null
                            : (v) {
                                if (v == null) return;
                                setState(() => _frequency = v);
                              },
                        decoration: const InputDecoration(
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_frequency == 'weekly') ...[
                        const SizedBox(height: 12),
                        Text(
                          'DAYS OF WEEK',
                          style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (i) {
                            const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                            final selected = _daysOfWeek.contains(i);
                            return ChoiceChip(
                              label: Text(labels[i]),
                              selected: selected,
                              onSelected: _loading
                                  ? null
                                  : (on) {
                                      setState(() {
                                        if (on) {
                                          _daysOfWeek.add(i);
                                        } else {
                                          if (_daysOfWeek.length > 1) _daysOfWeek.remove(i);
                                        }
                                      });
                                    },
                            );
                          }),
                        ),
                      ],
                      if (_frequency == 'monthly') ...[
                        const SizedBox(height: 12),
                        Text(
                          'DAY OF MONTH',
                          style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _dayOfMonth.clamp(1, 31),
                          items: List.generate(
                            31,
                            (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                          ),
                          onChanged: _loading ? null : (v) => setState(() => _dayOfMonth = v ?? 1),
                          decoration: const InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
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
                                    final picked =
                                        await showTimePicker(context: context, initialTime: _time);
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
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 140),
                          child: SingleChildScrollView(
                            child: Text(_error!, style: AppTextStyles.bodyMd.copyWith(color: cs.error)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _save,
                  child: Text(
                    _loading ? 'SAVING…' : 'SAVE CHANGES',
                    style: AppTextStyles.cta.copyWith(letterSpacing: 2.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

