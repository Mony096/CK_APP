// import 'package:flutter/services.dart';

// class RingtoneController {
//   static const _channel = MethodChannel('com.example.ckservice/ringtone');

//   static Future<void> stopRingtone() async {
//     try {
//       await _channel.invokeMethod('stopRingtone');
//     } catch (e) {
//       print('Error stopping ringtone: $e');
//     }
//   }

//   static Future<void> startRingtone() async {
//     try {
//       await _channel.invokeMethod('startRingtone');
//     } catch (e) {
//       print('Error starting ringtone: $e');
//     }
//   }
// }
import 'package:flutter/services.dart';

class RingtoneController {
  static const _channel = MethodChannel('com.example.lkdelivery/ringtone');

  static Future<void> stopRingtone() async {
    try {
      await _channel.invokeMethod('stopRingtone');
    } catch (e) {
      print('Error stopping ringtone: $e');
    }
  }

  static Future<void> startRingtone() async {
    try {
      await _channel.invokeMethod('startRingtone');
    } catch (e) {
      print('Error starting ringtone: $e');
    }
  }
}
