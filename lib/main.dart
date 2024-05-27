import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:voice_recording_app/res/color.dart';
import 'package:voice_recording_app/view/splash/splash_screen.dart';
import 'RecordingScreen/recording_screen.dart';
import 'ViewModel/Autheticate.dart';
import 'ViewModel/login/login_controller.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Directory directory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.openBox('voiceRecordingsBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LogInController(),),
        // ChangeNotifierProvider(create: (context) => RestaurantController(),),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.dividedColor,
          // backgroundColor: AppColors.dividedColor,
          appBarTheme: const AppBarTheme(color: AppColors.dividedColor,iconTheme: IconThemeData(color: Colors.white38)),
          fontFamily: 'TiltNeon-Regular',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
