import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sowaanerp_hr/models/employee_listItem.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/image_path.dart';
import 'package:sowaanerp_hr/utils/utils.dart';

class MyTextView extends Text {
  final TextAlign? textAlignNew;
  final int? maxLinesNew;
  final TextStyle? textStyleNew;
  final TextOverflow? overflowText;
  final bool isMaxLineWrap;

  const MyTextView(
    String s, {
    this.textAlignNew = TextAlign.start,
    this.maxLinesNew = 1,
    this.overflowText = TextOverflow.ellipsis,
    this.isMaxLineWrap = false,
    @required this.textStyleNew,
  }) : super(
          s,
          textAlign: textAlignNew,
          maxLines: isMaxLineWrap ? null : maxLinesNew,
          overflow: isMaxLineWrap ? null : overflowText,
          style: textStyleNew,
        );
}

class MyTextStyle extends TextStyle {
  Color? color;
  FontWeight? fontWeight;
  double? size;

  // String? fontFamily;
  TextDecoration? decorationNew;
  Paint? background;
  double? letterSpacing;

  MyTextStyle({
    this.color = Colors.black,
    // @required this.fontWeight,
    this.fontWeight = FontWeight.normal,
    this.size = 14,
    // this.fontFamily = "Poppins",
    this.decorationNew = TextDecoration.none,
    this.background,
    this.letterSpacing = 0.0,
  })  : assert(color != null && fontWeight != null),
        super(
          color: color,
          fontWeight: fontWeight,
          fontSize: size,
          // fontFamily: fontFamily,
          decoration: decorationNew,
          background: background,
          letterSpacing: letterSpacing,
        );
}

Widget commonButton({
  BuildContext? context,
  GestureTapCallback? callback,
  String? title,
  double? padding = 12,
  double? cornerRadius = 12,
  double? fontSize = 2.5,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return GestureDetector(
    onTap: callback,
    child: Container(
      /* decoration: BoxDecoration(
        color: AppColors.btn_color,
        borderRadius: BorderRadius.all(
          Radius.circular(
            ResponsiveFlutter.of(context).moderateScale(cornerRadius!),
          ),
        ),
      ),*/
      decoration: BoxDecoration(
        /*boxShadow: [
        BoxShadow(
          color: AppColors.colorBtnText1,
          offset: Offset(0.0, 2.0),
          blurRadius: 1.0,
        )
      ],*/
        borderRadius: BorderRadius.circular(
            ResponsiveFlutter.of(context).moderateScale(cornerRadius!)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.primary,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveFlutter.of(context).moderateScale(padding!),
        ),
        child: MyTextView(
          title!,
          textAlignNew: TextAlign.center,
          textStyleNew: MyTextStyle(
            size: ResponsiveFlutter.of(context).fontSize(fontSize!),
            color: AppColors.white,
            fontWeight: fontWeight,
          ),
          isMaxLineWrap: true,
        ),
      ),
    ),
  );
}

Widget commonButton1({
  BuildContext? context,
  GestureTapCallback? callback,
  String? title,
  double? padding = 12,
  double? cornerRadius = 12,
  double? fontSize = 2.5,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return GestureDetector(
    onTap: callback,
    child: Container(
      /* decoration: BoxDecoration(
        color: AppColors.btn_color,
        borderRadius: BorderRadius.all(
          Radius.circular(
            ResponsiveFlutter.of(context).moderateScale(cornerRadius!),
          ),
        ),
      ),*/
      decoration: BoxDecoration(
          /*boxShadow: [
            BoxShadow(
              color: AppColors.colorBtnText1,
              offset: Offset(0.0, 2.0),
              blurRadius: 3.0,
            )
          ],*/
          borderRadius: BorderRadius.circular(
              ResponsiveFlutter.of(context).moderateScale(cornerRadius!)),
          border: Border.all(
            color: AppColors.primary,
            width: ResponsiveFlutter.of(context).moderateScale(1),
          )
          /* gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.colorBtnStart, AppColors.colorBtnEnd])*/
          ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveFlutter.of(context).moderateScale(padding!),
        ),
        child: MyTextView(
          title!,
          textAlignNew: TextAlign.center,
          textStyleNew: MyTextStyle(
            size: ResponsiveFlutter.of(context).fontSize(fontSize!),
            color: AppColors.primary,
            fontWeight: fontWeight,
          ),
          isMaxLineWrap: true,
        ),
      ),
    ),
  );
}

Widget widgetToolBar(
  BuildContext context,
  Utils _utils,
  String title,
  String count, {
  bool isBackUpdated = false,
  bool isDelete = false,
  GestureTapCallback? onTapDelete,
}) {
  return Wrap(
    children: [
      Container(
        padding: EdgeInsets.only(
          left: ResponsiveFlutter.of(context).moderateScale(16, 0.0),
          right: isDelete
              ? ResponsiveFlutter.of(context).moderateScale(16, 0.0)
              : ResponsiveFlutter.of(context).moderateScale(28, 0.0),
        ),
        height: AppBar().preferredSize.height,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                _utils.hideKeyboard(context);
                isBackUpdated
                    ? Navigator.pop(context, true)
                    : Navigator.pop(context);
              },
              child: Container(
                height: double.infinity,
                color: AppColors.colorTransparentNull,
                padding: EdgeInsets.only(
                  left: ResponsiveFlutter.of(context).moderateScale(12, 0.0),
                  right: ResponsiveFlutter.of(context).moderateScale(12, 0.0),
                ),
                child: Icon(Icons.arrow_back),
              ),
            ),
            SizedBox(
              width: ResponsiveFlutter.of(context).verticalScale(12),
            ),
            Expanded(
              child: MyTextView(title,
                  textStyleNew: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    fontSize: ResponsiveFlutter.of(context).fontSize(2.5),
                  )),
              flex: 1,
            ),
            /*SizedBox(
              width: ResponsiveFlutter.of(context).verticalScale(12),
            ),*/
            Visibility(
              visible: _utils.isValidationEmptyWithZero(count) ? false : true,
              child: Container(
                padding: EdgeInsets.only(
                  left: ResponsiveFlutter.of(context).verticalScale(12),
                ),
                child: MyTextView(
                  count,
                  textStyleNew: new TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.colorWhiteOff,
                    fontSize: ResponsiveFlutter.of(context).fontSize(1.8),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isDelete,
              child: Row(
                children: [
                  SizedBox(
                    width: ResponsiveFlutter.of(context).scale(6),
                  ),
                  GestureDetector(
                    onTap: onTapDelete,
                    child: Container(
                      height: double.infinity,
                      color: AppColors.colorTransparentNull,
                      padding: EdgeInsets.only(
                        left: ResponsiveFlutter.of(context)
                            .moderateScale(12, 0.0),
                        right: ResponsiveFlutter.of(context)
                            .moderateScale(12, 0.0),
                      ),
                      child: const Icon(Icons.delete),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget widgetCommonProfile({
  String imagePath = "",
  bool isFile = false,
  File? imageFile,
  bool isBackGroundColorGray = false,
  String type = "",
}) {
  return CachedNetworkImage(
    imageUrl: imagePath,
    imageBuilder: (context, imageProvider) {
      return Container(
        decoration: BoxDecoration(
          color: isBackGroundColorGray ? AppColors.colorWhite : AppColors.grey,
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );
    },
    placeholder: (context, url) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  isBackGroundColorGray ? AppColors.colorWhite : AppColors.grey,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(type == 'P'
                    ? ImagePath.icNoImage
                    : ImagePath.icDefaultProfile),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SpinKitCircle(
            color: AppColors.colorWhite,
            size: ResponsiveFlutter.of(context).fontSize(5),
          ),
        ],
      );
    },
    errorWidget: (context, url, error) {
      return Container(
        decoration: isFile && imageFile != null
            ? BoxDecoration(
                color: isBackGroundColorGray
                    ? AppColors.colorWhite
                    : AppColors.grey,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(
                color: isBackGroundColorGray
                    ? AppColors.colorWhite
                    : AppColors.grey,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(type == 'P'
                      ? ImagePath.icNoImage
                      : ImagePath.icDefaultProfile),
                  fit: BoxFit.cover,
                ),
              ),
      );
    },
  );
}

Widget widgetRectangleImage({
  String imagePath = "",
  bool isFile = false,
  File? imageFile,
  bool isBackGroundColorGray = false,
  String type = "",
}) {
  return CachedNetworkImage(
    imageUrl: imagePath,
    imageBuilder: (context, imageProvider) {
      return Container(
        decoration: BoxDecoration(
          color: isBackGroundColorGray ? AppColors.colorWhite : AppColors.grey,
          shape: BoxShape.rectangle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );
    },
    placeholder: (context, url) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  isBackGroundColorGray ? AppColors.colorWhite : AppColors.grey,
              shape: BoxShape.rectangle,
              image: DecorationImage(
                image: AssetImage(type == 'P'
                    ? ImagePath.icNoImage
                    : ImagePath.icDefaultProfile),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SpinKitCircle(
            color: AppColors.colorWhite,
            size: ResponsiveFlutter.of(context).fontSize(5),
          ),
        ],
      );
    },
    errorWidget: (context, url, error) {
      return Container(
        decoration: isFile && imageFile != null
            ? BoxDecoration(
                color: isBackGroundColorGray
                    ? AppColors.colorWhite
                    : AppColors.grey,
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(
                color: isBackGroundColorGray
                    ? AppColors.colorWhite
                    : AppColors.grey,
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: AssetImage(type == 'P'
                      ? ImagePath.icSelectImage
                      : ImagePath.icDefaultProfile),
                  fit: BoxFit.cover,
                ),
              ),
      );
    },
  );
}

Widget myNetworkImage({
  String url = "",
}) {
  return Image.network(
    "${url}",
    fit: BoxFit.fill,
    loadingBuilder:
        (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      );
    },
  );
}

Widget employeeDropdownBuilder(BuildContext context, EmployeeListItem? item) {
  if (item == null) {
    return Container();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(item.employeeName.toString()),
      Text(
        item.name.toString(),
        style: TextStyle(
          color: AppColors.colorGrey,
        ),
      ),
    ],
  );
}

Widget employeePopupItemBuilder(
    BuildContext context, EmployeeListItem? item, bool isSelected) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 8),
    decoration: !isSelected
        ? null
        : BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
    child: ListTile(
      selected: isSelected,
      title: Text(item?.employeeName ?? ''),
      subtitle: Text(item?.name?.toString() ?? ''),
    ),
  );
}
