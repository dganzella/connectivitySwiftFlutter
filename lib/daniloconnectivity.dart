import 'dart:async';

import 'package:flutter/services.dart';

class Daniloconnectivity {
  static const MethodChannel _channel =
      const MethodChannel('daniloconnectivity');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
