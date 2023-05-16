import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/strings.dart';
import 'package:sowaanerp_hr/utils/utils.dart';

import 'common_widget.dart';

typedef AlertAction<T> = void Function(T index);

void dialogConfirm(BuildContext context, Utils _utils,
    GestureTapCallback? callbackPositive, String? msg) async {
  _utils.hideKeyboard(context);

  showDialog(
      context: context,
      barrierColor: AppColors.colorDialogTransparentBackground,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
                            ResponsiveFlutter.of(context)
                                .moderateScale(12, 0.0),
                          )),
                      alignment: AlignmentDirectional.center,
                      child: Column(
                        children: [
                          Container(
                            child: MyTextView(
                              /*Strings.titleConfirmation*/
                              Strings.appName,
                              textStyleNew: TextStyle(
                                color: AppColors.black,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                ResponsiveFlutter.of(context).verticalScale(28),
                          ),
                          Container(
                            child: MyTextView(
                              msg!,
                              textAlignNew: TextAlign.start,
                              textStyleNew: TextStyle(
                                color: AppColors.black,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(2),
                                fontWeight: FontWeight.w400,
                              ),
                              isMaxLineWrap: true,
                            ),
                          ),
                          SizedBox(
                            height:
                                ResponsiveFlutter.of(context).verticalScale(28),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  child: commonButton(
                                    context: context,
                                    title: Strings.btnYes,
                                    fontSize: 3,
                                    fontWeight: FontWeight.w800,
                                    callback: callbackPositive,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveFlutter.of(context)
                                    .verticalScale(20),
                              ),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  child: commonButton1(
                                    context: context,
                                    title: Strings.btnNo,
                                    fontSize: 3,
                                    callback: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
}

void dialogSelectOption(
    BuildContext context,
    Utils _utils,
    GestureTapCallback? callbackTakePhoto,
    GestureTapCallback? callbackChooseFromGallery) async {
  _utils.hideKeyboard(context);

  showDialog(
      context: context,
      barrierColor: AppColors.colorDialogTransparentBackground,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Container(
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
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    Align(
                      child: Container(
                        child: MyTextView(
                          'Select the source of photo',
                          textStyleNew: TextStyle(
                            color: AppColors.darkGreyColor,
                            fontSize: ResponsiveFlutter.of(context).fontSize(3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveFlutter.of(context).verticalScale(28),
                    ),
                    Container(
                      width: double.infinity,
                      child: commonButton(
                        context: context,
                        title: Strings.btnTakePhoto,
                        fontSize: 2,
                        callback: callbackTakePhoto,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveFlutter.of(context).verticalScale(20),
                    ),
                    Container(
                      width: double.infinity,
                      child: commonButton(
                        context: context,
                        title: Strings.btnChooseFromGallery,
                        fontSize: 2,
                        callback: callbackChooseFromGallery,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveFlutter.of(context).verticalScale(20),
                    ),
                    Container(
                      width: double.infinity,
                      child: commonButton1(
                        context: context,
                        title: Strings.btnCancel,
                        fontSize: 2,
                        callback: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
}

void dialogAlert(BuildContext context, Utils _utils, String? msg,
    {String? title = "", Icon? icon}) {
  if (_utils.isValidationEmpty(title!)) {
    title = Strings.appName;
  }

  showDialog(
      context: context,
      barrierColor: AppColors.colorDialogTransparentBackground,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
                            ResponsiveFlutter.of(context)
                                .moderateScale(12, 0.0),
                          )),
                      alignment: AlignmentDirectional.center,
                      child: Column(
                        children: [
                          Container(
                            child: MyTextView(
                              title!,
                              textStyleNew: TextStyle(
                                color: AppColors.darkGreyColor,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                ResponsiveFlutter.of(context).verticalScale(28),
                          ),
                          Container(
                            child: MyTextView(
                              msg!,
                              textAlignNew: TextAlign.start,
                              textStyleNew: TextStyle(
                                color: AppColors.darkGreyColor,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(2),
                                fontWeight: FontWeight.w400,
                              ),
                              isMaxLineWrap: true,
                              // isMaxLineWrap: false,
                              // maxLinesNew: 10,
                            ),
                          ),
                          if (icon != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: icon,
                              ),
                            ),
                          SizedBox(
                            height:
                                ResponsiveFlutter.of(context).verticalScale(28),
                          ),
                          Row(
                            children: [
                              Expanded(child: SizedBox()),
                              Container(
                                width: ResponsiveFlutter.of(context).scale(100),
                                child: commonButton(
                                  context: context,
                                  title: Strings.btnOk,
                                  fontSize: 2,
                                  callback: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                ),
                              ),
                              Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
}

void dialogAlertHandleOkClick(BuildContext context, Utils _utils, String? msg,
    GestureTapCallback? callback,
    {String? title = ""}) {
  if (_utils.isValidationEmpty(title!)) {
    title = Strings.appName;
  }

  showDialog(
      context: context,
      barrierColor: AppColors.colorDialogTransparentBackground,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                          ResponsiveFlutter.of(context).moderateScale(28)),
                      margin: EdgeInsets.all(
                        ResponsiveFlutter.of(context).moderateScale(20, 0.0),
                      ),
                      decoration: BoxDecoration(
                          color: AppColors.colorBgDialog,
                          borderRadius: BorderRadius.circular(
                            ResponsiveFlutter.of(context)
                                .moderateScale(12, 0.0),
                          )),
                      alignment: AlignmentDirectional.center,
                      child: Column(
                        children: [
                          Container(
                            child: MyTextView(
                              title!,
                              textStyleNew: TextStyle(
                                color: AppColors.colorWhite,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                ResponsiveFlutter.of(context).verticalScale(28),
                          ),
                          Container(
                            child: MyTextView(
                              msg!,
                              // textAligntNew: TextAlign.justify,
                              textAlignNew: TextAlign.start,
                              textStyleNew: TextStyle(
                                color: AppColors.colorWhite,
                                fontSize:
                                    ResponsiveFlutter.of(context).fontSize(2),
                                fontWeight: FontWeight.w400,
                              ),
                              isMaxLineWrap: true,
                            ),
                          ),
                          SizedBox(
                            height:
                                ResponsiveFlutter.of(context).verticalScale(28),
                          ),
                          Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              Container(
                                width: ResponsiveFlutter.of(context).scale(100),
                                child: commonButton(
                                  context: context,
                                  title: Strings.btnOk,
                                  fontSize: 2,
                                  callback: callback,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
}
