import 'dart:async';

import 'package:flutter/services.dart';

class LaunchStream {
  static const EventChannel _channel = EventChannel('doorpay/launch_stream');

  static Stream<String> taskIds() {
    return _channel
        .receiveBroadcastStream()
        .where((e) => e is String && e.isNotEmpty)
        .cast<String>();
  }
}

