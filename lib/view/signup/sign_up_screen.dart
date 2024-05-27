import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';
import '../../utils/utils.dart';
import '../login/login_screen.dart';

class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _number = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isLoading
            ? Center(
          child: Container(
            height: size.height / 20,
            width: size.height / 20,
            child: const CircularProgressIndicator(),
          ),
        )
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: size.width / 0.5,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                SizedBox(
                  width: size.width / 1.1,
                  child: const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 34,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: size.width / 1.1,
                  child: const Text(
                    "Create Account to Continue!",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 7,
                ),
                Container(
                  width: size.width,
                  alignment: Alignment.center,
                  child: field(
                    size,
                    "Name",
                    Icons.person_2_rounded,
                    _name,
                    TextInputType.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Container(
                    width: size.width,
                    alignment: Alignment.center,
                    child: field(
                      size,
                      "Phone Number",
                      Icons.phone,
                      _number,
                      TextInputType.number,
                    ),
                  ),
                ),
                Container(
                  width: size.width,
                  alignment: Alignment.center,
                  child: field(
                    size,
                    "email",
                    Icons.alternate_email_outlined,
                    _email,
                    TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Container(
                    width: size.width,
                    alignment: Alignment.center,
                    child: field(
                      size,
                      "password",
                      Icons.lock_rounded,
                      _password,
                      TextInputType.text,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 33
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xff4c505b),
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      customButton(size),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            color: Color(0xff4c505b),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          var userName = _name.text.trim();
          var userNumber = _number.text.trim();
          var userEmail = _email.text.trim();
          var userPassword = _password.text.trim();

          // Set isLoading to true before performing any async operation
          setState(() {
            isLoading = true;
          });
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: userEmail, password: userPassword)
              .then((value) {
            signUpUser(userName, userNumber, userEmail, context);
          }).catchError((error) {
            // Handle errors
            isLoading = false;
            print(error);
          }).whenComplete(() {
            // After the async operation, set isLoading back to false
            setState(() {
              isLoading = false;
            });
          });
        }
      },
      child: CircleAvatar(
        radius: 30,
        backgroundColor: const Color(0xff4c505b),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }

  Widget field(Size size, String hintText, IconData icon, TextEditingController cont, TextInputType? textInputType) {
    return Container(
      height: size.height / 14,
      width: size.width / 1.1,
      child: TextField(
        controller: cont,
        keyboardType: textInputType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black26),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.teal),
          ),
        ),
      ),
    );
  }

  Future<void> signUpUser(
      String userName, String userNumber, String userEmail, BuildContext context,
      ) async {
    final User? user = FirebaseAuth.instance.currentUser;
    try {
      // Create a user document in Firestore
      await FirebaseFirestore.instance.collection("users").doc(user?.uid).set({
        "name": userName,
        "number": userNumber,
        "email": userEmail,
        "status": "Unavailable",
        "image": "",
        "uid": user?.uid,
      }).then((_) {
        print("Firestore: User document created successfully");

        // Create a user entry in the Realtime Database
        final DatabaseReference databaseRef =
        FirebaseDatabase.instance.reference().child('users');
        databaseRef.child(user!.uid).set({
          "name": userName,
          "number": userNumber,
          "email": userEmail,
          "status": "Unavailable",
          "image": "",
          "uid": user.uid,
        }).then((_) {
          print("Realtime Database: User entry created successfully");

          // Store the UID in SharedPreferences and assign it to AppConstant.userID
          storeUidInSharedPreferences(user.uid,user.email.toString());

          // Show a success message, sign out, and navigate to the login screen
          Utils().toastMassage('User Created Successfully', true);
          FirebaseAuth.instance.signOut();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }).catchError((e) {
          Utils().toastMassage('Error creating user entry in Realtime Database', false);
          print("Realtime Database Error: $e");
        });
      }).catchError((e) {
        Utils().toastMassage('Error creating user document in Firestore', false);
        print("Firestore Error: $e");
      });
    } catch (e) {
      Utils().toastMassage('User Already Exists', false);
      print("Error: $e");
    }
  }

  void storeUidInSharedPreferences(String uid , String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
    prefs.setString('email', email);

    // Assign the UID to AppConstant.userID
    AppConstant.userID = uid;
    AppConstant.currentUserEmail = email;
  }
}
