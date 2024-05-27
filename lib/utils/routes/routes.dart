import 'package:flutter/material.dart';
import 'package:voice_recording_app/utils/routes/route_name.dart';

import '../../view/dashboard/dashboard_screen.dart';
import '../../view/forgotPAssword/forgotpaswwordscreen.dart';
import '../../view/login/login_screen.dart';
import '../../view/signup/sign_up_screen.dart';
import '../../view/splash/splash_screen.dart';


class Routes {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    switch (settings.name) {
      case RouteName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteName.loginView:
        return MaterialPageRoute(builder: (_) =>  const LoginScreen());
      case RouteName.signupView:
        return MaterialPageRoute(builder: (_) =>   SignUpView());
      case RouteName.dashboardView:
        return MaterialPageRoute(builder: (_) =>  const DashBoardScreen());
        case RouteName.forgotpassword:
        return MaterialPageRoute(builder: (_) =>  const ForgotPasswordScreen());

      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}