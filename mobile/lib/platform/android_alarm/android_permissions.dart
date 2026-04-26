import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AndroidPermissions {
  static const MethodChannel _channel = MethodChannel('doorpay/android_permissions');

  static Future<bool> requestPostNotifications() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;
    final ok = await _channel.invokeMethod<bool>('requestPostNotifications');
    return ok ?? false;
  }

  static Future<bool> canScheduleExactAlarms() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    final ok = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
    return ok ?? false;
  }

  static Future<void> openExactAlarmSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod('openExactAlarmSettings');
  }
}

