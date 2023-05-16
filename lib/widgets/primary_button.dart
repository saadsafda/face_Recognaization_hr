import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final Color buttonColor;
  final String textValue;
  final Color textColor;
  double? fontSize;
  FontWeight? fontWeight;
  IconData? icon;
  GestureTapCallback? callback;

  PrimaryButton(
      {required this.buttonColor,
      required this.textValue,
      required this.textColor,
      this.fontSize = 18,
      this.fontWeight = FontWeight.w600,
      this.icon,
      this.callback});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(14.0),
      elevation: 0,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: callback,
            borderRadius: BorderRadius.circular(14.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      color: textColor,
                    ),
                  // if (icon != null)
                  //   SizedBox(
                  //     width: 5,
                  //   ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      textValue,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
