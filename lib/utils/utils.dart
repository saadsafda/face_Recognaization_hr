import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sowaanerp_hr/common/common_dialog.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/theme.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/constants.dart';
import 'package:sowaanerp_hr/utils/strings.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class Utils {
  void darkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.grey,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  void lightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.grey,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  static void screenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void showProgressDialog(BuildContext buildContext, {text = ""}) {
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: WillPopScope(
              onWillPop: () async => false,
              child: Center(
                  child: text == ""
                      ? Container(
                          width:
                              ResponsiveFlutter.of(context).moderateScale(80),
                          height:
                              ResponsiveFlutter.of(context).moderateScale(80),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary,
                                offset: const Offset(0.0, 1.0),
                                blurRadius: 8.0,
                              )
                            ],
                            borderRadius: BorderRadius.circular(
                              ResponsiveFlutter.of(context).moderateScale(100),
                            ),
                            color: AppColors.white,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Container(
                          width:
                              ResponsiveFlutter.of(context).moderateScale(250),
                          height:
                              ResponsiveFlutter.of(context).moderateScale(130),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary,
                                offset: const Offset(0.0, 1.0),
                                blurRadius: 8.0,
                              )
                            ],
                            borderRadius: BorderRadius.circular(
                              ResponsiveFlutter.of(context).moderateScale(10),
                            ),
                            color: AppColors.white,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: ResponsiveFlutter.of(context)
                                      .verticalScale(20),
                                ),
                                CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                                SizedBox(
                                  height: ResponsiveFlutter.of(context)
                                      .verticalScale(20),
                                ),
                                Text(
                                  text,
                                  style: heading6.copyWith(
                                      color: AppColors.primary, fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        )),
            ),
          ),
        );
      },
    );
  }

  void hideProgressDialog(BuildContext buildContext) {
    Navigator.of(buildContext, rootNavigator: true).pop();
  }

  String getDeviceType() {
    if (Platform.isAndroid) {
      return Constants.deviceTypeAndroid;
    } else {
      return Constants.deviceTypeIos;
    }
  }

  bool emailValidator(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(email)) {
      return true;
    }

    return false;
  }

  bool phoneValidator(String contact) {
    String p =
        r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$';

    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(contact)) {
      return true;
    }

    return false;
  }

  bool isValidationEmpty(String? val) {
    if (val == null) {
      return true;
    } else {
      val = val.trim();
      if (val.isEmpty ||
          val == "null" ||
          val == "" ||
          val.length == 0 ||
          val == "NULL") {
        return true;
      } else {
        return false;
      }
    }
  }

  bool isValidationEmptyWithZero(String? val) {
    if (val == null) {
      return true;
    } else {
      val = val.trim();
      if (val.isEmpty ||
          val == "null" ||
          val == "" ||
          val.length == 0 ||
          val == "NULL" ||
          val == "0" ||
          val == "00") {
        return true;
      } else {
        return false;
      }
    }
  }

  bool validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  Future<bool> isNetworkAvailable(
    BuildContext? context,
    Utils? _utils, {
    bool? showDialog,
  }) async {
    ConnectivityResult _result;
    final Connectivity _connectivity = Connectivity();
    try {
      _result = await _connectivity.checkConnectivity();
      _utils!.loggerPrint(_result);
      switch (_result) {
        case ConnectivityResult.wifi:
          return true;
        case ConnectivityResult.mobile:
          return true;
        default:
          if (showDialog!) {
            // alertDialog('Your internet is not available, please try again later', contextDialog: context);
            dialogAlert(context!, _utils, Strings.extraInternetConnection);
          }
          return false;
      }
    } on PlatformException catch (e) {
      _utils!.loggerPrint(e.toString());
      if (showDialog!) {
        // alertDialog('Your internet is not available, please try again later', contextDialog: context);
        dialogAlert(context!, _utils, Strings.extraInternetConnection);
      }
      return false;
    }
  }

  /*void alertDialog(String alertDetailMessage, {BuildContext? contextDialog}) async {
    List<String> alertTitles = <String>[Strings.btnOk];
    CommonDialog(
      context: contextDialog,
      alertTitle: Strings.appName,
      alertDetailMessage: alertDetailMessage,
      alertActionTitles: alertTitles,
      onAlertAction: (int selectedActionIndex) {},
    ).show(contextDialog!);
  }*/

  getDeviceId() async {
    var deviceId = "";
    try {
      deviceId = await FlutterUdid.udid;
    } on PlatformException {
      deviceId = 'Failed to get UDID.';
    }

    return deviceId;
  }

  static transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String strTime = '';
    if (hoursStr == '00' || hoursStr == '0') {
      strTime = minutesStr.toString() + ':' + secondsStr.toString();
    } else {
      strTime = hoursStr.toString() +
          ':' +
          minutesStr.toString() +
          ':' +
          secondsStr.toString();
    }
    return strTime;
  }

  // String generateMd5(String input) {
  //   return md5.convert(utf8.encode(input)).toString();
  // }

  void showToast(Object message, BuildContext context) {
    Fluttertoast.showToast(
      msg: message.toString(),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primaryLight,
      fontSize: 14,
      textColor: AppColors.white,
    );
  }

  String currentTime() {
    String month = DateFormat.M().format(DateTime.now().toUtc());
    String day = DateFormat.d().format(DateTime.now().toUtc());
    String time = DateFormat.Hm().format(DateTime.now().toUtc());
    String timeDate = DateFormat.y().format(DateTime.now().toUtc()) +
        '-' +
        (month.length == 1 ? '0$month' : month) +
        '-' +
        (day.length == 1 ? '0$day' : day) +
        ' ' +
        time;
    return timeDate;
  }

  String currentDate(String outputFormat) {
    var now = new DateTime.now().toUtc();
    var formatter = new DateFormat(outputFormat);
    String formattedDate = formatter.format(now);

    return formattedDate;
  }

  List<String> fillSlots() {
    List<String> _list = [];
    for (int i = 1; i <= 100; i++) {
      _list.add("$i");
    }
    return _list;
  }

  String changeDateFormat(
    String? date,
    String? formatInput,
    String? formatOutput,
  ) {
    if (date != null && date.length != 0) {
      final format = DateFormat(formatInput);
      DateTime gettingDate = format.parse(date);
      final DateFormat formatter = DateFormat(formatOutput);
      final String formatted = formatter.format(gettingDate);
      return formatted;
    }
    return '';
  }

  String getDayOfMonthSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }

    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }

    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('dd-yyyy,MM HH:mm a');
    var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + 'DAY AGO';
      } else {
        time = diff.inDays.toString() + 'DAYS AGO';
      }
    }

    return time;
  }

  String removeTag(String content) {
    content = content.replaceAll("<b>", "").replaceAll("</b>", "");
    return content;
  }

  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void loggerPrint(Object? object) {
    if (object == null || isValidationEmpty(object.toString())) {
      debugPrint('>---> Empty Message');
    } else {
      debugPrint('>---> $object');
    }
  }

  String customDateTimeFormatDate(
    Utils? _utils, {
    required String dateTime,
    required String inputDateFormat,
    required String outputDateFormat,
  }) {
    if (!_utils!.isValidationEmpty(dateTime)) {
      var inputFormat = DateFormat(inputDateFormat);
      var inputDate = inputFormat.parse(dateTime);
      // var inputDate = inputFormat.parseUTC(dateTime);
      // var inputDate = inputFormat.parseUtc(dateTime);

      var outputFormat = DateFormat(outputDateFormat);
      return outputFormat.format(inputDate);
    } else {
      return dateTime;
    }
  }

  String customDateTimeFormatDuration(
    Utils? _utils, {
    required String dateTime,
    required String inputDateFormat,
    required String outputDateFormat,
  }) {
    if (!_utils!.isValidationEmpty(dateTime)) {
      dateTime = _utils.customDateTimeFormatDate(
        _utils,
        dateTime: dateTime,
        inputDateFormat: inputDateFormat,
        outputDateFormat: inputDateFormat,
      );

      String minute = _utils.customDateTimeFormatDate(
        _utils,
        dateTime: dateTime,
        inputDateFormat: inputDateFormat,
        outputDateFormat: Constants.dateFormatMM,
      );

      // if (minute.startsWith('0')) {
      //   minute = minute.replaceFirst('0', '');
      // }

      String second = _utils.customDateTimeFormatDate(
        _utils,
        dateTime: dateTime,
        inputDateFormat: inputDateFormat,
        outputDateFormat: Constants.dateFormatSS,
      );

      // if (second.startsWith('0')) {
      //   second = second.replaceFirst('0', '');
      // }
      String milliSec = _utils.customDateTimeFormatDate(
        _utils,
        dateTime: dateTime,
        inputDateFormat: inputDateFormat,
        outputDateFormat: Constants.dateFormatMS,
      );

      // if (milliSec.startsWith('0')) {
      //   milliSec = milliSec.replaceFirst('0', '');
      // }

      /*if (_utils.isValidationEmptyWithZero(milliSec)) {
        return '00:00:00';
      } else if (_utils.isValidationEmptyWithZero(second)) {
        return milliSec + Strings.hintAudioDurationMilliSecond;
      } else if (_utils.isValidationEmptyWithZero(minute)) {
        return second + Strings.hintAudioDurationSecond+ ' ' + milliSec + Strings.hintAudioDurationMilliSecond;
      } else {
        return minute + Strings.hintAudioDurationMinute + ' ' + second + Strings.hintAudioDurationSecond+ ' ' + milliSec + Strings.hintAudioDurationMilliSecond;
      }*/
      // return minute + Strings.hintAudioDurationMinute + ' ' + second + Strings.hintAudioDurationSecond + ' ' + milliSec + Strings.hintAudioDurationMilliSecond;
      return minute +
          Strings.hintAudioDurationMinute +
          ' ' +
          second +
          Strings.hintAudioDurationSecond +
          ' ' +
          milliSec +
          Strings.hintAudioDurationMilliSecond;
    } else {
      return dateTime;
    }
  }

  String convertToAgo({
    required Utils? utils,
    required String? dateTime,
  }) {
    var dateFormat =
        DateFormat("dd-MM-yyyy hh:mm aa"); // you can change the format here
    var utcDate =
        dateFormat.format(DateTime.parse(dateTime!)); // pass the UTC time here
    var localDate = dateFormat.parse(utcDate, true).toLocal().toString();

    DateTime input = DateTime.parse(localDate);

    Duration diff = DateTime.now().difference(input);
// TODO: Confirm: below string set to Strings.dart file

    if (diff.inDays >= 1) {
      if (diff.inDays > 1) {
        // return utils!.customDateTimeFormatDate(
        //   utils,
        //   dateTime: DateTime.parse('').toLocal().toString(),
        //   inputDateFormat: Constants.dateFormatYYYYMMDDTHHMMSSSSSZ,
        //   outputDateFormat: Constants.dateFormatDDMMMYYYYSlashHHMMSSCommaAA,
        // );

        var strToDateTime = DateTime.parse(dateTime);
        final convertLocal = strToDateTime.toLocal();
        var newFormat = DateFormat(Constants.dateFormatMMMDD);
        return newFormat.format(convertLocal);
      } else {
        // return '${diff.inDays} day(s) ago';
        return Strings.lblAgoDays(diff.inDays);
      }
    } else if (diff.inHours >= 1) {
      // return '${diff.inHours} hour(s) ago';
      return Strings.lblAgoHours(diff.inHours);
    } else if (diff.inMinutes >= 1) {
      // return '${diff.inMinutes} minute(s) ago';
      return Strings.lblAgoMinutes(diff.inMinutes);
    } else if (diff.inSeconds >= 1) {
      // return '${diff.inSeconds} second(s) ago';
      return Strings.lblAgoSeconds(diff.inSeconds);
    } else {
      // return 'Just now';
      return Strings.lblJustNow;
    }
  }

  // String getDifferenceBetweenTwoDateTime(
  //   Utils? _utils, {
  //   required String dateTime,
  //   required String inputDateFormat,
  //   required String outputDateFormat,
  // }) {
  //   /*if (!_utils!.isValidationEmpty(dateTime)) {
  //     var inputFormat = DateFormat(inputDateFormat);
  //     var inputDate = inputFormat.parse(dateTime);
  //
  //     DateTime time = new DateTime.now();
  //     var outputFormat = DateFormat(outputDateFormat);
  //     // var outputDate = outputFormat.parse(time);
  //     var outputDate = outputFormat.format(time);
  //     var inputDate1 = outputDate.compareTo(inputDate);
  //   } else {
  //     return dateTime;
  //   }*/
  //
  //   /*if (!_utils!.isValidationEmpty(dateTime)) {
  //     var inputFormat = DateFormat(inputDateFormat);
  //     var inputDate = inputFormat.parse(dateTime);
  //
  //     var outputFormat = DateFormat(outputDateFormat);
  //     return outputFormat.format(inputDate);
  //   } else {
  //     return dateTime;
  //   }*/
  //
  //   String output = '';
  //   final format = DateFormat(inputDateFormat);
  //   // DateTime from = format.parse(dateTime);
  //   DateTime from = format.parse(dateTime).toLocal();
  //   final to = DateTime.now();
  //
  //   int seconds = (to.difference(from).inSeconds /*/ 60).round(*/);
  //   int minutes = (to.difference(from).inMinutes /*/ 60).round(*/);
  //   int hours = (to.difference(from).inHours /*/ 24).round(*/);
  //   int days = (to.difference(from).inDays /*/ 365).round(*/);
  //
  //   // if (_utils != null) {
  //   //   _utils.loggerPrint('test_days $days');
  //   //   _utils.loggerPrint('test_hours $hours');
  //   //   _utils.loggerPrint('test_minutes $minutes');
  //   //   _utils.loggerPrint('test_seconds $seconds');
  //   // }
  //
  //   // : Test: confirm now below string set to Strings.dart file
  //
  //   if (days > 0) {
  //     /*if (days == 1) {
  //       output = '$days day ago';
  //     } else {
  //       output = '$days days ago';
  //     }*/
  //
  //     output = _utils!.customDateTimeFormatDate(
  //       _utils,
  //       dateTime: dateTime,
  //       inputDateFormat: Constants.dateFormatYYYYMMDDTHHMMSSSSSZ,
  //       outputDateFormat: Constants.dateFormatDDMMMYYYYSlashHHMMSSCommaAA,
  //     );
  //   } else if (hours > 0) {
  //     if (hours == 1) {
  //       output = '$hours hour ago';
  //     } else {
  //       output = '$hours hours ago';
  //     }
  //   } else if (minutes > 0) {
  //     if (minutes == 1) {
  //       output = '$minutes minute ago';
  //     } else {
  //       output = '$minutes minutes ago';
  //     }
  //   } else if (seconds > 0) {
  //     if (seconds == 1) {
  //       output = '$seconds second ago';
  //     } else {
  //       output = '$seconds seconds ago';
  //     }
  //   } else {
  //     output = 'Just now';
  //   }
  //
  //   return output;
  // }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    // return (to.difference(from).inHours / 24).round();
    return to.difference(from).inDays;
  }

  String getMilliSecToTime({
    required int? milliseconds,
    required String? outputDateFormat,
    required Utils? utils,
  }) {
    var date = DateTime.fromMillisecondsSinceEpoch(milliseconds!, isUtc: true);
    var txt = DateFormat(outputDateFormat, 'en_GB').format(date);
    utils!.loggerPrint('test_max_duration_3: $txt');

    if (txt.length > 8) {
      return txt.substring(0, 8);
    } else {
      return txt;
    }
  }

  String? getHttpsToHttp(String? url) {
    if (Platform.isAndroid) {
      // TODO: Pending: solution
      return url!.replaceAll('https', 'http');
    } else {
      return url;
    }
  }
}
