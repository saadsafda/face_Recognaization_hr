import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sowaanerp_hr/models/employee.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/screens/home_screen.dart';
import 'package:sowaanerp_hr/screens/login_screen.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/image_path.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/strings.dart';
import 'package:sowaanerp_hr/widgets/bottombar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Utils _utils = new Utils();
  final SharedPref _prefs = new SharedPref();
  Employee? _employeeModel;

  @override
  void initState() {
    super.initState();
    _prefs
        .readObject(_prefs.prefKeyEmployeeData)
        .then((value) => userDetails(value));
    startTime();
  }

  userDetails(value) async {
    if (value != null) {
      setState(() {
        _employeeModel = Employee.fromJson(value);
      });
    }
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    //// TODO: Build: above below
    // var _duration = new Duration(milliseconds: 100);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) {
          return (_employeeModel != null) ? const BottomBar() : LoginScreen();
        },
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: AppColors.textWhiteGrey,
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                ImagePath.icLogoTransparent,
                width: ResponsiveFlutter.of(context).scale(250),
                // height: ResponsiveFlutter.of(context).verticalScale(200),
              ),
              // Image.asset(
              //   ImagePath.icLogoTransparent_secondary,
              //   width: ResponsiveFlutter.of(context).scale(200),
              //   // height: ResponsiveFlutter.of(context).verticalScale(200),
              // )
              // Text(
              //   Strings.appName,
              //   style: TextStyle(
              //     fontWeight: FontWeight.w900,
              //     color: AppColors.black,
              //     fontSize: ResponsiveFlutter.of(context).fontSize(4),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
