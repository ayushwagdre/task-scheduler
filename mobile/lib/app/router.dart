import 'package:go_router/go_router.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/onboarding/onboarding_screen_1.dart';
import '../features/onboarding/onboarding_screen_2.dart';
import '../features/onboarding/onboarding_screen_3.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/screens/alarm_screen.dart';
import '../features/screens/data_privacy_screen.dart';
import '../features/screens/profile_screen.dart';
import '../features/screens/streak_stats_screen.dart';
import '../features/screens/success_screen.dart';
import '../features/screens/verification_screen.dart';
import '../features/tasks/create_task_screen.dart';
import '../features/tasks/edit_task_screen.dart';
import '../features/tasks/task_list_screen.dart';
import 'auth_state.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding1 = '/onboarding/1';
  static const onboarding2 = '/onboarding/2';
  static const onboarding3 = '/onboarding/3';
  static const login = '/login';
  static const signup = '/signup';
  static const forgot = '/forgot';
  static const home = '/home';
  static const createTask = '/tasks/create';
  static const editTask = '/tasks/:id/edit';
  static const alarm = '/alarm';
  static const verification = '/verification';
  static const success = '/success';
  static const streaks = '/streaks';
  static const profile = '/profile';
  static const privacy = '/privacy';
}

GoRouter buildRouter(AuthState auth) {
  bool isPublic(String loc) {
    return loc == AppRoutes.splash ||
        loc.startsWith('/onboarding/') ||
        loc == AppRoutes.login ||
        loc == AppRoutes.signup ||
        loc == AppRoutes.forgot;
  }

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: auth,
    redirect: (context, state) {
      // While bootstrapping, let Splash handle it.
      if (!auth.initialized) return null;

      final loc = state.uri.path;
      final loggedIn = auth.loggedIn;

      if (!loggedIn && !isPublic(loc)) {
        return AppRoutes.login;
      }
      if (loggedIn && (loc == AppRoutes.login || loc == AppRoutes.signup || loc == AppRoutes.forgot)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding1,
        builder: (context, state) => const OnboardingScreen1(),
      ),
      GoRoute(
        path: AppRoutes.onboarding2,
        builder: (context, state) => const OnboardingScreen2(),
      ),
      GoRoute(
        path: AppRoutes.onboarding3,
        builder: (context, state) => const OnboardingScreen3(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgot,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createTask,
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTask,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final t = (state.extra as Map?)?.cast<String, dynamic>();
          final schedule = (t?['schedule'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
          return EditTaskScreen(
            taskId: id,
            initialTitle: (t?['title'] ?? '').toString(),
            initialDescription: (t?['description'] ?? '').toString(),
            initialSchedule: schedule,
            initialTimezone: (t?['timezone'] ?? 'Asia/Kolkata').toString(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.alarm,
        builder: (context, state) => AlarmScreen(taskId: state.uri.queryParameters['taskId']),
      ),
      GoRoute(
        path: AppRoutes.verification,
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.success,
        builder: (context, state) => const SuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.streaks,
        builder: (context, state) => const StreakStatsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const DataPrivacyScreen(),
      ),
    ],
  );
}

