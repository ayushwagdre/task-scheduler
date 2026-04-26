import 'package:flutter/material.dart';

class AppColors {
  // Derived from Stitch Tailwind config (login_screen/code.html).
  static const surface = Color(0xFF141218);
  static const onSurface = Color(0xFFE6E0E9);
  static const onSurfaceVariant = Color(0xFFCBC4D2);

  static const primary = Color(0xFFCFBCFF);
  static const tertiary = Color(0xFFE7C365);

  static const outlineVariant = Color(0xFF494551);
  static const outline = Color(0xFF948E9C);

  static const surfaceContainerLowest = Color(0xFF0F0D13);
  static const surfaceContainerLow = Color(0xFF1D1B20);
}

class AppTextStyles {
  static const display = TextStyle(
    fontSize: 48,
    height: 1.1,
    letterSpacing: -0.04,
    fontWeight: FontWeight.w800,
  );

  static const labelCaps = TextStyle(
    fontSize: 12,
    height: 1.4,
    letterSpacing: 1.2, // ~0.1em
    fontWeight: FontWeight.w700,
  );

  static const bodyMd = TextStyle(
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w400,
  );

  static const cta = TextStyle(
    fontSize: 16,
    height: 1.0,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w600,
  );
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    surface: AppColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme.copyWith(
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      primary: AppColors.primary,
      tertiary: AppColors.tertiary,
      outline: AppColors.outline,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: ThemeData.dark().textTheme.copyWith(
          bodyMedium: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
          bodySmall: AppTextStyles.bodyMd.copyWith(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
          headlineLarge: AppTextStyles.display.copyWith(color: AppColors.onSurface),
          labelSmall: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
        ),
  );
}

