import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';

import '../theme.dart';

class PasswordFieldCircular extends StatefulWidget {
  final controller;
  final String hintText;
  PasswordFieldCircular({this.controller, required this.hintText});

  @override
  _PasswordFieldCircularState createState() => _PasswordFieldCircularState();
}

class _PasswordFieldCircularState extends State<PasswordFieldCircular> {
  bool passwordVisible = false;
  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textWhiteGrey,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        obscureText: !passwordVisible,
        onSaved: (value) {
          widget.controller.text = value;
        },
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: heading6.copyWith(color: AppColors.textGrey),
          suffixIcon: IconButton(
            color: passwordVisible ? AppColors.primary : AppColors.textGrey,
            splashRadius: 1,
            icon: Icon(passwordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: togglePassword,
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
    ;
  }
}
