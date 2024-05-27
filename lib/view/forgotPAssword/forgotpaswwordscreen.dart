import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/forgot_password/forgot_password_controller.dart';
import '../../widgets/RoundButton.dart';
import '../../widgets/TextFormFeild.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    emailFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * .03),
                const Text('Forgot Password',
                    style: TextStyle(color: Colors.white70,fontSize: 30)),
                SizedBox(height: height * .01),
                const Text('Enter the register Email you want\nto send the reset link',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38,fontSize: 18)),
                SizedBox(height: height * .2),
                Form(
                    key: _formKey,
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email,color: Colors.white70),
                        hintText: 'Email',
                        hintStyle: const TextStyle(color: Colors.black26),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.teal),
                        ),
                      ),
                    )),

                SizedBox(height: height * .03),
                ChangeNotifierProvider(
                  create: (_) => ForgotPasswordController(),
                  child: Consumer<ForgotPasswordController>(
                    builder: (context, provider, child) {
                      return RoundButton(
                        btntxt: 'Send Email',
                        loading: provider.loading,
                        ontap: () {
                          if (_formKey.currentState!.validate()) {
                            provider.forgotPassword(
                                context,
                                emailController.text
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
