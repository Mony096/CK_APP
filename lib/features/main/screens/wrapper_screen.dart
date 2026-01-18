import 'package:bizd_tech_service/core/theme/app_tokens.dart';
import 'package:bizd_tech_service/features/dashboard/screens/dashboard_screen.dart';
import 'package:bizd_tech_service/features/auth/screens/change_password_screen.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/main/screens/main_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        debugPrint('Auth state: isLoggedIn=${auth.isLoggedIn}');

        // STEP 1: Still checking session → show loading screen
        if (auth.isCheckSessionId) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(
                    color: AppColors.accent,
                    size: 60.0,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Loading',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  )
                ],
              ),
            ),
          );
        }

        // STEP 2: Password change required
        if (auth.isChangePassword) {
          return const ChangePasswordScreen();
        }

        // STEP 3: Not logged in → show new login screen
        if (!auth.isLoggedIn) {
          return const LoginScreenV2();
        }

        // STEP 4: All good → show main screen with bottom nav
        return const MainScreen();
      },
    );
  }
}
