import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await authState.init();
  runApp(const DoOrPayApp());
}

