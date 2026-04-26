import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/onboarding/splash_screen.dart';

class DoOrPayApp extends StatelessWidget {
  const DoOrPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoOrPay',
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}

