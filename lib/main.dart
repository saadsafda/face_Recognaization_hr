import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sowaanerp_hr/screens/splash_screen.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    // navigation bar color
    statusBarColor: AppColors.white, // status bar color
  ));
  runApp(const SowaanERPHR());
}

class SowaanERPHR extends StatelessWidget {
  const SowaanERPHR({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.textWhiteGrey,
        // systemStatusBarContrastEnforced: true,
        statusBarIconBrightness:
            Platform.isAndroid ? Brightness.dark : Brightness.light,
        // systemNavigationBarColor: Colors.black,
        // systemNavigationBarDividerColor: Colors.transparent,
        // systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
      ),
      // title: Strings.appName,
      home: const SplashScreen(),
    );
  }
}
