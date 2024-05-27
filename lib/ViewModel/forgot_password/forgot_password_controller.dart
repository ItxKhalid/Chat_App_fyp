import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voice_recording_app/view/login/login_screen.dart';
import '../../utils/routes/route_name.dart';
import '../../utils/utils.dart';

class ForgotPasswordController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('user');
  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void forgotPassword(BuildContext context,String email) async {
    setLoading(true);
    try {
      auth
          .sendPasswordResetEmail(email: email,)
          .then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen(),));
        Utils().toastMassage('Please check your email',false);
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
