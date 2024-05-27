// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:tech_media/ViewModel/services/session_manager.dart';
// import '../../utils/routes/route_name.dart';
// import '../../utils/utils.dart';
//
// class SignUpController with ChangeNotifier {
//   FirebaseAuth auth = FirebaseAuth.instance;
//   DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');
//   bool _loading = false;
//
//   bool get loading => _loading;
//
//   setLoading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }
//
//   void signUp(BuildContext context, String username,String number, String email,
//       String password) async {
//     setLoading(true);
//     try {
//       auth
//           .createUserWithEmailAndPassword(email: email, password: password)
//           .then((value) {
//         SessionController().userId = value.user!.uid.toString();
//         ref.child(value.user!.uid.toString()).set({
//           "name": username,
//           "number": number,
//           "email": email,
//           "status": "Unavalible",
//           "image": "",
//           'uid': value.user!.uid.toString(),
//           // 'email': value.user!.email.toString(),
//           // 'name': username,
//           // 'image': "",
//           // 'profile': "",
//           // 'number': "",
//         }).then((value) {
//           Navigator.pushNamed(context, RouteName.dashboardView);
//           Utils().toastMassage('User Created Successfully',false);
//           setLoading(false);
//         }).onError((error, stackTrace) {
//           Utils().toastMassage(error.toString(),true);
//           setLoading(false);
//         });
//         Utils().toastMassage('User Created Successfully',false);
//         setLoading(false);
//       }).onError((error, stackTrace) {
//         Utils().toastMassage(error.toString(),true);
//         setLoading(false);
//       });
//     } catch (e) {
//       Utils().toastMassage(e.toString(),true);
//       setLoading(false);
//     }
//   }
// }