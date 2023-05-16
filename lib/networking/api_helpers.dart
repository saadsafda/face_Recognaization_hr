import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/utils.dart';

import 'dio_client.dart';

class APIFunction {
  static Future<dynamic> get(
      BuildContext context, Utils? _utils, String _url, String? token) async {
    try {
      SharedPref prefs = SharedPref();
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.get(_url);
      return response.data;
    } catch (e) {
      _utils!.loggerPrint(e);
      rethrow;
      return null;
    }
  }

  static Future<dynamic> post(BuildContext context, Utils? _utils, String _url,
      FormData _formData, String? token) async {
    try {
      SharedPref prefs = SharedPref();
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      _utils!.loggerPrint(_formData);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.post(_url, data: _formData);
      return response;
    } catch (e) {
      _utils!.loggerPrint(e);
      return;
    }
  }

  static Future<dynamic> put(BuildContext context, Utils? _utils, String _url,
      FormData _formData, String? token) async {
    try {
      SharedPref prefs = SharedPref();
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      _utils!.loggerPrint(_formData);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.put(_url, data: _formData);
      return response;
    } catch (e) {
      _utils!.loggerPrint(e);
      rethrow;
    }
  }

  static Future<dynamic> delete(
      BuildContext context, Utils? _utils, String _url, String? token) async {
    try {
      SharedPref prefs = SharedPref();
      String baseURL = await prefs.readString(prefs.prefBaseUrl);
      var clientInstance =
          await ApiClient().apiClientInstance(context, baseURL);
      Response response = await clientInstance.delete(_url);
      return response.data;
    } catch (e) {
      _utils!.loggerPrint(e);
      rethrow;
    }
  }
}
