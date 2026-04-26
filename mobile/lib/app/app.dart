import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'app_router.dart';
import 'launch_state.dart';
import '../platform/android_alarm/launch_stream.dart';
import 'auth_state.dart';
import 'router.dart';

class DoOrPayApp extends StatefulWidget {
  const DoOrPayApp({super.key});

  @override
  State<DoOrPayApp> createState() => _DoOrPayAppState();
}

class _DoOrPayAppState extends State<DoOrPayApp> {
  late final _sub = LaunchStream.taskIds().listen((taskId) {
    LaunchState.pendingTaskId.value = taskId;
    if (authState.loggedIn) {
      AppRouter.router.go('${AppRoutes.alarm}?taskId=$taskId');
    }
  });

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DoOrPay',
      theme: buildAppTheme(),
      routerConfig: AppRouter.router,
    );
  }
}

