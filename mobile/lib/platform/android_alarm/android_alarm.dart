import 'package:flutter/services.dart';

class AndroidAlarm {
  static const MethodChannel _channel = MethodChannel('doorpay/android_alarm');

  static Future<void> scheduleExactAlarm({
    required String taskId,
    required int triggerAtEpochMillis,
    required String title,
  }) async {
    await _channel.invokeMethod('scheduleExactAlarm', {
      'taskId': taskId,
      'triggerAtEpochMillis': triggerAtEpochMillis,
      'title': title,
    });
  }

  static Future<void> cancelAlarm({required String taskId}) async {
    await _channel.invokeMethod('cancelAlarm', {'taskId': taskId});
  }
}

