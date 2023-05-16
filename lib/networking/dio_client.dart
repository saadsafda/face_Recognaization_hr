import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sowaanerp_hr/common/common_dialog.dart';
import 'package:sowaanerp_hr/screens/login_screen.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/strings.dart';
import 'package:sowaanerp_hr/utils/utils.dart';
import 'package:flutter/material.dart';

class ApiClient {
  // static String baseUrl = 'http://192.168.208.128:8000';
  // static String baseUrl = 'http://192.168.0.107:8000/api/';

  // header key
  static String headerKeyKey = 'key';
  static String headerKeyToken = 'token';

  // api
  static String apiLogin = '/api/method/login';
  static String apiGetEmployeeInfo =
      '/api/method/sowaan_hr.sowaan_hr.api.employee.get_employee_info';
  static String apiGetLocations =
      '/api/method/sowaan_hr.sowaan_hr.api.employee.get_allowed_locations';
  static String apiCreateEmployeeCheckIn =
      '/api/method/sowaan_hr.sowaan_hr.api.checkin.create_employee_checkin';
  static String apiGetEmployeeTodayCheckIn =
      '/api/method/sowaan_hr.sowaan_hr.api.checkin.get_my_today_checkins';
  static String apiGetAttendanceSummary =
      '/api/method/sowaan_hr.sowaan_hr.api.attendance.get_attendance_summary_statuswise';
  static String apiGetMonthlyHours =
      '/api/method/sowaan_hr.sowaan_hr.api.attendance.get_monthly_hours';
  static String apiGetCheckins =
      '/api/method/sowaan_hr.sowaan_hr.api.checkin.get_checkins';
  static String apiGetPayrollData =
      '/api/method/sowaan_hr.sowaan_hr.api.attendance.get_payroll_date';
  static String apiEmployeeAttendance =
      '/api/method/sowaan_hr.sowaan_hr.api.attendance.get_attendance';
  static String apiGetEmployeeList =
      "/api/method/sowaan_hr.sowaan_hr.api.employee.get_employee_list";
  static String apiAddFaceId =
      "/api/method/sowaan_hr.sowaan_hr.api.user.add_face_id";
      
  // user
  static String apiUploadImage = "/api/method/upload_file";
  static String apiUpdateUserImage =
      "/api/method/sowaan_hr.sowaan_hr.api.user.update_user_image";

  static String? cookies;

  Future<Dio> apiClientInstance(context, baseURL) async {
    Utils _utils = Utils();
    SharedPref prefs = new SharedPref();
    var cookieJar = await getCookiePath();

    BaseOptions options = BaseOptions(
      baseUrl: baseURL,
      connectTimeout: 60000,
      receiveTimeout: 60000,
    );
    // Locale myLocale = Localizations.localeOf(context);
    // String selectedLanguage = myLocale.languageCode;
    // _utils.loggerPrint("Language code: $selectedLanguage");

    Dio dio = Dio(options);

    // _utils.loggerPrint("Token : " + token);
    _utils.loggerPrint("Token : " + baseURL);

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    dio.interceptors.add(LogInterceptor(responseBody: true));
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions option, RequestInterceptorHandler handler) async {
          // var header = {
          //   headerKeyKey: headerKeyValue,
          //   // 'lang': selectedLanguage,
          // };
          //
          // option.headers.addAll(header);
          // option.headers['Authorization'] =
          //     "Bearer " + token.replaceAll('"', '').toString();
          _utils.loggerPrint(option.headers);
          return handler.next(option);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          return handler.next(response);
        },
        onError: (DioError e, ErrorInterceptorHandler handler) {
          if (e.response != null) {
            if (e.response!.statusCode == 403) {
              prefs.saveObject(prefs.prefKeyEmployeeData, null);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return LoginScreen();
                },
              ), (route) => false);
            } else if (e.response!.data["message"] != null) {
              _utils.showToast(e.response!.data["message"].toString(), context);
            } else if (e.response!.data["exception"] != null) {
              _utils.showToast(e.response!.data["exception"], context);
            } else {
              _utils.showToast(e.response.toString(), context);
              _utils.loggerPrint(e.response?.statusCode);
            }
          } else {
            _utils.showToast(Strings.msgTryAgain, context);
            _utils.loggerPrint(e.message);
          }

          // _utils.loggerPrint(
          //     'Dio DEFAULT Error Message :---------------> ${e.message} ${e.response}');
          // if (e.type == DioErrorType.other) {
          //   _utils
          //       .loggerPrint('<<<<<<<-------------other Error---------->>>>>>');
          // } else if (e.type == DioErrorType.connectTimeout) {
          //   _utils.loggerPrint(
          //       '<<<<<<<-------------CONNECT_TIMEOUT---------->>>>>>');
          // } else if (e.type == DioErrorType.receiveTimeout) {
          //   _utils.loggerPrint(
          //       '<<<<<<<-------------RECEIVE_TIMEOUT---------->>>>>>');
          // }

          // utils.alertDialog(Strings.msgTryAgain, contextDialog: context);
          // dialogAlert(context, _utils, Strings.msgTryAgain);

          return handler.reject(e);
        },
      ),
    );
    return dio;
  }

  static Future initCookies() async {
    cookies = await getCookies();
  }

  static Future<PersistCookieJar> getCookiePath() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    String appDocPath = appDocDir.path;
    return PersistCookieJar(
        ignoreExpires: true, storage: FileStorage(appDocPath));
  }

  static Future<String?> getCookies() async {
    var cookieJar = await getCookiePath();
    SharedPref prefs = SharedPref();
    String baseURL = await prefs.readString(prefs.prefBaseUrl);

    if (baseURL != "") {
      var cookies = await cookieJar.loadForRequest(Uri.parse(baseURL));

      var cookie = CookieManager.getCookies(cookies);

      return cookie;
    } else {
      return null;
    }
  }
}
