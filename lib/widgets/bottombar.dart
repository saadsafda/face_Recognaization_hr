import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:sowaanerp_hr/screens/checkin_screen.dart';
import 'package:sowaanerp_hr/screens/setting_screen.dart';
import 'package:sowaanerp_hr/utils/utils.dart';
import 'package:sowaanerp_hr/screens/attendance_screen.dart';
import 'package:sowaanerp_hr/screens/home_screen.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/widgets/checkin_dialog.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

Utils _utils = Utils();

var _currentIndex = 0;

final screens = [
  HomeScreen(),
  AttendanceScreen(),
  Container(),
  CheckinScreen(),
  Settings(),
];

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    openCheckinDialog() async {
      _utils.hideKeyboard(context);

      final result = await showDialog(
          context: context,
          barrierColor: AppColors.colorDialogTransparentBackground,
          builder: (BuildContext context) {
            // return WidgetRecordAudioDummy();
            return const CheckInDialog();
          });

      if (result == null) {
        return;
      }
      if (result) {
        //getTeams();
      }
    }

    return Scaffold(
        backgroundColor: AppColors.textWhiteGrey,
        body: screens[_currentIndex],
        bottomNavigationBar: SnakeNavigationBar.color(
          backgroundColor: AppColors.lightGreyColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          height: 65,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          snakeViewColor: AppColors.lightGreyColor,
          behaviour: SnakeBarBehaviour.floating,
          padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
          currentIndex: _currentIndex,
          onTap: (index) => {
            if (index == 2)
              {openCheckinDialog()}
            else
              setState(() => _currentIndex = index)
          },
          items: [
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 30,
                ),
                label: 'Home'),
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.access_time,
                  size: 30,
                ),
                label: 'Attendance'),
            BottomNavigationBarItem(
                icon: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 30,
                    child: Icon(
                      Icons.add,
                      color: AppColors.white,
                      size: 50,
                    )),
                label: 'Mark'),
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.list_alt,
                  size: 30,
                ),
                label: 'Projects'),
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  size: 30,
                ),
                label: 'Profile')
          ],
        ));
  }
}
