import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/screens/setting_screen.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final IconData? leadingIcon;
  final IconData? icon2;
  const CustomAppBar(
      {Key? key, this.title, this.leadingIcon, this.icon, this.icon2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      primary: false,
      toolbarHeight: 80,
      elevation: 0,
      leading: leadingIcon != null
          ? IconButton(
              icon: Icon(leadingIcon, color: AppColors.primary),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      title: Text("${title}",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            fontSize: 20,
          )),
      actions: [
        icon != null
            ? IconButton(
                onPressed: () {},
                icon: Icon(
                  icon,
                  color: AppColors.primary,
                ),
              )
            : Container(),
        icon2 != null
            ? IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Settings();
                      },
                    ),
                  );
                },
                icon: Icon(
                  icon2,
                  color: AppColors.primary,
                ),
              )
            : Container(),
      ],
      backgroundColor: AppColors.textWhiteGrey,
    );
  }
}
