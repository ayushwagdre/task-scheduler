import 'package:flutter/services.dart';

class LaunchIntent {
  static const MethodChannel _channel = MethodChannel('doorpay/launch');

  static Future<String?> consumeInitialTaskId() async {
    final v = await _channel.invokeMethod<String>('consumeInitialTaskId');
    if (v == null || v.isEmpty) return null;
    return v;
  }
}

