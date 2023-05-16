import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';

class BoxCard extends StatelessWidget {
  final String name;
  final Widget icon;

  const BoxCard({
    Key? key,
    required this.name,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 100,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: icon,
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 0, bottom: 4, left: 4, right: 4),
            child: Text(name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPurpleColor,
                  fontSize: MediaQuery.of(context).size.width / 26,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }
}
