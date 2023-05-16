import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sowaanerp_hr/common/common_widget.dart';
import 'package:sowaanerp_hr/models/checkin.dart';
import 'package:sowaanerp_hr/models/employee.dart';
import 'package:sowaanerp_hr/models/employee_listItem.dart';
import 'package:sowaanerp_hr/models/payroll_date.dart';
import 'package:sowaanerp_hr/networking/api_helpers.dart';
import 'package:sowaanerp_hr/networking/dio_client.dart';
import 'package:sowaanerp_hr/theme.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/utils.dart';
import 'package:sowaanerp_hr/widgets/custom_appbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CheckinScreen extends StatefulWidget {
  @override
  _CheckinScreenState createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final Utils _utils = Utils();
  final SharedPref _prefs = SharedPref();
  Employee _employeeModel = Employee();
  PayrollDate _payrollDate = PayrollDate();
  final _scrollController = ScrollController();
  List<EmployeeListItem> _employeeList = [];
  List<Checkin> checkinList = [];
  bool isNetworkAvailable = true;
  bool isLoadingCheckin = true;
  bool _scrollLoading = false;
  bool _isMessage = false;
  int _pageNumber = 1;
  var _start_date;
  var _end_date;
  var dateStart;
  var dateEnd;
  Employee _selectedEmployee = Employee();

  @override
  void initState() {
    super.initState();
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

    // get Employee list from server
    _scrollController.addListener(() async {
      if (_isMessage) {
        return;
      } else {
        setState(() {
          _scrollLoading = true;
        });
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.offset) {
          await getCheckinLog();
        }
      }
    });
  }

  userDetails(value) async {
    if (value != null) {
      setState(() {
        _employeeModel = Employee.fromJson(value);
        _selectedEmployee = _employeeModel;
        _pageNumber = 1;
      });
      await getEmployeeList();

      await getCheckinLog();
    }
  }

  Future<void> getEmployeeList() async {
    _utils
        .isNetworkAvailable(context, _utils, showDialog: true)
        .then((value) async {
      _utils.hideKeyboard(context);
      if (value) {
        var response = await APIFunction.get(
            context, _utils, ApiClient.apiGetEmployeeList, '');

        if (response != null) {
          var data = response['message']['employees'];
          // EmployeeList employeeList = EmployeeList.fromJson(response.data);
          _employeeList = [];
          setState(() {
            data.forEach((item) {
              _employeeList.add(EmployeeListItem.fromJson(item));
            });
            isLoadingCheckin = false;
          });
        } else {
          _utils.showToast(response['message'], context);
        }
      }
    });
  }

  Future<void> getCheckinLog() async {
    bool available =
        await _utils.isNetworkAvailable(context, _utils, showDialog: true);

    _utils.hideKeyboard(context);
    if (available) {
      var formData = FormData.fromMap({
        "employee": _selectedEmployee.name.toString(),
        "from_date": DateFormat('yyyy-MM-dd').format(_start_date).toString(),
        "to_date": DateFormat('yyyy-MM-dd').format(_end_date).toString(),
        "page": _pageNumber,
      });

      var data = APIFunction.post(
          context, _utils, ApiClient.apiGetCheckins, formData, '');

      await data.then((value) {
        setState(() {
          isLoadingCheckin = false;
        });
        if (value != null && value.statusCode == 200) {
          checkinList = [...checkinList];
          final v = value.data["message"];
          if (v.length == 0) {
            setState(() {
              _scrollLoading = false;
              _isMessage = true;
            });
          } else {
            setState(() {
              _pageNumber = _pageNumber + 1;
              v.forEach((i) {
                checkinList.add(Checkin.fromJson(i));
              });
              _scrollLoading = false;
              _isMessage = false;
            });
          }
        }
      }).onError((error, stackTrace) {
        // setState(() {
        //   isLoadingAttendanceSummary = false;
        // });
        print('error $error');
      });
    } else {
      setState(() {
        isNetworkAvailable = false;
        isLoadingCheckin = false;
      });
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        dateStart = args.value.startDate;
        dateEnd = args.value.endDate ?? args.value.startDate;
      }
    });
  }

  _onSubmit() async {
    setState(() {
      _start_date = DateTime.parse(dateStart.toString());
      _end_date = DateTime.parse(dateEnd.toString());
      isLoadingCheckin = false;
    });
    await getCheckinLog();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.textWhiteGrey,
        appBar: const PreferredSize(
          child: CustomAppBar(
            title: "Checkin log",
            icon: Icons.notifications_none,
            // icon2: Icons.settings,
          ),
          preferredSize: Size.fromHeight(50),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: AppColors.textWhiteGrey,
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _scrollLoading = true;
                checkinList = [];
                _pageNumber = 1;
              });
              await getCheckinLog();
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
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
                      '${_start_date != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_start_date.toString())).toString() : ""} - ${_end_date != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_end_date.toString())).toString() : ""}',
                    ),
                  ),
                  _employeeList.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownSearch<EmployeeListItem>(
                            items: _employeeList,
                            selectedItem: _selectedEmployee.name == ""
                                ? null
                                : _employeeList.firstWhere((element) =>
                                    element.name == _selectedEmployee.name),
                            compareFn: (i, s) =>
                                i.employeeName == s.employeeName! ||
                                i.name == s.name,
                            filterFn: (i, s) =>
                                i.employeeName!
                                    .toLowerCase()
                                    .contains(s.toString().toLowerCase()) ||
                                i.name!
                                    .toLowerCase()
                                    .contains(s.toString().toLowerCase()),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                label: Text(
                                  'Employee',
                                  style: TextStyle(
                                    color: AppColors.textPurpleColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.textPurpleColor,
                                  ),
                                ),
                              ),
                              baseStyle: TextStyle(
                                fontSize: 16,
                                color: AppColors.textPurpleColor,
                              ),
                            ),
                            onChanged: (value) async {
                              if (value != null) {
                                setState(() {
                                  _selectedEmployee.name = value.name;
                                  _selectedEmployee.employeeName =
                                      value.employeeName;
                                  _scrollLoading = true;
                                  _pageNumber = 1;
                                  checkinList = [];
                                });
                              } else {
                                setState(() {
                                  _scrollLoading = true;
                                  checkinList = [];
                                  _selectedEmployee.name = "";
                                  _selectedEmployee.employeeName = "";
                                  _pageNumber = 1;
                                });
                              }
                              await getCheckinLog();
                            },
                            clearButtonProps: ClearButtonProps(
                              isVisible: true,
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.primary,
                              ),
                            ),
                            dropdownBuilder: employeeDropdownBuilder,
                            popupProps: const PopupProps.bottomSheet(
                                showSelectedItems: true,
                                showSearchBox: true,
                                itemBuilder: employeePopupItemBuilder),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  !isLoadingCheckin && !isNetworkAvailable
                      ? Center(
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
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: checkinList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 12, right: 12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          checkinList[index].employeeName ==
                                                  _employeeModel.employeeName
                                              ? Container()
                                              : Text(
                                                  checkinList[index]
                                                      .employeeName
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: heading6.copyWith(
                                                      color: AppColors.grey,
                                                      fontSize: 12),
                                                ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat('dd-MMM-yyyy kk:mm')
                                                    .format(DateTime.parse(
                                                        checkinList[index]
                                                            .time!)),
                                                textAlign: TextAlign.center,
                                                style: heading6.copyWith(
                                                    color: AppColors.grey,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 45,
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color:
                                              checkinList[index].logType == "IN"
                                                  ? AppColors.checkinGreenBg
                                                  : AppColors.checkoutRedBg,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(4),
                                          ),
                                        ),
                                        child: Text(
                                            checkinList[index]
                                                .logType
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            style: heading6.copyWith(
                                                color: checkinList[index]
                                                            .logType ==
                                                        "IN"
                                                    ? AppColors.checkinGreen
                                                    : AppColors.checkoutRed,
                                                fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  const Divider()
                                ],
                              ),
                            );
                          },
                        ),
                  isLoadingCheckin || _scrollLoading == true
                      ? Container(
                          margin: const EdgeInsets.all(20),
                          child: SpinKitThreeBounce(
                            size: 30,
                            color: AppColors.primary,
                          ),
                        )
                      : !isLoadingCheckin &&
                                  isNetworkAvailable &&
                                  checkinList.isEmpty ||
                              _isMessage == true
                          ? Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.light_grey,
                                  ),
                                  Text("No data to show",
                                      style: heading6.copyWith(
                                          color: AppColors.light_grey)),
                                ],
                              ),
                            )
                          : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
