import 'package:go_router/go_router.dart';

import 'auth_state.dart';
import 'router.dart';

class AppRouter {
  static final GoRouter router = buildRouter(authState);
}

