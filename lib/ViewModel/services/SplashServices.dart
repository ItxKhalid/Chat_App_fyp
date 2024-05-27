import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';
import '../../utils/routes/route_name.dart';
import '../Autheticate.dart';

class SplashServices {
  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;

    final user = auth.currentUser;

    if (user != null) {
      AppConstant.userID = user.uid.toString();
      Timer(
          const Duration(seconds: 3),
              () => Navigator.pushNamed(context, RouteName.dashboardView));
    } else {
      Timer(
          Duration(seconds: 3),
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate(),)));
    }
  }
}
