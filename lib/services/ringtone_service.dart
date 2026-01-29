import 'package:flutter/services.dart';

class RingtoneController {
  static const MethodChannel _channel =
      MethodChannel('com.example.ckservice/ringtone');

  static Future<void> startRingtone() async {
    try {
      await _channel.invokeMethod('startRingtone');
    } catch (e) {
      // ignore
    }
  }

  static Future<void> stopRingtone() async {
    try {
      await _channel.invokeMethod('stopRingtone');
    } catch (e) {
      // ignore
    }
  }
}
