import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/routes/route_name.dart';
import '../../utils/utils.dart';
import '../../view/dashboard/dashboard_screen.dart';

class LogInController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void login(BuildContext context,String email,
      String password) async {
    setLoading(true);
    try {
      auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        AppConstant.userID = value.user!.uid.toString();
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DashBoardScreen(),));
        Utils().toastMassage('LogIn Successfully',false);
        setLoading(false);
      }).onError((error, stackTrace) {
        Utils().toastMassage(error.toString(),true);
        setLoading(false);
      });
    } catch (e) {
      Utils().toastMassage(e.toString(),true);
      setLoading(false);
    }
  }
}