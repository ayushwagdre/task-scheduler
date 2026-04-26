import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/auth_state.dart';
import '../../data/api/api_client.dart';
import '../../data/storage/token_store.dart';
import '../../platform/android_alarm/android_alarm.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  static const _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  late final ApiClient _api = ApiClient(
    baseUrl: _baseUrl,
    tokenStore: TokenStore(const FlutterSecureStorage()),
    onUnauthorized: authState.logout,
  );

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _tasks = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Note: ApiClient unwraps {success,data} assuming a map; /tasks returns a list.
      // For now, we call raw and parse from its debug log if needed. We'll treat non-map as empty.
      final data = await _api.getJson('/tasks');
      final maybeList = data['items'];
      if (maybeList is List) {
        _tasks = maybeList.cast<Map<String, dynamic>>();
      } else {
        _tasks = const [];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteTask(String id) async {
    try {
      await _api.deleteJson('/tasks/$id');
    } catch (_) {
      // If server deletion fails, still try canceling the local alarm.
    } finally {
      await AndroidAlarm.cancelAlarm(taskId: id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () => context.go(AppRoutes.profile), icon: const Icon(Icons.person)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.createTask),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: AppTextStyles.bodyMd.copyWith(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  )
                : _tasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks yet. Tap + to create one.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final t = _tasks[i];
                          final title = (t['title'] ?? '').toString();
                          final next = (t['nextTriggerAt'] ?? '').toString();
                          final id = (t['id'] ?? '').toString();
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.alarm, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: AppTextStyles.cta.copyWith(color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Text(
                                        next,
                                        style: AppTextStyles.bodyMd.copyWith(
                                          fontSize: 12,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: id.isEmpty
                                      ? null
                                      : () async {
                                          final ok = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete task?'),
                                              content: const Text('This removes it from the server and cancels reminders.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () => Navigator.of(ctx).pop(true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (ok == true) {
                                            await _deleteTask(id);
                                          }
                                        },
                                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

