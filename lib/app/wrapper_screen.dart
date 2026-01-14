import 'package:bizd_tech_service/features/dashboard/presentation/dashboard.dart';
import 'package:bizd_tech_service/features/auth/presentation/ChangePasswordScreen.dart';
import 'package:bizd_tech_service/features/auth/presentation/LoginScreen.dart';
import 'package:bizd_tech_service/features/auth/providers/auth_provider.dart';
import 'package:bizd_tech_service/legacy/view_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        print(auth.isLoggedIn);
        // STEP 1: Still checking session â†’ show loading screen
        if (auth.isCheckSessionId) {
          return Scaffold(
            body: Center(
                child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingCircle(
                      color: Colors.green,
                      size: 60.0,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Loading",
                      style: TextStyle(
                          fontSize: 15, color: Color.fromARGB(255, 94, 96, 97)),
                    )
                  ],
                ),
              ),
            )),
          );
        }
        if (auth.isChangePassword) {
          return const ChangePasswordScreen();
        }
        // // STEP 2: Notification screen has priority
        // if (auth.isCheckPendingObj) {
        //   return const ViewNotification();
        // }

        // STEP 3: Not logged in â†’ show login screen
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }

        // STEP 4: All good â†’ show dashboard
        return Dashboard();
      },
    );
  }
}

