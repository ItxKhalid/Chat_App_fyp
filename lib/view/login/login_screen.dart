import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/Methods.dart';
import '../../ViewModel/login/login_controller.dart';
import '../../res/color.dart';
import '../../utils/routes/route_name.dart';
import '../../utils/utils.dart';
import '../../widgets/RoundButton.dart';
import '../../widgets/TextFormFeild.dart';
import '../dashboard/Home/HomeScreen.dart';
import '../dashboard/dashboard_screen.dart';
import '../forgotPAssword/forgotpaswwordscreen.dart';
import '../signup/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    passwordFocus.dispose();
    emailFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height * .03),
                  Text('WelCome Here',
                      style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.white70)),
                  SizedBox(height: height * .01),
                  Text('Enter your Email to Connect to your account',
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white54)),
                  SizedBox(height: height * .2),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormFieldWidget(
                              myController: _email,
                              myFocusNode: emailFocus,
                              onFieldSubmitted: (value) {},
                              prefixIcon: const Icon(Icons.email_outlined),
                              formFieldValidator: (value) {
                                return value.isEmpty ? 'EnterEmail' : null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              hint: 'Email',
                              enable: true,
                              obscureText: false),
                          SizedBox(height: height * .03),
                          TextFormFieldWidget(
                              myController: _password,
                              myFocusNode: passwordFocus,
                              onFieldSubmitted: (value) {},
                              prefixIcon: const Icon(Icons.person_outline),
                              formFieldValidator: (value) {
                                return value.isEmpty ? 'Enter Password' : null;
                              },
                              keyboardType: TextInputType.text,
                              hint: 'Password',
                              enable: true,
                              obscureText: true),
                        ],
                      )),
                  // SizedBox(height: height * .001),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen(),));
                        },
                        child: Text(
                          'Forget Password!',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(
                                  fontSize: 15,
                                  decoration: TextDecoration.underline),
                        )),
                  ),
                  SizedBox(height: height * .03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'LogIn',
                          style: TextStyle(
                            color: Color(0xff4c505b),
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ChangeNotifierProvider(
                          create: (context) => LogInController(),
                          child: Consumer<LogInController>(
                            builder: (context, value, child) {
                              return GestureDetector(
                                onTap:  () {
                                  if (_formKey.currentState!.validate()) {
                                    value.login(
                                        context,
                                        _email.text.toString(),
                                        _password.text.toString());
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xff4c505b),
                                  child: value.loading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Icon(Icons.arrow_forward,
                                          color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpView(),));
                            },
                            child: const Text(
                              'SignUp',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                                color: Color(0xff4c505b),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
