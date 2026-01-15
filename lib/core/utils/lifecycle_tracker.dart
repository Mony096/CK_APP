import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLifecycleTracker extends StatefulWidget {
  final Widget child;
  const AppLifecycleTracker({super.key, required this.child});

  @override
  State<AppLifecycleTracker> createState() => _AppLifecycleTrackerState();
}

class _AppLifecycleTrackerState extends State<AppLifecycleTracker>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("📱 App resumed (foreground)");
      // Example: check session or refresh data
      Provider.of<AuthProvider>(context, listen: false).checkSession();
    } else if (state == AppLifecycleState.paused) {
      print("📴 App paused (background)");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
