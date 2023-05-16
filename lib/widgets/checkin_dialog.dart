import 'dart:async';
import 'dart:io';

import 'package:datetime_setting/datetime_setting.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sowaanerp_hr/common/common_dialog.dart';
import 'package:sowaanerp_hr/models/employee.dart';
import 'package:sowaanerp_hr/networking/api_helpers.dart';
import 'package:sowaanerp_hr/networking/dio_client.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/utils.dart';
import 'package:sowaanerp_hr/widgets/primary_button.dart';

class CheckInDialog extends StatefulWidget {
  final int projectId;
  final int teamId;

  const CheckInDialog({Key? key, this.projectId = 0, this.teamId = 0})
      : super(key: key);

  @override
  _CheckInDialogState createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog>
    with SingleTickerProviderStateMixin {
  Utils _utils = Utils();
  var userlocation = Location();
  StreamSubscription<LocationData>? locationSubscription;
  final SharedPref _prefs = SharedPref();
  Employee _employeeModel = Employee();
  String deviceId = "";
  var logType = "IN";

  @override
  void initState() {
    super.initState();
    _prefs
        .readObject(_prefs.prefKeyEmployeeData)
        .then((value) => userDetails(value));
  }

  userDetails(value) async {
    if (value != null) {
      _employeeModel = Employee.fromJson(value);

      deviceId = await _utils.getDeviceId();

      setState(() {});
    }
  }

  // getDeviceId() async {
  //   final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  //   try {
  //     if (Platform.isAndroid) {
  //       var build = await deviceInfoPlugin.androidInfo;
  //       setState(() {
  //         deviceId = build.androidId;
  //       });
  //     } else if (Platform.isIOS) {
  //       var data = await deviceInfoPlugin.iosInfo;
  //       setState(() {
  //         deviceId = data.identifierForVendor;
  //       });
  //     }
  //   } catch (e) {
  //   }
  // }

  handleMarkAttendance(type) async {
    setState(() {
      logType = type;
    });

    checkNetworkTime();
  }

  checkNetworkTime() async {
    // if (Platform.isAndroid) {
    //   bool timeAuto = await DatetimeSetting.timeIsAuto();
    //   bool timezoneAuto = await DatetimeSetting.timeZoneIsAuto();
    //   if (!timezoneAuto || !timeAuto) {
    //     dialogConfirm(context, _utils, () {
    //       Navigator.of(context, rootNavigator: true).pop();
    //       DatetimeSetting.openSetting();
    //     }, "Please enable automatic time and timezone in device settings");
    //     return;
    //   }
    // }

    checkGpsLocation();
  }

  checkGpsLocation() async {
    var _serviceEnabled = await userlocation.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await userlocation.requestService();
      if (!_serviceEnabled) {
        dialogAlert(context, _utils, "Please enable the location services");
        return;
      }
    }

    var _permissionGranted = await userlocation.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await userlocation.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        dialogAlert(context, _utils, "Location permission was denied by user");
        return;
      }
    }
    // _utils.showProgressDialog(context);
    _utils.showProgressDialog(context,
        text: "Trying to get the GPS location...");
    locationSubscription =
        userlocation.onLocationChanged.listen((LocationData currentLocation) {
      handleLocationReceived(currentLocation);
    });
  }

  handleLocationReceived(LocationData currentLocation) {
    if (currentLocation.accuracy! <= 50) {
      _utils.hideProgressDialog(context);
      locationSubscription!.cancel();

      if (currentLocation.isMock!) {
        dialogAlert(context, _utils,
            "Fake Location detected. Attendance cannot be marked",
            icon: Icon(
              Icons.error,
              color: AppColors.danger,
              size: 70,
            ));
        return false;
      }
      sendAttendanceToSowaanERP(currentLocation);
    }
  }

  sendAttendanceToSowaanERP(LocationData currentLocation) {
    _utils.showProgressDialog(context, text: "Communicating with SowaanERP...");

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm');
    final String formatted = formatter.format(now).toString();

    var formData = FormData.fromMap({
      "logtype": logType,
      "employee": _employeeModel.name,
      "time": formatted,
      "gps": "${currentLocation.latitude},${currentLocation.longitude}",
      "deviceId": deviceId,
    });

    _utils.isNetworkAvailable(context, _utils, showDialog: true).then((value) {
      _utils.hideKeyboard(context);

      Future data = APIFunction.post(
          context, _utils, ApiClient.apiCreateEmployeeCheckIn, formData, '');
      data.then((value) {
        if (value != null && value.statusCode == 200) {
          final v = value.data["message"];
          _utils.hideProgressDialog(context);
          if (v['success'] == true) {
            dialogAlert(context, _utils, v['message'],
                icon: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 70,
                ));
          } else {
            dialogAlert(context, _utils, v['message'],
                icon: Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 70,
                ));
          }
        }
      }).onError((error, stackTrace) {
        _utils.hideProgressDialog(context);
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                  ResponsiveFlutter.of(context).moderateScale(28)),
              margin: EdgeInsets.all(
                ResponsiveFlutter.of(context).moderateScale(20, 0.0),
              ),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    ResponsiveFlutter.of(context).moderateScale(12, 0.0),
                  )),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                        buttonColor: AppColors.checkinGreen,
                        textValue: "Check-In",
                        textColor: AppColors.white,
                        callback: () {
                          handleMarkAttendance('IN');
                        }),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: PrimaryButton(
                        buttonColor: AppColors.checkoutRed,
                        textValue: "Check-Out",
                        textColor: AppColors.white,
                        callback: () {
                          handleMarkAttendance('OUT');
                        }),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
