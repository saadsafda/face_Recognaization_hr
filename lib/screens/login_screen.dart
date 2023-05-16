// ignore_for_file: must_be_immutable, unused_local_variable

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/common/common_dialog.dart';
import 'package:sowaanerp_hr/models/employee.dart';
import 'package:sowaanerp_hr/models/payroll_date.dart';
import 'package:sowaanerp_hr/networking/api_helpers.dart';
import 'package:sowaanerp_hr/networking/dio_client.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/image_path.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/utils.dart';
import 'package:sowaanerp_hr/widgets/bottombar.dart';
import 'package:sowaanerp_hr/widgets/passwordfield_circular.dart';
import 'package:sowaanerp_hr/widgets/primary_button.dart';
import 'package:sowaanerp_hr/widgets/textfield_circular.dart';

import '../theme.dart';

class LoginScreen extends StatefulWidget {
  bool? isLoggedIn;
  LoginScreen({Key? key, this.isLoggedIn}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = false;
  bool isRemember = false;

  final Utils _utils = Utils();
  final SharedPref _pref = SharedPref();

  final TextEditingController _urlController =
      TextEditingController(text: "https://demo.sowaan.com");
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pref.readString(_pref.prefUserName).then((value) {
      if (value != "") {
        setState(() {
          isRemember = true;
          _emailController.text = value;
        });
      }
    });
    _pref.readString(_pref.prefPassword).then((value) {
      if (value != "") {
        setState(() {
          _passwordController.text = value;
        });
        if (widget.isLoggedIn == true &&
            _urlController.text != "" &&
            _emailController.text != "" &&
            _passwordController.text != "") {
          handleLogin();
        }
      }
    });
    _pref.readString(_pref.prefBaseUrl).then((value) {
      if (value == "") {
        _urlController.text = "https://";
      } else {
        _urlController.text = value;
      }
    });
  }

  Future<void> validateBaseUrl() async {
    _urlController.text = _urlController.text.toLowerCase().replaceAll(' ', '');
    if (_urlController.text.endsWith("/")) {
      _urlController.text =
          _urlController.text.substring(0, _urlController.text.length - 1);
    }
    if (!_urlController.text.startsWith("https://") &&
        !_urlController.text.startsWith("http://")) {
      _urlController.text = "https://${_urlController.text}";
    }
  }

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  handleLogin() async {
    if (_utils.isValidationEmpty(_urlController.text)) {
      dialogAlert(context, _utils, "Please enter SowaanERP Url");
    } else if (_utils.isValidationEmpty(_emailController.text)) {
      dialogAlert(context, _utils, "Please enter username");
    } else if (_utils.isValidationEmpty(_passwordController.text)) {
      dialogAlert(context, _utils, "Please enter password");
    } else {
      await validateBaseUrl();
      _utils
          .isNetworkAvailable(context, _utils, showDialog: true)
          .then((value) {
        _utils.hideKeyboard(context);

        checkNetwork(value);
      });
    }
  }

  checkNetwork(bool value) async {
    if (value) {
      _utils.showProgressDialog(context);

      String token = await _pref.readString(_pref.prefKeyToken);
      await _pref.saveString(_pref.prefBaseUrl, _urlController.text);
      if (isRemember) {
        await _pref.saveString(_pref.prefUserName, _emailController.text);
        await _pref.saveString(_pref.prefPassword, _passwordController.text);
      } else {
        await _pref.saveString(_pref.prefUserName, "");
        await _pref.saveString(_pref.prefPassword, "");
      }
      String baseURL = await _pref.readString(_pref.prefBaseUrl);

      var formData = FormData.fromMap({
        'usr': _emailController.text,
        'pwd': _passwordController.text,
      });
      Future<dynamic> user = APIFunction.post(
          context, _utils, ApiClient.apiLogin, formData, token);
      user.then((value) => responseApi(value)).onError((error, stackTrace) {
        _utils.hideProgressDialog(context);
      });
    }
  }

  responseApi(value) {
    if (value != null && value.statusCode == 200) {
      // _utils.showToast(value.data["message"], context);
      getEmployeeInfo(true);
    } else {
      _utils.hideProgressDialog(context);
    }
  }

  getEmployeeInfo(bool value) async {
    if (value) {
      var formData = FormData.fromMap({'email': _emailController.text});
      Future<dynamic> user = APIFunction.post(
          context, _utils, ApiClient.apiGetEmployeeInfo, formData, "");
      await user
          .then((value) => responseApiEmployeeInfo(value))
          .onError((error, stackTrace) {
        _utils.hideProgressDialog(context);
      });
    }
  }

  responseApiEmployeeInfo(value) {
    if (value != null && value.statusCode == 200) {
      Employee employeeModel =
          Employee.fromJson(value.data["message"]["employee"]);

      _pref.saveObject(_pref.prefKeyEmployeeData, employeeModel);

      getPayrollDate(employeeModel.name);
    }
  }

  getPayrollDate(employee) async {
    _utils
        .isNetworkAvailable(context, _utils, showDialog: true)
        .then((value) async {
      _utils.hideKeyboard(context);
      var formData = FormData.fromMap({
        "employee": employee,
      });
      Future data = APIFunction.post(
          context, _utils, ApiClient.apiGetPayrollData, formData, '');
      await data.then((value) async {
        _utils.hideProgressDialog(context);
        if (value != null && value.statusCode == 200) {
          PayrollDate payrollDateModel =
              PayrollDate.fromJson(value.data["message"]);
          await _pref.saveObject(_pref.prefKeyPayrollDate, payrollDateModel);

          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) {
              return const BottomBar();
            },
          ), (route) => false);
        }
      }).onError((error, stackTrace) {
        _utils.hideProgressDialog(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Login to your account',
                    style: heading2.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    'assets/images/accent.png',
                    width: 99,
                    height: 4,
                  ),
                ],
              ),
              const SizedBox(
                height: 48,
              ),
              Form(
                child: Column(
                  children: [
                    TextFieldCircular(
                      controller: _urlController,
                      hintText: 'SowaanERP Url',
                      color: AppColors.textWhiteGrey,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFieldCircular(
                      controller: _emailController,
                      hintText: 'Username',
                      color: AppColors.textWhiteGrey,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    PasswordFieldCircular(
                      controller: _passwordController,
                      hintText: 'Password',
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Remember me",
                          style: heading6.copyWith(color: AppColors.textGrey),
                        ),
                        Switch(
                          value: isRemember,
                          onChanged: (value) {
                            setState(() {
                              isRemember = value;
                            });
                          },
                          activeTrackColor: AppColors.primary,
                          activeColor: AppColors.primaryLight,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              PrimaryButton(
                  buttonColor: AppColors.primary,
                  textValue: 'Login',
                  textColor: Colors.white,
                  callback: () => {handleLogin()}),
              const SizedBox(
                height: 24,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Powered by',
                            style: heading6.copyWith(
                                color: AppColors.textGrey, fontSize: 13)),
                        Image.asset(
                          ImagePath.icLogoTransparent,
                          width: 120,
                          // height: ResponsiveFlutter.of(context).verticalScale(200),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}