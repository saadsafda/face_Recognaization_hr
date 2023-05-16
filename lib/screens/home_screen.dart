// ignore_for_file: unused_local_variable, unnecessary_new, avoid_types_as_parameter_names, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sowaanerp_hr/common/common_dialog.dart';
import 'package:sowaanerp_hr/common/common_widget.dart';
import 'package:sowaanerp_hr/models/attendance_count.dart';
import 'package:sowaanerp_hr/models/employee.dart';
import 'package:sowaanerp_hr/models/attendance_summary.dart';
import 'package:sowaanerp_hr/models/employee_attendance.dart';
import 'package:sowaanerp_hr/models/gps_location.dart';
import 'package:sowaanerp_hr/models/monthly_hours_count.dart';
import 'package:sowaanerp_hr/models/payroll_date.dart';
import 'package:sowaanerp_hr/models/today_checkin.dart';
import 'package:sowaanerp_hr/networking/api_helpers.dart';
import 'package:sowaanerp_hr/networking/dio_client.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/screens/locations_screen.dart';
import 'package:sowaanerp_hr/screens/salary_screen.dart';
import 'package:sowaanerp_hr/theme.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/utils.dart';
import 'package:sowaanerp_hr/widgets/box_card.dart';
import 'package:sowaanerp_hr/widgets/custom_appbar.dart';
import 'package:location/location.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../face_recog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Utils _utils = new Utils();
  final SharedPref _prefs = new SharedPref();
  var userlocation = new Location();
  List<EmployeeAttendance> _employeeAttendance = [];
  StreamSubscription<LocationData>? locationSubscription;
  Employee _employeeModel = Employee();
  PayrollDate _payrollDate = PayrollDate();
  AttendanceSummary attendanceSummaryModel = AttendanceSummary();
  var dateStart = DateTime.now();
  var dateEnd = DateTime.now();
  var _start_date;
  var _end_date;
  String presents = "";
  String absents = "";
  String lates = "";
  String early = "";
  List<GpsLocationModel> gpsLocations = [];
  List<TodayCheckinModel> todayCheckins = [];
  List<AttendanceCount> attendanceCount = [];
  List<MonthlyHoursCount> hoursCount = [];
  String showCheckInOut = "IN";
  int pageIndex = 0;
  String deviceId = "";
  bool isNetworkAvailable = true;
  bool isLoadingCheckin = true;
  bool isLoadingAttendanceSummary = true;
  bool isLoadingMonthlyHours = true;
  File? faceImage;
  var logType = "IN";
  String checkInLogName = "";
  String baseURL = '';

  @override
  void initState() {
    super.initState();
    //Read base url from prefs
    _prefs.readString(_prefs.prefBaseUrl).then((value) {
      setState(() {
        baseURL = value;
      });
    });

    //Read payroll dates from prefs
    _prefs.readObject(_prefs.prefKeyPayrollDate).then((value) {
      setState(() {
        _payrollDate = PayrollDate.fromJson(value);
        _start_date = DateTime.parse(_payrollDate.startDate!);
        _end_date = DateTime.parse(_payrollDate.endDate!);
      });
    });

    //Read employee info from prefs
    _prefs
        .readObject(_prefs.prefKeyEmployeeData)
        .then((value) => userDetails(value));
    getAttendanceSummary();
  }

  userDetails(value) async {
    if (value != null) {
      _employeeModel = Employee.fromJson(value);
      print("$value, Employee values cheking");

      deviceId = await _utils.getDeviceId();
      getLocations();
      getTodayCheckIn();
      getAttendanceSummary();
      getMonthlyHours();
      setState(() {});
    }
  }

  getLocations() {
    _utils.isNetworkAvailable(context, _utils, showDialog: true).then((value) {
      _utils.hideKeyboard(context);

      var formData = FormData.fromMap({
        "employee": _employeeModel.name,
      });
      Future data = APIFunction.post(
          context, _utils, ApiClient.apiGetLocations, formData, '');
      data.then((value) {
        if (value != null &&
            value.statusCode == 200 &&
            value.data["message"] != "") {
          gpsLocations = [];
          final v = value.data["message"]["locations"];
          v.forEach((i) {
            gpsLocations.add(GpsLocationModel.fromJson(i));
          });
          _prefs.saveObject(_prefs.prefLocation, gpsLocations);
        }
      });
    });
  }

  getTodayCheckIn() {
    _utils.isNetworkAvailable(context, _utils, showDialog: true).then((value) {
      _utils.hideKeyboard(context);
      if (value) {
        // show loading
        setState(() {
          isNetworkAvailable = true;
          isLoadingCheckin = true;
        });
        var formData = FormData.fromMap({
          "employee": _employeeModel.name,
        });
        Future data = APIFunction.post(context, _utils,
            ApiClient.apiGetEmployeeTodayCheckIn, formData, '');
        data.then((value) async {
          setState(() {
            isLoadingCheckin = false;
          });
          if (value != null && value.statusCode == 200) {
            final v = value.data["message"]["data"];
            if (v != null) {
              todayCheckins = [];
              await v.forEach((i) {
                todayCheckins.add(TodayCheckinModel.fromJson(i));
              });
              setState(() {
                if (todayCheckins.length > 0) {
                  checkInLogName = todayCheckins.first.name!;
                }
                showCheckInOut = value.data["message"]["ShowCheckInOut"];
              });
              // _prefs.saveObject(_prefs.prefTodayCheckIn, todayCheckins);
            }
          }
        }).onError((error, stackTrace) {
          setState(() {
            isNetworkAvailable = false;
            isLoadingCheckin = false;
          });
        });
      } else {
        setState(() {
          isNetworkAvailable = false;
          isLoadingCheckin = false;
        });
      }
    });
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

  getAttendanceSummary() async {
    _utils.isNetworkAvailable(context, _utils, showDialog: true).then((value) {
      _utils.hideKeyboard(context);
      if (value) {
        setState(() {
          isNetworkAvailable = true;
          isLoadingAttendanceSummary = true;
        });
        var formData = FormData.fromMap({
          "employee": _employeeModel.name,
          "from_date": DateFormat('yyyy-MM-dd').format(_start_date).toString(),
          "to_date": DateFormat('yyyy-MM-dd').format(_end_date).toString(),
        });

        Future data = APIFunction.post(
            context, _utils, ApiClient.apiGetAttendanceSummary, formData, '');
        data.then((value) {
          isLoadingAttendanceSummary = false;

          if (value != null && value.statusCode == 200) {
            final v = value.data["message"];
            if (v != null) {
              attendanceCount = [];
              setState(() {
                v.forEach((i) {
                  attendanceCount.add(AttendanceCount.fromJson(i));
                });
              });
            }
          }
        }).catchError((error) {
          setState(() {
            isLoadingAttendanceSummary = false;
          });
          print('error $error');
        });
      } else {
        setState(() {
          isNetworkAvailable = false;
          isLoadingAttendanceSummary = false;
        });
      }
    });
  }

  getMonthlyHours() async {
    _utils.isNetworkAvailable(context, _utils, showDialog: true).then((value) {
      _utils.hideKeyboard(context);
      if (value) {
        var formData = FormData.fromMap({
          "employee": _employeeModel.name,
          "from_date": DateFormat('yyyy-MM-dd').format(_start_date).toString(),
          "to_date": DateFormat('yyyy-MM-dd').format(_end_date).toString(),
        });

        Future data = APIFunction.post(
            context, _utils, ApiClient.apiGetMonthlyHours, formData, '');
        data.then((value) {
          if (value != null && value.statusCode == 200) {
            final v = value.data["message"];
            if (v != null) {
              hoursCount = [];
              setState(() {
                v.forEach((i) {
                  hoursCount.add(MonthlyHoursCount.fromJson(i));
                });
              });
            }
          }
        }).catchError((error) {
          print('error $error');
        });
      }
    });
  }

  handleMarkAttendance(type) async {
    setState(() {
      logType = type;
    });

    checkNetworkTime();
  }

  checkNetworkTime() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyFaceRecog(),
      ),
    );
    faceImage = await result["attchFaceImage"];
    print('${faceImage!.path}, Response Resized image file path:');
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
    if (faceImage != null) {
      checkGpsLocation();
    }
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
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
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
      data.then((value) async {
        if (value != null && value.statusCode == 200) {
          final v = value.data["message"];
          _utils.hideProgressDialog(context);
          print('${v["message"]}, checkin Resized image file path:');
          if (v['success'] == true) {
            await getTodayCheckIn();
            Timer(new Duration(seconds: 4), () async {
              List<MultipartFile> _files = [];
              _files.add(MultipartFile.fromFileSync(
                faceImage!.path,
                filename: faceImage!.path.split('/').last,
              ));
              var formData = FormData.fromMap({
                'file': _files.first,
                'is_private': 1,
                'folder': 'Home/Attachments',
                'doctype': 'Employee Checkin',
                'docname': checkInLogName
              });
              print(
                  '$checkInLogName , checkInLogName Resized image file path:');
              Future data = APIFunction.post(
                  context, _utils, ApiClient.apiUploadImage, formData, '');
              var res = await data;
              print('${res}, upload image res Resized image file path:');
            });
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

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        dateStart = args.value.startDate;
        dateEnd = args.value.endDate ?? args.value.startDate;
      }
    });
  }

  _onSubmit() {
    setState(() {
      _start_date = DateTime.parse(dateStart.toString());
      _end_date = DateTime.parse(dateEnd.toString());
    });
    getAttendanceSummary();
    getMonthlyHours();
    Navigator.of(context).pop();
  }

  pickDateRange() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SfDateRangePicker(
              todayHighlightColor: AppColors.textPurpleColor,
              startRangeSelectionColor: AppColors.textPurpleColor,
              endRangeSelectionColor: AppColors.textPurpleColor,
              rangeSelectionColor: AppColors.textPurpleColorWithOpacity,
              backgroundColor: Colors.white,
              onSelectionChanged: _onSelectionChanged,
              selectionMode: DateRangePickerSelectionMode.range,
              showActionButtons: false,
              initialSelectedRange: PickerDateRange(
                  DateTime.parse(_start_date.toString()),
                  DateTime.parse(_end_date.toString())),
            ),
            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      onPressed: () => _onSubmit(), child: const Text('Ok')),
                  TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Cancel')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color getAttendanceStatusColor(status) {
    return status == "Present" || status == "Work From Home"
        ? AppColors.checkinGreen
        : status == "Absent" || status == "On Leave"
            ? AppColors.checkoutRed
            : status == "Half Day"
                ? AppColors.orange
                : AppColors.light_grey;
  }

  Color getAttendanceStatusBgColor(status) {
    return status == "Present" || status == "Work From Home"
        ? AppColors.checkinGreenBg
        : status == "Absent" || status == "On Leave"
            ? AppColors.checkoutRedBg
            : status == "Half Day"
                ? AppColors.orangeBg
                : AppColors.bgGreyLight;
  }

  String getAttendanceStatusText(String text) {
    return text == "Work From Home" ? "W.F.H" : text;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.textWhiteGrey,
        appBar: const PreferredSize(
          child: CustomAppBar(
            title: "Home",
            icon: Icons.notifications_none,
            // icon2: Icons.settings,
          ),
          preferredSize: Size.fromHeight(50),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textWhiteGrey,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IntrinsicHeight(
                          child: GestureDetector(
                            onTap: () {},
                            child: SizedBox(
                              width: ResponsiveFlutter.of(context).scale(52),
                              height: ResponsiveFlutter.of(context)
                                  .verticalScale(52),
                              // child: Container(

                              // ),

                              child: Hero(
                                tag: 'imageHero',
                                child: widgetCommonProfile(
                                  imagePath: _employeeModel.image != null &&
                                          _employeeModel.image!
                                              .startsWith("https://")
                                      ? _employeeModel.image.toString()
                                      : '$baseURL${_employeeModel.image}',
                                  isBackGroundColorGray: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Welcome, ${_employeeModel.firstName}',
                                textAlign: TextAlign.right,
                                style: heading6.copyWith(color: AppColors.grey),
                              ),
                              Text(
                                'What do you want to do today?',
                                textAlign: TextAlign.right,
                                style: heading6.copyWith(
                                    color: AppColors.light_grey, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                  child: isLoadingCheckin && isNetworkAvailable
                      ? Container(
                          height: 100,
                          margin: const EdgeInsets.only(
                              left: 6, right: 6, bottom: 6),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SpinKitThreeBounce(
                            size: 20,
                            color: AppColors.primary,
                          ),
                        )
                      : !isLoadingCheckin && !isNetworkAvailable
                          ? Container(
                              height: 100,
                              margin: const EdgeInsets.only(
                                  left: 6, right: 6, bottom: 6),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wifi_off,
                                    color: AppColors.light_grey,
                                  ),
                                  Text("No internet",
                                      style: heading6.copyWith(
                                          color: AppColors.light_grey)),
                                ],
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(
                                  left: 6, right: 6, bottom: 6),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        todayCheckins.isEmpty
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Check In',
                                                    style: heading2.copyWith(
                                                        color:
                                                            AppColors.textGrey),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    '''You haven't check in yet.''',
                                                    style: heading6.copyWith(
                                                        color:
                                                            AppColors.textGrey),
                                                  ),
                                                ],
                                              )
                                            : todayCheckins.isNotEmpty
                                                ? SizedBox(
                                                    height: 100,
                                                    child: ListView.builder(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        itemCount: todayCheckins
                                                            .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (index != 0)
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    left: 5,
                                                                  ),
                                                                  height: 20,
                                                                  width: 1,
                                                                  color: AppColors
                                                                      .textGrey,
                                                                ),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: 10,
                                                                    height: 10,
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            10),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      color: todayCheckins[index].log_type ==
                                                                              "IN"
                                                                          ? AppColors
                                                                              .checkinGreen
                                                                          : AppColors
                                                                              .checkoutRed,
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                            '',
                                                                            style:
                                                                                TextStyle(color: Colors.white))),
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        todayCheckins[index]
                                                                            .time!
                                                                            .substring(11,
                                                                                16),
                                                                        style: heading6.copyWith(
                                                                            color:
                                                                                AppColors.textGrey),
                                                                      ),
                                                                      Text(
                                                                        todayCheckins[index]
                                                                            .log_type!,
                                                                        style:
                                                                            TextStyle(
                                                                          color: todayCheckins[index].log_type == "IN"
                                                                              ? AppColors.checkinGreen
                                                                              : AppColors.checkoutRed,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        }),
                                                  )
                                                : Container(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  ElevatedButton(
                                    child: showCheckInOut == "IN"
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text('IN',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              Icon(
                                                Icons.arrow_downward_rounded,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.arrow_upward_rounded,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                              Text('OUT',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  )),
                                            ],
                                          ),
                                    onPressed: () {
                                      handleMarkAttendance(
                                          showCheckInOut == "IN"
                                              ? "IN"
                                              : "OUT");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shadowColor: AppColors.primary,
                                      primary: showCheckInOut == "IN"
                                          ? AppColors.checkinGreen
                                          : AppColors.checkoutRed,
                                      fixedSize: const Size(100, 100),
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                  child: isLoadingAttendanceSummary && isNetworkAvailable
                      ? Container(
                          height: 100,
                          margin:
                              const EdgeInsets.only(left: 6, right: 6, top: 6),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SpinKitThreeBounce(
                            size: 20,
                            color: AppColors.primary,
                          ),
                        )
                      : !isLoadingAttendanceSummary && !isNetworkAvailable ||
                              attendanceCount.isEmpty
                          ? Container()
                          : Container(
                              margin: const EdgeInsets.only(
                                  left: 6, right: 6, top: 6),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 0, left: 10, right: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        pickDateRange();
                                      },
                                      icon: Icon(
                                        Icons.date_range,
                                        color: AppColors.primary,
                                      ),
                                      label: Text(
                                        '${_start_date != null ? DateFormat('dd/MM/yyyy').format(_start_date).toString() : ""} - ${_end_date != null ? DateFormat('dd/MM/yyyy').format(_end_date).toString() : ""}',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 75,
                                      child: ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: attendanceCount.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, i) {
                                            return Container(
                                              padding: const EdgeInsets.only(
                                                  right: 15, left: 10),
                                              margin: EdgeInsets.only(right: 5),
                                              decoration: BoxDecoration(
                                                  color:
                                                      getAttendanceStatusBgColor(
                                                          attendanceCount[i]
                                                              .status!),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    attendanceCount[i]
                                                        .count
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          getAttendanceStatusColor(
                                                              attendanceCount[i]
                                                                  .status!),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    getAttendanceStatusText(
                                                        attendanceCount[i]
                                                            .status!),
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .textPurpleColor,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                    if (hoursCount.isNotEmpty)
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    if (hoursCount.isNotEmpty)
                                      SizedBox(
                                        height: 75,
                                        child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: hoursCount.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, i) {
                                              return Container(
                                                padding: const EdgeInsets.only(
                                                    right: 15, left: 10),
                                                margin:
                                                    EdgeInsets.only(right: 5),
                                                decoration: BoxDecoration(
                                                    color: hoursCount[i].isOk!
                                                        ? AppColors
                                                            .checkinGreenBg
                                                        : AppColors
                                                            .checkoutRedBg,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      hoursCount[i]
                                                          .count
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: hoursCount[i]
                                                                .isOk!
                                                            ? AppColors
                                                                .checkinGreen
                                                            : AppColors
                                                                .checkoutRed,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      hoursCount[i].status!,
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .textPurpleColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                ),
                GridView.extent(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: BoxCard(
                          name: 'Attendance',
                          icon: Icon(
                            Icons.access_time,
                            size: MediaQuery.of(context).size.width / 6,
                            color: const Color(0xFF563174),
                          )),
                    ),
                    BoxCard(
                      name: 'Leave',
                      icon: Icon(
                        Icons.ballot_outlined,
                        size: MediaQuery.of(context).size.width / 6,
                        color: const Color(0xFF563174),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationsScreen(),
                          ),
                        );
                      },
                      child: BoxCard(
                        name: 'Locations',
                        icon: Icon(
                          Icons.location_on_outlined,
                          size: MediaQuery.of(context).size.width / 6,
                          color: const Color(0xFF563174),
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () async {
                    //     final result = await Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => MyFaceRecog(),
                    //       ),
                    //     );
                    //     print(
                    //         '${result["attchFaceImage"]}, Response Resized image file path Saad:');
                    //   },
                    //   child: BoxCard(
                    //     name: 'Face Scanner',
                    //     icon: Icon(
                    //       Icons.settings_overscan_sharp,
                    //       size: MediaQuery.of(context).size.width / 6,
                    //       color: const Color(0xFF563174),
                    //     ),
                    //   ),
                    // ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const SalaryScreen(),
                    //       ),
                    //     );
                    //   },
                    //   child: BoxCard(
                    //     name: 'Salary',
                    //     icon: Icon(
                    //       Icons.attach_money_outlined,
                    //       size: MediaQuery.of(context).size.width / 6,
                    //       color: const Color(0xFF563174),
                    //     ),
                    //   ),
                    // ),
                    // BoxCard(
                    //   name: 'Loans',
                    //   icon: Icon(
                    //     Icons.payment,
                    //     size: MediaQuery.of(context).size.width / 6,
                    //     color: const Color(0xFF563174),
                    //   ),
                    // ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
