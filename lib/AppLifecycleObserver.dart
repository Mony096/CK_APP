import 'package:bizd_tech_service/services/notification_service.dart';
import 'package:flutter/widgets.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 🔥 STOP IMMEDIATELY ON RESUME
      NotificationService.forceStop();
    }
  }
}
